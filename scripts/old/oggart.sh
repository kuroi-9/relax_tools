#!/bin/sh

FILE1="`basename \"$1\"`"
EXT1=${FILE1##*.}
EXTTYPE1=`echo $EXT1 | tr '[:upper:]' '[:lower:]'`

FILE2="`basename \"$2\"`"
EXT2=${FILE2##*.}
EXTTYPE2=`echo $EXT2 | tr '[:upper:]' '[:lower:]'`

OGG=""
if [ "$EXTTYPE1" = ogg ]; then
OGG="$1"
elif [ "$EXTTYPE2" = ogg ]; then
OGG="$2"
fi
if [ "$OGG" = "" ]; then
echo no ogg file selected
exit 0
fi

PIC=""
array=(jpeg jpg png)
for item in ${array[*]}
do
if [ "$item" = "$EXTTYPE1" ]; then
PIC="$1"
elif [ "$item" = "$EXTTYPE2" ]; then
PIC="$2"
fi
done
if [ "$PIC" = "" ]; then
echo no jpg or png file selected
exit 0
fi

if [ "$3" = -e ]; then
EASYTAG=Y
else
EASYTAG=N
fi

DESC=`basename "$PIC"`
APIC=`base64 --wrap=0 "$PIC"`
if [ "`which exiv2`" != "" ]; then
MIME=`exiv2 "$PIC" | grep 'MIME type ' | sed 's/: /|/' | cut -f 2 -d '|' | tail -n 1`
fi
if [ "$MIME" = "" ]; then
MIME="image/jpeg"
fi

vorbiscomment -l "$OGG" | grep -v '^COVERART=' | grep -v '^COVERARTDESCRIPTION=' | grep -v '^COVERARTMIME=' | grep -v 'METADATA_BLOCK_PICTURE=' > "$OGG".tags

if [ "$EASYTAG" = N ]; then
echo METADATA_BLOCK_PICTURE="$APIC" > "$OGG".tags2
else
echo COVERART="$APIC" > "$OGG".tags2
fi
vorbiscomment -w -R -c "$OGG".tags2 "$OGG"
vorbiscomment -a -R -t COVERARTDESCRIPTION="$DESC" "$OGG"
vorbiscomment -a -R -t COVERARTMIME="$MIME" "$OGG"
vorbiscomment -a -R -c "$OGG".tags "$OGG"

rm -f "$OGG".tags
rm -f "$OGG".tags2


