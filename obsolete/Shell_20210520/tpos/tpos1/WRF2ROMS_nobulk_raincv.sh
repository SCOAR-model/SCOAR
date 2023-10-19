#!/bin/sh
set -ax
# bulk version of WRF2ROMS
NHour=$1
MHour=$2
JD=$3

YYYYs=`echo $4 | cut -d':' -f1`
MMs=`echo $4 | cut -d':' -f2`
DDs=`echo $4 | cut -d':' -f3`
HHs=`echo $4 | cut -d':' -f4`

echo "*****************************"
echo "Coupling in WRF domain $WRF_Domain"
echo "*****************************"

echo "********************************"
echo "WRF2ROMS (bulk version) Starting"
# LH: latent heat flux 
# HFX: sensible heat flux
# GSW: NET shortwave radiation
# GLW: DOWNWARD longwave radiation
# SST: to caluclate upward longwave raidation
# UST: Friction velocity
# U10/V10: to drive stress from UST
# RAINC/RAINNC

# June 11, 2018, RAINCV and RAINNCV (unit == mm) are used (acuumulated over each output time-step of WRF)
# 	#1. Need my_file_d01.txt in wrf direcgory showing 
#		+:h:0:RAINCV,RAINNCV,RAINSHV
	
echo "********************************"

# -F uses Fortran (1-based, not 0) indexing convention; try to use this option always to avoid confusion
       # different averaging depending on output frequency of WRF 6hr or 3hr.... 

# te=CF/WRF_OUTPUT_FREQUENCY+1
# CF \ WRF |    1       |     3      |      6     |    24     |
#-------------------------------------------------------------
#    1     | 1/1+1=2    |     X      |      X     |     X     |
#-------------------------------------------------------------
#    3     | 3/1+1=4    |  3/3+1=2   |      X     |     X     |
#-------------------------------------------------------------
#    6     | 6/1+1=5    |  6/3+1=3   |  6/6+1=2   |     X     |
#-------------------------------------------------------------
#   24     | 24/1+1=25  | 24/3+1=9   |  24/6+1=5  |  24/24=2  |
#-------------------------------------------------------------

		# if WRF output is 1h regardless of CF
        if [ $WRF_OUTPUT_FREQUENCY -eq 1 ]; then
		te=`expr $CF + 1`
	else
		# if WRF output is the same as CF; te=2 (beginning and end);
        	te=`expr $CF \/ $SST_FREQUENCY + 1`
	fi
	echo "te=$te"

#echo WRF_Hour begin
#date
#	# averages; -d Time $start,$end,$stride 
#	# for raincv and rainncv; it is average rain rate (mm/wrf_dt e.g., mm/90s)
#        $NCO/ncra -F -O -v ZNT,CD,CDA,LH,HFX,GSW,GLW,SST,UST,U10,V10,RAINCV,RAINNCV,OLR,T2,Q2,PSFC,PBLH,QFX,TH2 -d Time,1,$te,1 $WRF_Output2_Dir/wrfout_d0$WRF_Domain\_$YYYYs-$MMs-$DDs\_$HHs\_00\_00   $WRF_Output_Dir/WRF_Hour$NHour.nc || exit 8
#date
#echo WRF_Hour end
#
#Read vars only 3D (time,lat,lon)
for VAR in LH HFX GSW GLW SST UST U10 V10 RAINCV RAINNCV
 do
    rm -f fort.* 2>/dev/null
    ln -fs $Couple_Lib_grids_WRF_Dir/$Nameit_WRF-nxnyr.dat fort.11
    echo $VAR > fort.12
    echo 1 > fort.13
#    	ln -fs $WRF_Output_Dir/WRF_Hour$NHour.nc fort.21
                ln -fs $WRF_Output2_Dir/$YYYYs/wrfout_d0$WRF_Domain\_$YYYYs-$MMs-$DDs\_$HHs\_00\_00 fort.21
    $Couple_Lib_exec_coupler_Dir/read_ncvar.x || exit 8
    mv fort.51 $Couple_Data_tempo_files_Dir/$VAR.workin.dat || exit 8
done

## HS  Nov 23, 2022 added for ROMS_wave to pass tau_oc, instead of tau to ROMS
if [ $NLOOP -gt 1 -a  $ROMS_wave = yes -a $parameter_WW32ROMS = yes ]; then
	# read utaw, vtaw, utwo, and vtwo from WW3
	# only when NLOOP>1

	# read 1 CF earlier than
	$Couple_Lib_utils_Dir/incdte $YYYYs $MMs $DDs $HHs -$CF > dteout$$ || exit 8
	read YYYYim MMim DDim HHim < dteout$$; rm dteout$$
        WW3_In=$WW3_Outnc_Dir/ww3.$YYYYim$MMim$DDim$HHim\_Hour$NHourm\.nc

	for VAR in utaw vtaw utwo vtwo
 	do
    	rm -f fort.* 2>/dev/null
	# WRF and WW3 grids are the same still..
    	ln -fs $Couple_Lib_grids_WRF_Dir/$Nameit_WRF-nxnyr.dat fort.11
    	echo $VAR > fort.12
    	echo 1 > fort.13
        ln -fs $WW3_In fort.21
    	$Couple_Lib_exec_coupler_Dir/read_ncvar.x || exit 8
    	mv fort.51 $Couple_Data_tempo_files_Dir/$VAR.workin.dat || exit 8
 	done
fi # NLOOP
######


# bulk_flux computation
    rm -f fort.* 2>/dev/null
    ln -fs $Couple_Lib_grids_WRF_Dir/$Nameit_WRF-nxnyr.dat fort.11

# READ WRF TIME_STEP TO USE RAINCV and RAINNCV
# Feb 27 2020
grep  "time_step "  $Couple_Lib_exec_WRF_Dir/$WRF_Namelist_input  | awk '{print $3}'  | sed 's/,//g' > fort.16

 ii=21
 if [ $NLOOP -gt 1 -a $ROMS_wave = yes -a $parameter_WW32ROMS = yes ]; then
for VAR in U10 V10 UST GSW GLW SST LH HFX RAINCV RAINNCV utaw vtaw utwo vtwo
 do
 ln -fs $Couple_Data_tempo_files_Dir/$VAR.workin.dat fort.$ii
 ii=`expr $ii + 1 `
 done
   $Couple_Lib_exec_coupler_Dir/calculate_WRF_flux_nobulk_raincv_tauoc.x || exit 8

else #NLOOP, ROMS_wave, parameter_WW32ROMS

for VAR in U10 V10 UST GSW GLW SST LH HFX RAINCV RAINNCV
 do
 ln -fs $Couple_Data_tempo_files_Dir/$VAR.workin.dat fort.$ii
 ii=`expr $ii + 1 `
 done
   $Couple_Lib_exec_coupler_Dir/calculate_WRF_flux_nobulk_raincv.x || exit 8
fi #NLOOP, ROMS_wave, parameter_WW32ROMS

# output
ii=51
for VAR in sustr svstr shflux swrad swflux 
 do
 mv fort.$ii $Couple_Data_tempo_files_Dir/$VAR.workout.dat || exit 8
 ii=`expr $ii + 1 `
done

if [ $WRF_ROMS_SAME_GRID = no ]; then
echo "grid interpolation.. in WRF2ROMS.."
# skip the interpolation for now for matchin grid
## grid interpolation: WRF-->ROMS
## use gridinterp.f90
#echo "gridinterp.f90"
#	rm -f fort.* 2>/dev/null
#	ln -fs $Couple_Lib_grids_WRF_Dir/$Nameit_WRF-nxny.dat fort.11
#	ln -fs $Couple_Lib_grids_Coupler_Dir/lon_$Nameit_WRF.dat fort.13
#	ln -fs $Couple_Lib_grids_Coupler_Dir/lat_$Nameit_WRF.dat fort.14
#    for flx in SWRAD LWRAD PAIR QAIR TAIR CLOUD U10 V10 RAIN
#	do
#	ln -fs $Couple_Data_tempo_files_Dir/$Nameit_WRF.$flx.workin1.dat fort.17
#	ln -fs $Couple_Lib_grids_ROMS_Dir/$Nameit_ROMS-nxnyr.dat fort.12
#	ln -fs $Couple_Lib_grids_Coupler_Dir/lon_$Nameit_ROMS.r.dat fort.15
#	ln -fs $Couple_Lib_grids_Coupler_Dir/lat_$Nameit_ROMS.r.dat fort.16
#	$Couple_Lib_exec_coupler_Dir/gridinterp.x || exit 8
#	mv fort.51 $Couple_Data_tempo_files_Dir/$Nameit_WRF.$flx.workin3.dat
#	done
fi #WRF_ROMS_SAME_GRID

# insert forcings to forcing file
echo "updating forcing file..."
rm -f fort.* 2>/dev/null

mkdir -p $ROMS_Forc_Dir/$YYYYin  || exit 8
        forcfile=$ROMS_Forc_Dir/$YYYYin/forc_$YYYYin-$MMin-$DDin\_$HHin\_Hour$NHour\.nc
cp $Couple_Lib_template_Dir/ROMS_ForcingGeneral-$gridname.nc $forcfile || exit 8

for VAR in sustr svstr shflux swrad swflux 
 do
   rm -f fort.* 2>/dev/null
   ln -fs $forcfile fort.21
	if [ $VAR = sustr ]; then
	ln -fs $Couple_Lib_grids_ROMS_Dir/$Nameit_ROMS-nxnyu.dat fort.11
	elif [ $VAR = svstr ]; then
	ln -fs $Couple_Lib_grids_ROMS_Dir/$Nameit_ROMS-nxnyv.dat fort.11
	else
	ln -fs $Couple_Lib_grids_ROMS_Dir/$Nameit_ROMS-nxnyr.dat fort.11
	fi
   echo 1 > fort.12
	echo $VAR > fort.13
   ln -fs $Couple_Data_tempo_files_Dir/$VAR.workout.dat fort.14
   $Couple_Lib_exec_coupler_Dir/update_forc.x || exit 8
done

## update time variables of the forcing file with julian date
#echo "update time variables of the forcing file with julian date"
#rm -f VARTIME fort.* 2>/dev/null
#ln -fs $forcfile fort.21
#echo 1 > fort.11
#echo $JD > fort.13
#echo $NHour > VARTIME
#for var_time in srf_time wind_time pair_time qair_time tair_time rain_time lrf_time shf_time swf_time sms_time srf_time
#  do
#    #echo $var_time " --> " $JD
#    echo $var_time > fort.12
#    #$Couple_Lib_exec_coupler_Dir/update_forc_time.x || exit 8
#	#need JD + hour to be more precise 7/19/2017
#    $Couple_Lib_exec_coupler_Dir/update_forc_time2.x || exit 8
#done
#

if [ $SSS_CORRECTION = yes ]; then
# 1. make sure to define  either of these:
	#define SCORRECTION        
	#undef SRELAXATION        
# 2. Need pre-processed one SSS file, containing all SSS fields from observations, 
# 	@ each couplign step, SSS from this file will be read and written to forc.
echo "APPLYING SCORRECTION OR SRELXATION"
	rm -f fort.* 2>/dev/null
	# determine current timestep
	  tindx=`expr $JD \/ 10 + 1`
	   echo "time index ==> $tindx ***"
#	 this is a file to read from
	cmd="SSSfile=$SSS_path/$YYYYi/sss_$YYYYi$MMi$DDi\.nc"
	eval $cmd
	echo $SSSfile
	
    	echo "file to read", $SSSfile
	if [ ! -s $SSSfile ]; then
	echo "missing SSS file for SSS Correction: exiting..."
	exit 8
	else
    
	# write SSS to forcing file
	$NCO/ncks -A -v SSS $SSSfile $forcfile
    	echo "file to update", $forcfile
	fi
fi #SSS_CORRECTION

# ******************

rm -f $Couple_Run_Dir/fort.* 2>/dev/null
rm $Couple_Run_Dir/ftp.* 2>/dev/null
rm $Couple_Run_Dir/incdte* 2>/dev/null

 echo "NHour:$NHour end: WRF --> ROMS"

echo "********************************"
echo "WRF2ROMS (bulk version) Done...."
echo "********************************"
