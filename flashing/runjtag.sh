#!/bin/bash

# Ugly script that wraps around urjtag and returns a non-zero exit code when
# things go wrong.

# Usage: ./runjtag.sh jtag_commands_file

LOG=$(mktemp)
date > $LOG
cat $1 >> $LOG
echo "GO!" >> $LOG

(/usr/local/bin/jtag $1 2>&1 >> $LOG) &
PID=$!
run=1

tail -f $LOG &
TAILPID=$!


function ctrl_c() {
    echo "** Trapped CTRL-C"
    kill $TAILPID
    kill $PID
    exit 2
}
trap ctrl_c INT


function check_log(){
    cat $LOG | egrep --color --line-buffered -i '(transaction failed|no flash driver|flash not found|amd_detect)'
    if [ "$?" == 0 ] ; then
        echo ""
        echo "OOPS! There were errors, log in: $LOG"
        kill $TAILPID
        kill $PID
        exit 1
    fi
}


while [ $run == 1 ] ; do
    ps | grep $PID > /dev/null
    if [ "$?" == 0 ] ; then
        echo -n "."
    else
        echo jtag exited!
        run=0
    fi
    sleep 0.5
    check_log
done

echo Done, looks good.

kill $TAILPID
rm $LOG

exit 0
