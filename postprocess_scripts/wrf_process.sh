#!/bin/bash
#SBATCH --job-name=r01wrf# Job name
##SBATCH --mail-type=all
##SBATCH --mail-user=hseo@whoi.edu
##SBATCH --ntasks=24                  # Number of MPI ranks
##SBATCH --cpus-per-task=1            # Number of cores per MPI rank
#SBATCH --nodes=1                    # Number of nodes
#SBATCH -n 1
#SBATCH --ntasks-per-node=36         # How many tasks on each node
##SBATCH --distribution=cyclic:cyclic # Distribute tasks cyclically on nodes and sockets
#SBATCH --mem=192000          # Memory per processor
#SBATCH --time=24:00:00              # Time limit hrs:min:sec
##SBATCH --output=scoar_%j.log     # Standard output and error log
#pwd; hostname; date
#SBATCH -p scavenger
#SBATCH --qos=scavenger
set -ax
export run_name=wfp_r01; echo $run_name
export DT=1

for domain in d02 #d01
do

YYYYS=2017
MMS=12
DDS=01
HHS=00

YYYYE=2017
MME=12
DDE=31
HHE=00

wrf_sfc=yes
wrf_prs=no
wrf_zlev=no

do_subdaily=yes
do_daily=yes
do_monthly=yes

# variable for wrfsfc
var1=RAINC,RAINNC,RAINCV,RAINNCV,SST,OLR,U10,V10,SWDOWN,GLW,T2,Q2,PSFC,ALBEDO,UST,ZNT,CD,HFX,LH,PBLH,QFX,TH2,XICEM,RMOL

# variable for wrfzlev
var3=U_ZL,V_ZL,T_ZL,RH_ZL,GHT_ZL,S_ZL,TD_ZL,Q_ZL,U10,V10,T2,Q2

######### 
YYYY=$YYYYS
MM=$MMS
DD=$DDS
HH=$HHS

last_time=$YYYYE$MME$DDE$HHE
tindx=$YYYY$MM$DD$HH
	tindx2=$YYYY-$MM-$DD\_$HH

# sub-daily: concatenate everything in the same month regardless of the end date: need to fix this
while [ $tindx -le $last_time ]; do
echo $tindx

if [ $wrf_sfc = yes ]; then
dirw1=./$YYYY/wrfsfc; mkdir -p $dirw1
	if [ $do_subdaily = yes -a $DD -eq 01 -a $HH -eq 00 ]; then
# sub-daily 
filer=../WRF_Out2/$domain/$YYYY/wrfout_$domain\_$YYYY\-$MM-??_??_00_00
filew_sfc=$dirw1/wrfsfc_$domain\_$run_name\_$DT\h\_$YYYY$MM\.nc
ncrcat -O -v $var1 $filer $filew_sfc || exit 8
	fi
# daily
	if [ $do_daily = yes ]; then
filer=../WRF_Out2/$domain/$YYYY/wrfout_$domain\_$YYYY\-$MM\-$DD\_00_00_00
filew_sfc=$dirw1/wrfsfc_$domain\_$run_name\_1d_$tindx2\.nc
ncra -O -v $var1 $filer $filew_sfc || exit 8
	fi
fi

if [ $wrf_prs = yes ]; then
# sub-daily
dirw2=./$YYYY/wrfprs; mkdir -p $dirw2
        if [ $do_subdaily = yes -a $DD -eq 01 -a $HH -eq 00 ]; then
filer_prs=../WRF_PRS/$domain/$YYYY/wrfprs_$domain\_$YYYY\-$MM-??_??_00_00
filew_prs=$dirw2/wrfprs_$domain\_$run_name\_$DT\h\_$YYYY$MM\.nc
ncrcat -O $filer_prs $filew_prs || exit 8
	fi
# daily
        if [ $do_daily = yes ]; then
filer_prs=../WRF_PRS/$domain/$YYYY/wrfprs_$domain\_$YYYY\-$MM-$DD\_??_00_00
filew_prs=$dirw2/wrfprs_$domain\_$run_name\_1d_$tindx2\.nc
ncra -O $filer_prs $filew_prs || exit 8
	fi
fi

if [ $wrf_zlev = yes ]; then
dirw3=./$YYYY/wrfzlev; mkdir -p $dirw3
        if [ $do_subdaily = yes  -a $DD -eq 01 -a $HH -eq 00 ]; then
filer_zlev=../WRF_ZLEV/$domain/$YYYY/wrfzlev_$domain\_$YYYY\-$MM\-??_??_00_00
filew_zlev=$dirw3/wrfzlev_$domain\_$run_name\_$DT\h\_$YYYY$MM\.nc
ncrcat -O -v $var3 $filer_zlev $filew_zlev || exit 8
	fi
	if [ $do_daily = yes ]; then
filer_zlev=../WRF_ZLEV/$domain/$YYYY/wrfzlev_$domain\_$YYYY\-$MM\-$DD\_??_00_00
filew_zlev=$dirw3/wrfzlev_$domain\_$run_name\_1d_$tindx2\.nc
ncra -O -v $var3 $filer_zlev $filew_zlev || exit 8
	fi
fi

incdte $YYYY $MM $DD $HH 24 >& incdte.$$ # increase by day
read YYYY MM DD HH < incdte.$$; rm incdte.$$

#tindx=$YYYY\-$MM\-$DD\_00
tindx=$YYYY$MM$DD\00
tindx2=$YYYY-$MM-$DD\_00
done # tindx

#
YYYY=$YYYYS
MM=$MMS
DD=$DDS
HH=$HHS
tindx=$YYYY$MM
last_time=$YYYYE$MME

#while [ "$tindx" !=  "$last_time" ]; do
while [ $tindx -le $last_time ]; do
if [ $MM -eq 1 -o $MM -eq 3 -o $MM -eq 5 -o $MM -eq 7 -o $MM -eq 8 -o $MM -eq 10 -o $MM -eq 12 ]; then
nday=31
elif [ $MM -eq 4 -o $MM -eq 6 -o $MM -eq 9 -o $MM -eq 11 ]; then
nday=30
else
leap=`expr $YYYY % 4`
	if [ $leap -eq 0 ]; then
	nday=29 # leap year
	else
	nday=28
	fi #leap
fi # $MM
if [ $do_daily = yes ]; then
# concatenate daily files into one per month
	if [ $wrf_sfc = yes ]; then
	ncrcat -O $dirw1/wrfsfc_$domain\_$run_name\_1d_$YYYY-$MM-??_00.nc $dirw1/wrfsfc_$domain\_$run_name\_1d_$YYYY$MM\.nc || exit 8
	fi
	if [ $wrf_prs = yes ]; then
	ncrcat -O $dirw2/wrfprs_$domain\_$run_name\_1d_$YYYY-$MM-??_00.nc $dirw2/wrfprs_$domain\_$run_name\_1d_$YYYY$MM\.nc || exit 8
	fi
	if [ $wrf_zlev = yes ]; then
	ncrcat -O $dirw3/wrfzlev_$domain\_$run_name\_1d_$YYYY-$MM-??_00.nc $dirw3/wrfzlev_$domain\_$run_name\_1d_$YYYY$MM\.nc || exit 8
	fi
fi

# if monthly, average to monthly data
if [ $do_monthly = yes ]; then
	if [ $wrf_sfc = yes ]; then
	ncra -O $dirw1/wrfsfc_$domain\_$run_name\_1d_$YYYY-$MM-??_??.nc  $dirw1/wrfsfc_$domain\_$run_name\_1m_$YYYY$MM\.nc || exit 8
	fi
	if [ $wrf_prs = yes ]; then
	ncra -O $dirw2/wrfprs_$domain\_$run_name\_1d_$YYYY-$MM-??_??.nc $dirw2/wrfprs_$domain\_$run_name\_1m_$YYYY$MM\.nc || exit 8
	fi
	if [ $wrf_zlev = yes ]; then
	ncra -O $dirw3/wrfzlev_$domain\_$run_name\_1d_$YYYY-$MM-??_??.nc  $dirw3/wrfzlev_$domain\_$run_name\_1m_$YYYY$MM\.nc || exit 8
	fi
fi
incr=`expr $nday \* 24`
echo $YYYY $MM $DD $HH $incr
incdte $YYYY $MM $DD $HH $incr >& incdte.$$ # increase by day
read YYYY MM DD HH < incdte.$$; rm incdte.$$
tindx=$YYYY$MM

done #tindx 

# clean up
if [ $wrf_sfc = yes ]; then
rm $dirw1/wrfsfc_$domain\_$run_name\_1d_????-??-??_00.nc
fi
if [ $wrf_prs = yes ]; then
rm $dirw2/wrfprs_$domain\_$run_name\_1d_????-??-??_00.nc 
fi
if [ $wrf_zlev = yes ]; then
rm $dirw3/wrfzlev_$domain\_$run_name\_1d_????-??-??_00.nc
fi

done #domain

echo "DONE"
