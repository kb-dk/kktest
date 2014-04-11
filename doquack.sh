#!/bin/bash
i="$1"
j="$(echo $i|tr ' ' '_')"
cd "$(dirname $(readlink -f $0))"
mkdir -p "/home/kfc/public_html/kfc/kk/$j"
mkdir -p "/home/kfc/public_html/kfc/source/kk/$j"
#./linkfiles.sh "$i" "/home/kfc/public_html/kfc/source/kk/$j"
cd ~/quack
./quack.sh "/home/kfc/public_html/kfc/source/kk/$j" "/home/kfc/public_html/kfc/kk/$j"
