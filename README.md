# crash_hunt
A simple script to run zzuf and quit when an error occurs.

# introduction

This script calls the `zzuf` fuzzer using a random seed on an input file you provide (by modifying the script with the input file name).

Then, it runs a command (that you provide by modifying the script) on the result of the most recent fuzzing.

Finally, it checks the return value of the command that was run on the fuzzed input.

The script will try again with a new fuzzed input on the following return values:

  * 0 -- no error
  * 1-126 -- handled error
  * 255 -- I don't remember why it ignores 255!

If the return value is between 127-254, it quits and alerts the user, as this value is returned upon abnormal termination (segfault, OOM killed, protection error, etc.).

# use

  1. Make the script executable if it is not.
  2. Put an input file example in the working directory (smaller inputs are generally better, to allow the fuzzer to focus mostly on the header and other structures).
  3. Modify the script's `zzuf` call to fuzz the new input file.
  4. Add a suitable command that will run your program (preferably noninteractively for maximum speed)
  5. Run `./crash_hunt.sh`
  6. When `crash_hunt.sh` terminates, investigate the fuzzed input by running your test command manually.

# questions / comments

Email [pahp@d.umn.edu](mailto:pahp@d.umn.edu)
