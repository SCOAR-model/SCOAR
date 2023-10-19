#!/bin/sh
set -ax

#       NRREC == 0
#sed -i -e 's/^[ \t]*//' namelist.input
sed -i -e '/^NRREC /d' ocean.in  -e "209 i \          NRREC ==  1" $Couple_Data_ROMS_Dir/ocean.in
