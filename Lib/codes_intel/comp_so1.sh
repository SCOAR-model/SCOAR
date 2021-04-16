#!/bin/sh
INCLUDEDIR=/vortexfs1/apps/impistack-1.0/include
LIBDIR=/vortexfs1/apps/impistack-1.0/lib
Couple_Lib_exec_coupler_Dir=/vortexfs1/home/hseo/SCOAR2/Lib/exec/Coupler_intel

fname=filt2d_use_qck_so1
echo "$fname.f and smooth"
ifort -c -I$INCLUDEDIR $fname.f
ifort -c smooth2d_so1.f
ifort -o $fname.x smooth2d_so1.o $fname.o  -L$LIBDIR -lnetcdff -lnetcdf

mv *x $Couple_Lib_exec_coupler_Dir


