#!/bin/sh
INCLUDEDIR=/vortexfs1/apps/impistack-1.0/include
LIBDIR=/vortexfs1/apps/impistack-1.0/lib
Couple_Lib_exec_coupler_Dir=/vortexfs1/home/hseo/SCOAR2/Lib/exec/Coupler_intel

fname=filt2d_use_qck
echo "$fname.f and smooth"
ifort -c -I$INCLUDEDIR $fname.f
ifort -c smooth2d.f
ifort -o $fname.x smooth2d.o $fname.o  -L$LIBDIR -lnetcdff -lnetcdf

fname=uauo_use_qck
echo "$fname.f"
ifort -c -I$INCLUDEDIR $fname.f
ifort -o $fname.x $fname.o -L$LIBDIR -lnetcdff -lnetcdf

fname=uauo_use_qck_20190604
echo "$fname.f"
ifort -c -I$INCLUDEDIR $fname.f
ifort -o $fname.x $fname.o -L$LIBDIR -lnetcdff -lnetcdf

fname=sst_wrflowinp_nolake_use_qck
echo $fname.f
ifort -c -I$INCLUDEDIR $fname.f
ifort -o $fname.x $fname.o -L$LIBDIR -lnetcdff -lnetcdf
#
fname=sst_wrflowinp_use_qck
echo $fname.f
ifort -c -I$INCLUDEDIR $fname.f
ifort -o $fname.x $fname.o -L$LIBDIR -lnetcdff -lnetcdf
#

fname=filt2d_use_qck_nio1
echo "$fname.f and smooth"
ifort -c -I$INCLUDEDIR $fname.f
ifort -c smooth2d.f
ifort -o $fname.x smooth2d.o $fname.o  -L$LIBDIR -lnetcdff -lnetcdf

mv *x $Couple_Lib_exec_coupler_Dir


