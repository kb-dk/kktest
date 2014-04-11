#!/bin/bash
IFS=''
DIR="$1"    #"/sbftp-home/scan-dk2/Protokol Håndskrevne 1871-1892"
OUTDIR="$2" #.
if [ -z "$OUTDIR" ]; then echo "Usage: $0 <inputdir> <outputdir>" >&2; exit 1; fi
find "$DIR"/ -name "*.pdf" -printf %P\\0 | while read -d $'\0' -r FILE; do 
    mkdir -p "$OUTDIR/$(dirname $FILE)"
    gs -dPDFA -dBATCH -dNOPAUSE -dNOOUTERSAVE -dUseCIEColor -dPDFOPTIONS=/screen -sDEVICE=pdfwrite -sOutputFile="$OUTDIR/$FILE" "$DIR/$FILE"
done
