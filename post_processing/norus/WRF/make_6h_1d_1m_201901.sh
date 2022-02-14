#!/bin/sh
set -ax
export run_name=norus_wave_z0cap
echo $run_name
export DT=3

for domain in d01
do

YYYY=2019
MM=01
DD=01
HH=00

YYYYS=$YYYY
MONS=$MM
MON=$MONS
MONE=2
# last time should be "one more day" after the last time-step
last_time=2019-03-01_00

####
dirw1=./$YYYY/wrfsfc
dirw2=./$YYYY/wrfprs
dirw3=./$YYYY/wrflev
mkdir -p $dirw1
mkdir -p $dirw2
mkdir -p $dirw3
ZZ=10

while [ $MON -le $MONE ]; do

MON=`expr $MON + 0`
if [ $MON -lt 10 ]; then 
MON=0$MON
fi

#just concatenate everything
filer=../WRF_Out2/wrfout_$domain\_$YYYY\-$MON-??_??_00_00
filew_sfc=$dirw1/wrfsfc_$domain\_$run_name\_$DT\h\_$YYYY$MON\.nc
ncrcat -O -v RAINC,RAINNC,RAINCV,RAINNCV,SST,OLR,U10,V10,SWDOWN,GLW,T2,Q2,PSFC,ALBEDO,UST,ZNT,CD,HFX,LH,PBLH,QFX,TH2,XICEM $filer $filew_sfc || exit 8

filer_prs=../WRF_PRS/$domain/wrfprs_$domain\_$YYYY\-$MON-??_??_00_00
filew_prs=$dirw2/wrfprs_$domain\_$run_name\_$DT\h\_$YYYY$MON\.nc
ncrcat -O $filer_prs $filew_prs || exit 8

filer=../WRF_Out2/wrfout_$domain\_$YYYY\-$MON-??_??_00_00
filew_lev=$dirw3/wrflev_$domain\_$run_name\_$DT\h\_$YYYY$MON\.nc
# lower 10 layers
ncrcat -F -O -v U,V,T,THM,QVAPOR -d bottom_top,1,$ZZ $filer $filew_lev || exit 8

MON=`expr $MON + 0`
MON=`expr $MON + 1`
done # MON

# daily averaging
tindx=$YYYY-$MM\-$DD\_$HH
while [ "$tindx" !=  "$last_time" ]; do
echo $tindx

filer=../WRF_Out2/wrfout_$domain\_$YYYY\-$MM\-$DD\_??_00_00
filew_sfc=$dirw1/wrfsfc_$domain\_$run_name\_1d_$tindx\.nc
ncra -O -v RAINC,RAINNC,RAINCV,RAINNCV,SST,OLR,U10,V10,SWDOWN,GLW,T2,Q2,PSFC,ALBEDO,UST,ZNT,CD,HFX,LH,PBLH,QFX,TH2,XICEM $filer $filew_sfc || exit 8

filer_prs=../WRF_PRS/$domain/wrfprs_$domain\_$YYYY\-$MM-$DD\_??_00_00
filew_prs=$dirw2/wrfprs_$domain\_$run_name\_1d_$tindx\.nc
ncra -O $filer_prs $filew_prs || exit 8

filer=../WRF_Out2/wrfout_$domain\_$YYYY\-$MM\-$DD\_??_00_00
filew_lev=$dirw3/wrflev_$domain\_$run_name\_1d_$tindx\.nc
ncra -F -O -v U,V,T,THM,QVAPOR -d bottom_top,1,$ZZ $filer $filew_lev || exit 8

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
ncrcat -O $dirw1/wrfsfc_$domain\_$run_name\_1d_$YYYYS-$MON-??_00.nc $dirw1/wrfsfc_$domain\_$run_name\_1d_$YYYYS$MON\.nc
ncrcat -O $dirw2/wrfprs_$domain\_$run_name\_1d_$YYYYS-$MON-??_00.nc $dirw2/wrfprs_$domain\_$run_name\_1d_$YYYYS$MON\.nc
ncrcat -O $dirw3/wrflev_$domain\_$run_name\_1d_$YYYYS-$MON-??_00.nc $dirw3/wrflev_$domain\_$run_name\_1d_$YYYYS$MON\.nc

# monthly averaging
ncra -O $dirw1/wrfsfc_$domain\_$run_name\_1d_$YYYYS$MON\.nc  $dirw1/wrfsfc_$domain\_$run_name\_1m_$YYYYS$MON\.nc
ncra -O $dirw2/wrfprs_$domain\_$run_name\_1d_$YYYYS$MON\.nc $dirw2/wrfprs_$domain\_$run_name\_1m_$YYYYS$MON\.nc
ncra -O $dirw3/wrflev_$domain\_$run_name\_1d_$YYYYS$MON\.nc  $dirw3/wrflev_$domain\_$run_name\_1m_$YYYYS$MON\.nc

# cleanup
rm $dirw1/wrfsfc_$domain\_$run_name\_1d_$YYYYS-$MON-??_00.nc
rm $dirw2/wrfprs_$domain\_$run_name\_1d_$YYYYS-$MON-??_00.nc
rm $dirw3/wrflev_$domain\_$run_name\_1d_$YYYYS-$MON-??_00.nc

MON=`expr $MON + 0`
MON=`expr $MON + 1`
done # MON
done #domain

echo "DONE"
