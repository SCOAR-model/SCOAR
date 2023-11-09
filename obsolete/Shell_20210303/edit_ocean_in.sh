#!/bin/sh
set -ax
# ocean.in file, if ROMS_Rst is defined, NRREC is set to 1 if NLOOP>1
#
#cat << INN > awktemp
#{
#        if (NR==209)
#        {
#                \$1=" NRREC "; 
#                \$2="     == "; 
#                \$3 = " 1"
#        }
#        {print \$0}
#}
#INN
#
#cat $Couple_Data_ROMS_Dir/ocean.in | awk -f awktemp > $Couple_Data_ROMS_Dir/ocean.in2 || exit 8
#mv  $Couple_Data_ROMS_Dir/ocean.in2  $Couple_Data_ROMS_Dir/ocean.in
#rm awktemp

#sed -i -e 's/^[ \t]*//' namelist.input
sed -i -e '/^NRREC /d' ocean.in  -e "209 i      NRREC ==  1" $Couple_Data_ROMS_Dir/ocean.in
