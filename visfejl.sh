#!/bin/bash
LOG=$1
if [ -z $LOG ]; then
 LOG=log
fi
#echo antal TIF i alt: $(wc -l tifs) \(aktuelt mount\)
echo antal filer analyseret: $(grep ^[0-9] $LOG | sort -u | wc -l) 
echo alto-XML-fejl: $(./fejl.sh $LOG | egrep -i 'alto.*validerer ikke' | wc -l) \(kan have falske positiver\)
echo mods-XML-fejl: $(egrep -i 'mods.*ikke' $LOG | wc -l) \(kan have falske positiver\)
AF=$(grep -i fejl $LOG | grep -v TIF-tags | wc -l);
echo antal andre fejl: $AF; if [ $AF -ge 1 ]; then grep -i fejl $LOG | grep -v TIF-tags; fi
