#!/bin/sh
INCLUDEDIR=/vortexfs1/apps/impistack-1.0/include
LIBDIR=/vortexfs1/apps/impistack-1.0/lib
Couple_Lib_exec_coupler_Dir=/vortexfs1/home/hseo/SCOAR2/Lib/exec/Coupler_intel

echo "calculate_WRF_flux_bulk_longout.f"
ifort calculate_WRF_flux_bulk_longout.f -o calculate_WRF_flux_bulk_longout.x
#ifort calculate_WRF_flux_bulk_longout_include_rainsh.f -o calculate_WRF_flux_bulk_longout_include_rainsh.x

#echo "calculate_WRF_flux_bulk_longout_2018Jun11.f"
#ifort calculate_WRF_flux_bulk_longout_2018Jun11.f -o calculate_WRF_flux_bulk_longout_2018Jun11.x

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
