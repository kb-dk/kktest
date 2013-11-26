#!/bin/bash
D=$1
ANTAL=0
DEBUG=0
LOGFILE=log

ALTO=ALTO
MODSXML=MODS
PDF=PDF
TIFFHOME=/sbftp-home/scan-dk/DR

date|tee $LOGFILE

ls "$D/$PDF/"*.pdf | while read I; do 
ANTAL=$(echo $ANTAL+1 | bc)
F=$(basename "$I")
echo $ANTAL: $F - $I
B=$(echo $F | cut -d'.' -f1)
FEJL=0

if [ $DEBUG -eq 1 ]; then echo ALTO-tjek; fi
if [ ! -f "$D/$ALTO/"$B.xml ]; then echo mangler ALTO: $F; FEJL=$(echo $FEJL+1|bc); fi

if [ $DEBUG -eq 1 ]; then echo MODS-tjek; fi
if [ ! -f "$D/$MODSXML/"$B-MODS.xml ]; then echo mangler MODS: $F; FEJL=$(echo $FEJL+1|bc); fi

if [ ! $FEJL -eq 0 ]; then echo antal fejl: $FEJL; fi

if [ $DEBUG -eq 1 ]; then echo XML-skema-tjek; fi
CALTO=$(xmllint --noout --schema alto-1-4-fixed.xsd "$D/$ALTO/"$B.xml 2>&1 | grep validates$ | wc -l); if [ ! $CALTO -eq 1 ]; then echo $B.xml \(ALTO\) validerer IKKE; fi
CMODS=$(xmllint --noout --schema mods-3-1.xsd "$D/$MODSXML/"$B-MODS.xml 2>&1 | grep validates$ | wc -l); if [ ! $CMODS -eq 1 ]; then echo $B-MODS.xml validerer IKKE; fi

if [ $DEBUG -eq 1 ]; then echo PDF filformat-tjek; fi
FORMAT=$(file "$D/$PDF/"$B.pdf | grep 'PDF document, version 1.6' | wc -l); if [ ! $FORMAT -eq 1 ]; then echo fejl i PDF-format: $(file "$D/$PDF/"$B.pdf); fi
FORMAT2=$(jhove/jhove -l OFF "$D/$PDF/"$B.pdf | grep '^  Profile:.*ISO PDF/A-1' | wc -l); if [ ! $FORMAT2 -eq 1 ]; then echo "fejl i PDF-format (skal være PDF-A): $(jhove/jhove -l OFF "$D/$PDF/"$B.pdf | grep '^  Profile')"; fi
FORMAT3=$(jhove/jhove -l OFF "$D/$PDF/"$B.pdf | grep '^  Status: Well-Formed and valid' | wc -l); if [ ! $FORMAT3 -eq 1 ]; then echo "fejl i PDF-format (ugyldig): $(jhove/jhove -l OFF "$D/$PDF/"$B.pdf | grep '^  Profile')"; fi

if [ $DEBUG -eq 1 ]; then echo ALTO indholds-tjek; fi
ALTOTIFFFIL=$(xpath -q -e "//fileName/text()" "$D/$ALTO/$B.xml"); ALTOTIFFDIR=$(echo $ALTOTIFFFIL|cut -d_ -f1); if [ ! -e $TIFFHOME/$ALTOTIFFDIR/$ALTOTIFFFIL ]; then echo "Fejl i ALTO-fil - refereret TIFF-fil ($ALTOTIFFFIL) ikke fundet"; fi

if [ $DEBUG -eq 1 ]; then echo MODS indholds-tjek; fi
MODSIDENTIFIER=$(xpath -q -e "/mods:mods/mods:identifier[@type='local']/text()" "$D/$MODSXML/$B-MODS.xml"); if [ ! $MODSIDENTIFIER == $B ]; then echo "Fejl i MODS-fil - identifier er forkert. Forventet $B, var $MODSIDENFIER"; fi
MODSTIFFFIL="$(xpath -q -e "/mods:mods/mods:relatedItem/mods:identifier[@type='local']/text()" "$D/$MODSXML/$B-MODS.xml"|cut -d\" -f2).tif"; MODSTIFFDIR=$(echo $MODSTIFFFIL|cut -d_ -f1); if [ ! -e $TIFFHOME/$MODSTIFFDIR/$MODSTIFFFIL ]; then echo "Fejl i MODS-fil - refereret TIFF-fil ($MODSTIFFFIL) ukendt"; fi
MODSSTARTDATE=$(xpath -q -e "/mods:mods/mods:subject/mods:temporal[@point='start']/text()" "$D/$MODSXML/$B-MODS.xml"); MODSENDDATE=$(xpath -q -e "/mods:mods/mods:subject/mods:temporal[@point='end']/text()" "$D/$MODSXML/$B-MODS.xml"); TIFFSTARTDATE=$(echo $MODSTIFFFIL|cut -d- -f1|tr . -); TIFFENDDATE=$(echo $MODSTIFFFIL|cut -d- -f2|cut -d_ -f1|tr . -); if [ $MODSSTARTDATE \< $TIFFSTARTDATE ] || [ $MODSSTARTDATE \> $TIFFENDDATE ] || [ $MODSENDDATE \< $TIFFSTARTDATE ] || [ $MODSENDDATE \> $TIFFENDDATE ]; then echo "Fejl i MODS-fil - start/stopdatoer $MODSSTARTDATE - $MODSENDDATE udenfor TIFF-filens start/stop-datoer $TIFFSTARTDATE - $TIFFENDDATE"; fi
FILENAMEDATE=$(echo $B|cut -d- -f2-4); if [ $MODSSTARTDATE != $FILENAMEDATE ]; then echo "Fejl i MODS-fil - startdato $MODSSTARTDATE forskellig fra filnavnsdato $FILENAMEDATE"; fi
FILENAMESUFFIX=$(echo $B|cut -d_ -f2|cut -d. _f1|sed -e 's/^0*//'); TIFFSUFFIX=$(echo $MODSTIFFFIL|cut -d_ -f2|cut -d. -f1|sed -e 's/^0*//'); if [ $FILENAMESUFFIX != $TIFFSUFFIX ]; then echo "Fejl i MODS-fil - MODS-fil slutter med $FILENAMESUFFIX, men refereret TIFF-fil slutter med $TIFFSUFFIX."; fi

if [ $DEBUG -eq 1 ]; then echo PDF indholds-tjek; fi
PDFSIZE=$(stat -c %s  "$D/$PDF/"$B.pdf); if [ $PDFSIZE -lt 200000 ]; then echo "Meget lille PDF-fil: filstørrelse $PDFSIZE"; fi

done | tee -a $LOGFILE
