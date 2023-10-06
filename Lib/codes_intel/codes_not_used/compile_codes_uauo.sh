#!/bin/sh
INCLUDEDIR=/vortexfs1/apps/impistack-1.0/include
LIBDIR=/vortexfs1/apps/impistack-1.0/lib
Couple_Lib_exec_coupler_Dir=../exec/Coupler_intel/

echo "uauo.f"
ifort -c -I$INCLUDEDIR uauo.f
#ifort -o uauo.x uauo.o -L$LIBDIR -lnetcdff -lnetcdf

#cp uauo.x $Couple_Lib_exec_coupler_Dir
