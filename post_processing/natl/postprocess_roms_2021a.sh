#!/bin/bash
#SBATCH -J r01rp21a
#SBATCH -t 12:00:00
#SBATCH -o accounting/slurm-%j.out
#SBATCH -o err21a
#SBATCH -e log21a
#SBATCH --ntasks=1
#SBATCH -A s2634
##SBATCH --qos=high
##SBATCH --mail-user=user@nasa.gov

set -ax
CF=3
run_name=r01

YYYY=2021
MM=01
DD=01
HH=00

# keep the initial
YYYYS=$YYYY
MMS=$MM
DDS=$DD

MON=$MMS
MME=06
# last time should be "one more day" after the last time-step
last_time=2021-07-01

for file0 in qck forc avg
do

if [ $file0 = avg ]; then
file1=Avg
#vlist=("temp" "salt" "u_eastward" "v_northward" "w" "shflux" "ssflux" "swrad")
vlist=("temp" "salt" "u_eastward" "v_northward" "w") 
comm1=ncrcat
comm2=ncra

elif [ $file0 = qck ]; then
file1=Qck
#vlist=("temp_sur" "salt_sur" "zeta" "vbar_northward" " v_sur_northward" "ubar_eastward" "u_sur_eastward" "swrad" "svstr" "sustr" "ssflux" "shflux")
vlist=("temp_sur" "salt_sur" "zeta" "vbar_northward" " v_sur_northward" "ubar_eastward" "u_sur_eastward" "ssflux" )
comm1=ncrcat
comm2=ncra

elif [ $file0 = forc ]; then
file1=Forc
# nobulk
vlist=("sustr" "svstr" "shflux" "swflux" "swrad")
# bulk
#$vlist=("Uwind" "Vwind" "Pair" "Qair" "Tair" "swrad" "rain" "lwrad_down" "Uwind_abs" " Vwind_abs")
comm1=ncecat
comm2=ncea
fi

diri=../$file1/$YYYYS/
diro=./$file0/$YYYYS/
mkdir -p $diro

for vvar in ${vlist[@]}
do

YYYY=$YYYYS
MON=$MMS
while [ $MON -le $MME ]; do
MON=`expr $MON + 0`
if [ $MON -lt 10 ]; then
MON=0$MON
fi

echo "$CF\h $file0 $vvar $YYYY $MON"
filer=../$file1/$YYYY/$file0\_$YYYY\-$MON-??_??_*nc
filew1=$diro/$file0\_$run_name\_$CF\h_$vvar\_$YYYY$MON\.nc
$comm1 -O -v $vvar $filer $filew1 || exit 8

MON=`expr $MON + 0`
MON=`expr $MON + 1`
done # MON

# daily averaging
YYYY=$YYYYS
MM=$MMS
DD=$DDS
tindx=$YYYY-$MM\-$DD
echo $tindx
while [ "$tindx" !=  "$last_time" ]; do

filer=../$file1/$YYYY/$file0\_$YYYY\-$MM\-$DD\_??_*nc
filew2=$diro/$file0\_$run_name\_1d_$vvar\_$tindx\.nc
echo "1d $file0 $vvar $YYYY $MM $DD"
$comm2 -O -v $vvar  $filer $filew2 || exit 8 

incdte $YYYY $MM $DD 0 24 >& incdte.$$ # increase by day
read YYYY MM DD HH < incdte.$$; rm incdte.$$

tindx=$YYYY\-$MM\-$DD
done # tindx

# concatenate each month
MON=$MMS
while [ $MON -le $MME ]; do
MON=`expr $MON + 0`
if [ $MON -lt 10 ]; then
MON=0$MON
fi

# concatenate into each month
filer=$diro/$file0\_$run_name\_1d_$vvar\_$YYYYS-$MON-??.nc
filew3=$diro/$file0\_$run_name\_1d_$vvar\_$YYYYS$MON\.nc
$comm1 -O -v $vvar $filer $filew3 || exit 8

echo "1m $file0 $vvar $YYYY $MON"
filer=$diro/$file0\_$run_name\_1d_$vvar\_$YYYYS-$MON-??.nc
filew4=$diro/$file0\_$run_name\_1m_$vvar\_$YYYYS$MON\.nc 
$comm2 -O -v $vvar $filer $filew4 || exit 8

# cleanup
rm $diro/$file0\_$run_name\_1d_$vvar\_$YYYYS-$MON-??.nc

MON=`expr $MON + 0`
MON=`expr $MON + 1`
done # MON

done #vvar
done #file0
