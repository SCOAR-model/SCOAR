#!/bin/sh
set -ax
NHour=$1
NHourm=$2
CF=$3
NLOOP=$4
YYYYi=`echo $5 | cut -d':' -f1`
MMi=`echo $5 | cut -d':' -f2`
DDi=`echo $5 | cut -d':' -f3`
HHi=`echo $5 | cut -d':' -f4`

$Couple_Lib_utils_Dir/incdte $YYYYi $MMi $DDi $HHi $CF > dteout$$ || exit 8
#n : 1 $CF later than
read YYYYin MMin DDin HHin < dteout$$; rm dteout$$

$Couple_Lib_utils_Dir/incdte $YYYYi $MMi $DDi $HHi -$CF > dteout$$ || exit 8
#n : 1 $CF earlier than
read YYYYim MMim DDim HHim < dteout$$; rm dteout$$

if [ $NLOOP -eq 1 ]; then
	WW3_In=$WW3_ICFile_NC
else # NLOOP>1
	WW3_In=$WW3_Outnc_Dir/ww3.$YYYYim$MMim$DDim$HHim\_Hour$NHourm\.nc
fi # NLOOP=1

if [ -s $WW3_In ]; then
	echo "$WW3_In"
	else
	echo "ERROR: missing $WW3_In !!"
	exit 8
fi

# read wrflowinp file
wrflowinp_file=wrflowinp_d0$Coupling_Domain
WW3_Out=$Model_WRF_Dir/$wrflowinp_file

# 2021/03/16
# WW3 smooth wave case is not consiered yet; # Assume no smooth case

ln -fs $Couple_Lib_grids_ROMS_Dir/$Nameit_ROMS-nxnyr.dat fort.11
ln -fs $WW3_In fort.12 || exit 8
ln -fs $WW3_Out fort.14 || exit 8

# mask
echo "use nolake grid for updating wave data. i.e lake values are not updated to WRF"
ln -fs $Couple_Lib_grids_ROMS_Dir/roms-$gridname-nolake-maskr.dat fort.16

# USE SST_FREQUENCT for waves (also for uoce/voce); they should be all same
if [ $SST_FREQUENCY -gt $CF ]; then
	echo" SST_FREQUENCY > CF: not meaninful. exiting"
	exit 8

else # SST_FREQUENCT -le CF

HOWMANY=`expr $CF \/ $SST_FREQUENCY + 1`
# calculate the time-stpes (nt2) of wrflowinp to update SST to.
ii=1 
while [ $ii -le $HOWMANY ]; do
        nt2=`expr  \( $CF \/ $SST_FREQUENCY \) \* \( $NLOOP \- 1 \) + $ii`
        #nt2=`expr  $CF \* \( $NLOOP \- 1 \) + $ii`
	#nt2 is the time stamp of the wflowinp at which ROMS SST will be entered..
	#make sure this is a correct value
	echo "nt2=$nt2"
        echo $nt2 > fort.15 || exit 8

	if [ $isftcflx -eq 351 ]; then
	# COARE3.5 WBF1 (wave age based on peak frequency)
        $Couple_Lib_exec_coupler_Dir/ww3_fp_wrflowinp.x || exit 8

	elif [ $isftcflx -eq 352 ]; then
	# COARE3.5 WBF2 (wave age based on peak frequency and Hs)
        $Couple_Lib_exec_coupler_Dir/ww3_fp_wrflowinp.x || exit 8
        $Couple_Lib_exec_coupler_Dir/ww3_hs_wrflowinp.x || exit 8

	elif [ $isftcflx -eq 353 ]; then
	# modified COARE3.5 WBF2 to include peak absolute angle difference
	# beween wind and wave (Sauvage et al. (2022)
        $Couple_Lib_exec_coupler_Dir/ww3_fp_wrflowinp.x || exit 8
        $Couple_Lib_exec_coupler_Dir/ww3_hs_wrflowinp.x || exit 8
        $Couple_Lib_exec_coupler_Dir/ww3_dp_wrflowinp.x || exit 8

	elif [ $isftcflx -eq 354 ]; then
        # modified COARE3.5 WBF2 to replace 
	# peak wave age with mean wave age (computed with t02)
	# Sauvage et al. (2022)
        $Couple_Lib_exec_coupler_Dir/ww3_t02_wrflowinp.x || exit 8
        $Couple_Lib_exec_coupler_Dir/ww3_hs_wrflowinp.x || exit 8

	elif [ $isftcflx -eq 355 ]; then
	# Porchetta et al. (2021) formulation
	# similar to 353 except for different parameters
	# not recommended
        $Couple_Lib_exec_coupler_Dir/ww3_fp_wrflowinp.x || exit 8
        $Couple_Lib_exec_coupler_Dir/ww3_hs_wrflowinp.x || exit 8
        $Couple_Lib_exec_coupler_Dir/ww3_dp_wrflowinp.x || exit 8

	elif [ $isftcflx -eq 3500 ]; then
	# Use COARE3.5 WBF2 for heat fluxes
	# Use UST from WW3 for momentum flux (work in progress)
        $Couple_Lib_exec_coupler_Dir/ww3_fp_wrflowinp.x || exit 8
        $Couple_Lib_exec_coupler_Dir/ww3_hs_wrflowinp.x || exit 8
        $Couple_Lib_exec_coupler_Dir/ww3_ust_wrflowinp.x || exit 8

	else
	echo "isftcflx missing"
	exit 8
	fi
##
        ii=`expr $ii + 1`
done
fi #[ $SST_FREQUENCY -gt $CF ]; then

rm -f fort.?? 2>/dev/null
