#!/bin/bash
D=$1
ANTAL=0
DEBUG=0
LOGFILE=log

TIF=TIF
ALTO=ALTO
CHECKSUM=CHECKSUM
MIXXML=MIXXML
MODSXML=MODS
PDF=PDF
TIFFTAGS=22
TIFFHOME=/sbftp-home/scan-dk/DR

date|tee $LOGFILE

#This check is disabled, since we can't check existence of all numbers before we have all batches. Ungh.
#A=$(ls "$D/$PDF/"*.pdf|wc -l); for I in $(seq 1 $A); do N=$(printf "%04d" $I); echo ls "$D/$PDF/"*-$N*.pdf; C=$(ls "$D/$PDF/"*-$N*.pdf 2>&1 | grep -v pdf$ | wc -l); if [ ! $C -eq 0 ]; then echo FEJL i nummerering:  $D: $N ikke fundet; fi; done

ls "$D/$PDF/"*.pdf | while read I; do 
ANTAL=$(echo $ANTAL+1 | bc)
F=$(basename "$I")
echo $ANTAL: $F - $I
B=$(echo $F | cut -d'.' -f1)
FEJL=0

#This check is disabled, since we have no MD5 sums for the files. Ungh.
#if [ ! -f $D/$CHECKSUM/$F-MD5.txt ]; then echo mangler checksum for TIF: $F; FEJL=$(echo $FEJL+1|bc); fi;

if [ $DEBUG -eq 1 ]; then echo ALTO-tjek; fi
if [ ! -f "$D/$ALTO/"$B.xml ]; then echo mangler ALTO: $F; FEJL=$(echo $FEJL+1|bc); fi

#This check is disabled, since we have no MD5 sums for the files. Ungh.
#if [ ! -f $D/$CHECKSUM/$B.xml-MD5.txt ]; then echo mangler checksum for ALTO: $F; FEJL=$(echo $FEJL+1|bc); fi
#MD=$(md5sum $D/$ALTO/$B.xml | awk '{print $1}')
#if [ -z $MD ]; then MD="FOOBAR"; fi
#MDTEST1=$(egrep -i $MD $D/$CHECKSUM/$B.xml-MD5.txt | wc -l);  if [ ! $MDTEST1 -eq 1 ]; then echo fejl i MD5 for ALTO i MD5-fil: $F; fi

#This check is disabled, since we do not check MIX files for these batches.
#if [ $DEBUG -eq 1 ]; then echo MIX-tjek; fi
#if [ ! -f "$D/$MIXXML/"$B-MIX.xml ]; then echo mangler MIX: $F; FEJL=$(echo $FEJL+1|bc); fi
#if [ ! -f $D/$CHECKSUM/$B-MIX.xml-MD5.txt ]; then echo mangler checksum for MIX: $F; FEJL=$(echo $FEJL+1|bc); fi
#MD=$(md5sum $D/$MIXXML/$B-MIX.xml | awk '{print $1}')
#if [ -z $MD ]; then MD="FOOBAR"; fi
#MDTEST2=$(egrep -i $MD $D/$CHECKSUM/$B-MIX.xml-MD5.txt | wc -l);  if [ ! $MDTEST2 -eq 1 ]; then echo fejl i MD5 for MIX i MD5-fil: $F; fi

if [ $DEBUG -eq 1 ]; then echo MODS-tjek; fi
if [ ! -f "$D/$MODSXML/"$B-MODS.xml ]; then echo mangler MODS: $F; FEJL=$(echo $FEJL+1|bc); fi
#This check is disabled, since we have no MD5 sums for the files. Ungh.
#if [ ! -f $D/$CHECKSUM/$B-MODS.xml-MD5.txt ]; then echo mangler checksum for MODS: $F; FEJL=$(echo $FEJL+1|bc); fi
#MD=$(md5sum $D/$MODSXML/$B-MODS.xml | awk '{print $1}')
#if [ -z $MD ]; then MD="FOOBAR"; fi
#MDTEST3=$(egrep -i $MD $D/$CHECKSUM/$B-MODS.xml-MD5.txt | wc -l);  if [ ! $MDTEST3 -eq 1 ]; then echo fejl i MD5 for MODS i MD5-fil: $F; fi

#This check is disabled, since pdfs are the primary files in these batches, not TIFs.
#if [ $DEBUG -eq 1 ]; then echo PDF-tjek; fi
#if [ ! -f $D/$PDF/$B.pdf ]; then echo mangler PDF: $F; FEJL=$(echo $FEJL+1|bc); fi
#if [ ! -f $D/$CHECKSUM/$B.pdf-MD5.txt ]; then echo mangler checksum for PDF: $F; FEJL=$(echo $FEJL+1|bc); fi
#MD=$(md5sum $D/$PDF/$B.pdf | awk '{print $1}')
#if [ -z $MD ]; then MD="FOOBAR"; fi
#MDTEST4=$(egrep -i $MD $D/$CHECKSUM/$B.pdf-MD5.txt | wc -l);  if [ ! $MDTEST4 -eq 1 ]; then echo fejl i MD5 for PDF i MD5-fil: $F; fi

if [ ! $FEJL -eq 0 ]; then echo antal fejl: $FEJL; fi

#This check is disabled, since we do not check MIX files for these batches.
#if [ $DEBUG -eq 1 ]; then echo MIX-indhold-tjek; fi
#FNTEST=$(egrep objectIdentifierValue\>$B "$D/$MIXXML/"$B-MIX.xml | wc -l); if [ ! $FNTEST -eq 1 ]; then echo fejl i objectIdentifier i MIX: $F; fi
#FS=$(ls -l $I | awk '{print $5}')
#FSTEST=$(egrep fileSize\>$FS "$D/$MIXXML/"$B-MIX.xml | wc -l); if [ ! $FSTEST -eq 1 ]; then echo fejl i fileSize i MIX: $F; fi

#This check is disabled, since we do not check MIX files for these batches.
#if [ $DEBUG -eq 1 ]; then echo TIF-MD5-tjek; fi
#MD=$(md5sum $I | awk '{print $1}');
#if [ -z $MD ]; then MD="FOOBAR"; fi
#MDTEST5=$(egrep -i messageDigest\>$MD "$D/$MIXXML/"$B-MIX.xml | wc -l); if [ ! $MDTEST5 -eq 1 ]; then echo fejl i MD5 for TIF i MIX-fil: $F; fi
#MDTEST6=$(egrep -i $MD "$D/$CHECKSUM/"$F-MD5.txt | wc -l);  if [ ! $MDTEST6 -eq 1 ]; then echo fejl i MD5 for TIF i MD5-fil: $F; fi

if [ $DEBUG -eq 1 ]; then echo XML-skema-tjek; fi
sleep 1
CALTO=$(xmllint --noout --schema alto-1-4-fixed.xsd "$D/$ALTO/"$B.xml 2>&1 | grep validates$ | wc -l); if [ ! $CALTO -eq 1 ]; then echo $B.xml \(ALTO\) validerer IKKE; fi
sleep 1
#This check is disabled, since we do not check MIX files for these batches.
#CMIX=$(xmllint --noout --schema mix20.xsd "$D/$MIXXML/"$B-MIX.xml 2>&1 | grep validates$ | wc -l); if [ ! $CMIX -eq 1 ]; then echo $B-MIX.xml validerer IKKE; fi
sleep 1
CMODS=$(xmllint --noout --schema mods-3-1.xsd "$D/$MODSXML/"$B-MODS.xml 2>&1 | grep validates$ | wc -l); if [ ! $CMODS -eq 1 ]; then echo $B-MODS.xml validerer IKKE; fi

if [ $DEBUG -eq 1 ]; then echo PDF filformat-tjek; fi
#This check is disabled, since we do not check TIF files for these batches.
#FORMAT=$(file $I | grep 'TIFF image data' | wc -l); if [ ! $FORMAT -eq 1 ]; then echo fejl i TIF-format: $(file $I); fi
FORMAT=$(file "$D/$PDF/"$B.pdf | grep 'PDF document, version 1.6' | wc -l); if [ ! $FORMAT -eq 1 ]; then echo fejl i PDF-format: $(file "$D/$PDF/"$B.pdf); fi
FORMAT2=$(jhove/jhove -l OFF "$D/$PDF/"$B.pdf | grep '^  Profile:.*ISO PDF/A-1' | wc -l); if [ ! $FORMAT2 -eq 1 ]; then echo "fejl i PDF-format (skal være PDF-A): $(jhove/jhove -l OFF "$D/$PDF/"$B.pdf | grep '^  Profile')"; fi
FORMAT3=$(jhove/jhove -l OFF "$D/$PDF/"$B.pdf | grep '^  Status: Well-Formed and valid' | wc -l); if [ ! $FORMAT3 -eq 1 ]; then echo "fejl i PDF-format (ugyldig): $(jhove/jhove -l OFF "$D/$PDF/"$B.pdf | grep '^  Profile')"; fi

#This check is disabled since we do not  check TIF files for these batches.
#if [ $DEBUG -eq 1 ]; then echo TIF-tags-tjek; fi
#TAGS=$(tiffinfo $I 2>&1 | wc -l); if [ ! $TAGS -eq $TIFFTAGS ]; then echo fejl i TIF-tags: antal: $TAGS \(forventet $TIFFTAGS\); fi

if [ $DEBUG -eq 1 ]; then echo ALTO indholds-tjek; fi
ALTOTIFFFIL=$(xpath -q -e "//fileName/text()" "$D/$ALTO/$B.xml"); ALTOTIFFDIR=$(echo $ALTOTIFFFIL|cut -d_ -f1); if [ ! -e $TIFFHOME/$ALTOTIFFDIR/$ALTOTIFFFIL ]; then echo "Fejl i ALTO-fil - refereret TIFF-fil ($ALTOTIFFFIL) ikke fundet"; fi

if [ $DEBUG -eq 1 ]; then echo MODS indholds-tjek; fi
MODSIDENTIFIER=$(xpath -q -e "/mods:mods/mods:identifier[@type='local']/text()" "$D/$MODSXML/$B-MODS.xml"); if [ ! $MODSIDENTIFIER == $B ]; then echo "Fejl i MODS-fil - identifier er forkert. Forventet $B, var $MODSIDENFIER"; fi
MODSTIFFFIL="$(xpath -q -e "/mods:mods/mods:relatedItem/mods:identifier/@type" "$D/$MODSXML/$B-MODS.xml"|cut -d\" -f2).tif"; MODSTIFFDIR=$(echo $MODSTIFFFIL|cut -d_ -f1); if [ ! -e $TIFFHOME/$MODSTIFFDIR/$MODSTIFFFIL ]; then echo "Fejl i MODS-fil - refereret TIFF-fil ($MODSTIFFFIL) ukendt"; fi
MODSSTARTDATE=$(xpath -q -e "/mods:mods/mods:subject/mods:temporal[@point='start']/text()" "$D/$MODSXML/$B-MODS.xml"); MODSENDDATE=$(xpath -q -e "/mods:mods/mods:subject/mods:temporal[@point='end']/text()" "$D/$MODSXML/$B-MODS.xml"); TIFFSTARTDATE=$(echo $MODSTIFFFIL|cut -d- -f1|tr . -); TIFFENDDATE=$(echo $MODSTIFFFIL|cut -d- -f2|cut -d_ -f1|tr . -); if [ $MODSSTARTDATE \< $TIFFSTARTDATE ] || [ $MODSSTARTDATE \> $TIFFENDDATE ] || [ $MODSENDDATE \< $TIFFSTARTDATE ] || [ $MODSENDDATE \> $TIFFENDDATE ]; then echo "Fejl i MODS-fil - start/stopdatoer $MODSSTARTDATE - $MODSENDDATE udenfor TIFF-filens start/stop-datoer $TIFFSTARTDATE - $TIFFENDDATE"; fi
FILENAMEDATE=$(echo $B|cut -d- -f2-4); if [ $MODSSTARTDATE \> $FILENAMEDATE ] || [ $MODSENDDATE \< $FILENAMEDATE ]; then echo "Fejl i MODS-fil - start/stopdatoer $MODSSTARTDATE - $MODSENDDATE udenfor filnavnsdato $FILENAMEDATE"; fi

done | tee -a $LOGFILE
#./ditte "$1"
