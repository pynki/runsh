# About

Script to wrap a script call. Meant to source common functionality in a single script to save effort in the actual called script. For now just providing logger (see [tools/logger.sh](https://github.com/pynki/runsh/blob/master/tools/logger.sh) )functionality and some network functions (see [tools/tools.sh](https://github.com/pynki/runsh/blob/master/tools/tools.sh)).

See the [scripts/test/test.sh](https://github.com/pynki/runsh/blob/master/scripts/test/test.sh) and [scripts/test/test.conf](https://github.com/pynki/runsh/blob/master/scripts/test/test.conf) on how to use the logging functionality.

Call 

`./run.sh ./scripts/test/test.conf`

to run the test script.

# Remarks

This is work in progress. There might be bugs, unhandled corner cases or plain stupid code in the scripts. It works for me, in the cases i use it. If you need something changed: open an issue or fork the code. I am happy about pull requests.