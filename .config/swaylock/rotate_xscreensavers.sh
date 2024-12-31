#!/bin/sh
file=`ls $1 | shuf -n 1`
delay=60.
echo "Runnning screensaver $1/$file for $delay secs"
timeout $delay $1/$file
