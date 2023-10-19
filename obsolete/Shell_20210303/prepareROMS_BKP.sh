#!/bin/sh
set -ax
cd $Couple_Data_ROMS_Dir || exit 8

ROMS_BCFile=$1
JD=$2
if [ $CF -ge 24 ]; then
NDay=$3
elif [ $CF -lt 24 ]; then
NHour=$3
fi
YYYYi=$4
NLOOP=$5

rm $Couple_Data_ROMS_Dir/ocean_bry.nc 2>/dev/null

echo "ROMS_BCFile = $ROMS_BCFile"

 if [ $ROMS_BCFile = SODA -a $ROMS_BCFile_Freq = 1mon ]; then
 	echo $ROMS_BCFile
  	tindx=`expr $JD \/ 30 + 1`
  	if [ $tindx -gt 12 ]; then
        	tindx=12
   	fi
	if [ $tindx -lt 10 ]; then
	tindx=0$tindx
	fi
   	echo "time index ==> $tindx ***"
   	tindxm=`expr $tindx - 1`
        bryfile=$ROMS_BCFile_Name\_$YYYYi$tindx.nc
        ifile_bry=$ROMS_BCFile_Dir/$YYYYi/$bryfile

 elif [ $ROMS_BCFile = SODA -a $ROMS_BCFile_Freq = 1day ]; then
        echo $ROMS_BCFile
        tindx=$JD
        echo "time index ==> $tindx ***"
        bryfile=$ROMS_BCFile_Name\_$YYYYi\_$tindx.nc
        ifile_bry=$ROMS_BCFile_Dir/$YYYYi/$bryfile

 elif [ $ROMS_BCFile = HYCOM ]; then
        echo $ROMS_BCFile
        tindx=$JD
        echo "time index ==> $tindx ***"
        tindxm=`expr $tindx - 1`
        bryfile=$ROMS_BCFile_Name\_$YYYYi\_$tindx.nc
        ifile_bry=$ROMS_BCFile_Dir/$YYYYi/$bryfile

 elif [ $ROMS_BCFile = ECCO_10day_clim ]; then
        echo $ROMS_BCFile
        tindx=`expr $JD \/ 10 + 1`
        if [ $tindx -gt 73 ]; then
                tindx=73
        fi
        echo "time index ==> $tindx ***"
        tindxm=`expr $tindx - 1`
        bryfile=$ROMS_BCFile_Name\_$tindx.nc
        ifile_bry=$ROMS_BCFile_Dir/$bryfile
 fi

 echo " bryfile = $ifile_bry"

# obtain bry file
   ofile=$Couple_Data_ROMS_Dir/$bryfile
   $Couple_Lib_utils_Dir/fetchfile $ifile_bry $Couple_Data_ROMS_Dir/ocean_bry.nc ln || exit 8
   #if [ ! -s $Couple_Data_ROMS_Dir/$bryfile  ]; then
   #  exit 8
  # fi

# update initial file
# identical both for  daily and 3hrly coupling
# 1. if NHour=3 or NDay=1
#   use the specified ICFILE from main script
# 2. if NHour>3 or NDay>1
#   use previous time step ROMS run as an IC
#
rm -f fort.* 2>/dev/null
 if [ $NLOOP -eq 1 ]; then
    	if [ ! -s $ROMS_ICFile ]; then
        echo "ERROR: missing $ROMS_ICFile !!!!!"
        exit 8
    	fi
   	echo "your Initial File is  $ROMS_ICFile "
   	ln -fs $ROMS_ICFile fort.14
    	echo 1 > fort.13
  else  #NLOOP>1
   	NHourm=`expr $NHour - $CF`
   	echo "your Initial File is" 

        if [ $ROMS_Avg = yes ]; then
   	echo "$ROMS_Avg_Dir/avg_Hour$NHourm.nc"
    	if [ ! -s $ROMS_Avg_Dir/avg_Hour$NHourm.nc ]; then
        echo "ERROR: missing initial file"
        echo "$ROMS_Avg_Dir/avg_Hour$NHourm.nc"
        exit  8
    	fi
    	ln -fs $ROMS_Avg_Dir/avg_Hour$NHourm.nc fort.14 || exit 8
	echo ROMS_Avg_Dir/avg_Hour$NHourm.nc

        else # OR His
        echo "$ROMS_His_Dir/his_Hour$NHourm.nc"
        if [ ! -s $ROMS_His_Dir/his_Hour$NHourm.nc ]; then
        echo "ERROR: missing initial file"
        echo "$ROMS_His_Dir/his_Hour$NHourm.nc"
        exit  8
        fi
        ln -fs $ROMS_His_Dir/his_Hour$NHourm.nc fort.14 || exit 8
	echo ROMS_His_Dir/his_Hour$NHourm.nc
	fi
    	echo 1 > fort.13
  fi

# copy initial template file to ocean_ini.nc for initial time only
if [ $NLOOP -eq 1 ]; then
cp $Couple_Lib_template_Dir/$gridname-init.nc $Couple_Data_ROMS_Dir/ocean_ini.nc || exit 8
fi

echo "linking ocean_ini.nc"
ln -fsv $Couple_Data_ROMS_Dir/ocean_ini.nc fort.15 || exit 8

# for 4d variable
echo $nd > fort.16

echo "inserting 4d variables into ini.nc"
for var in temp salt u v
do
#echo "variable=  $var "
if [ $var = u ]; then
  ln -fs $Couple_Lib_grids_ROMS_Dir/$Nameit_ROMS-nxnyu.dat fort.11
  ln -fs $Couple_Lib_auxfiles_Dir/u.txt fort.12
elif [ $var = v ]; then
  ln -fs $Couple_Lib_grids_ROMS_Dir/$Nameit_ROMS-nxnyv.dat fort.11
  ln -fs $Couple_Lib_auxfiles_Dir/v.txt fort.12
else
  ln -fs $Couple_Lib_grids_ROMS_Dir/$Nameit_ROMS-nxnyr.dat fort.11
  ln -fs $Couple_Lib_auxfiles_Dir/$var.txt fort.12
fi
$Couple_Lib_exec_coupler_Dir/update_init4D.x || exit 8
done

echo "inserting 3d variables into ini.nc"
# for 3d variable
for var in zeta ubar vbar
do
#echo "variable=  $var "
if [ $var = ubar ]; then
  ln -fs $Couple_Lib_grids_ROMS_Dir/$Nameit_ROMS-nxnyu.dat fort.11
  ln -fs $Couple_Lib_auxfiles_Dir/ubar.txt fort.12
elif [ $var = vbar ]; then
  ln -fs $Couple_Lib_grids_ROMS_Dir/$Nameit_ROMS-nxnyv.dat fort.11
  ln -fs $Couple_Lib_auxfiles_Dir/vbar.txt fort.12
else
  ln -fs $Couple_Lib_grids_ROMS_Dir/$Nameit_ROMS-nxnyr.dat fort.11
  ln -fs $Couple_Lib_auxfiles_Dir/$var.txt fort.12
fi
$Couple_Lib_exec_coupler_Dir/update_init3D.x || exit 8
done

### originally tested : 11/20/2009 
### revised tested : 06/16/2017
### update time variables of the initial file with juland date 
#echo "update time variables of the initial file with juliand date"
## initial file
#ln -fsv $Couple_Data_ROMS_Dir/ocean_ini.nc fort.15 || exit 8
#rm fort.* 2>/dev/null
#    ln -fs $Couple_Data_ROMS_Dir/ROMS_ForcingGeneral-$gridname.nc fort.11
#var_time=ocean_time
#JDm=`expr $JD - 1 `
#itime=`expr $JDm * 86400`
#echo $var_time " --> " $JDm
#  echo $var_time > fort.12
#  echo $itime > fort.13
#  $Couple_Lib_exec_coupler_Dir/update_forc_time.x || exit 8
#fi

rm fort.* 2>/dev/null
rm -f $Couple_Data_ROMS_Dir/ftp* 2>/dev/null
