#!/bin/bash
set -ax
CF=3
run_name=norus_wave_z0cap
year=2019
#HourPrev=8016 # #2018 11 30
HourPrev=0
HourPrev=744

diri=../Outnc/$year/
diro=./$year
mkdir -p $diro

mm=1
mone=2

while [ $mm -le $mone ]; do
if [ $mm -eq 1 ]; then
        days=1; daye=31 
elif [ $mm -eq 2 ]; then
        days=32; daye=59
elif [ $mm -eq 3 ]; then
        days=60; daye=90
elif [ $mm -eq 4 ]; then
        days=91; daye=120
elif [ $mm -eq 5 ]; then
        days=121; daye=151
elif [ $mm -eq 6 ]; then
        days=152; daye=181
elif [ $mm -eq 7 ]; then
        days=182; daye=212
elif [ $mm -eq 8 ]; then
        days=213; daye=243
elif [ $mm -eq 9 ]; then
        days=244; daye=273
elif [ $mm -eq 10  ]; then
        days=274; daye=304;
elif [ $mm -eq 11  ]; then
        days=305; daye=334;
elif [ $mm -eq 12 ]; then
        days=335; daye=365;
fi

# leap year 
leap_year=`expr $year \% 4`
if [ $leap_year -eq 0 ]; then
        echo $year is a leap year...
        if [ $mm -eq 2 ]; then
        days=32; daye=60
        elif [ $mm -gt 2 ]; then
        days=`expr $days + 1`
        daye=`expr $daye + 1`
        else
        echo ""
        fi
echo "***"
echo "year=$year mon=$mm days=$days daye=$daye leap year"
echo "***"
fi

numd=`expr $daye \- $days \+ 1`
numh=`expr $numd \* 24 `

day=$days
day0=$days
while [ $day -le $daye ]; do

if [ $day -lt 10 ]; then
        day=00$day
fi
if [ $day -ge 10 -a $day -lt 100 ]; then
	day=0$day
fi

# 3-27
#ts=`expr \( $day \- $day0 \) \* 24 + $CF + $HourPrev`
#te=`expr $ts \+ 24 \- $CF`
# 0 ~ 24
ts=`expr \( $day \- $day0 \) \* 24 + $HourPrev`
te=`expr $ts \+ 24 \- $CF`

tt=$ts
nn=1
	ww3_filer=()
while [ $tt -le $te ]; do
	ww3_filer[$nn]=$diri/ww3.*_Hour$tt.nc
	nn=`expr $nn + 1`
	tt=`expr $tt + $CF`
done

echo "mon=$mm, day=$day time= $ts ~ $te"
ncecat -O ${ww3_filer[*]} $diro/ww3_$run_name\_$CF\h_$year\_day$day\.nc || exit 8
ncra -O $diro/ww3_$run_name\_$CF\h_$year\_day$day\.nc $diro/ww3_$run_name\_1d_$year\_day$day\.nc|| exit 8

day=`expr $day + 0`
day=`expr $day + 1`
done

# combine into one file
day1=$days
if [ $days -lt 10 ]; then
        day1=00$days
fi
if [ $days -ge 10 -a $days -lt 100 ]; then
        day1=0$days
fi

mm=`expr $mm + 0`
if [ $mm -lt 10 ]; then
        mm=0$mm
fi
ncrcat -O -n $numd,3,1 -p $diro  ww3_$run_name\_$CF\h_$year\_day$day1\.nc  $diro/ww3_$run_name\_$CF\h_$year$mm\.nc
ncrcat -O -n $numd,3,1 -p $diro  ww3_$run_name\_1d_$year\_day$day1\.nc $diro/ww3_$run_name\_1d_$year$mm\.nc

# monthly averating
ncra -O $diro/ww3_$run_name\_1d_$year$mm\.nc $diro/ww3_$run_name\_1m_$year$mm\.nc

# clean up
rm $diro/ww3_$run_name\_$CF\h_$year\_day*.nc      
rm $diro/ww3_$run_name\_1d_$year\_day*.nc

mm=`expr $mm + 0`
mm=`expr $mm + 1`
done #mm

