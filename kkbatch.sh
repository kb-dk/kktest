#!/bin/bash
D="$1"
ANTAL=0
DEBUG=0
LOGFILE=log
#TIFFTAGS=23

PAGEFOLDER="Sider"
COMPLETEFOLDER="Komplet årgang"
NOALTO="Håndskrevne"

date|tee $LOGFILE

find "$D" -name "$PAGEFOLDER" -type d -print0|while read -d $'\0' S; do A=$(ls "$S/"*.pdf|wc -l); for I in $(seq 1 $A); do N=$(printf "%04d" $I); C=$(ls "$S/"*-$N\.pdf 2>&1 | wc -l); if [ ! $C -eq 1 ]; then echo Error in sequence for $S: $N not found; fi; done; done|tee -a log

find "$D" -name "*.pdf" -print0 | while read -d $'\0' I; do 
ANTAL=$(echo $ANTAL+1 | bc)
F=$(basename "$I")
echo $ANTAL: $F - $I
B=$(echo $F | rev | cut -d'.' -f2- | rev)
FEJL=0
P=$(dirname "$I")
T=$(basename "$P")
PDFFILE="$I"
TIFFFILE="$P/${B}.tif"
MIXFILE="$P/${B}.mix.xml"
MODSFILE="$P/${B}.mods.xml"
ALTOFILE="$P/${B}.alto.xml"

if [ $DEBUG -eq 1 ]; then echo PDF check; fi
if [ ! -f "$P/$F.md5" ]; then echo Error: Missing checksum for PDF: $F; FEJL=$(echo $FEJL+1|bc); fi
MD=$(md5sum "$PDFFILE" | awk '{print $1}')
if [ -z $MD ]; then MD="FOOBAR"; fi
MDTEST2=$(egrep -i $MD "$P/$F.md5" | wc -l);  if [ ! $MDTEST2 -eq 1 ]; then echo Error in MD5 for PDF in MD5 file: $P/$F; fi

if [ $DEBUG -eq 1 ]; then echo MODS check; fi
if [ ! -f "${MODSFILE}" ]; then echo Error: Missing MODS: $F; FEJL=$(echo $FEJL+1|bc); fi
if [ ! -f "${MODSFILE}.md5" ]; then echo Error: Missing checksum for MODS: $F; FEJL=$(echo $FEJL+1|bc); fi
MD=$(md5sum "${MODSFILE}" | awk '{print $1}')
if [ -z $MD ]; then MD="FOOBAR"; fi
MDTEST2=$(egrep -i $MD "${MODSFILE}.md5" | wc -l);  if [ ! $MDTEST2 -eq 1 ]; then echo Error in MD5 for MODS in MD5 file: $F; fi

if [[ ! "$P" == *"$NOALTO"* ]] ; then
if [ $DEBUG -eq 1 ]; then echo ALTO check; fi
if [ ! -f "${ALTOFILE}" ]; then echo Error: Missing ALTO: $F; FEJL=$(echo $FEJL+1|bc); fi
if [ ! -f "${ALTOFILE}.md5" ]; then echo Error: Missing checksum for ALTO: $F; FEJL=$(echo $FEJL+1|bc); fi
MD=$(md5sum "${ALTOFILE}" | awk '{print $1}')
if [ -z $MD ]; then MD="FOOBAR"; fi
MDTEST2=$(egrep -i $MD "${ALTOFILE}.md5" | wc -l);  if [ ! $MDTEST2 -eq 1 ]; then echo Error in MD5 for ALTO in MD5 file: $F; fi
fi

if [ "$T" == "$PAGEFOLDER" ]; then
if [ $DEBUG -eq 1 ]; then echo TIFF check; fi
if [ ! -f "${TIFFFILE}" ]; then echo Error: Missing TIF: $F; FEJL=$(echo $FEJL+1|bc); fi
if [ ! -f "${TIFFFILE}.md5" ]; then echo Error: Missing checksum for TIF: $F; FEJL=$(echo $FEJL+1|bc); fi
MD=$(md5sum "${TIFFFILE}" | awk '{print $1}')
if [ -z $MD ]; then MD="FOOBAR"; fi
MDTEST2=$(egrep -i $MD "${TIFFFILE}.md5" | wc -l);  if [ ! $MDTEST2 -eq 1 ]; then echo Error in MD5 for TIF in MD5 file: $F; fi
MDTEST5=$(egrep -i messageDigest\>$MD "${MIXFILE}" | wc -l); if [ ! $MDTEST5 -eq 1 ]; then echo Error in MD5 for TIF in MIX file: $F; fi
fi

if [ "$T" == "$PAGEFOLDER" ]; then
if [ $DEBUG -eq 1 ]; then echo MIX check; fi
if [ ! -f "${MIXFILE}" ]; then echo Error: Missing MIX: $F; FEJL=$(echo $FEJL+1|bc); fi
if [ ! -f "${MIXFILE}.md5" ]; then echo Error: Missing checksum for MIX: $F; FEJL=$(echo $FEJL+1|bc); fi
MD=$(md5sum "${MIXFILE}" | awk '{print $1}')
if [ -z $MD ]; then MD="FOOBAR"; fi
MDTEST2=$(egrep -i $MD "${MIXFILE}.md5" | wc -l);  if [ ! $MDTEST2 -eq 1 ]; then echo Error in MD5 for MIX in MD5 file: $F; fi
fi

if [ ! $FEJL -eq 0 ]; then echo Number of missing files: $FEJL; fi

if [ $DEBUG -eq 1 ]; then echo XML schema checks; fi
CMODS=$(xmllint --noout --schema mods-3-5.xsd "${MODSFILE}" 2>&1 | grep validates$ | wc -l); if [ ! $CMODS -eq 1 ]; then echo "${MODSFILE}" fails to validate; fi
if [ "$T" == "$PAGEFOLDER" ]; then
CMIX=$(xmllint --noout --schema mix20.xsd "${MIXFILE}" 2>&1 | grep validates$ | wc -l); if [ ! $CMIX -eq 1 ]; then echo "${MIXFILE}" fails to validate; fi
fi
#if [ "$T" == "$PAGEFOLDER" ] && [[ ! "$P" == *"$NOALTO"* ]] ; then
#CALTO=$(xmllint --noout --schema alto-v2.0.xsd "${ALTOFILE}" 2>&1 | grep validates$ | wc -l); if [ ! $CALTO -eq 1 ]; then echo "${ALTOFILE}" fails to validate; fi
#fi

if [ $DEBUG -eq 1 ]; then echo PDF file format check; fi
FORMAT=$(file "${PDFFILE}" | grep 'PDF document, version 1.4' | wc -l); if [ ! $FORMAT -eq 1 ]; then echo "Error: Wrong PDF format (assumed to be 1.4): $(file "${PDFFILE}")"; fi
FORMAT2=$(jhove/jhove -l OFF "${PDFFILE}" | grep '^  Profile:.*ISO PDF/A-1' | wc -l); if [ ! $FORMAT2 -eq 1 ]; then echo "Error in PDF format (should be PDF-A): $(jhove/jhove -l OFF "${PDFFILE}" | grep '^  Profile')"; fi
FORMAT3=$(jhove/jhove -l OFF "${PDFFILE}" | grep '^  Status: Well-Formed and valid' | wc -l); if [ ! $FORMAT3 -eq 1 ]; then echo "Error in PDF format (invalid): $(jhove/jhove -l OFF "${PDFFILE}" | grep '^  Profile')"; fi

if [ "$T" == "$PAGEFOLDER" ]; then
if [ $DEBUG -eq 1 ]; then echo TIF file format check; fi
FORMAT=$(file "$TIFFFILE" | grep 'TIFF image data' | wc -l); if [ ! $FORMAT -eq 1 ]; then echo Error in TIF format: $(file "$TIFFFILE"); fi
tiffinfo -D "${TIFFFILE}" >& /dev/null; if [ ! "$?" -eq 0 ]; then echo Error in TIF format: $(tiffinfo "$TIFFFILE"); fi
#jhove2/jhove2.sh "$TIFFFILE" > jhove2.output 2> /dev/null
#VALID=$(grep "^   isValid: true" jhove2.output | wc -l); if [ ! "$VALID" -eq 1 ]; then echo "Error in TIF format - not valid: $(grep "^   isValid:" jhove2.output)"; fi
#VERSION=$(grep "^   TiffVersion: 6" jhove2.output | wc -l); if [ ! $VERSION -eq 1 ]; then echo "Error in TIF format - wrong version (should be 6): $(grep "^   TiffVersion:" jhove2.output)"; fi
fi

if [ $DEBUG -eq 1 ]; then echo MODS contents check; fi
MODSIDENTIFIER=$(xpath "${MODSFILE}" "/mods/identifier[@type='Statsbiblioteket, kvindekilder']/text()" 2>/dev/null); if [ ! "$MODSIDENTIFIER" == "$B" ]; then echo "Error in MODS file - wrong identifier. Expected $B, was $MODSIDENTIFIER"; fi
WRONGUTF8=$(grep "\(Ã¦\|Ã¸\|Ã¥\|Ã\|Ã\|Ã\)" "${MODSFILE}"|wc -l); if [ ! "$WRONGUTF8" -eq 0 ]; then echo "Error in MODS file - contains illegal characters. Probably wrong encoding"; fi

if [ $DEBUG -eq 1 ]; then echo PDF contents check; fi
PDFSIZE=$(stat -c %s  "${PDFFILE}"); if [ $PDFSIZE -lt 200000 ]; then echo "Error: Very small PDF file: File size $PDFSIZE"; fi

if [ "$T" == "$PAGEFOLDER" ]; then
if [ $DEBUG -eq 1 ]; then echo MIX content check; fi
FNTEST=$(egrep "objectIdentifierValue>$B" "${MIXFILE}" | wc -l); if [ ! $FNTEST -eq 1 ]; then echo Error in objectIdentifier in MIX: $F; fi
FS=$(ls -l "${TIFFFILE}" | awk '{print $5}')
FSTEST=$(egrep fileSize\>$FS "${MIXFILE}" | wc -l); if [ ! $FSTEST -eq 1 ]; then echo Error in fileSize in MIX: $F; fi
fi

if [ "$T" == "$PAGEFOLDER" ]; then
if [ $DEBUG -eq 1 ]; then echo TIF tags check; fi
#TAGS=$(tiffinfo "${TIFFFILE}" 2>&1 | wc -l); if [ ! $TAGS -eq $TIFFTAGS ]; then echo Error in TIF tags: number: $TAGS \(expected $TIFFTAGS\); fi
TAG256=$(tiffinfo "${TIFFFILE}" 2>&1 | grep "Image Width" | wc -l); if [ ! $TAG256 -eq 1 ]; then echo Error in TIF tags: Missing tag 256 Image Width ;fi
TAG257=$(tiffinfo "${TIFFFILE}" 2>&1 | grep "Image Length" | wc -l); if [ ! $TAG257 -eq 1 ]; then echo Error in TIF tags: Missing tag 257 Image Length;fi
TAG258=$(tiffinfo "${TIFFFILE}" 2>&1 | grep "Bits/Sample: 8" | wc -l); if [ ! $TAG258 -eq 1 ]; then echo Error in TIF tags: Missing tag 258 Bits/Sample: 8;fi
TAG259=$(tiffinfo "${TIFFFILE}" 2>&1 | grep "Compression Scheme: LZW" | wc -l); if [ ! $TAG259 -eq 1 ]; then echo Error in TIF tags: Missing tag 259 Compression Scheme: LZW;fi
TAG262=$(tiffinfo "${TIFFFILE}" 2>&1 | grep "Photometric Interpretation: RGB color" | wc -l); if [ ! $TAG262 -eq 1 ]; then echo Error in TIF tags: Missing tag 262 Photometric Interpretation: RGB color;fi
TAG271=$(tiffinfo "${TIFFFILE}" 2>&1 | grep "Make:" | wc -l); if [ ! $TAG271 -eq 1 ]; then echo Error in TIF tags: Missing tag 271 Make:;fi
TAG272=$(tiffinfo "${TIFFFILE}" 2>&1 | grep "Model:" | wc -l); if [ ! $TAG272 -eq 1 ]; then echo Error in TIF tags: Missing tag 272 Model:;fi
TAG273=$(tiffdump "${TIFFFILE}" 2>&1 | grep "StripOffsets (273)" | wc -l); if [ ! $TAG273 -eq 1 ]; then echo Error in TIF tags: Missing tag 273 ;fi
TAG277=$(tiffinfo "${TIFFFILE}" 2>&1 | grep "Samples/Pixel: 3" | wc -l); if [ ! $TAG277 -eq 1 ]; then echo Error in TIF tags: Missing tag 277 Samples/Pixel: 3;fi
TAG278=$(tiffinfo "${TIFFFILE}" 2>&1 | grep "Rows/Strip:" | wc -l); if [ ! $TAG278 -eq 1 ]; then echo Error in TIF tags: Missing tag 278 Rows/Strip:;fi
TAG279=$(tiffdump "${TIFFFILE}" 2>&1 | grep "StripByteCounts (279)" | wc -l); if [ ! $TAG279 -eq 1 ]; then echo Error in TIF tags: Missing tag 279 ;fi
TAG282=$(tiffinfo "${TIFFFILE}" 2>&1 | grep "Resolution: 400, 400 pixels/inch" | wc -l); if [ ! $TAG282 -eq 1 ]; then echo Error in TIF tags: Missing tag 282/283/296 Resolution: 400, 400 pixels/inch;fi
#TAG283=$(tiffinfo "${TIFFFILE}" 2>&1 | grep "" | wc -l); if [ ! $TAG283 -eq 1 ]; then echo Error in TIF tags: Missing tag 283 ;fi
#TAG296=$(tiffinfo "${TIFFFILE}" 2>&1 | grep "" | wc -l); if [ ! $TAG296 -eq 1 ]; then echo Error in TIF tags: Missing tag 296 ;fi
TAG305=$(tiffinfo "${TIFFFILE}" 2>&1 | grep "Software:" | wc -l); if [ ! $TAG305 -eq 1 ]; then echo Error in TIF tags: Missing tag 305 Software:;fi
TAG306=$(tiffinfo "${TIFFFILE}" 2>&1 | grep "DateTime:" | wc -l); if [ ! $TAG306 -eq 1 ]; then echo Error in TIF tags: Missing tag 306 DateTime:;fi
TAG315=$(tiffinfo "${TIFFFILE}" 2>&1 | grep "Artist: Statsbiblioteket; Scanning.dk A/S" | wc -l); if [ ! $TAG315 -eq 1 ]; then echo Error in TIF tags: Missing tag 315 Artist: Statsbiblioteket\; Scanning.dk A/S;fi
TAG41728=$(tiffinfo "${TIFFFILE}" 2>&1 | grep "Tag 41728: print" | wc -l); if [ ! $TAG41728 -eq 1 ]; then echo Error in TIF tags: Missing tag 41728 Tag 41728: print;fi
TAG42016=$(tiffinfo "${TIFFFILE}" 2>&1 | grep "Tag 42016:" | wc -l); if [ ! $TAG42016 -eq 1 ]; then echo Error in TIF tags: Missing tag 42016 Tag 42016: ;fi
TAG42016B=$(tiffinfo "${TIFFFILE}" 2>&1 | grep "Tag 42016: $B" | wc -l); if [ ! $TAG42016B -eq 1 ]; then echo Error in TIF tags: Wrong tag 42016 - should be right identifier ;fi
fi

done | tee -a log

echo Check complete

# ./ditte "$1"
