#!/bin/bash

for dir in '/sbftp-home/scan-dk2/Kvinden og Samfundet 1921-1953 – ekstra årgange/Rettelse KS – Ekstra årgange – 31-03-2015'; do 
    IFS=''
    find "$dir"/ -name "*.jpg" -printf %P\\0 | while read -d $'\0' -r file; do 
        mkdir -p "$(basename "$dir")/$(dirname "$file")"
        convert -units PixelsPerInch "$dir/$file" \
                -resample 96 \
                "$(basename "$dir")/$file"
    done
done
