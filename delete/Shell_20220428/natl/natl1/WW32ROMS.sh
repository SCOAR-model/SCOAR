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
	if [ $WW3_spinup = yes ]; then
	WW3_In=$WW3_ICFile_NC
	else #WW3_spinup=no
	WW3_In=
	fi
else # NLOOP>1
	WW3_In=$WW3_Outnc_Dir/ww3.$YYYYim$MMim$DDim$HHim\_Hour$NHourm\.nc
fi # NLOOP=1

if [ -s $WW3_In ]; then
	echo "$WW3_In"
else
	if [ $NLOOP -eq 1 -a $WW3_spinup = no ]; then
	echo "it is OKAY that WW3_In is empty @ NLOOP = 1 because WW3_spinuip = no"
	else
	echo "ERROR: missing $WW3_In !!"
	exit 8
	fi
fi

if [ $NLOOP -eq 1 -a $WW3_spinup = no ]; then
echo "No WW3_In file exists yet. Skip adding FOC to ROMS forcing file as NLOOP=1 and WW3_spinup=no"
echo "this will use zeor values in wave fields"
else
forcfile=$ROMS_Forc_Dir/$YYYYin/forc_$YYYYin-$MMin-$DDin\_$HHin\_Hour$NHour\.nc

#1. FOC (WW3) --> Wave_dissip (ROMS)
ncrcat -O -v foc $WW3_In tempo.nc
ncrename -h -O -v foc,Wave_dissip tempo.nc
ncatted -a ,Wave_dissip,d,, -a ,global,d,, tempo.nc
ncap2 -O -s 'Wave_dissip=double(Wave_dissip)' tempo.nc tempo.nc 
ncks -A tempo.nc $forcfile
rm tempo.nc

##2. HS (WW3) --> Hwave (ROMS)
ncrcat -O -v hs $WW3_In tempo.nc
ncrename -h -O -v hs,Hwave tempo.nc
ncatted -a ,Wave_dissip,d,, -a ,global,d,, tempo.nc
ncap2 -O -s 'Hwave=double(Hwave)' tempo.nc tempo.nc
ncks -A tempo.nc $forcfile
rm tempo.nc

fi
