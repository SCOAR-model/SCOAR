#!/bin/sh
set -ax

YYYYi=`echo $1 | cut -d':' -f1`
MMi=`echo $1 | cut -d':' -f2`
DDi=`echo $1 | cut -d':' -f3`

namelist_input_file=$Couple_Data_ROMS_Dir/ocean.in

# grep -m N : save only N first matches for search
#I assume here first match is the right one since all the others are commented at the end as namelists info


#sed -i -e 's/^[ \t]*//' namelist.input
l1=$(grep -n -m 1 'NRREC' $namelist_input_file | grep -Eo '^[0-9]{1,4}')
sed -i "$l1 d" $namelist_input_file
sed -i -e "$l1 i      NRREC ==  1" $namelist_input_file

#special case simulation changing year e.g 2019/12 to 2020/01
#changing TIME_REF to January 1st of current year

l2=$(grep -n -m 1 'TIME_REF' $namelist_input_file | grep -Eo '^[0-9]{1,4}')
if [ $MMi == 01 ] && [ $DDi == 01 ]; then
	sed -i "$l2 d" $namelist_input_file
	sed -i -e "$l2 i      TIME_REF ==  $YYYYi$MMi$DDi\.0d0" $namelist_input_file
else
	dummy="do nothing"
fi
