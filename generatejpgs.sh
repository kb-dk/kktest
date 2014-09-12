#!/bin/bash

for DIR in /sbftp-home/scan-dk2/OM/Rettelse\ PH\ 24-01-2014 /sbftp-home/scan-dk2/OM/Rettelse\ PML\ 16-04-2014 /sbftp-home/scan-dk2/OM/Rettelse\ KS\ 06-05-2014; do 
    IFS=' '
    find "$DIR"/ -name "*.jpg" -printf %P\\0 | while read -d $'\0' -r FILE; do 
        mkdir -p "$(basename "$DIR")/$(dirname "$FILE")"
        convert -units PixelsPerInch "$DIR/$FILE" -resample 96 "$(basename "$DIR")/$FILE"
    done
done
