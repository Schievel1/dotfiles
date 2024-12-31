#!/usr/bin/env bash

script_dir=`dirname $0`
cd $script_dir

/bin/bash -c "source /home/pascal/python-venv/bin/activate; python walland.py $@"

# also download while at it
date=$(date -Idate)
wlpath="/home/pascal/Pictures/wallpapers"
baseurl="https://www.bing.com/"
wluri=$(curl $baseurl"HPImageArchive.aspx?format=js&idx=0&n=20&mkt=en-US" -s | jq '.images[].url' --raw-output | shuf -n 1)
if [ ! -f "$wlpath/bing-$date.jpg" ]
   curl -o "$wlpath/bing-$date.jpg" "$baseurl$wluri"
fi
