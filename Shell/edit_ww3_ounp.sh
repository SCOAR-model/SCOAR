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

l1=$(grep -n 'POINT%TIMESTART' $edit_file  | grep -v ':!' | grep -Eo '^[0-9]{1,3}')
sed -i "$l1 d" $edit_file
sed -i -e  "$l1 i          POINT%TIMESTART         = '$YYYYi$MMi$DDi $HHi\0000'" $edit_file

l2=$(grep -n 'POINT%TIMESTRIDE' $edit_file  | grep -v ':!' | grep -Eo '^[0-9]{1,3}')
sed -i "$l2 d" $edit_file
sed -i -e  "$l2 i          POINT%TIMESTRIDE        = '$STRIDE'" $edit_file
