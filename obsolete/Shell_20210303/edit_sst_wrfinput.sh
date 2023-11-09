#!/bin/sh
set -ax

# wps files are assumed ready already.
# modify the sst boundary conidition in wps
# and proceed until real.exe

metfile=$1
echo $metfile
romsfile=$ROMS_ICFile

 ln -fs $Couple_Lib_grids_WRF_Dir/$Nameit_WRF-nxnyr.dat fort.11
 ln -fs $romsfile fort.12
 echo $nd > fort.13
 ln -fs $metfile fort.14
 echo 1 > fort.15
 $Couple_Lib_exec_coupler_Dir/edit_sst_wrfinput.x  || exit 8
 rm fort.* 2>/dev/null
