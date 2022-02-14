#!/bin/bash
set -ax
CF=3
run_name=norus_wave_z0cap
year=2018
HourPrev=0 

for file0 in forc qck avg
do

comm1=ncrcat
comm2=ncra

if [ $file0 = avg ]; then
file1=Avg
vlist=("temp" "salt" "u_eastward" "v_northward" "w" "shflux" "ssflux" "swrad")

elif [ $file0 = qck ]; then
file1=Qck
vlist=("salt_sur" "zeta" "vbar_northward" " v_sur_northward" "ubar_eastward" "u_sur_eastward" "temp_sur" "swrad" "svstr" "sustr" "ssflux" "shflux")

elif [ $file0 = forc ]; then
file1=Forc
# nobulk
vlist=("sustr" "svstr" "shflux" "swflux" "swrad")
# bulk
#$vlist=("Uwind" "Vwind" "Pair" "Qair" "Tair" "swrad" "rain" "lwrad_down" "Uwind_abs" " Vwind_abs")
comm1=ncecat
comm2=ncea
fi
#echo ${vlist[@]}

diri=../$file1/$year/
diro=./$file0/$year
mkdir -p $diro

#day0=335 # 
mm=12
mone=12

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

ts=`expr \( $day \- $day0 \) \* 24 + $CF + $HourPrev`
te=`expr $ts \+ 24 \- $CF`

tt=$ts
	nn=1
filer=()
	while [ $tt -le $te ]; do
	filer[$nn]=$diri/$file0\_Hour$tt.nc
	nn=`expr $nn + 1`
	tt=`expr $tt + $CF`
	done

for vvar in ${vlist[@]}
	do
	echo "$vvar mon=$mm, day=$day time= $ts ~ $te"
$comm1 -O -v $vvar ${filer[*]} $diro/$file0\_$run_name\_$CF\h_$vvar\_$year\_day$day\.nc || exit 8
$comm2 -O $diro/$file0\_$run_name\_$CF\h_$vvar\_$year\_day$day.nc $diro/$file0\_$run_name\_1d_$vvar\_$year\_day$day\.nc|| exit 8
done #vvar

day=`expr $day + 0`
day=`expr $day + 1`
done

# all into one file
# for some reason, zeta and h are included in all files; i cannot removed them (even with ncks -x -v command)
for vvar in ${vlist[@]}
do
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
ncrcat -O -n $numd,3,1 -p $diro $file0\_$run_name\_$CF\h_$vvar\_$year\_day$day1\.nc  $diro/$file0\_$run_name\_$CF\h_$vvar\_$year$mm\.nc
ncra   -O -n $numd,3,1 -p $diro $file0\_$run_name\_1d_$vvar\_$year\_day$day1\.nc $diro/$file0\_$run_name\_1d_$vvar\_$year$mm\.nc

# monthly averaging
ncra -O $diro/$file0\_$run_name\_1d_$vvar\_$year$mm\.nc $diro/$file0\_$run_name\_1m_$vvar\_$year$mm\.nc

done

# clean up
rm $diro/$file0\_$run_name\_$CF\h_$vvar\_$year\_day*.nc
rm $diro/$file0\_$run_name\_1d_$vvar\_$year\_day*.nc

mm=`expr $mm + 0`
mm=`expr $mm + 1`
done #mm

done
