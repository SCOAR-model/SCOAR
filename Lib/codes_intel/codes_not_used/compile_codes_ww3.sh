#!/bin/sh
INCLUDEDIR=/discover/nobackup/projects/nu-wrf/lib/sles12/ekman/intel-intelmpi/netcdf4/include
LIBDIR=/discover/nobackup/projects/nu-wrf/lib/sles12/ekman/intel-intelmpi/netcdf4/lib
Couple_Lib_exec_coupler_Dir=../exec/Coupler_intel/

fname=ww3_hs_wrflowinp
echo "$fname.f" 
ifort -c -I$INCLUDEDIR $fname.f
ifort -o $fname.x $fname.o -L$LIBDIR -lnetcdff -lnetcdf

fname=ww3_t0m1_wrflowinp
echo "$fname.f" 
ifort -c -I$INCLUDEDIR $fname.f
ifort -o $fname.x $fname.o -L$LIBDIR -lnetcdff -lnetcdf

fname=ww3_fp_wrflowinp
echo "$fname.f" 
ifort -c -I$INCLUDEDIR $fname.f
ifort -o $fname.x $fname.o -L$LIBDIR -lnetcdff -lnetcdf

fname=ww3_dp_wrflowinp
echo "$fname.f"
ifort -c -I$INCLUDEDIR $fname.f
ifort -o $fname.x $fname.o -L$LIBDIR -lnetcdff -lnetcdf

fname=ww3_t02_wrflowinp
echo "$fname.f"
ifort -c -I$INCLUDEDIR $fname.f
ifort -o $fname.x $fname.o -L$LIBDIR -lnetcdff -lnetcdf

fname=ww3_ust_wrflowinp
echo "$fname.f"
ifort -c -I$INCLUDEDIR $fname.f
ifort -o $fname.x $fname.o -L$LIBDIR -lnetcdff -lnetcdf

cp *.x $Couple_Lib_exec_coupler_Dir || exit 8

rm -f *.x 2>/dev/null
rm -f *.o 2>/dev/null
if [ $? -eq 0 ]; then
echo "compiled and copied exectuables"
else
echo " compile failed!"
fi
