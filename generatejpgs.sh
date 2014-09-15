#!/bin/bash

for dir in /sbftp-home/scan-dk2/OM/Rettelse\ PH\ 24-01-2014 /sbftp-home/scan-dk2/OM/Rettelse\ PML\ 16-04-2014 /sbftp-home/scan-dk2/OM/Rettelse\ KS\ 06-05-2014; do 
    IFS=''
    find "$dir"/ -name "*.jpg" -printf %P\\0 | while read -d $'\0' -r file; do 
        mkdir -p "$(basename "$dir")/$(dirname "$file")"
        convert -units PixelsPerInch "$dir/$file" \
                -resample 96 \
                "$(basename "$dir")/$file"
    done
done
