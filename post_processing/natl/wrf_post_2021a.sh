#!/bin/bash
#SBATCH -J r01wp21a
#SBATCH -t 12:00:00
#SBATCH -o accounting/slurm-%j.out
#SBATCH -o err_21a
#SBATCH -e log_21a
#SBATCH --ntasks=1
#SBATCH -A s2634
##SBATCH --qos=high
##SBATCH --mail-user=user@nasa.gov

set -ax
export run_name=r01
echo $run_name
export DT=3

for domain in d01
do

YYYY=2021
MM=01
DD=01
HH=00

YYYYS=$YYYY
MONS=$MM
MON=$MONS
MONE=06
# last time should be "one more day" after the last time-step
last_time=2021-07-01_00

####
dirw1=./$YYYY/wrfsfc
dirw2=./$YYYY/wrfprs
dirw3=./$YYYY/wrfzlev
mkdir -p $dirw1
mkdir -p $dirw2
mkdir -p $dirw3

while [ $MON -le $MONE ]; do

MON=`expr $MON + 0`
if [ $MON -lt 10 ]; then 
MON=0$MON
fi

#just concatenate everything
filer=../WRF_Out2/$YYYY/wrfout_$domain\_$YYYY\-$MON-??_??_00_00
filew_sfc=$dirw1/wrfsfc_$domain\_$run_name\_$DT\h\_$YYYY$MON\.nc
ncrcat -O -v RAINC,RAINNC,RAINCV,RAINNCV,SST,OLR,U10,V10,SWDOWN,GLW,T2,Q2,PSFC,ALBEDO,UST,ZNT,CD,HFX,LH,PBLH,QFX,TH2,XICEM $filer $filew_sfc || exit 8

filer_prs=../WRF_PRS/$domain/$YYYY/wrfprs_$domain\_$YYYY\-$MON-??_??_00_00
filew_prs=$dirw2/wrfprs_$domain\_$run_name\_$DT\h\_$YYYY$MON\.nc
ncrcat -O $filer_prs $filew_prs || exit 8

filer_zlev=../WRF_ZLEV/$domain/$YYYY/wrfzlev_$domain\_$YYYY\-$MM\-$DD\_??_00_00
filew_zlev=$dirw3/wrfzlev_$domain\_$run_name\_$DT\h\_$YYYY$MON\.nc
ncrcat -O -v U_ZL,V_ZL,T_ZL,Q_ZL,RH_ZL $filer_zlev $filew_zlev || exit 8

MON=`expr $MON + 0`
MON=`expr $MON + 1`
done # MON

# daily averaging
tindx=$YYYY-$MM\-$DD\_$HH
while [ "$tindx" !=  "$last_time" ]; do
echo $tindx

filer=../WRF_Out2/$YYYY/wrfout_$domain\_$YYYY\-$MM\-$DD\_??_00_00
filew_sfc=$dirw1/wrfsfc_$domain\_$run_name\_1d_$tindx\.nc
ncra -O -v RAINC,RAINNC,RAINCV,RAINNCV,SST,OLR,U10,V10,SWDOWN,GLW,T2,Q2,PSFC,ALBEDO,UST,ZNT,CD,HFX,LH,PBLH,QFX,TH2,XICEM $filer $filew_sfc || exit 8

filer_prs=../WRF_PRS/$domain/$YYYY/wrfprs_$domain\_$YYYY\-$MM-$DD\_??_00_00
filew_prs=$dirw2/wrfprs_$domain\_$run_name\_1d_$tindx\.nc
ncra -O $filer_prs $filew_prs || exit 8

filer_zlev=../WRF_ZLEV/$domain/$YYYY/wrfzlev_$domain\_$YYYY\-$MM\-$DD\_??_00_00
filew_zlev=$dirw3/wrfzlev_$domain\_$run_name\_1d_$tindx\.nc
ncra -O -v U_ZL,V_ZL,T_ZL,Q_ZL,RH_ZL $filer_zlev $filew_zlev || exit 8

incdte $YYYY $MM $DD $HH 24 >& incdte.$$ # increase by day
read YYYY MM DD HH < incdte.$$; rm incdte.$$

tindx=$YYYY\-$MM\-$DD\_00
done # tindx

# concatenate each month
MON=$MONS
while [ $MON -le $MONE ]; do
MON=`expr $MON + 0`
if [ $MON -lt 10 ]; then
MON=0$MON
fi
ncrcat -O $dirw1/wrfsfc_$domain\_$run_name\_1d_$YYYYS-$MON-??_00.nc $dirw1/wrfsfc_$domain\_$run_name\_1d_$YYYYS$MON\.nc || exit 8
ncrcat -O $dirw2/wrfprs_$domain\_$run_name\_1d_$YYYYS-$MON-??_00.nc $dirw2/wrfprs_$domain\_$run_name\_1d_$YYYYS$MON\.nc || exit 8
ncrcat -O $dirw3/wrfzlev_$domain\_$run_name\_1d_$YYYYS-$MON-??_00.nc $dirw3/wrfzlev_$domain\_$run_name\_1d_$YYYYS$MON\.nc || exit 8

# monthly averaging
ncra -O $dirw1/wrfsfc_$domain\_$run_name\_1d_$YYYYS$MON\.nc  $dirw1/wrfsfc_$domain\_$run_name\_1m_$YYYYS$MON\.nc || exit 8
ncra -O $dirw2/wrfprs_$domain\_$run_name\_1d_$YYYYS$MON\.nc $dirw2/wrfprs_$domain\_$run_name\_1m_$YYYYS$MON\.nc || exit 8
ncra -O $dirw3/wrfzlev_$domain\_$run_name\_1d_$YYYYS$MON\.nc  $dirw3/wrfzlev_$domain\_$run_name\_1m_$YYYYS$MON\.nc || exit 8

# cleanup
rm $dirw1/wrfsfc_$domain\_$run_name\_1d_$YYYYS-$MON-??_00.nc
rm $dirw2/wrfprs_$domain\_$run_name\_1d_$YYYYS-$MON-??_00.nc 
rm $dirw3/wrfzlev_$domain\_$run_name\_1d_$YYYYS-$MON-??_00.nc

MON=`expr $MON + 0`
MON=`expr $MON + 1`
done # MON
done #domain

echo "DONE"
