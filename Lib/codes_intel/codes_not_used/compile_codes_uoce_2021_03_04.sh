#!/bin/sh
INCLUDEDIR=$(nf-config --prefix)/include
LIBDIR=$(nf-config --prefix)/lib
Couple_Lib_exec_coupler_Dir=../exec/Coupler_intel/

fname=sst_wrflowinp_nolake_initial
echo "$fname.f" 
ifort -c -I$INCLUDEDIR $fname.f
ifort -o $fname.x $fname.o -L$LIBDIR -lnetcdff -lnetcdf

fname=uoce_wrflowinp_nolake_initial
echo "$fname.f" 
ifort -c -I$INCLUDEDIR $fname.f
ifort -o $fname.x $fname.o -L$LIBDIR -lnetcdff -lnetcdf

fname=uoce_wrflowinp_nolake_use_qck
echo "$fname.f" 
ifort -c -I$INCLUDEDIR $fname.f
ifort -o $fname.x $fname.o -L$LIBDIR -lnetcdff -lnetcdf

fname=voce_wrflowinp_nolake_initial
echo "$fname.f" 
ifort -c -I$INCLUDEDIR $fname.f
ifort -o $fname.x $fname.o -L$LIBDIR -lnetcdff -lnetcdf

fname=voce_wrflowinp_nolake_use_qck
echo "$fname.f" 
ifort -c -I$INCLUDEDIR $fname.f
ifort -o $fname.x $fname.o -L$LIBDIR -lnetcdff -lnetcdf

fname=uvoce_wrflowinp_nolake_initial
echo "$fname.f" 
ifort -c -I$INCLUDEDIR $fname.f
ifort -o $fname.x $fname.o -L$LIBDIR -lnetcdff -lnetcdf

fname=uvoce_wrflowinp_nolake_use_qck
echo "$fname.f" 
ifort -c -I$INCLUDEDIR $fname.f
ifort -o $fname.x $fname.o -L$LIBDIR -lnetcdff -lnetcdf


##
####
cp *.x $Couple_Lib_exec_coupler_Dir || exit 8

rm -f *.x 2>/dev/null
rm -f *.o 2>/dev/null
if [ $? -eq 0 ]; then
echo "compiled and copied exectuables"
else
echo " compile failed!"
fi
