#!/bin/sh
set -ax
# Synopsis; edit SST in wrflowinp in each wrf time-steps
#Input: $ROMS_ICFile or ROMS_previoustimestep
#Output: $Model_WRF_Dir/wrflowinp_d01

# future work
# 1. need to add interpolation part later if grids are different.
# 2. repeat for d02 and d03
# imprive SST CF COupling by increasing sSST frequency in wrflowinp

# caution
# 1. make sure wrflowinp has the correct total timestep
# 2. NDay=1 sst is written for 1-5 (for 6hourly case as it include t=0)
# and NDay>1 sst is written for 1-4 (for 6hourly case)

#Part of the coupler: ROMS to WRF


# HOWMANY=CF/SST_FREQUENCY+1
# CF \ SST |    1       |     3      |      6     |    24     |
#-------------------------------------------------------------
#    1     | 1/1+1=2    |     X      |      X     |     X     |
#-------------------------------------------------------------
#    3     | 3/1+1=4    |  3/3+1=2   |      X     |     X     |
#-------------------------------------------------------------
#    6     | 6/1+1=5    |  6/3+1=3   |   6/6+1=2  |     X     |
#-------------------------------------------------------------
#   24     | 24/1+1=25  | 24/3+1=9   |  24/6+1=5  |  24/24=2  |
#-------------------------------------------------------------

   NHour=$1
   NHourm=$6

# $2 and $3 are not used (should be removed in the future..)
YYYYs=`echo $2 | cut -d':' -f1`
MMs=`echo $2 | cut -d':' -f2`
DDs=`echo $2 | cut -d':' -f3`
HHs=`echo $2 | cut -d':' -f4`

YYYYe=`echo $3 | cut -d':' -f1`
MMe=`echo $3 | cut -d':' -f2`
DDe=`echo $3 | cut -d':' -f3`
HHe=`echo $3 | cut -d':' -f4`

CF=$4
NLOOP=$5

# 1. read ROMS file to read SST; either qck (use _use_qck.x) or avg
     echo "updating SST fields from ROMS initial file to SST in wrflowinp: NHour = $NHour, $YYYYi-$MMi-$DDi-$HHi"
if [ $NLOOP -eq 1 ]; then
        SST_In=$ROMS_ICFile
else # NLOOP>1
     if [ $ROMS_Qck = yes ]; then
       SST_In=$ROMS_Qck_Dir/$YYYYi/qck_$YYYYi-$MMi-$DDi\_$HHi\_Hour$NHourm.nc
        else
       SST_In=$ROMS_Avg_Dir/$YYYYi/avg_$YYYYi-$MMi-$DDi\_$HHi\_Hour$NHourm.nc
      fi
fi # NLOOP=1

	echo "File to read SST from (in ROMS)"
	if [ -s $SST_In ]; then
	echo "$SST_In"
	else
	echo "ERROR: missing $SST_In !!"
	exit 8
	fi

#  read wrflowinpt file
wrflowinp_file=wrflowinp_d0$Coupling_Domain
SST_Out=$Model_WRF_Dir/$wrflowinp_file
echo "file to update SST: $SST_Out"

# if SmoothSST=yes, then do filt2d to create sst.nc file and then update wrflow from sst
# if SmoothSST=no, then do ususally

if [ $SmoothSST = yes ]; then
	echo "Interactive SST Smoothing at NHour=$NHour: spanx=$spanx, spany=$spany"
   rm -f fort.* 2>/dev/null
   ln -fs $Couple_Lib_grids_ROMS_Dir/$Nameit_ROMS-nxnyr.dat fort.11
   echo $spanx > fort.12
   echo $spany > fort.13
	if [ $ROMS_Qck = yes -a $NLOOP -gt 1 ]; then
   		echo temp_sur > fort.14 
	else
   		echo temp > fort.14 
	fi

   echo $nd > fort.16
   echo sst > fort.17
   ln -fs $Couple_Lib_grids_ROMS_Dir/$ROMS_Grid_Filename fort.18
   ln -fs $SST_In fort.19 
   echo lon_rho > fort.20
   echo lat_rho > fort.21
   echo mask_rho > fort.22
	# diagnostic
   cp $Couple_Lib_template_Dir/sst.nc $ROMS_Smooth_Before_Dir/sst_Hour$NHourm.nc
   cp $Couple_Lib_template_Dir/sst.nc $ROMS_Smooth_After_Dir/sst_Hour$NHourm.nc
   ln -fs $ROMS_Smooth_Before_Dir/sst_Hour$NHourm.nc fort.51
   ln -fs $ROMS_Smooth_After_Dir/sst_Hour$NHourm.nc fort.52

        if [ $ROMS_Qck = yes -a $NLOOP -gt 1 ]; then
   #$Couple_Lib_exec_coupler_Dir/filt2d_use_qck_$gridname\.x || exit 8
   $Couple_Lib_exec_coupler_Dir/filt2d_use_qck.x || exit 8
	else
   $Couple_Lib_exec_coupler_Dir/filt2d.x || exit 8
	fi

# before  minus after to see the result of smoothing
$NCO/ncbo --op_typ=- -O $ROMS_Smooth_Before_Dir/sst_Hour$NHourm.nc $ROMS_Smooth_After_Dir/sst_Hour$NHourm.nc $ROMS_Smooth_Diff_Dir/sst_diff_Hour$NHourm.nc || exit 8

# write to wrflowinput at nt2
ln -fs $Couple_Lib_grids_ROMS_Dir/$Nameit_ROMS-nxnyr.dat fort.11
ln -fs $ROMS_Smooth_After_Dir/sst_Hour$NHourm.nc fort.12 || exit 8
ln -fs $SST_In fort.122 || exit 8
ln -fs $SST_Out fort.14 || exit 8
if [ $NOLAKE = yes ]; then
        echo "use nolake grid for updating SST. i.e lake values are not updated by ROMS"
        ln -fs $Couple_Lib_grids_ROMS_Dir/roms-$gridname-nolake-maskr.dat fort.16
fi
ln -fs $SST_Out fort.51 || exit 8

        if [ $SST_FREQUENCY -gt $CF ]; then
        echo" SST_FREQUENCY > CF: not meaninful. exiting"
        exit 8
        else # SST_FREQUENCT -lt CF
        HOWMANY=`expr $CF \/ $SST_FREQUENCY + 1`
        # calculate the time-stpes (nt2) of wrflowinp to update SST to.
        ii=1; while [ $ii -le $HOWMANY ]; do
#nt2 is the time stamp of the wflowinp at which ROMS SST will be entered..
#make sure this is a correct value
        nt2=`expr  \( $CF \/ $SST_FREQUENCY \) \* \( $NLOOP \- 1 \) + $ii`
        #nt2=`expr  $CF \* \( $NLOOP \- 1 \) + $ii`
        echo "nt2=$nt2"
        echo $nt2 > fort.15 || exit 8
if [ $NOLAKE = yes ]; then
        $Couple_Lib_exec_coupler_Dir/sst_wrflowinp_nolake_smooth.x || exit 8
else
	echo "NOLAKE IS NOT IMPLEMENTED FOR SMOOTHING YET!!"
	exit 8
fi
        ii=`expr $ii + 1`
        done
        fi #[ $SST_FREQUENCY -gt $CF ]; then

else # if SmoothSST is not defined,

ln -fs $Couple_Lib_grids_ROMS_Dir/$Nameit_ROMS-nxnyr.dat fort.11
ln -fs $SST_In fort.12 || exit 8
echo $nd > fort.13
ln -fs $SST_Out fort.14 || exit 8

if [ $NOLAKE = yes ]; then
# eventually, there should be a code that autumatically detect lakes and overwritw sst from wrflowinp on these pts.
# instead of make nolake mask manually
####### read this for landmask
#####ln -fs  $Model_WRF_Dir/wrfinput_d01 fort.16
# read landmask with nolake; (new)
# update sst only over the land.
# over lake use the existing values in wrf_lowinp
	echo "use nolake grid for updating SST. i.e lake values are not updated by ROMS"
	ln -fs $Couple_Lib_grids_ROMS_Dir/roms-$gridname-nolake-maskr.dat fort.16
fi

	if [ $SST_FREQUENCY -gt $CF ]; then
	echo" SST_FREQUENCY > CF: not meaninful. exiting"
	exit 8
	else # SST_FREQUENCT -lt CF
	HOWMANY=`expr $CF \/ $SST_FREQUENCY + 1`
	# calculate the time-stpes (nt2) of wrflowinp to update SST to.
        ii=1; while [ $ii -le $HOWMANY ]; do
        nt2=`expr  \( $CF \/ $SST_FREQUENCY \) \* \( $NLOOP \- 1 \) + $ii`
        #nt2=`expr  $CF \* \( $NLOOP \- 1 \) + $ii`
#nt2 is the time stamp of the wflowinp at which ROMS SST will be entered..
#make sure this is a correct value
	echo "nt2=$nt2"
        echo $nt2 > fort.15 || exit 8

if [ $NOLAKE = yes ]; then
	if [ $NLOOP -eq 1 ]; then
	#  for initial SST update, since it is usually ROMS IC, don't use use_qck. 
        $Couple_Lib_exec_coupler_Dir/sst_wrflowinp_nolake.x || exit 8
	else

	# after the initial, use qck as SST are read from ocean qck file
        $Couple_Lib_exec_coupler_Dir/sst_wrflowinp_nolake_use_qck.x || exit 8
	fi
else
	if [ $NLOOP -eq 1 ]; then
        $Couple_Lib_exec_coupler_Dir/sst_wrflowinp.x || exit 8
	else
        $Couple_Lib_exec_coupler_Dir/sst_wrflowinp_use_qck.x || exit 8
	fi
fi
        ii=`expr $ii + 1`
        done
	fi #[ $SST_FREQUENCY -gt $CF ]; then
fi # SmoothSST
