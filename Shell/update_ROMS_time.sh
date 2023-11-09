#!/bin/sh
set -ax
# update time (julian date + hours) in ini, bry, and frc

# time varaible names different depending on what ocean preprocessing script is used.
# for mercator data with coawst package;
# ini: time
# bry: zeta_time, v2d_time, v3d_time. salt_time, temp_time
# frc is the same (as it is genearated by the coupler, not the preprocessing)

# 1. inifile
echo $JD > fort.13
echo $NHour > fort.14
echo time  > fort.12
ln -fsv $Couple_Data_ROMS_Dir/ocean_ini.nc fort.21 || exit 8
$Couple_Lib_exec_coupler_Dir/update_init_time3.x || exit 8
rm fort.?? 2>/dev/null

# 2. bryfile
echo $JD > fort.13
echo $NHour > fort.14
ln -fs $bryfile fort.21
for time_name in zeta_time v2d_time v3d_time salt_time temp_time
  do
    echo $time_name > fort.12
$Couple_Lib_exec_coupler_Dir/update_bry_time3.x || exit 8
rm fort.12 2>/dev/null
done
rm fort.?? 2>/dev/null

# #3. frc
echo $JD > fort.13
echo $NHour > fort.14
ln -fs $frcfile fort.21
#for time_name in srf_time wind_time pair_time qair_time tair_time rain_time lrf_time
for var_time in srf_time wind_time pair_time qair_time tair_time rain_time lrf_time shf_time swf_time sms_time srf_time
  do
    echo $time_name > fort.12
$Couple_Lib_exec_coupler_Dir/update_forc_time3.x || exit 8
rm fort.12 2>/dev/null
done
rm fort.?? 2>/dev/null
