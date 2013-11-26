#!/bin/bash
LOG=log
TIF=TIF
ALTO=ALTO
MODSXML=MODS

echo "$1"/ALTO/* | sed 's/xml /xml\n/g' > altos
grep -i 'validerer ikke' $LOG | grep -i alto | cut -d' ' -f1 | sed 's/\.xml//' | while read I; do egrep $I altos; done | while read J; do echo tjekker ALTO: $J; xmllint --noout --schema alto-1-4-fixed.xsd "$J" 2>&1; echo \#\#; echo \#\#; done
grep -i 'validerer ikke' $LOG | grep -i mods | cut -d' ' -f1 | sed 's/-MODS\.xml//' | while read I; do grep $I altos; done | sed "s/\/$ALTO\//\/$MODSXML\//" | sed 's/\.xml/-MODS\.xml/' | while read J; do echo tjekker MODS: $J; xmllint --noout --schema mods-3-1.xsd $J 2>&1; echo \#\#; echo \#\#; done
