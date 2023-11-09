#!/bin/sh
set -ax
# bulk version of WRF2ROMS
NHour=$1
MHour=$2
JD=$3

YYYYs=`echo $4 | cut -d':' -f1`
MMs=`echo $4 | cut -d':' -f2`
DDs=`echo $4 | cut -d':' -f3`
HHs=`echo $4 | cut -d':' -f4`

echo "********************************"
echo "WRF2ROMS (bulk version) Starting"
#U10 V10 SWDOWN GLW T2 Q2 PSFC ALBEDO RAINC RAINNC RAINSH

echo "********************************"
# -F uses Fortran (1-based, not 0) indexing convention; try to use this option always to avoid confusion

        # wrfout should have two timesteps 
        ncra -F -O -v SST,OLR,U10,V10,SWDOWN,GLW,T2,Q2,PSFC,ALBEDO,UST,HFX,LH,PBLH,QFX,GSW,TH2 -d Time,2,2,1 $WRF_Output2_Dir/wrfout_d01_$YYYYs-$MMs-$DDs\_$HHs\_00\_00 $WRF_Output_Dir/WRF_Hour$NHour.nc || exit 8

        # 1. take the diff: R(2)-R(1) gives mm for CF period; e.g., for CF=6; mm for 6hr
        # read rain from 2nd time step until the maximum (,,) at every 2 points -> result; read 2nd timestep
        ncrcat -F -O -v RAINC,RAINNC,RAINSH -d Time,2,2,2 $WRF_Output2_Dir/wrfout_d01_$YYYYs-$MMs-$DDs\_$HHs\_00\_00 $WRF_Output2_Dir/rain_d01_Hour$NHour\_1 || exit 8
        # read rain from 1st time step until the maximum (,,) at every 2 points -> result; read 1st timestep
        ncrcat -F -O -v RAINC,RAINNC,RAINSH -d Time,1,2,2 $WRF_Output2_Dir/wrfout_d01_$YYYYs-$MMs-$DDs\_$HHs\_00\_00 $WRF_Output2_Dir/rain_d01_Hour$NHour\_2 || exit 8
        # difference R(2)-R(1) mm for 6hr if CF=6
        ncbo -O --op_typ=- $WRF_Output2_Dir/rain_d01_Hour$NHour\_1 $WRF_Output2_Dir/rain_d01_Hour$NHour\_2 $WRF_Output2_Dir/rain_d01_Hour$NHour || exit 8
        rm $WRF_Output2_Dir/rain_d01_Hour$NHour\_1 $WRF_Output2_Dir/rain_d01_Hour$NHour\_2 2>/dev/null

        # append RAINC/RAINNC/RAINSH to WRF_Hour?.nc file
        ncks -A $WRF_Output2_Dir/rain_d01_Hour$NHour $WRF_Output_Dir/WRF_Hour$NHour.nc
        rm $WRF_Output2_Dir/rain_d01_Hour$NHour\_1 $WRF_Output2_Dir/rain_d01_Hour$NHour\_2 $WRF_Output2_Dir/rain_d01_Hour$NHour 2>/dev/null

#Read vars only 3D (time,lat,lon)
for VAR in U10 V10 SWDOWN GLW T2 Q2 PSFC ALBEDO RAINC RAINNC RAINSH
 do
    rm -f fort.* 2>/dev/null
    ln -fs $Couple_Lib_grids_WRF_Dir/$Nameit_WRF-nxnyr.dat fort.11
    echo $VAR > fort.12
    echo 1 > fort.13
	    	ln -fs $WRF_Output_Dir/WRF_Hour$NHour.nc fort.21
    $Couple_Lib_exec_coupler_Dir/read_ncvar.x || exit 8
    mv fort.51 $Couple_Data_tempo_files_Dir/$Nameit_WRF.$VAR.workin.dat || exit 8
done

rm -f $Couple_Run_Dir/fort.* 2>/dev/null
rm $Couple_Run_Dir/ftp.* 2>/dev/null
rm $Couple_Run_Dir/incdte* 2>/dev/null

 echo "NHour:$NHour end: WRF --> ROMS"

echo "********************************"
echo "WRF2ROMS (bulk version) Done...."
echo "********************************"
