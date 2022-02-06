#!/bin/bash

M=$1
gap=/tmp/csv-table-gap
tmp=/tmp/csv-table-temp-file
lines=$(tput lines)
columns=$(tput cols)
for i in {1..1000}; do sh ./bin/watch-it.sh $M > $tmp 2>&1; clear && cat $tmp; printf "%*s\n" $(cat $gap) "$(date)"; sleep 5; done
