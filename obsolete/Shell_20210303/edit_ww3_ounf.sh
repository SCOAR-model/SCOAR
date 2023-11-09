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
STRIDE=`expr $4 \* 60 \* 60`

sed -i -e 's/^[ \t]*//' $edit_file
sed -i -e '/^FIELD%TIMESTART /d' $edit_file  -e "33 i       FIELD%TIMESTART         = '$YYYYi$MMi$DDi $HHi\0000'"         $edit_file
sed -i -e '/^FIELD%TIMESTRIDE /d' $edit_file -e "34 i       FIELD%TIMESTRIDE        = '$STRIDE'"  			  $edit_file
