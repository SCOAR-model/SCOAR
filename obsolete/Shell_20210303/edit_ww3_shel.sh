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
sed -i -e '/^DOMAIN%START /d' $edit_file  -e "25 i        DOMAIN%START         = '$YYYYi$MMi$DDi $HHi\0000'"         $edit_file
sed -i -e '/^DOMAIN%STOP /d' $edit_file  -e  "26 i        DOMAIN%STOP          = '$YYYYin$MMin$DDin $HHin\0000'"     $edit_file


sed -i -e '/^DATE%FIELD%START /d'  $edit_file -e "290 i        DATE%FIELD%START     = '$YYYYi$MMi$DDi $HHi\0000'"         $edit_file
sed -i -e '/^DATE%FIELD%STRIDE /d' $edit_file -e "291 i        DATE%FIELD%STRIDE    = '$STRIDE'"  			  $edit_file
sed -i -e '/^DATE%FIELD%STOP /d'   $edit_file -e "292 i        DATE%FIELD%STOP      = '$YYYYin$MMin$DDin $HHin\0000'"     $edit_file
sed -i -e '/^DATE%RESTART /d'      $edit_file -e "293 i        DATE%RESTART         = '$YYYYi$MMi$DDi $HHi\0000' '$STRIDE' '$YYYYin$MMin$DDin $HHin\0000'" $edit_file
