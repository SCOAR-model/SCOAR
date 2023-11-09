# list all the options defined"
echo "RUN_ID = $RUN_ID"
echo "RESTART=$RESTART"
if [ $RESTART = yes ]; then
echo "LastNHour= $LastNHour"
fi
echo "run started for $YYYYi-$MMi-$DDi-$HHi @ NHour=$NHour"
date
echo ""

# Coupler option
echo "************************************"
echo "Coupler option"
echo "CF= $CF"
echo "UaUo = $UaUo"
echo "CPL_PHYS= $CPL_PHYS"
echo "BULK_FLUX = $BULK_FLUX"
echo "LONGWAVE_OUT= $LONGWAVE_OUT"
echo "BULK= $BULK"
echo "SmoothSST = $SmoothSST"
echo "SmoothUV= $SmoothUV"
echo "************************************"
echo ""

# WRF
echo "************************************"
echo "WRF option"
echo "WRF_TS = $WRF_TS"
echo "WRF_AFWA= $WRF_AFWA"
echo "WRF_Namelist_input= $WRF_Namelist_input"
echo "************************************"
echo ""

# ROMS
echo "************************************"
echo "ROMS option"
echo "oceanM = $ROMS_Executable_Filename"
echo "ocean.in = $ROMS_Input_Filename"
echo "River = $River"
echo "Tide = $Tide"
echo "SSS_CORRECTION = $SSS_CORRECTION"
echo "nd = $nd"
echo "************************************"
echo ""

# WW3
echo "************************************"
echo "WW3 option"
echo "parameter_run_WW3 = $parameter_run_WW3"
echo "parameter_WW32WRF= $parameter_WW32WRF"
echo "isftcflx= $isftcflx"
echo "WW3_spinup= $WW3_spinup"
echo "ROMS_wave = $ROMS_wave"
echo "parameter_WW32ROMS = $parameter_WW32ROMS"
echo "************************************"
