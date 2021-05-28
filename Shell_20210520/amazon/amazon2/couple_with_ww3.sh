#!/bin/sh
set -ax
cd $Couple_Run_Dir || exit 8

YYYYS=$YYYYS
MMS=$MMS
DDS=$DDS
HHS=$HHS

if [ $RESTART = no ]; then
YYYYi=$YYYYS
MMi=$MMS
DDi=$DDS
HHi=$HHS
NDay=1

	NHour=$CF

# NUMBER OF DAYS
$Couple_Lib_utils_Dir/inchour $YYYYS $MMS $DDS $HHS $YYYYE $MME $DDE $HHE > inchour$$ || exit 8
read FHOUR < inchour$$ ; rm inchour$$
NUMDAY=`expr $FHOUR \/ 24 `
echo "Number of Days From Starting Date To Ending Date: $NUMDAY"

elif [ $RESTART = yes ]; then
 	RestartNDay=`expr $LastNHour \/ 24`
 	RestartNHour=$LastNHour
 	RestartNHour2=`expr $LastNHour - $CF`
	# RESTARTING DATE
  	$Couple_Lib_utils_Dir/incdte $YYYYS $MMS $DDS $HHS $RestartNHour2> incdte$$ || exit 8
  	read YYYYSr MMSr DDSr HHSr < incdte$$ ; rm incdte$$
  	echo $YYYYSr $MMSr $DDSr $HHSr

 NDay=$RestartNDay
 NHour=$RestartNHour
 YYYYi=$YYYYSr
 MMi=$MMSr
 DDi=$DDSr
 HHi=$HHSr
echo "****"
echo "Restarting from $YYYYi $MMi $DDi $HHi"
echo "NHour: $NHour NDay:$NDay "
echo "****"
fi #RESTART

# TOTAL NUMBER OF HOURS OF INTEGRATION
$Couple_Lib_utils_Dir/inchour $YYYYS $MMS $DDS $HHS $YYYYE $MME $DDE $HHE > inchour$$ || exit 8
read EndHOUR < inchour$$ ; rm inchour$$
echo "EndHOUR = $EndHOUR"

# TOTAL NUMBER OF DAYS OF INTEGRATION
EndDAY=`expr $EndHOUR \/ 24`
echo "Total EndDay = $EndDAY"

# Starting Loop
	NLOOP=1
	if [ $RESTART = yes ]; then
		NLOOP=`expr $LastNHour \/ $CF`
	fi

     while [ $NDay -le $EndDAY ] ; do
NDayp=`expr $NDay + 1`
NDaym=`expr $NDay - 1`
if [ $NDaym -le 0 ]; then
   NDaym=$NDay
fi
NHourp=`expr $NHour + $CF`
NHourm=`expr $NHour - $CF`

$Couple_Lib_utils_Dir/incdte $YYYYi $MMi $DDi $HHi $CF > dteout$$ || exit 8
#n : 1 $CF later than
read YYYYin MMin DDin HHin < dteout$$; rm dteout$$

$Couple_Lib_utils_Dir/incdte $YYYYi $MMi $DDi $HHi -$CF > dteout$$ || exit 8
#n : 1 $CF earlier than
read YYYYim MMim DDim HHim < dteout$$; rm dteout$$

# determine MHour
# MHour is r_pgb.ft$MHour
if [ $YYYYi -eq $YYYYS ]; then
# if current year is the same as the initial year
# MHour is identical to NHour
 MHour=$NHour
elif [ $YYYYi -gt $YYYYS ]; then
# if the current year is greater than the inital year
# calculate number of hours from inital date to
# Jan 1st 0h of the current year
# and substract that from NHour
 ENDHOUR=`$Couple_Lib_utils_Dir/inchour $YYYYS $MMS $DDS $HHS $YYYYi 01 01 00`
 MHour=`expr $NHour - $ENDHOUR`
fi
 echo "MHour =  $MHour"

## 0. Modify wrfinput_d01
# metgrid.exe is for horizontal interpolation.
# real.exe is for the vertical interpolation
# here i decide to modify wrfinput_d01 which is after the vertical interpolation..
# ideally i need to change psfc as well, but ... aug/11/2011

# prepare wrfinput wrfbdy wrflowinp
if [ $NLOOP -eq 1 ]; then
	echo "Prepared the wrfinput wrfbdy wrflowinp..."
	# link initial and bdy files (since these are not changed during the integration)
	ln -fs $WRF_Input_Data/$wrfinput_file_d01 $Model_WRF_Dir/wrfinput_d01 || exit 8
	if [ $WRF_FDDA = yes ] ; then
	ln -fs $WRF_Input_Data/$wrffdda_file_d01 $Model_WRF_Dir/wrffdda_d01 || exit 8
	fi
		if [ $WRF_Domain -eq 2 ]; then
		ln -fs $WRF_Input_Data/$wrfinput_file_d02 $Model_WRF_Dir/wrfinput_d02 || exit 8
			if [ $WRF_FDDA = yes ] ; then
		ln -fs $WRF_Input_Data/$wrffdda_file_d02 $Model_WRF_Dir/wrffdda_d02 || exit 8
			fi
		fi
	ln -fs $WRF_Input_Data/$wrfbdy_file_d01 $Model_WRF_Dir/wrfbdy_d01 || exit 8

	# cp lowinp as this will be modified during the integratoin..
     if [ $already_copied_wrflowinp != yes ]; then
        # wrflow is copied for nascar2 case
        cp $WRF_Input_Data/$wrflowinp_file_d01 $Model_WRF_Dir/wrflowinp_d01 || exit 8
 	if [ $WRF_Domain -eq 2 ]; then
    	cp $WRF_Input_Data/$wrflowinp_file_d02 $Model_WRF_Dir/wrflowinp_d02 || exit 8
 	fi
     fi

	#echo "Modify SST in lowinp at intial time NLOOP=1"
 	#$Couple_Run_Dir/edit_sst_wrfinput.sh $Model_WRF_Dir/$wrfinput_file_d01 || exit 8
fi

$Couple_Lib_utils_Dir/incdte $YYYYi $MMi $DDi $HHi $CF > dteout$$ || exit 8
read YYYYin MMin DDin HHin < dteout$$ ; rm dteout$$

# ***************************************
## 1.1 ROMS2WRF yes/no
if [ $parameter_ROMS2WRF = yes ]; then
echo "ROMS2WRF: NHour=$NHour, NLOOP=$NLOOP, $YYYYi:$MMi:$DDi:$HHi"
$Couple_Run_Dir/ROMS2WRF.sh $NHour $YYYYi:$MMi:$DDi:$HHi $YYYYin:$MMin:$DDin:$HHin $CF $NLOOP $NHourm || exit 8
else
echo " skipping ROMS2WRF"
fi

# ***************************************
# 1.2 WW32WRF yes/no
# write output time at the end of the fcst hour: YYYYin
if [ $parameter_WW32WRF = yes ]; then
# do this only when
if [ $NLOOP -gt 1 -o $WW3_spinup = yes ]; then
echo "WW32WRF: NHour=$NHour, NLOOP=$NLOOP, $YYYYi:$MMi:$DDi:$HHi ~ $YYYYin:$MMin:$DDin:$HHin"
	$Couple_Run_Dir/WW32WRF.sh $NHour $NHourm $CF $NLOOP $YYYYin:$MMin:$DDin:$HHin  || exit 8
else
	echo " skipping WW32WRF"
fi
else            
	echo " skipping WW32WRF"
fi                      

# ***************************************
## 2. WRF Run yes/no
	if [ $WRF_PRS = yes ]; then
                mkdir -p $WRF_PRS_Dir/d01
                mkdir -p $WRF_PRS_Dir/d02
	fi
  	if [ $WRF_AFWA = yes ]; then
                mkdir -p $WRF_AFWA_Dir/d01
                mkdir -p $WRF_AFWA_Dir/d02
        fi
                wrfrst_subdir_write=$YYYYin-$MMin-$DDin\_$HHin
                wrfrst_subdir_read=$YYYYi-$MMi-$DDi\_$HHi
		mkdir -p $WRF_RST_Dir/$wrfrst_subdir_write/d01
		mkdir -p $WRF_RST_Dir/$wrfrst_subdir_write/d02
                mkdir -p $WRF_RST_Dir/$wrfrst_subdir_read/d01
                mkdir -p $WRF_RST_Dir/$wrfrst_subdir_read/d02
 if [ $parameter_RunWRF = yes ]; then
    	rm $Model_WRF_Dir/wrfrst_d0?_*_00_00_???? 2>/dev/null
	if [ $NLOOP -eq 1 ] ; then
		WRF_RESTART=.false.
		write_hist_at_0h_rst=.false.
	        if [ $restart_from_coupled_spinup = yes ]; then
       	  	echo "Restart from coupled spin-up: wrfrst file is linked"
 		WRF_RESTART=.true.
		write_hist_at_0h_rst=.true.
	# this has to be changed eventually; for now (july 10, 2017), the first restart is used from earlir run with io_form_restart=2
         	ln -fs $WRF_RST_coupled_spinup/d01/wrfrst_d01_$YYYYi-$MMi-$DDi\_$HHi\_00\_00_???? $Model_WRF_Dir || exit 8
      			if [ $WRF_Domain -eq 2 ]; then
         		ln -fs $WRF_RST_coupled_spinup/d02/wrfrst_d02_$YYYYi-$MMi-$DDi\_$HHi\_00\_00_???? $Model_WRF_Dir || exit 8
               		fi
 		else
 		WRF_RESTART=.false.
		write_hist_at_0h_rst=.false.
 		fi

	#copy this if defined
        if [ $iofields_filename = yes ]; then
        cp $Couple_Lib_exec_WRF_Dir/my_file_d0?.txt $Model_WRF_Dir || exit 8
        fi

	else
	WRF_RESTART=.true.
#	write_hist_at_0h_rst=.true.
#	this is set to false; WRF produces output only at the end of the forecast and this is used for WRF2ROMS.sh : 2/5/2021
	write_hist_at_0h_rst=.false.
        ln -fs $WRF_RST_Dir/$wrfrst_subdir_read/d01/wrfrst_d01_$YYYYi-$MMi-$DDi\_$HHi\_00\_00_???? $Model_WRF_Dir || exit 8
                if [ $WRF_Domain -eq 2 ]; then
                ln -fs $WRF_RST_Dir/$wrfrst_subdir_read/d02/wrfrst_d02_$YYYYi-$MMi-$DDi\_$HHi\_00\_00_???? $Model_WRF_Dir || exit 8
                fi
	fi #NLOOP

	echo "WRF_RESTART =" $WRF_RESTART
	if [ $WRFRST_MULTI = yes ]; then
		io_form_restart=102
	else
		io_form_restart=2
	fi
	$Couple_Run_Dir/edit_WRF_namelist.sh $YYYYi:$MMi:$DDi:$HHi $WRF_RESTART $write_hist_at_0h_rst $io_form_restart
	
 	echo " *****************  Run WRF *********************"
        echo "Run WRF (NHour:$NHour $YYYYi:$MMi:$DDi:$HHi ~ $YYYYin:$MMin:$DDin:$HHin)"

	$Couple_Data_WRF_Dir/$WRF_Launch_Filename $YYYYi:$MMi:$DDi:$HHi || exit 8

#	organize the outputs
	mv $Model_WRF_Dir/wrfout_d01_$YYYYin-$MMin-$DDin\_$HHin\_00\_00 $WRF_Output2_Dir/ || exit 8
	        if [ $NLOOP  -eq 1 ]; then
                # first time, move the initial WRFOUT as well
        	mv $Model_WRF_Dir/wrfout_d01_$YYYYi-$MMi-$DDi\_$HHi\_00\_00 $WRF_Output2_Dir/ || exit 8
                fi

	mv $Model_WRF_Dir/wrfrst_d01_$YYYYin-$MMin-$DDin\_$HHin\_00\_00_???? $WRF_RST_Dir/$wrfrst_subdir_write/d01 || exit 8

	if [ $WRF_PRS = yes ]; then
	mv $Model_WRF_Dir/wrfprs_d01_$YYYYin-$MMin-$DDin\_$HHin\_00\_00 $WRF_PRS_Dir/d01 || exit 8
	      if [ $NLOOP  -eq 1 ]; then
              # first time, move the initial WRFPRS as well
	      mv $Model_WRF_Dir/wrfprs_d01_$YYYYi-$MMi-$DDi\_$HHi\_00\_00 $WRF_PRS_Dir/d01 || exit 8
              else
      	      rm $Model_WRF_Dir/wrfprs_d01_$YYYYi-$MMi-$DDi\_$HHi\_00\_00 || exit 8
              fi
	fi

	if [ $WRF_AFWA = yes ]; then 
	# AFWA writes only beginning of fcst...
	mv $Model_WRF_Dir/afwa_d01_$YYYYi-$MMi-$DDi\_$HHi\_00\_00 $WRF_AFWA_Dir/d01 || exit 8
	fi
		if [ $WRF_Domain -eq 2 ]; then
		mv $Model_WRF_Dir/wrfout_d02_$YYYYin-$MMin-$DDin\_$HHin\_00\_00 $WRF_Output2_Dir/ || exit 8
		mv $Model_WRF_Dir/wrfrst_d02_$YYYYin-$MMin-$DDin\_$HHin\_00\_00_???? $WRF_RST_Dir/$wrfrst_subdir_write/d02 || exit 8
		mv $Model_WRF_Dir/wrfprs_d02_$YYYYin-$MMin-$DDin\_$HHin\_00\_00 $WRF_PRS_Dir/d02 || exit 8
		mv $Model_WRF_Dir/afwa_d02_$YYYYi-$MMi-$DDi\_$HHi\_00\_00 $WRF_AFWA_Dir/d02 || exit 8
		fi

	# remove WRF_RST files (They are too big) keep the last four files
        p1=`expr $CF \* $WRFRST_SAVE_NUMBER \* -1 `
        $Couple_Lib_utils_Dir/incdte $YYYYin $MMin $DDin $HHin $p1 > dteout$$ || exit 8
        read YYYYp MMp DDp HHp < dteout$$; rm dteout$$
	wrfrst_subdir_delete=$YYYYp-$MMp-$DDp\_$HHp

	# delete wrfrst file prior to 120 hrs or older EXCEPt when HH==0 (top of the hour , please save it)
	if [ $HHp -ne 00 ]; then
        rm -rf $WRF_RST_Dir/$wrfrst_subdir_delete
	else
	echo "keeping WRFRST at $wrfrst_subdir_delete"
	fi
 	echo "End Run WRF"

else # parameter_RunWRF=yes
 echo "skipping WRF Run"
fi # parameter_RunWRF=o

# WRF --> ROMS
echo "Creating Forcing from WRF To ROMS at NDay=$NDay NHour=$NHour NLOOP=$NLOOP"
JD=`$Couple_Lib_utils_Dir/jd $YYYYi $MMi $DDi` || exit 8
## WRF2ROMS: yes/no
if [ $parameter_WRF2ROMS = yes ]; then
echo  "****************** WRF2ROMS **************"
	#$Couple_Run_Dir/WRF2ROMS.sh $NHour $MHour $JD $YYYYi:$MMi:$DDi:$HHi || exit 8
	# use the WRF output at the end of the forecast (YYYYin, not YYYYi) 2/5/2021
	$Couple_Run_Dir/WRF2ROMS.sh $NHour $MHour $JD $YYYYin:$MMin:$DDin:$HHin || exit 8
echo  "****************** WRF2ROMS **************"
elif [ $WRF2ROMS_WRFONLY =  yes ]; then
        #$Couple_Run_Dir/WRF2ROMS_WRFONLY.sh $NHour $MHour $JD $YYYYi:$MMi:$DDi:$HHi || exit 8
        $Couple_Run_Dir/WRF2ROMS_WRFONLY.sh $NHour $MHour $JD $YYYYin:$MMin:$DDin:$HHin || exit 8
fi

## Run ROMS yes/no
if [ $parameter_RunROMS = yes ]; then
# link forc_Day to ocean_frc
mkdir -p  $ROMS_Forc_Dir/$YYYYi  || exit 8
        rm $Couple_Data_ROMS_Dir/ocean_frc.nc >/dev/null
        #ln -fs $ROMS_Forc_Dir/$YYYYi/forc_Hour$NHour.nc $Couple_Data_ROMS_Dir/ocean_frc.nc || exit 8
        ln -fs $ROMS_Forc_Dir/forc_Hour$NHour\.nc $Couple_Data_ROMS_Dir/ocean_frc.nc || exit 8

cd $Couple_Data_ROMS_Dir || exit 8

# prepare ROMS run (init, bry, clm files)
echo "*********   prepare-ROMS **************"
echo "preparing ROMS Runs.. $gridname"
        #$Couple_Run_Dir/prepareROMS.sh $ROMS_BCFile $JD $NHour $YYYYin:$MMin:$DDin $NLOOP || exit 8
# 2020/04/16 add HHin
        $Couple_Run_Dir/prepareROMS.sh $ROMS_BCFile $JD $NHour $YYYYin:$MMin:$DDin:$HHin $NLOOP || exit 8
echo "*********   prepare-ROMS **************"


if [ $CPL_PHYS = ROMS_PHYS  ]; then
# calculate ua-uo and input to forcing in ROMS bulk formula
if [ $UaUo = yes ]; then
echo "Ua - Uo: 10 m wind speed relateve to current"
$Couple_Shell_Dir_common/uauo.sh $NHour || exit 8
else
echo "ocean sfc is motionless."
fi
fi

echo "Run ROMS (NDay=$NDay NHour=$NHour NLOOP=$NLOOP: $YYYYi:$MMi:$DDi:$HHi ~ $YYYYin:$MMin:$DDin:$HHin)"
echo "****************  Run ROMS ****************"
	$Couple_Data_ROMS_Dir/$ROMS_Launch_Filename > $ROMS_Runlog_Dir/ROMS_Hour$NHour\.log || exit 8
	grep Blowing $ROMS_Runlog_Dir/ROMS_Hour$NHour\.log 
	if [ $? -eq 0 ]; then
        echo "ERROR: ROMS BLOW UP!!!!!!!!!"
        exit 8
fi
echo "****************  Run ROMS ****************"

# avg
if [ $ROMS_Avg = yes ]; then
mkdir -p  $ROMS_Avg_Dir/$YYYYi  || exit 8
	mv $Couple_Data_ROMS_Dir/ocean_avg.nc $ROMS_Avg_Dir/$YYYYi/avg_Hour$NHour\.nc || exit 8
        ln -fs  $ROMS_Avg_Dir/$YYYYi/avg_Hour$NHour\.nc $ROMS_Avg_Dir/avg_Hour$NHour\.nc  || exit 8
fi

# rst
mkdir -p  $ROMS_Rst_Dir/$YYYYi  || exit 8
        mv $Couple_Data_ROMS_Dir/ocean_rst.nc $ROMS_Rst_Dir/$YYYYi/rst_Hour$NHour\.nc || exit 8
        ln -fs  $ROMS_Rst_Dir/$YYYYi/rst_Hour$NHour\.nc $ROMS_Rst_Dir/rst_Hour$NHour\.nc  || exit 8

## save rst file at the end of the month : 
## to do this, find when DDin=1 and save DDi (which is DDin-CF)
#	if [ $DDin -eq 1 -a $HHin -eq 0 ]; then
#	echo "save rst file at YYYY=$YYYYi MM=$MMi DD=$DDi HH=$HHi NHour=$NHour"
#	mkdir -p $ROMS_Rst_Dir/$YYYYi/save
#	cp $ROMS_Rst_Dir/$YYYYi/rst_Hour$NHour.nc $ROMS_Rst_Dir/$YYYYi/save/rst_NHour$NHour-$MMi-$DDi-$HHi.nc || exit 8
#	fi

# his
if [ $ROMS_His = yes ]; then
mkdir -p  $ROMS_His_Dir/$YYYYi  || exit 8
        mv $Couple_Data_ROMS_Dir/ocean_his.nc $ROMS_His_Dir/$YYYYi/his_Hour$NHour\.nc || exit 8
        ln -fs  $ROMS_His_Dir/$YYYYi/his_Hour$NHour\.nc $ROMS_His_Dir/his_Hour$NHour\.nc  || exit 8
fi
# qck
if [ $ROMS_Qck = yes ]; then
mkdir -p  $ROMS_Qck_Dir/$YYYYi  || exit 8
        mv $Couple_Data_ROMS_Dir/ocean_qck.nc $ROMS_Qck_Dir/$YYYYi/qck_Hour$NHour\.nc || exit 8

	# added: July 2, 2017
	# if use Qck; obtain only the last time step 
	# as is for HIS, it writes the first and last time-step of each segment of integrations
	echo "qck_Hour$NHour.nc: use only the last time-step"
	$NCO/ncks -F -O -d ocean_time,2 $ROMS_Qck_Dir/$YYYYi/qck_Hour$NHour\.nc $ROMS_Qck_Dir/$YYYYi/qck_Hour$NHour\.nc
	###
        ln -fs  $ROMS_Qck_Dir/$YYYYi/qck_Hour$NHour\.nc $ROMS_Qck_Dir/qck_Hour$NHour\.nc  || exit 8
fi

        NHourm2=`expr $NHour - $CF \* 2 `
        rm $ROMS_Avg_Dir/avg_Hour$NHourm2.nc
        rm $ROMS_Qck_Dir/qck_Hour$NHourm2.nc
        rm $ROMS_Rst_Dir/rst_Hour$NHourm2.nc
        #mv $Couple_Data_ROMS_Dir/ocean_frc.nc $ROMS_Forc_Dir/$YYYYi/forc_Hour$NHour.nc || exit 8
        #ln -fs  $ROMS_Forc_Dir/$YYYYi/forc_Hour$NHour.nc $ROMS_Forc_Dir/forc_Hour$NHour.nc  || exit 8
        rm $ROMS_Forc_Dir/forc_Hour$NHourm2.nc

        else #parameter_RunROMS
        echo "skipping ROMS Run"
fi #parameter_RunROMS

##################
# March 15, 2021 add WW3 coupling

if [ $parameter_run_WW3 = yes ]; then

cd $WW3_Exe_Dir

# #1. WRF U10 and V10 for WW3
rm -f fort.* wind.ww3* 2>/dev/null
rm  $WW3_Exe_Dir/ww3_prnc.nml 2>/dev/null

if [ 1 -eq 1 ]; then
# edit wind nml
	ncks -3 -O -v U10,V10,XLONG,XLAT,XTIME $WRF_Output2_Dir/wrfout_d01_$YYYYi-$MMi-$DDi\_$HHi\_00_00 fort.11
	ncks -3 -O -v U10,V10,XLONG,XLAT,XTIME $WRF_Output2_Dir/wrfout_d01_$YYYYin-$MMin-$DDin\_$HHin\_00_00 fort.12
	ncrcat -O fort.11 fort.12 fort.11; 	rm fort.12
	ncrename -d west_east,lon -d south_north,lat -d Time,time fort.11
	ncrename -v XTIME,time -v XLONG,lon -v XLAT,lat fort.11
	ncks -4 -O fort.11 fort.11
        ncatted -a _FillValue,U10,c,f,9.999e+20 fort.11
        ncatted -a _FillValue,V10,c,f,9.999e+20 fort.11
        ncap2 -O -s 'lon=lon+360' fort.11 fort.11
	$WW3_Exe_Dir/edit_ww3_prnc.sh $YYYYi:$MMi:$DDi:$HHi $YYYYin:$MMin:$DDin:$HHin $WW3_Exe_Dir/ww3_prnc_wind.nml
	ln -fs ww3_prnc_wind.nml ww3_prnc.nml
	$WW3_Exe_Dir/ww3_prnc >& log_prnc_wind_$$
	mv wind.ww3 wind.ww3.$YYYYin$MMin$DDin$HHin\_Hour$NHour
	ln -fs wind.ww3.$YYYYin$MMin$DDin$HHin\_Hour$NHour wind.ww3
fi

# #2. ROMS u/v sfc current for WW3
if [ $wave_current = yes ];then
	rm -f fort.* current.ww3* 2>/dev/null
	rm  $WW3_Exe_Dir/ww3_prnc.nml 2>/dev/null
	# edit current nml
	if [ $NLOOP -eq 1 ]; then
	# for inital case, jusy duplicate NHour for NHourm
       		ncks -3 -O -v u_sur_eastward,v_sur_northward,lon_rho,lat_rho $ROMS_Qck_Dir/qck_Hour$NHour\.nc fort.11
	else
        	ncks -3 -O -v u_sur_eastward,v_sur_northward,lon_rho,lat_rho $ROMS_Qck_Dir/qck_Hour$NHourm\.nc fort.11
	fi
        ncks -3 -O -v u_sur_eastward,v_sur_northward,lon_rho,lat_rho $ROMS_Qck_Dir/qck_Hour$NHour\.nc fort.12
        ncrcat -O fort.11 fort.12 fort.11;      rm fort.12
        ncrename -d xi_rho,lon -d eta_rho,lat fort.11
        ncrename -d ocean_time,time fort.11
        ncrename -v lon_rho,lon -v lat_rho,lat fort.11
        ncrename -v ocean_time,time  fort.11
        ncks -4 -O fort.11 fort.11
	$WW3_Exe_Dir/edit_ww3_prnc.sh $YYYYi:$MMi:$DDi:$HHi $YYYYin:$MMin:$DDin:$HHin $WW3_Exe_Dir/ww3_prnc_current.nml
	ln -fs ww3_prnc_current.nml ww3_prnc.nml
	$WW3_Exe_Dir/ww3_prnc >& log_prnc_current_$$
	mv current.ww3 current.ww3.$YYYYin$MMin$DDin$HHin\_Hour$NHour
	ln -fs current.ww3.$YYYYin$MMin$DDin$HHin\_Hour$NHour current.ww3
fi #wave_current = yes

# #3. update WW3 main namelist; restart/ start/end date 
	$WW3_Exe_Dir/edit_ww3_shel.sh $YYYYi:$MMi:$DDi:$HHi $YYYYin:$MMin:$DDin:$HHin $WW3_Exe_Dir/ww3_shel.nml $CF

# Run WW3
rm -f out_grd.ww3 ww3_*.nc restart.ww3 2>/dev/null
# 1. $WW3_spinup = yes, then provide the WW3_ICfile 
# 2. $WW3_spinup = no,  no initial file is necessary.
if [ $NLOOP -eq 1 ]; then
        if [ $WW3_spinup = yes ]; then
	ln -fs $WW3_ICFile ./restart.ww3 || exit 8
	fi
else
# if NLOOP>1, it is a restart, link restart file from previous time 
	ln -fs $WW3_Rst_Dir/restart.ww3.$YYYYi$MMi$DDi$HHi\_Hour$NHourm ./restart.ww3 || exit 8
fi
# 1. Run WW3 codes
echo "runWW3"
date
	mpirun -np $ww3NCPU $WW3_Exe_Dir/ww3_shel >& log_shel_$$
date
echo "end runWW3"

#2. Convert outputs to netcdf
	$WW3_Exe_Dir/edit_ww3_ounf.sh $YYYYi:$MMi:$DDi:$HHi $YYYYin:$MMin:$DDin:$HHin $WW3_Exe_Dir/ww3_ounf.nml $CF
	$WW3_Exe_Dir/ww3_ounf >& log_ounf_$$

# organize
#Out, binary: No Need to link
# *********
# # maybe we don't want to save out_grd.ww3; we don't use it anywhere..
#mkdir -p $WW3_Out_Dir/$YYYYin
#        mv ./out_grd.ww3 $WW3_Out_Dir/$YYYYin/ww3.$YYYYin$MMin$DDin$HHin\_Hour$NHour
# *********
#Out, netcdf: need to link for WW32WRF
mkdir -p $WW3_Outnc_Dir/$YYYYin
	#mv ./ww3.$YYYYi$MMi\.nc $WW3_Outnc_Dir/$YYYYin/ww3.$YYYYin$MMin$DDin$HHin\_Hour$NHour\.nc
	mv ./ww3.$YYYYin$MMin$DDinT$HHin\Z.nc $WW3_Outnc_Dir/$YYYYin/ww3.$YYYYin$MMin$DDin$HHin\_Hour$NHour\.nc
	ln -fs $WW3_Outnc_Dir/$YYYYin/ww3.$YYYYin$MMin$DDin$HHin\_Hour$NHour\.nc $WW3_Outnc_Dir/

#Rst: binary: Need to link
mkdir -p $WW3_Rst_Dir/$YYYYin
	mv ./restart001.ww3 $WW3_Rst_Dir/$YYYYin/restart.ww3.$YYYYin$MMin$DDin$HHin\_Hour$NHour
	ln -fs $WW3_Rst_Dir/$YYYYin/restart.ww3.$YYYYin$MMin$DDin$HHin\_Hour$NHour $WW3_Rst_Dir/
#Frc: binary: No need to link
mkdir -p $WW3_Frc_Dir/$YYYYin/wind
mkdir -p $WW3_Frc_Dir/$YYYYin/current
	mv ./wind.ww3.$YYYYin$MMin$DDin$HHin\_Hour$NHour $WW3_Frc_Dir/$YYYYin/wind/
	mv ./current.ww3.$YYYYin$MMin$DDin$HHin\_Hour$NHour $WW3_Frc_Dir/$YYYYin/current/
	rm $WW3_Exe_Dir/wind.ww3 2>/dev/null
	rm $WW3_Exe_Dir/current.ww3 2>/dev/null
#Log file
mkdir -p $WW3_Log_Dir/prnc_wind/$YYYYin
mkdir -p $WW3_Log_Dir/prnc_current/$YYYYin
mkdir -p $WW3_Log_Dir/shel/$YYYYin
mkdir -p $WW3_Log_Dir/ounf/$YYYYin
	mv ./log_prnc_wind_$$ $WW3_Log_Dir/prnc_wind/$YYYYin/log_prnc_wind_$YYYYin$MMin$DDin$HHin\_Hour$NHour
        mv ./log_shel_$$ $WW3_Log_Dir/shel/$YYYYin/log_shel_$YYYYin$MMin$DDin$HHin\_Hour$NHour
        mv ./log_ounf_$$ $WW3_Log_Dir/ounf/$YYYYin/log_ounf_$YYYYin$MMin$DDin$HHin\_Hour$NHour
if [ $wave_current = yes ];then
mkdir -p $WW3_Log_Dir/prnc_current/$YYYYin
	mv ./log_prnc_current_$$ $WW3_Log_Dir/prnc_current/$YYYYin/log_prnc_current_$YYYYin$MMin$DDin$HHin\_Hour$NHour
fi

# clean up
        rm $WW3_Rst_Dir/restart.ww3.??????????\_Hour$NHourm2 2>/dev/null
        rm $WW3_Outnc_Dir/ww3.??????????\_Hour$NHourm2\.nc
#  WW3 netcdf file; 
	if [ $NLOOP -eq 1 ]; then 
        mv ./ww3.$YYYYi$MMi$DDi\T$HHi\Z.nc $WW3_Outnc_Dir/$YYYYi/ww3.$YYYYi$MMi$DDi$HHi\_Hour$NHourm\.nc
	else
        rm ./ww3.$YYYYi$MMi$DDi\T$HHi\Z.nc 2>/dev/null
	fi
        mv ./ww3.$YYYYin$MMin$DDin\T$HHin\Z.nc $WW3_Outnc_Dir/$YYYYin/ww3.$YYYYin$MMin$DDin$HHin\_Hour$NHour\.nc

cd -
else #parameter_run_WW3
	echo "skipping WW3 Run"
fi
###################

echo " *****************************"
echo " COUPLING DONE at Day = $NDay Hour=$NHour NLOOP=$NLOOP"
echo " *****************************"

# 4. Continue WRF Run
YYYYi=$YYYYin
MMi=$MMin
DDi=$DDin
HHi=$HHin

NHour=`expr $NHour + $CF`
	if [ $HHi -eq 0 ]; then
  	NDay=`expr $NDay + 1`
	fi
NLOOP=`expr $NLOOP + 1 `

# cleaning..
rm $Couple_Data_tempo_files_Dir/* 2>/dev/null
rm $Couple_Data_ROMS_Dir/fort.* 2>/dev/null
rm $Couple_Data/fort.* 2>/dev/null

# Cleaning WRF Directory
#rm $Model_WRF_grid_Dir/wrfout_d01_$YYYYi-* 2>/dev/null
#rm $Model_WRF_grid_Dir/wrfsd10_$YYYYi-* 2>/dev/null

# Cleaning ROMS directory
rm $Couple_Data_ROMS_Dir/ocean_bry.nc 2>/dev/null
rm $Couple_Data_ROMS_Dir/ocean_frc.nc 2>/dev/null
# Keep the ocean_ini.nc!
done
# DONE

echo " *****************************"
echo "WRF2ROMS COMPLETED!"
echo " *****************************"
