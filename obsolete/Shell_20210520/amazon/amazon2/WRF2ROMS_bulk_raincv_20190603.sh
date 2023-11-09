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
#U10 V10 SWDOWN GLW T2 Q2 PSFC ALBEDO RAINCV RAINNCV RAINSHV, GSW
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
	
# June 11, 2018, RAINCV and RAINNCV (unit == mm) are used (acuumulated over each output time-step of WRF)
#       #1. Need my_file_d01.txt in wrf direcgory showing 
#               +:h:0:RAINCV,RAINNCV,RAINSHV

        #te=`expr $CF \/ $SST_FREQUENCY + 1`
	#echo "te=$te"
	te=1

	# averages; -d Time $start,$end,$stride
        $NCO/ncra -F -O -v ZNT,CD,CDA,SST,OLR,U10,V10,SWDOWN,GLW,T2,Q2,PSFC,ALBEDO,UST,HFX,LH,PBLH,QFX,TH2,RAINCV,RAINNCV -d Time,1,$te,1 $WRF_Output2_Dir/wrfout_d0$WRF_Domain\_$YYYYs-$MMs-$DDs\_$HHs\_00\_00 $WRF_Output_Dir/WRF_Hour$NHour\.nc || exit 8

#Read vars only 3D (time,lat,lon)
for VAR in U10 V10 SWDOWN GLW T2 Q2 PSFC ALBEDO RAINCV RAINNCV #RAINSH ## GSW
 do
    rm -f fort.* 2>/dev/null
    ln -fs $Couple_Lib_grids_WRF_Dir/$Nameit_WRF-nxnyr.dat fort.11
    echo $VAR > fort.12
    echo 1 > fort.13
	    	ln -fs $WRF_Output_Dir/WRF_Hour$NHour\.nc fort.21
    $Couple_Lib_exec_coupler_Dir/read_ncvar.x || exit 8
    mv fort.51 $Couple_Data_tempo_files_Dir/$Nameit_WRF.$VAR.workin.dat || exit 8
done

# bulk_flux computation
	echo "flux computation" 
rm -f fort.* 2>/dev/null
ln -fs $Couple_Lib_grids_WRF_Dir/$Nameit_WRF-nxnyr.dat fort.11

# READ WRF TIME_STEP TO USE RAINCV and RAINNCV
# Feb 27 2020
grep  "time_step "  $Couple_Lib_exec_WRF_Dir/$WRF_Namelist_input | awk '{print $3}'  | sed 's/,//g' > fort.12

 ii=21
for VAR in U10 V10 SWDOWN GLW T2 Q2 PSFC ALBEDO RAINCV RAINNCV # RAINSH ## GSW
 do
 ln -fs $Couple_Data_tempo_files_Dir/$Nameit_WRF.$VAR.workin.dat fort.$ii
 ii=`expr $ii + 1 `
 done

if [ $LONGWAVE_OUT = no ]; then
	echo "WRF does not provide upward longwave radiation"
	echo " Need to write a code for calculating upward longwave radiation"
	echo " for now LONGWAVE_OUT should be yes"
	echo "change the setting LONGWAVE_OUT"
	exit 8
   #$Couple_Lib_exec_coupler_Dir/calculate_WRF_flux_bulk.x || exit 8
   #echo "LONGWAVE_OUT is NOT defined! You need to provide net longwave radiation,lwrad"
else
   #$Couple_Lib_exec_coupler_Dir/calculate_WRF_flux_bulk_longout.x || exit 8
   $Couple_Lib_exec_coupler_Dir/calculate_WRF_flux_bulk_longout_raincv.x || exit 8
   echo "LONGWAVE_OUT is defined!: You only need to provide lwrad_down"
fi
 ii=51
for VAR in SWRAD LWRAD PAIR QAIR TAIR RAIN U10 V10 
 do
 mv fort.$ii $Couple_Data_tempo_files_Dir/$Nameit_WRF.$VAR.workout.dat || exit 8
 ii=`expr $ii + 1 `
done

#Deal with bad values in QAIR exceeding 100%.
echo "Dealing with bad values in QAIR >100%"
rm -f fort.* 2>/dev/null
ln -fs $Couple_Lib_grids_ROMS_Dir/$Nameit_ROMS-nxnyr.dat fort.11 
ln -fs $Couple_Data_tempo_files_Dir/$Nameit_WRF.QAIR.workout.dat fort.21
$Couple_Lib_exec_coupler_Dir/badnegative_qair.x || exit 8
mv fort.51 $Couple_Data_tempo_files_Dir/$Nameit_WRF.QAIR.workout.dat
echo "done QAIR"

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

mkdir -p $ROMS_Forc_Dir/$YYYYs  || exit 8
        forcfile=$ROMS_Forc_Dir/$YYYYs/forc_Hour$NHour\.nc 
cp $Couple_Lib_template_Dir/ROMS_ForcingGeneral-$gridname.nc $forcfile || exit 8
ln -fs $forcfile $ROMS_Forc_Dir/forc_Hour$NHour\.nc

for VAR in SWRAD LWRAD PAIR QAIR TAIR RAIN U10 V10 
 do
   rm -f fort.* 2>/dev/null
   ln -fs $forcfile fort.21
   ln -fs $Couple_Lib_grids_ROMS_Dir/$Nameit_ROMS-nxnyr.dat fort.11
   echo 1 > fort.12
	if [ $VAR = SWRAD ]; then
		echo swrad > fort.13
	elif [ $VAR = LWRAD -a $LONGWAVE_OUT = yes ]; then
		echo lwrad_down > fort.13
	elif [ $VAR = LWRAD -a $LONGWAVE_OUT = no ]; then
		echo lwrad> fort.13
	elif [ $VAR = PAIR ]; then
		echo Pair > fort.13
	elif [ $VAR = QAIR ]; then
		echo Qair > fort.13
	elif [ $VAR = TAIR ]; then
		echo Tair > fort.13
	elif [ $VAR = RAIN ]; then
		echo rain> fort.13
	elif [ $VAR = U10 ]; then
		echo Uwind > fort.13
	elif [ $VAR = V10 ]; then
		echo Vwind > fort.13
	else
	echo "missing field.." 
	exit 8
        fi 

   ln -fs $Couple_Data_tempo_files_Dir/$Nameit_WRF.$VAR.workout.dat fort.14
   $Couple_Lib_exec_coupler_Dir/update_forc.x || exit 8
done

# THIS IS MOVED to update_ROMS_time.sh within prepareROMS_Rst.sh
## update time variables of the forcing file with julian date
#echo "update time variables of the forcing file with julian date"
#rm -f VARTIME fort.* 2>/dev/null
#ln -fs $forcfile fort.21
#echo 1 > fort.11
#echo $JD > fort.13
#echo $NHour > VARTIME
#for var_time in srf_time wind_time pair_time qair_time tair_time rain_time lrf_time
#  do
#    #echo $var_time " --> " $JD
#    echo $var_time > fort.12
#        #need JD + hour to be more precise 7/19/2017
#    $Couple_Lib_exec_coupler_Dir/update_forc_time2.x || exit 8
#done
##

if [ $SSS_CORRECTION = yes ]; then
# 1. make sure to define  either of these:
        #define SCORRECTION        
        #undef SRELAXATION        
# 2. Need pre-processed one SSS file, containing all SSS fields from observations, 
#       @ each couplign step, SSS from this file will be read and written to forc.
echo "APPLYING SCORRECTION OR SRELXATION"
        rm -f fort.* 2>/dev/null
        # determine current timestep
          tindx=`expr $JD \/ 10 + 1`
           echo "time index ==> $tindx ***"
#        this is a file to read from
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
