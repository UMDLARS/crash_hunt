#!/usr/bin/env bash

# crash hunt! 
# program that fuzzes an input, runs a program, and then quits when it causes a crash
# usage:
# 	crash_hunt.sh infile
#
# PLEASE NOTE:
# You must specify the program you want to run in the script (see below)

count=0
infile=$1

if [[ -z $1 ]]
then
	echo "Please enter a filename to fuzz."
	exit 1
fi

while true
do 
	ts=$(date +%s%N) 		# high-res timestamp to use as identifier
	outfile="$ts-$infile"	# output file (temporary)
	
	# print some output, including the seed
	echo "---------------------------------------------------"
	echo "mutation: $count seed: $ts"

	# create the fuzzed file
	zzuf -c -s $ts -r0.01 < $infile > $outfile

	# COMMAND TO TEST -- UPDATE THIS COMMAND ACCORDING TO YOUR NEEDS

	CURPID=$$ # get current PID
	
	# example programs (only the uncommented one will run)
	#oggenc $outfile -o /dev/null		# music encoder
	#unxz -c $outfile > /dev/null 		# decompressor
	#img2sixel $outfile -o /dev/null	# display images as sixels
	#convert -size 400x600 $outfile $CURPID.png	# image converter
	./asciiart $outfile					# display image as ascii blocks

	ret=$?						# get the return value
	if [[ -f $CURPID ]]
	then
		rm $CURPID
	fi
	echo "return value: $ret"	# print the return value

	# typical program return values:
	# - 0: normal termination - this ending is not bad
	# - 1-126: some kind of error - something bad happened but we know what
	# - 127-255: the program crashed unexpectedly - kernel adds 127 to return value
	if [[ $ret == 0 ]]
	then
		echo "terminated with value 0 (normal termination)"
	elif [[ $ret == 255 ]]
	then
		echo "Ignoring 255"
	elif [[ $(( $ret > 126 )) == 1 ]]
	then 

		# this program was killed by the OS or crashed unexpectedly
		
		echo "abnormal termination! (return value above 126!)"
		break # quit to inspect
	
	else 
		echo "terminated with handled error (1-126)"
	fi

	# erase uninteresting files
	rm $outfile

	count=$(( count + 1 ))

done

echo "I quit so that you can inspect file $outfile."
echo "Try running your test command manually using $outfile and see what happens."
