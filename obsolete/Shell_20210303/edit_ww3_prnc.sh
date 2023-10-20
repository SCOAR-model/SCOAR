#!/bin/sh
set -ax
YYYYi=`echo $1 | cut -d':' -f1`
MMi=`echo $1 | cut -d':' -f2`
DDi=`echo $1 | cut -d':' -f3`
HHi=`echo $1 | cut -d':' -f4`

YYYYin=`echo $2 | cut -d':' -f1`
MMin=`echo $2 | cut -d':' -f2`
DDin=`echo $2 | cut -d':' -f3`
HHin=`echo $2 | cut -d':' -f4`

edit_file=$3
sed -i -e 's/^[ \t]*//' $edit_file
sed -i -e '/^FORCING%TIMESTART /d' $edit_file  -e "40 i        FORCING%TIMESTART         = '$YYYYi$MMi$DDi $HHi\0000'"     $edit_file
sed -i -e '/^FORCING%TIMESTOP /d' $edit_file   -e "41 i        FORCING%TIMESTOP          = '$YYYYin$MMin$DDin $HHin\0000'" $edit_file
