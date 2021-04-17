#!/bin/sh
INCLUDEDIR=/vortexfs1/apps/impistack-1.0/include
LIBDIR=/vortexfs1/apps/impistack-1.0/lib
Couple_Lib_exec_coupler_Dir=../exec/Coupler_intel/

echo "gridinterp.f90"
ifort -c -I$INCLUDEDIR gridinterp.f90
ifort -o gridinterp.x gridinterp.o -L$LIBDIR -lnetcdff -lnetcdf

##
####
#rm $Couple_Lib_exec_coupler_Dir/*.x
cp gridinterp.x $Couple_Lib_exec_coupler_Dir || exit 8

#rm -f *.x 2>/dev/null
#rm -f *.o 2>/dev/null
if [ $? -eq 0 ]; then
echo "compiled and copied exectuables"
else
echo " compile failed!"
fi
