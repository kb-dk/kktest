#!/bin/bash

for dir in '/sbftp-home/scan-dk2/Kvinden og Samfundet 1921-1953 – ekstra årgange/Rettelse KS – Ekstra årgange – 31-03-2015'; do
    IFS=''
    find "$dir"/ -name "*.pdf" -printf %P\\0 | while read -d $'\0' -r file; do 
        mkdir -p "$(basename "$dir")/$(dirname "$file")"
        #http://stackoverflow.com/questions/9497120/how-to-downsample-images-within-pdf-file/9571488#9571488
        gs -dPDFA -dBATCH -dNOPAUSE -dNOOUTERSAVE -dUseCIEColor \
           -dPDFOPTIONS=/screen \
           -dDownsampleColorImages=true \
           -dDownsampleGrayImages=true \
           -dDownsampleMonoImages=true \
           -dColorImageResolution=96 \
           -dGrayImageResolution=96 \
           -dMonoImageResolution=96 \
           -sDEVICE=pdfwrite -sOutputFile="$(basename "$dir")/$file" \
           "$dir/$file"
    done
done
