#!/bin/bash

if [ -z $2 ]; then
  echo "Usage: $0 <batchdir> <outputdir>"
  exit 1
fi

D=$1
OUT=$2

mkdir -p "$OUT"
find "$D" -name \*.alto.xml | sort -R | head -n 100 | while read ALTOFILE; do
  B=$(basename "$ALTOFILE" .alto.xml)
  O=$(echo $B|tr ' ' '_')
  mkdir -p "$(dirname "$B")"
  TIFFFILE="$(dirname "$ALTOFILE")/$B.tif"
  ln -s "$ALTOFILE" "$OUT/$O.alto.xml"
  ln -s "$TIFFFILE" "$OUT/$O.tif"
done
