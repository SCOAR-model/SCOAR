#!/bin/sh
INCLUDEDIR=/vortexfs1/apps/impistack-1.0/include
LIBDIR=/vortexfs1/apps/impistack-1.0/lib
Couple_Lib_exec_coupler_Dir=../exec/Coupler_intel/

fname=update_forc_time2  update_ini_time2 update_bry_time2
echo "$fname.f" 
ifort -c -I$INCLUDEDIR $fname.f
ifort -o $fname.x $fname.o -L$LIBDIR -lnetcdff -lnetcdf
##


####
#rm $Couple_Lib_exec_coupler_Dir/*.x
cp *.x $Couple_Lib_exec_coupler_Dir || exit 8

rm -f *.x 2>/dev/null
rm -f *.o 2>/dev/null
if [ $? -eq 0 ]; then
echo "compiled and copied exectuables"
else
echo " compile failed!"
fi
