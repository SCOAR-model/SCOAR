#!/bin/sh
set -ax

namelist_input_file=$Couple_Data_ROMS_Dir/ocean.in

#sed -i -e 's/^[ \t]*//' namelist.input
l1=$(grep -n -m 1 'NRREC' $namelist_input_file | grep -Eo '^[0-9]{1,4}')
sed -i "$l1 d" $namelist_input_file
sed -i -e "$l1 i      NRREC ==  1" $namelist_input_file

