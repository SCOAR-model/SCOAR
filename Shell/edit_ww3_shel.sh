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


l1=$(grep -n 'DOMAIN%START' $edit_file  | grep -v ':!' | grep -Eo '^[0-9]{1,3}')
sed -i "$l1 d" $edit_file
sed -i -e  "$l1 i          DOMAIN%START         = '$YYYYi$MMi$DDi $HHi\0000'" $edit_file

l2=$(grep -n 'DOMAIN%STOP' $edit_file | grep -v ':!' | grep -Eo '^[0-9]{1,3}')
sed -i "$l2 d" $edit_file
sed -i -e  "$l2 i         DOMAIN%STOP         = '$YYYYin$MMin$DDin $HHin\0000'" $edit_file

l3=$(grep -n 'DATE%FIELD%START' $edit_file | grep -v ':!' | grep -Eo '^[0-9]{1,3}')
sed -i "$l3 d" $edit_file
sed -i -e  "$l3 i         DATE%FIELD%START     = '$YYYYi$MMi$DDi $HHi\0000'" $edit_file

l4=$(grep -n 'DATE%FIELD%STRIDE' $edit_file | grep -v ':!' | grep -Eo '^[0-9]{1,3}')
sed -i "$l4 d" $edit_file
sed -i -e  "$l4 i         DATE%FIELD%STRIDE    = '$STRIDE'" $edit_file

l5=$(grep -n 'DATE%FIELD%STOP' $edit_file | grep -v ':!' | grep -Eo '^[0-9]{1,3}')
sed -i "$l5 d" $edit_file
sed -i -e  "$l5 i         DATE%FIELD%STOP    = '$YYYYin$MMin$DDin $HHin\0000'" $edit_file

l6=$(grep -n 'DATE%RESTART' $edit_file | grep -v ':!' | grep -Eo '^[0-9]{1,3}')
sed -i "$l6 d" $edit_file
sed -i -e  "$l6 i         DATE%RESTART         = '$YYYYi$MMi$DDi $HHi\0000' '$STRIDE' '$YYYYin$MMin$DDin $HHin\0000'" $edit_file


l7=$(grep -n 'INPUT%FORCING%CURRENTS' $edit_file | grep -v ':!' | grep -Eo '^[0-9]{1,3}')
sed -i "$l7 d" $edit_file
#
if [ $wave_current = yes ];then #sending ocean current
        sed -i -e  "$l7 i              INPUT%FORCING%CURRENTS         = 'T'" $edit_file
elif [ $wave_current = no ];then # no ocean current
        sed -i -e  "$l7 i              INPUT%FORCING%CURRENTS         = 'F'" $edit_file
fi

if [ $wave_spec = yes ]; then
	l8=$(grep -n 'DATE%POINT%START' $edit_file | grep -v ':!' | grep -Eo '^[0-9]{1,3}')
	sed -i "$l8 d" $edit_file
	sed -i -e  "$l8 i         DATE%POINT%START     = '$YYYYi$MMi$DDi $HHi\0000'" $edit_file
	
	l9=$(grep -n 'DATE%POINT%STRIDE' $edit_file | grep -v ':!' | grep -Eo '^[0-9]{1,3}')
	sed -i "$l9 d" $edit_file
	sed -i -e  "$l9 i         DATE%POINT%STRIDE    = '$STRIDE'" $edit_file
	
	l10=$(grep -n 'DATE%POINT%STOP' $edit_file | grep -v ':!' | grep -Eo '^[0-9]{1,3}')
	sed -i "$l10 d" $edit_file
	sed -i -e  "$l10 i         DATE%POINT%STOP    = '$YYYYin$MMin$DDin $HHin\0000'" $edit_file
fi

l11=$(grep -n 'INPUT%FORCING%WATER_LEVELS' $edit_file | grep -v ':!' | grep -Eo '^[0-9]{1,3}')
sed -i "$l11 d" $edit_file
#
if [ $wave_ssh = yes ];then #sending ocean ssh
        sed -i -e  "$l11 i              INPUT%FORCING%WATER_LEVELS         = 'T'" $edit_file
elif [ $wave_ssh = no ];then # no ocean ssh
        sed -i -e  "$l11 i              INPUT%FORCING%WATER_LEVELS         = 'F'" $edit_file
fi



