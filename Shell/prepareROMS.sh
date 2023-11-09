#!/bin/sh
set -ax
cd $Couple_Data_ROMS_Dir || exit 8

ROMS_BCFile=$1
JD=$2
if [ $CF -ge 24 ]; then
NDay=$3
elif [ $CF -lt 24 ]; then
NHour=$3
fi
# updated 2018/4/23
YYYYin=`echo $4 | cut -d':' -f1`
MMin=`echo $4 | cut -d':' -f2`
DDin=`echo $4 | cut -d':' -f3`
HHin=`echo $4 | cut -d':' -f4`
NLOOP=$5

rm $Couple_Data_ROMS_Dir/ocean_bry.nc 2>/dev/null

echo "ROMS_BCFile = $ROMS_BCFile"

ROMS_BCtimes='zeta_time v2d_time v3d_time salt_time temp_time'

 if [ $ROMS_BCFile = SODA -a $ROMS_BCFile_Freq = 1mon ]; then
 	echo $ROMS_BCFile
  	tindx=`expr $JD \/ 30 + 1`
  	if [ $tindx -gt 12 ]; then
        	tindx=12
   	fi
	if [ $tindx -lt 10 ]; then
	tindx=0$tindx
	fi
   	echo "time index ==> $tindx ***"
   	tindxm=`expr $tindx - 1`
        bryfile=$ROMS_BCFile_Name\_$YYYYin$tindx.nc
        ifile_bry=$ROMS_BCFile_Dir/$YYYYin/$bryfile

 elif [ $ROMS_BCFile = SODA -a $ROMS_BCFile_Freq = 1day ]; then
        echo $ROMS_BCFile
        tindx=$JD
        echo "time index ==> $tindx ***"
        bryfile=$ROMS_BCFile_Name\_$YYYYin\_$tindx.nc
        ifile_bry=$ROMS_BCFile_Dir/$YYYYin/$bryfile

# addition 2018/4/23
 elif [ $ROMS_BCFile = SODA342 -a $ROMS_BCFile_Freq = 1day ]; then
        echo $ROMS_BCFile
#       tindx=$JD
#       echo "time index ==> $tindx ***"
        echo "$YYYYin $MMin $DDin"
        bryfile=$ROMS_BCFile_Name\_$YYYYin$MMin$DDin.nc
        ifile_bry=$ROMS_BCFile_Dir/$YYYYin/$bryfile

# modified on 2019/06/21
 elif [ $ROMS_BCFile = HYCOM ]; then
        echo $ROMS_BCFile
        bryfile=$ROMS_BCFile_Name\_$YYYYin$MMin$DDin.nc
        ifile_bry=$ROMS_BCFile_Dir/$YYYYin/$bryfile

# addition 2021/1/22 Cesar
 elif [ $ROMS_BCFile = mercator -a $ROMS_BCFile_Freq = 1day ]; then
        echo $ROMS_BCFile
        echo "$YYYYin $MMin $DDin"
        #bryfile=$ROMS_BCFile_Name\_$YYYYin\_$MMin\_$DDin\.nc
	# cesar's roms preprocessing tool gives this format: 05/28/2021
        bryfile=$ROMS_BCFile_Name\_$YYYYin$MMin$DDin\.nc
        ifile_bry=$ROMS_BCFile_Dir/$YYYYin/$bryfile

# CR 2023-07-14: addition - Christoph's Python pre-processing of GLORYS12v1 data
# The Python pre-processing routines can generate boundary files with multiple
# dates. So we extract the fields for the relavant date and write it into a
# temporary boundary file that follows the SCOAR standard.
 elif [ $ROMS_BCFile = glorys12v1 ]; then
        echo $ROMS_BCFile
        bryfile=$ROMS_BCFile_Name\_$YYYYin.nc
        mkdir -p $ROMS_BCFile_Dir/$ROMS_BCFile_Freq
        ncks -O -d bry_time,"$YYYYin-$MMin-$DDin 12:00:00" $ROMS_BCFile_Dir/$bryfile \
            $ROMS_BCFile_Dir/$ROMS_BCFile_Freq/$ROMS_BCFile_Name\_$YYYYin$MMin$DDin\.nc
        ifile_bry=$ROMS_BCFile_Dir/$ROMS_BCFile_Freq/$ROMS_BCFile_Name\_$YYYYin$MMin$DDin\.nc
        # note that all variables share the same time dimension `bry_time`
        ROMS_BCtimes=bry_time

## AR2 clim OBC run
# elif [ $ROMS_BCFile = mercator_daily_clim -a $ROMS_BCFile_Freq = 1day ]; then
#        echo $ROMS_BCFile
#        echo "$YYYYin $MMin $DDin"
#        bryfile=$ROMS_BCFile_Name\_$YYYYin\_$MMin\_$DDin\.nc
#        ifile_bry=$ROMS_BCFile_Dir/$YYYYin/$bryfile

## AR2 CLIM + 1997/1998 Observed S OBC
# elif [ $ROMS_BCFile = mercator_modified_obc -a $ROMS_BCFile_Freq = 1day ]; then
#        echo $ROMS_BCFile
#        echo "$YYYYin $MMin $DDin"
#        bryfile=$ROMS_BCFile_Name\_$YYYYin\_$MMin\_$DDin\.nc
#        ifile_bry=$ROMS_BCFile_Dir/$YYYYin/$bryfile

 elif [ $ROMS_BCFile = ECCO_10day_clim ]; then
        echo $ROMS_BCFile
        tindx=`expr $JD \/ 10 + 1`
        if [ $tindx -gt 73 ]; then
                tindx=73
        fi
        echo "time index ==> $tindx ***"
        tindxm=`expr $tindx - 1`
        bryfile=$ROMS_BCFile_Name\_$tindx.nc
        ifile_bry=$ROMS_BCFile_Dir/$bryfile
 fi

 echo " bryfile = $ifile_bry"

# obtain bry file
   ofile=$Couple_Data_ROMS_Dir/$bryfile
   $Couple_Lib_utils_Dir/fetchfile $ifile_bry $Couple_Data_ROMS_Dir/ocean_bry.nc ln || exit 8
   #if [ ! -s $Couple_Data_ROMS_Dir/$bryfile  ]; then
   #  exit 8
  # fi

# update initial file
# identical both for  daily and 3hrly coupling
# 1. if NHour=3 or NDay=1
#   use the specified ICFILE from main script
# 2. if NHour>3 or NDay>1
#   use previous time step ROMS run as an IC
#

rm -f fort.* 2>/dev/null
if [ $NLOOP -eq 1 ]; then

# 2018/04/25
if [ $restart_from_coupled_spinup = yes -o $ROMS_PERFECT_RESTART = yes ]; then
        # remove existing rst file
        rm $Couple_Data_ROMS_Dir/ocean_rst.nc 2>/dev/null
        ln -fs $ROMS_ICFile $Couple_Data_ROMS_Dir/ocean_ini.nc
# CR 2023-08-14 $Couple_Run_Dir/change_ocean_in.sh || exit 8
        $Couple_Run_Dir/edit_ROMS_ocean_in.sh || exit 8
else # if restarting from Avg or His file

    	if [ ! -s $ROMS_ICFile ]; then
        echo "ERROR: missing $ROMS_ICFile !!!!!"
        exit 8
    	fi
   	echo "your Initial File is  $ROMS_ICFile "
   	ln -fs $ROMS_ICFile fort.14
    	echo 1 > fort.13
# copy initial template file to ocean_ini.nc for initial time only
	cp $Couple_Lib_template_Dir/$gridname-init.nc $Couple_Data_ROMS_Dir/ocean_ini.nc || exit 8

echo "linking ocean_ini.nc"
ln -fsv $Couple_Data_ROMS_Dir/ocean_ini.nc fort.15 || exit 8

##
# for 4d variable
# number of depth needed for preparing the initial conditon for ROMS 
# read nd directly from ocean.in :October 27, 2022
# nd is already read and defined in main.sh
echo "number of ROMS depth level = $nd"
echo $nd > fort.16

echo "inserting 4d variables into ini.nc"
for var in temp salt u v
do
#echo "variable=  $var "
if [ $var = u ]; then
  ln -fs $Couple_Lib_grids_ROMS_Dir/$Nameit_ROMS-nxnyu.dat fort.11
  #ln -fs $Couple_Lib_auxfiles_Dir/u.txt fort.12
	echo u > fort.12
elif [ $var = v ]; then
  ln -fs $Couple_Lib_grids_ROMS_Dir/$Nameit_ROMS-nxnyv.dat fort.11
  #ln -fs $Couple_Lib_auxfiles_Dir/v.txt fort.12
	echo v > fort.12
else
  ln -fs $Couple_Lib_grids_ROMS_Dir/$Nameit_ROMS-nxnyr.dat fort.11
  #ln -fs $Couple_Lib_auxfiles_Dir/$var.txt fort.12
	echo $var > fort.12
fi
$Couple_Lib_exec_coupler_Dir/update_init4D.x || exit 8
done

echo "inserting 3d variables into ini.nc"
# for 3d variable
for var in zeta ubar vbar
do
#echo "variable=  $var "
if [ $var = ubar ]; then
  ln -fs $Couple_Lib_grids_ROMS_Dir/$Nameit_ROMS-nxnyu.dat fort.11
  #ln -fs $Couple_Lib_auxfiles_Dir/ubar.txt fort.12
	echo ubar > fort.12
elif [ $var = vbar ]; then
  ln -fs $Couple_Lib_grids_ROMS_Dir/$Nameit_ROMS-nxnyv.dat fort.11
  #ln -fs $Couple_Lib_auxfiles_Dir/vbar.txt fort.12
	echo vbar > fort.12
else
  ln -fs $Couple_Lib_grids_ROMS_Dir/$Nameit_ROMS-nxnyr.dat fort.11
  #ln -fs $Couple_Lib_auxfiles_Dir/$var.txt fort.12
	echo $var > fort.12
fi
$Couple_Lib_exec_coupler_Dir/update_init3D.x || exit 8
done

fi #[ $restart_from_coupled_spinup= yes ];

 else  #NLOOP>1

if [ $ROMS_Rst = yes ]; then
# restart using the ocean_rst.nc file # Jul 19, 2017
	# remove existing rst file
	rm $Couple_Data_ROMS_Dir/ocean_rst.nc 2>/dev/null

	ln -fs $ROMS_Rst_Dir/$YYYYi/rst_$YYYYi-$MMi-$DDi\_$HHi\_Hour$NHourm\.nc  $Couple_Data_ROMS_Dir/ocean_ini.nc 
	 $Couple_Run_Dir/edit_ROMS_ocean_in.sh || exit 8

else # if restarting from Avg or His file
exit 8
fi # if [ $ROMS_Rst = yes ]; then

fi # NLOOP

#####
# added 2021/03/05
# correct time stamps for ini, bry, and frc
# update time (julian date + hours) in ini, bry, and frc

# time varaible names different depending on what ocean preprocessing script is used.
# for mercator data with coawst package;
# ini: time
# bry: zeta_time, v2d_time, v3d_time. salt_time, temp_time
# frc is the same (as it is genearated by the coupler, not the preprocessing)

rm fort.?? 2>/dev/null

######
# bug fix; 2021/04/15 
# jd and ocean_time only varies between 0 and 365. This causes the problem in multi-year runs
# where ocean_time is defined wrt TIME_REF in ocean.in
# thanks to Cesar

# calculate JD

ocean_input_file=$Couple_Data_ROMS_Dir/ocean.in
YYYY_ref=$(grep -m 1 'TIME_REF' $Couple_Data_ROMS_Dir/ocean.in | grep -Eo '[0-9]{8}' | cut -b 1-4)
MM_ref=$(grep -m 1 'TIME_REF' $Couple_Data_ROMS_Dir/ocean.in | grep -Eo '[0-9]{8}'| cut -b 5-6)
DD_ref=$(grep -m 1 'TIME_REF' $Couple_Data_ROMS_Dir/ocean.in | grep -Eo '[0-9]{8}'| cut -b 7-8)

$Couple_Lib_utils_Dir/inchour $YYYY_ref $MM_ref $DD_ref 0 $YYYYin $MMin $DDin $HHin > inchour$$ || exit 9
read num_hour < inchour$$ ; rm inchour$$

# initial time is set to begnning of the fcst
# frc is set to the end of the fcst 
# bry is daily
# 1. inifile
echo $num_hour> fort.13
#echo $NHour > fort.14
echo $CF > fort.15
echo ocean_time  > fort.12
ln -fsv $Couple_Data_ROMS_Dir/ocean_ini.nc fort.21 || exit 8
$Couple_Lib_exec_coupler_Dir/update_init_time3.x || exit 8
rm fort.?? 2>/dev/null

# 2. bryfile: daily
echo $num_hour> fort.13
#echo $NHour > fort.14
echo $CF > fort.15
ln -fs $Couple_Data_ROMS_Dir/ocean_bry.nc fort.21
for time_name in $ROMS_BCtimes #zeta_time v2d_time v3d_time salt_time temp_time
  do
    echo $time_name > fort.12
$Couple_Lib_exec_coupler_Dir/update_bry_time3.x || exit 8
done
rm fort.?? 2>/dev/null

# #3. forc
echo $num_hour> fort.13
#echo $NHour > fort.14
echo $CF > fort.15
frcfile=$ROMS_Frc_Dir/$YYYYin/frc_$YYYYin-$MMin-$DDin\_$HHin\_Hour$NHour\.nc
ln -fs $frcfile fort.21

        if [ $CPL_PHYS = WRF_PHYS ]; then
for time_name in shf_time swf_time sms_time srf_time
  do
    echo $time_name > fort.12
$Couple_Lib_exec_coupler_Dir/update_forc_time3.x || exit 8
done
	fi

        if [ $CPL_PHYS = ROMS_PHYS ]; then
for time_name in srf_time wind_time pair_time qair_time tair_time rain_time lrf_time
  do
    echo $time_name > fort.12
$Couple_Lib_exec_coupler_Dir/update_forc_time3.x || exit 8
done
	fi

# if ROMS_wave is defined: update wave_time.
        if [ $ROMS_wave = yes ]; then
for time_name in wave_time
  do
    echo $time_name > fort.12
$Couple_Lib_exec_coupler_Dir/update_forc_time3.x || exit 8
done
        fi

rm fort.?? 2>/dev/null
