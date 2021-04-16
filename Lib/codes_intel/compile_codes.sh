#!/bin/sh
INCLUDEDIR=/vortexfs1/apps/impistack-1.0/include
LIBDIR=/vortexfs1/apps/impistack-1.0/lib
Couple_Lib_exec_coupler_Dir=/vortexfs1/home/hseo/SCOAR2/Lib/exec/Coupler_intel

echo "sst_wrflowinp.f"
ifort -c -I$INCLUDEDIR sst_wrflowinp_nolake.f
ifort -o sst_wrflowinp_nolake.x sst_wrflowinp_nolake.o -L$LIBDIR -lnetcdff -lnetcdf

echo "sst_wrflowinp.f"
ifort -c -I$INCLUDEDIR sst_wrflowinp.f
ifort -o sst_wrflowinp.x sst_wrflowinp.o -L$LIBDIR -lnetcdff -lnetcdf

echo "edit_sst_wrfinput.f"
ifort -c -I$INCLUDEDIR edit_sst_wrfinput.f
ifort -o edit_sst_wrfinput.x edit_sst_wrfinput.o -L$LIBDIR -lnetcdff -lnetcdf

###
#echo "write_wpsformat.f"
#ifort write_wpsformat.f -o write_wpsformat.x -byteswapio
###
echo "write_roms2met.f"
ifort -c -I$INCLUDEDIR write_roms2met.f
ifort -o write_roms2met.x write_roms2met.o -L$LIBDIR -lnetcdff -lnetcdf
###
echo "write_rst2init1D.f"
ifort -c -I$INCLUDEDIR write_rst2init1D.f
ifort -o write_rst2init1D.x write_rst2init1D.o -L$LIBDIR -lnetcdff -lnetcdf
###
echo "write_rst2init2D.f"
ifort -c -I$INCLUDEDIR write_rst2init2D.f
ifort -o write_rst2init2D.x write_rst2init2D.o -L$LIBDIR -lnetcdff -lnetcdf
###
echo "write_rst2init3D.f"
ifort -c -I$INCLUDEDIR write_rst2init3D.f
ifort -o write_rst2init3D.x write_rst2init3D.o -L$LIBDIR -lnetcdff -lnetcdf
###
echo "write_rst2init4D.f"
ifort -c -I$INCLUDEDIR write_rst2init4D.f
ifort -o write_rst2init4D.x write_rst2init4D.o -L$LIBDIR -lnetcdff -lnetcdf
##
echo "read_ncvar.f"
ifort -c -I$INCLUDEDIR read_ncvar.f
ifort -o read_ncvar.x read_ncvar.o -L$LIBDIR -lnetcdff -lnetcdf
##
echo "read_write_ncvar.f"
ifort -c -I$INCLUDEDIR read_write_ncvar.f
ifort -o read_write_ncvar.x read_write_ncvar.o -L$LIBDIR -lnetcdff -lnetcdf
##
echo "badneagtive_qair.f"
ifort badnegative_qair.f -o badnegative_qair.x
##
echo "calculate_WRF_flux_bulk_longout.f"
ifort calculate_WRF_flux_bulk_longout.f -o calculate_WRF_flux_bulk_longout.x
##
echo "uauo.f"
ifort -c -I$INCLUDEDIR uauo.f
ifort -o uauo.x uauo.o -L$LIBDIR -lnetcdff -lnetcdf
##
echo "update_forc.f"
ifort -c -I$INCLUDEDIR update_forc.f
ifort -o update_forc.x update_forc.o -L$LIBDIR -lnetcdff -lnetcdf
##
echo "update_forc_time.f"
ifort -c -I$INCLUDEDIR update_forc_time.f
ifort -o update_forc_time.x update_forc_time.o -L$LIBDIR -lnetcdff -lnetcdf
##
fname=update_forc_time2
echo "$fname.f"
ifort -c -I$INCLUDEDIR $fname.f
ifort -o $fname.x $fname.o -L$LIBDIR -lnetcdff -lnetcdf
##
echo "update_init4D.f"
ifort -c -I$INCLUDEDIR update_init4D.f
ifort -o update_init4D.x update_init4D.o -L$LIBDIR -lnetcdff -lnetcdf
##
echo "update_init3D.f"
ifort -c -I$INCLUDEDIR update_init3D.f
ifort -o update_init3D.x update_init3D.o -L$LIBDIR -lnetcdff -lnetcdf
##
fname=update_init_time
echo "$fname"
ifort -c -I$INCLUDEDIR $fname.f
ifort -o $fname.x $fname.o -L$LIBDIR -lnetcdff -lnetcdf

fname=update_init_time2
echo "$fname"
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
