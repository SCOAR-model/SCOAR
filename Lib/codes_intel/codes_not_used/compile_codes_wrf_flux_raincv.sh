#!/bin/sh
INCLUDEDIR=$(nf-config --prefix)/include
LIBDIR=$(nf-config --prefix)/lib
Couple_Lib_exec_coupler_Dir=../exec/Coupler_intel/

fname=calculate_WRF_flux_nobulk_raincv
echo $fname.f
ifort -c -I$INCLUDEDIR $fname.f
ifort -o $fname.x $fname.o -L$LIBDIR -lnetcdff -lnetcdf
cp $fname.x  $Couple_Lib_exec_coupler_Dir || exit 8

fname=calculate_WRF_flux_nobulk_prec_acc
echo $fname.f
ifort -c -I$INCLUDEDIR $fname.f
ifort -o $fname.x $fname.o -L$LIBDIR -lnetcdff -lnetcdf
cp $fname.x  $Couple_Lib_exec_coupler_Dir || exit 8

fname=calculate_WRF_flux_bulk_longout_raincv
echo $fname.f
ifort -c -I$INCLUDEDIR $fname.f
ifort -o $fname.x $fname.o -L$LIBDIR -lnetcdff -lnetcdf
cp $fname.x  $Couple_Lib_exec_coupler_Dir || exit 8

fname=calculate_WRF_flux_nobulk_raincv_tauoc
echo $fname.f
ifort -c -I$INCLUDEDIR $fname.f
ifort -o $fname.x $fname.o -L$LIBDIR -lnetcdff -lnetcdf
cp $fname.x  $Couple_Lib_exec_coupler_Dir || exit 8

rm -f *.x 2>/dev/null
rm -f *.o 2>/dev/null
if [ $? -eq 0 ]; then
echo "compiled and copied exectuable: $fname"
else
echo " compile failed!"
fi

