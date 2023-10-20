#!/bin/sh
set -ax
cd $Couple_Data_ROMS_Dir

NHour=$1

   # sfc current from previous time-step 
   NHourm=`expr $NHour - $CF`
   if [ $NHourm -gt 0 ]; then
        if [ $ROMS_Qck = yes ]; then
	UV_In=$ROMS_Qck_Dir/$YYYYi/qck_$YYYYi-$MMi-$DDi\_$HHi\_Hour$NHourm.nc 
	else
	UV_In=$ROMS_Avg_Dir/$YYYYi/avg_$YYYYi-$MMi-$DDi\_$HHi\_Hour$NHourm.nc 
	fi
   else
        # initial time
	UV_In=$Couple_Data_ROMS_Dir/ocean_ini.nc
   fi

if [ $SmoothUV = yes ]; then

   echo "Interactive Usfv and Vsfc Smoothing at NHour=$NHour: spanx=$spanx, spany=$spany"
   #1. Usfc
   rm -f fort.* 2>/dev/null
    ln -fs $Couple_Lib_grids_ROMS_Dir/$Nameit_ROMS-nxnyu.dat fort.11
   echo $spanx > fort.12
   echo $spany > fort.13 
   if [ $ROMS_Qck = yes -a $NHourm -gt 0  ]; then
   	echo u_sur_eastward > fort.14
   	echo lon_rho > fort.20
   	echo lat_rho > fort.21
   	echo mask_rho > fort.22
   else
   	echo u> fort.14
   	echo lon_u > fort.20
   	echo lat_u > fort.21
   	echo mask_u > fort.22
   fi
   echo $nd > fort.16
   echo usfc > fort.17
   ln -fs $Couple_Lib_grids_ROMS_Dir/$ROMS_Grid_Filename fort.18
   ln -fs $UV_In fort.19
	#diagnostic
   cp $Couple_Lib_template_Dir/usfc.nc $ROMS_Smooth_Before_Dir/usfc_Hour$NHourm.nc || exit 8
   cp $Couple_Lib_template_Dir/usfc.nc $ROMS_Smooth_After_Dir/usfc_Hour$NHourm.nc ||  exit 8
   ln -fs $ROMS_Smooth_Before_Dir/usfc_Hour$NHourm.nc fort.51
   ln -fs $ROMS_Smooth_After_Dir/usfc_Hour$NHourm.nc fort.52

   if [ $NHourm -gt 0 ]; then 	 # if not initial then there's option for qck or avg
        if [ $ROMS_Qck = yes  ]; then
   	$Couple_Lib_exec_coupler_Dir/filt2d_use_qck.x || exit 8 # use: qck
    else
   	$Couple_Lib_exec_coupler_Dir/filt2d.x || exit 8 # use: avg
	fi
    else # if initial, mostly avg or his (not qck)
   	$Couple_Lib_exec_coupler_Dir/filt2d.x || exit 8
    fi

# before  minus after to see the result of smoothing
$NCO/ncbo --op_typ=- -O $ROMS_Smooth_Before_Dir/usfc_Hour$NHour.nc $ROMS_Smooth_After_Dir/usfc_Hour$NHour.nc $ROMS_Smooth_Diff_Dir/usfc_diff_Hour$NHour.nc

   #2. Vsfc
   rm -f fort.* 2>/dev/null
   ln -fs $Couple_Lib_grids_ROMS_Dir/$Nameit_ROMS-nxnyv.dat fort.11
   echo $spanx > fort.12
   echo $spany > fort.13
   if [ $ROMS_Qck = yes -a $NHourm -gt 0 ]; then
        echo v_sur_northward > fort.14
   	echo lon_rho > fort.20
        echo lat_rho > fort.21
        echo mask_rho > fort.22
   else 
        echo v> fort.14
   	echo lon_v > fort.20
   	echo lat_v > fort.21
   	echo mask_v > fort.22
   fi   
   echo $nd > fort.16
   echo vsfc > fort.17
   ln -fs $Couple_Lib_grids_ROMS_Dir/$ROMS_Grid_Filename fort.18
   ln -fs $UV_In fort.19
	# diagnostic
   cp $Couple_Lib_template_Dir/vsfc.nc $ROMS_Smooth_Before_Dir/vsfc_Hour$NHourm.nc
   cp $Couple_Lib_template_Dir/vsfc.nc $ROMS_Smooth_After_Dir/vsfc_Hour$NHourm.nc
   ln -fs $ROMS_Smooth_Before_Dir/vsfc_Hour$NHourm.nc fort.51
   ln -fs $ROMS_Smooth_After_Dir/vsfc_Hour$NHourm.nc fort.52

 if [ $NHourm -gt 0 ]; then         # if not initial then there's option for qck or avg
        if [ $ROMS_Qck = yes ]; then
        $Couple_Lib_exec_coupler_Dir/filt2d_use_qck.x || exit 8
        else
        $Couple_Lib_exec_coupler_Dir/filt2d.x || exit 8
        fi
    else # if initial, mostly avg or his (not qck)
        $Couple_Lib_exec_coupler_Dir/filt2d.x || exit 8
    fi

# before  minus after to see the result of smoothing
$NCO/ncbo --op_typ=- -O $ROMS_Smooth_Before_Dir/vsfc_Hour$NHour.nc $ROMS_Smooth_After_Dir/vsfc_Hour$NHour.nc $ROMS_Smooth_Diff_Dir/vsfc_diff_Hour$NHour.nc
fi

rm -f $Couple_Data_ROMS_Dir/fort.* 2>/dev/null
# calculate u10, v10 relative to ocean current(usfc, vsfc)
# usfc, vsfc come from the previous time step ROMS solution
# if it is the first time step, read them from initaial file

# note that u10, v10 are rho points
# wheareas usfc, vsfc are u and v points
# so usfcr, vsfcr are created such that
# usfcr(1:nx-1)=usfc; and usfcr(nx)=usfc(nx-1)

rm -f fort.* 2>/dev/null
ln -fs $Couple_Lib_grids_ROMS_Dir/$Nameit_ROMS-nxnyu.dat fort.11
ln -fs $Couple_Lib_grids_ROMS_Dir/$Nameit_ROMS-nxnyv.dat fort.12
ln -fs $Couple_Lib_grids_ROMS_Dir/$Nameit_ROMS-nxnyr.dat fort.13
cp $Couple_Data_ROMS_Dir/ocean_frc.nc $Couple_Data_ROMS_Dir/fort.21
echo 1 > $Couple_Data_ROMS_Dir/fort.14 || exit 8

if [ $SmoothUV = yes ]; then
	ln -fs $ROMS_Smooth_After_Dir/usfc_Hour$NHour.nc fort.22 || exit 8
	ln -fs $ROMS_Smooth_After_Dir/vsfc_Hour$NHour.nc fort.23 || exit 8
	$Couple_Lib_exec_coupler_Dir/uauo_smooth.x || exit 8

#######################
else # SmoothUV not defined (most cases)
      echo $nd > fort.15
      ln -fs $UV_In fort.22 || exit 8

   if [ $ROMS_Qck = yes -a $NHourm -ge 0 ]; then
        #ln -fs $Couple_Lib_grids_ROMS_Dir/roms-$gridname-nolake-maskr.dat fort.16
# this include Uwind_abs
	$Couple_Lib_exec_coupler_Dir/uauo_use_qck_20190604.x || exit 8
	#$Couple_Lib_exec_coupler_Dir/uauo_use_qck.x || exit 8

   elif [ $ROMS_Qck = yes -a $NHourm -eq 0 ]; then
	$Couple_Lib_exec_coupler_Dir/uauo.x || exit 8

   else
	$Couple_Lib_exec_coupler_Dir/uauo.x || exit 8
   fi
fi #SmoothUV Defined?

cp $Couple_Data_ROMS_Dir/fort.21  $Couple_Data_ROMS_Dir/ocean_frc.nc || exit 8
rm -f $Couple_Data_ROMS_Dir/fort.* 2>/dev/null
