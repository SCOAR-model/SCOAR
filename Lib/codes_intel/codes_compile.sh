#!/bin/sh
INCLUDEDIR=$NETCDF/include
LIBDIR=$NETCDF/lib
Couple_Lib_exec_coupler_Dir=../exec/Coupler_intel

# ROMS2WRF
for fname in sst_wrflowinp_nolake_smooth sst_wrflowinp_nolake_initial sst_wrflowinp_nolake_perf_rst sst_wrflowinp sst_wrflowinp_use_qck sst_wrflowinp_nolake_use_qck uvoce_wrflowinp_nolake_use_qck uvoce_wrflowinp_nolake_initial uvoce_wrflowinp_nolake_perf_rst #uoce_wrflowinp_nolake_use_qck voce_wrflowinp_nolake_use_qck uoce_wrflowinp_nolake_initial voce_wrflowinp_nolake_initial
do
echo "$fname"
ifort -c -I$INCLUDEDIR $fname.f
ifort -o $fname.x $fname.o -L$LIBDIR -lnetcdff -lnetcdf
done

echo ""
# filt2d
for fname in filt2d_use_qck filt2d #filt2d_use_qck_inimerc 
do
echo "$fname"
ifort -c -I$INCLUDEDIR $fname.f
ifort -c smooth2d.f
ifort -o $fname.x smooth2d.o $fname.o -L$LIBDIR -lnetcdff -lnetcdf
done

echo ""
# WRF2ROMS_nobulk and bulk wrfonly
for fname in read_ncvar calculate_WRF_flux_nobulk_prec_acc update_forc calculate_WRF_flux_bulk_longout_raincv calculate_WRF_flux_nobulk_prec_acc_tauoc #calculate_WRF_flux_nobulk_raincv
do
echo "$fname"
ifort -c -I$INCLUDEDIR $fname.f
ifort -o $fname.x $fname.o -L$LIBDIR -lnetcdff -lnetcdf
done

echo ""
# prepareROMS + update_ROMS_time.sh
for fname in update_init4D update_init3D update_bry_time3 update_forc_time3 update_init_time3 #update_forc_time2  update_ini_time2 update_bry_time2 update_init_time
do
echo "$fname"
ifort -c -I$INCLUDEDIR $fname.f
ifort -o $fname.x $fname.o -L$LIBDIR -lnetcdff -lnetcdf
done

# uauo
for fname in uauo_smooth uauo_use_qck_20190604 uauo #uauo_use_qck
do
echo "$fname"
ifort -c -I$INCLUDEDIR $fname.f
ifort -o $fname.x $fname.o -L$LIBDIR -lnetcdff -lnetcdf
done

echo ""
# WW32WRF
for fname in ww3_hs_wrflowinp ww3_t0m1_wrflowinp ww3_fp_wrflowinp ww3_dp_wrflowinp ww3_t02_wrflowinp ww3_ust_wrflowinp
do
echo "$fname"
ifort -c -I$INCLUDEDIR $fname.f
ifort -o $fname.x $fname.o -L$LIBDIR -lnetcdff -lnetcdf
done

# Misc
for fname in read_ncvar
do
echo "$fname"
ifort -c -I$INCLUDEDIR $fname.f
ifort -o $fname.x $fname.o -L$LIBDIR -lnetcdff -lnetcdf
done

echo ""
# grid interp. or other codes with .f90
for fname in gridinterp
do
echo "$fname"
ifort -c -I$INCLUDEDIR $fname.f90
ifort -o $fname.x $fname.o -L$LIBDIR -lnetcdff -lnetcdf
done

# application specific codes

# SO1
#fname=filt2d_use_qck_so1
#echo "$fname.f and smooth"
#ifort -c -I$INCLUDEDIR $fname.f
#ifort -c smooth2d_so1.f
#ifort -o $fname.x smooth2d_so1.o $fname.o  -L$LIBDIR -lnetcdff -lnetcdf

#rm $Couple_Lib_exec_coupler_Dir/*.x
cp *.x $Couple_Lib_exec_coupler_Dir || exit 8


# test new more codes here
#fname=?????
#echo "$fname.f and smooth"
#ifort -c -I$INCLUDEDIR $fname.f
#ifort -c smooth2d_so1.f
#ifort -o $fname.x smooth2d_so1.o $fname.o  -L$LIBDIR -lnetcdff -lnetcdf


rm -f *.x 2>/dev/null
rm -f *.o 2>/dev/null
if [ $? -eq 0 ]; then
echo "compiled and copied exectuables"
else
echo " compile failed!"
fi
