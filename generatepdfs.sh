for DIR in /sbftp-home/scan-dk2/OM/Rettelse\ PH\ 24-01-2014 /sbftp-home/scan-dk2/OM/Rettelse\ PML\ 16-04-2014 /sbftp-home/scan-dk2/OM/Rettelse\ KS\ 06-05-2014; do IFS=''; find "$DIR"/ -name "*.pdf" -printf %P\\0|while read -d $'\0' -r i; do mkdir -p "$(basename "$DIR")/$(dirname $i)"; gs -dPDFA -dBATCH -dNOPAUSE -dNOOUTERSAVE -dUseCIEColor -dPDFOPTIONS=/screen -dDownsampleColorImages=true -dDownsampleGrayImages=true -dDownsampleMonoImages=true -dColorImageResolution=96 -dGrayImageResolution=96 -dGrayImageResolution=96 -sDEVICE=pdfwrite -sOutputFile="$(basename "$DIR")/$i" "$DIR/$i";done; done