#!/bin/sh
INCLUDEDIR=/vortexfs1/apps/impistack-1.0/include
LIBDIR=/vortexfs1/apps/impistack-1.0/lib
Couple_Lib_exec_coupler_Dir=/vortexfs1/home/hseo/SCOAR2/Lib/exec/Coupler_intel

echo "filt2d.f and smooth2d.f"
ifort -c -I$INCLUDEDIR filt2d.f
ifort -c smooth2d.f
ifort -o filt2d.x smooth2d.o filt2d.o  -L$LIBDIR -lnetcdff -lnetcdf

echo "sst_wrflowinp_nolake_smooth.f"
ifort -c -I$INCLUDEDIR sst_wrflowinp_nolake_smooth.f
ifort -o sst_wrflowinp_nolake_smooth.x sst_wrflowinp_nolake_smooth.o -L$LIBDIR -lnetcdff -lnetcdf

echo "uauo_smooth.f"
ifort -c -I$INCLUDEDIR uauo_smooth.f
ifort -o uauo_smooth.x uauo_smooth.o -L$LIBDIR -lnetcdff -lnetcdf

echo "for nio1 only"
ifort -c -I$INCLUDEDIR sst_wrflowinp_nolake_smooth_for_nio1.f
ifort -o sst_wrflowinp_nolake_smooth_for_nio1.x sst_wrflowinp_nolake_smooth_for_nio1.o -L$LIBDIR -lnetcdff -lnetcdf

mv *.x $Couple_Lib_exec_coupler_Dir
rm *.o

