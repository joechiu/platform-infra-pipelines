#!/bin/sh

VM=$1
LOG=$2
a=1
n=0
max=120
rm -f $LOG
while [ $a -gt 0 ]
do
  a=$(ssh -o ConnectTimeout=3 -o StrictHostKeyChecking=no -q $VM exit; echo $?)
  ((n=n+1))
  echo "$n. result: $a" >> $LOG
  [ $n -ge $max ] && { echo "$max tries reached, exit!" >> $LOG; exit 3; }
  sleep 1;
done
echo "SSH connectivity test - DONE!" >> $LOG
