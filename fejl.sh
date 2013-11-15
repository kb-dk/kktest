#!/bin/bash
LOG=$1
if [ -z $LOG ]; then
 LOG=log
fi
egrep -v '^[0-9]' $LOG | grep -v 'CET 2011' | grep -v TIF-tags
grep -B1 tags $LOG
