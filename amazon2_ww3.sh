#!/bin/sh
# apply RW wind on wind only (LH and SH are based on absolulte wind)
# in ROMS I modified
	# module/mod_forces.F and Nonliner/bulk_fluxex.F

# WRF-ROMS coupled version
set -ax
export RUN_ID=amazon2_wave
export NCO=/vortexfs1/apps/nco-4.7.4/bin

# starting time : YYYYS MMS DDS HHS
export YYYYS=2020
export MMS=01
export DDS=01
export HHS=00

# ending time : YYYYE MME DDE HHE
export YYYYE=2020
export MME=01
export DDE=05
export HHE=00

# in ocean.in
#TIME_REF = 20101231.0d0    

export gridname=amazon2
export gridname2=amazon

# restart option; 
export RESTART=no
export LastNHour=

# for so note that ROMS2WRF use the so4 version: See Shell
export parameter_ROMS2WRF=yes
export parameter_RunWRF=yes
export parameter_WRF2ROMS=yes
	# addition for WRF ONLY run but process WRF_Out from WRF_Out2
	# this should be no in case of the coupled run
	export WRF2ROMS_WRFONLY=no
export parameter_RunROMS=yes
export parameter_run_WW3=yes
# ROMS_wave: use wave dissipiation in ROMS GLS scheme;
        export ROMS_wave=yes

# in order to have WW3 coupling but use WSDF in WRF
# 1. parameter_run_WW3=yes
# 2. COARE_wave_option=0 : #WSDF
# 3. parameter_WW32WRF=no

        if [ $parameter_run_WW3 = yes ]; then
# if WW3 is on, isftcflx option have to defined in physics of namelist.input 
# two options are available for now (May 2021)
#
# COARE_wave_option=0  :  isftcflx is set to 0 and this uses the windspeed  only formulation of COARE3.5 in WRF surface layer scheme
# COARE_wave_option=1  :  isftcflx is set to 351 and this uses the wave-age only formulation of COARE3.5 in WRF surface layer scheme
# COARE_wave_option=2  :  isftcflx is set to 352 and this uses the wave-age and wave height formulation of COARE3.5 in WRF surface layer scheme
# (default should be option 2 when using wave)
        export COARE_wave_option=2 # or 0 or 1
# if sending ocean surface current to WW3
        export wave_current=yes
        export parameter_WW32WRF=yes 
		if [ $ROMS_wave = yes ]; then
       		export parameter_WW32ROMS=yes
		fi
        else
# if sending ocean surface current to WW3
        export COARE_wave_option=0 # nominal
        export wave_current=no
        export parameter_WW32WRF=no
        export parameter_WW32ROMS=no
fi

export WRF_ROMS_SAME_GRID=yes
# option revised 2021-07-23
export SSS_CORRECTION=no
        # SSS files should reside under ROMS_Input_mercator
        SSS_path=\$Couple_Misc_Data_Dir/ROMS_Input/\$ROMS_BCFile/sss

# ROMS: new option: restart from ocean_rst.nc
export ROMS_Rst=yes

# are there small lakes in WRF land pts?
# did you prepare roms-nolake mask?
# if you dont want to update sst on these lake  from roms but want to use sst from wrflow?
export NOLAKE=yes #in ROMS2WRF.sh lakes in ROMS grids have been already filled out:? e.g. in roms-grid-nolake.nc

#Number of CPUs used
# THIS NEED TO BE MATCHED IN THE SGL script and ocean.in file
export wrfNCPU=36
export romsNCPU=36
export ww3NCPU=36

# coupling frequency, MPI, version of ROMS
export CF=3
# output frequency in wrfout this has to match with namelist.input
export WRF_OUTPUT_FREQUENCY=$CF
# output frequency in wrfout this has to match with ocean.in
export ROMS_OUTPUT_FREQUENCY=1
export WRF_PRS=yes
# WRF time-series option added 2021/06/04
export WRF_TS=yes
export WRF_AFWA=no
export WRF_FDDA=no

# Compiler; intel or pgi
export FC=intel

# How many wrfrst files to save:  N times $C
# if CF=1, 24 means save past 24 hours of wrfrst files and delete the prior
export WRFRST_SAVE_NUMBER=`expr 120 \/ $CF`

# In WRF Namelist, io_form_restart=102
# Faster when frequent restart is used (e.g., CF=1)
# make sure in namelistinput file io_form_restart=102
# default is yes ; speed things up a lot..
export WRFRST_MULTI=yes

# SST frequency in wrflowinp_d01
export SST_FREQUENCY=$CF
echo "check both WRF_OUTPUT_FREQUENCY SST_FREQUENCY in namelist.input file ...."

# WRF input files after real.exe ; located in $Couple_Misc_Data_Dir
export WRF_Domain=1 # WRF # of domains
export Coupling_Domain=1 # Domains where ROMS and WRF are coupled: 1 if d01, 2 if d02
export wrfinput_file_d01=wrfinput_d01
# grid-point nudging
export wrffdda_file_d01=wrffdda_d01
export wrfbdy_file_d01=wrfbdy_d01
export wrflowinp_file_d01=wrflowinp_d01
        if [ $WRF_Domain -eq 2 ]; then
        export wrfinput_file_d02=wrfinput_d02
        export wrflowinp_file_d02=wrflowinp_d02
        fi

if [ $RESTART = yes ]; then
	export already_copied_wrflowinp=yes
else
	export already_copied_wrflowinp=no
fi

# ROMS OUTPUTS Types to use
# for mjo and yso runs, avg is the average for the coupling interver and his is output every 1h regardless of CF 
export ROMS_Avg=yes 
export ROMS_His=no
export ROMS_Qck=yes
export Use_SST_In=Qck

export MPI=yes
export vROMS=202103
export vWRF=422

#Naming the WRF and ROMS model (resolution & region)
export Nameit_WRF=wrf-$gridname
export Nameit_ROMS=roms-$gridname
#export ROMS_Grid_Filename=$Nameit_ROMS\-grid.nc
# use nolake mask for ROMS run
export ROMS_Grid_Filename=$Nameit_ROMS\-grid_nolake.nc

# Two options for calculating the flux
# 1. Use WRF Physics CPL_PHY=WRF
# 2. Use ROMS Bulk formula CPL_PHYS=ROMS
# WRF_PHYS should be set as default
# If WW
# If parameter_run_WW3 = yes, Set CPL_PHYS=WRF_PHYS
export CPL_PHYS=WRF_PHYS
	if [ $CPL_PHYS = ROMS_PHYS -a $parameter_run_WW3 = yes ]; then
		echo "If parameter_run_WW3 = yes , Set CPL_PHYS=WRF_PHYS"
		exit 8 
	fi
	if [ $CPL_PHYS = WRF_PHYS ]; then
	export BULK_FLUX=no
	export LONGWAVE_OUT=no
	export BULK=nobulk
	fi
	if [ $CPL_PHYS = ROMS_PHYS ]; then
	export BULK_FLUX=yes
	export LONGWAVE_OUT=yes
	export BULK=bulk
	fi
# UaUo
export UaUo=yes
# NEED TO THINK
        if [ $CPL_PHYS = WRF_PHYS ]; then
 	# UaUo is calculated as UOCE/VOCE entered in wrflowinp
 	export ROMS2WRF=ROMS2WRF_use_qck_uoce.sh
         elif [ $CPL_PHYS = ROMS_PHYS  ]; then
 	# UaUo is calculated using uauo.sh
 	export ROMS2WRF=ROMS2WRF_use_qck.sh
 	fi

## THIS IS TO BE FIXED.... In rename Uauo to smooth... and drop Urel Verel part
## Interactive Smoothing (Putrasahan et al. 2013a,b; Seo et al. 2016; Seo 2017)
export SmoothSST=no #in ROMS2WRF
export SmoothUV=no  #in UaUo
	if [ $SmoothUV = yes -a $UaUo = no ]; then
	echo "When SmoothUV is yes, UaUo should be yes"
	exit 8
	fi
#since we're using lat/lon, dist is in deg.
# note this is a loess smoothing scale:
if [ $SmoothSST = yes -o $SmoothUV = yes ]; then
export spanx=20.0
export spany=5.0
fi

# River for ROMS
export River=no
if [ $River = yes ]; then
        echo "make sure to set river parameters in ocean.in"
        export river_data=
fi
# Tides for ROMS
export Tide=no
if [ $Tide = yes ]; then
        echo "Tide is yes; need tide file and ocean.in file"
        export tide_data=
fi

# ROMS BC files SODA_1day or SODA_mon
export ROMS_BCFile=mercator
export ROMS_BCFile_Freq=1day  
        export ROMS_BCFile_Dir=\$Couple_Misc_Data_Dir/ROMS_Input/$ROMS_BCFile/$ROMS_BCFile_Freq
        export ROMS_BCFile_Name=mercator.bry_1dy

# WRF/ROMS Initial condition for coupled somulation
# 1. start from reanaylsis data (for both WRF and ROMS) or spinup (for ROMS)
# 2. or start from coupled spin-up runs (for WRF and ROMS): this method was done for nascar runs (Seo 2017)
export restart_from_coupled_spinup=no
# restart from coupled spinup run?  this will do 
        #1. link wrfrst file and change namelist WRF_RESTART option accordingly in couple.sh
        #2. ICFile is set to the ROMS coupled spinup run
if [ $restart_from_coupled_spinup = yes ]; then
        # this is where wrfrst files are located
export WRF_RST_coupled_spinup=
export ROMS_ICFile=
else
export ROMS_ICFile=/vortexfs1/share/seolab/SCOAR2_share/scoar_ww3/Data/domains/amazon/amazon2/ROMS_Input/mercator/1day/2020/mercator.ini_1dy_20200101.nc
fi

# WW3 Initial File : from WW3 Spinup
if [ $parameter_run_WW3 = yes ]; then
export WW3_spinup=yes
	if [ $WW3_spinup = yes ]; then
	# provide WW3 spinup restart file
	export WW3_ICFile=/vortexfs1/share/seolab/SCOAR2_share/scoar_ww3/Data/domains/amazon/amazon2/WW3_Input/ww3.restart.2020010100
	export WW3_ICFile_NC=/vortexfs1/share/seolab/SCOAR2_share/scoar_ww3/Data/domains/amazon/amazon2/WW3_Input/ww3.2020010100.nc
	fi
fi

# Main Run Directory
#export Couple_Run_Dir=/vortexfs1/share/seolab/hseo/SCOAR2/Run/$gridname2/$gridname/$RUN_ID
export Couple_Run_Dir=/vortexfs1/share/seolab/SCOAR2_share/scoar_ww3/Run/$gridname2/$gridname/$RUN_ID

# executables and inputs files
export ROMS_Executable_Filename=oceanM
        # as ROMS output is an averaged fileds. produce only one time-step
        #export ROMS_Input_Filename=ocean$romsNCPU\_roms38_3hr_dt60.in
        export ROMS_Input_Filename=ocean.in

        # as WRF output is an snapshot, produce 1-hrly fields for given CF and then average
        #export WRF_Namelist_input=namelist.input_$gridname\_$CF\hr
	# BE SURE TO INCLUDE write_hist_at_0h_rst  
        export WRF_Namelist_input=namelist.input

	# if add/remove output option is defined, need to be stated in the namelist.input file
	export iofields_filename=yes

export WW3_exe_Filename=ww3_*

#Launch file
export ROMS_Launch_Filename=romslaunch
export WRF_Launch_Filename=wrflaunch

##ROMS grid file
#export WRF_Grid_Filename=geo_em.d01.nc

# number of vertical layer in ocean model
# not needed if use ROMS Qck file to read SST and UVsfc
export nd=30

# IF ROMS and WRF have the same grid/mask 
# needinterp=no && tiling=no

# Spatial interpolation between WRF and ROMS?
export needinterp=no
# SST tiling average from ROMS to WRF (not using grid interpolation..)
# obsolete
export tiling=no

#####--------------------- END OF USER DEFINITION -----------------------#####
echo "CF is $CF"
if [ $CPL_PHYS = WRF_PHYS ]; then
   echo "Use WRF's boudary layer physics!"
elif [ $CPL_PHYS = ROMS_PHYS ]; then
   echo "Use ROMS' Bulk formula"
fi
if [ $UaUo = yes ]; then
   echo "Ua-Uo is ON"
elif [ $UaUo = no ]; then
   echo "Ua-Uo is OFF"
fi
#####--------------------- END OF PRINT OUT -----------------------#####

###EXPORT
export YYYYS MMS DDS HHS YYYYE MME DDE HHE

#Home Directory
export Couple_Home_Dir=/vortexfs1/share/seolab/SCOAR2_share/scoar_ww3

#Shell Directory
export Couple_Shell_Dir_common=$Couple_Home_Dir/Shell
export Couple_Shell_Dir=$Couple_Shell_Dir_common/$gridname2/$gridname

#Couple Lib Directories
export Couple_Lib_Dir=$Couple_Home_Dir/Lib
  export Couple_Lib_auxfiles_Dir=$Couple_Lib_Dir/aux-files
  export Couple_Lib_codes_Dir=$Couple_Lib_Dir/codes
  export Couple_Lib_exec_Dir=$Couple_Lib_Dir/exec
        export Couple_Lib_exec_coupler_Dir=$Couple_Lib_exec_Dir/Coupler_$FC
        export Couple_Lib_exec_ROMS_Dir=$Couple_Lib_exec_Dir/ROMS/$gridname2/$gridname
        export Couple_Lib_exec_WRF_Dir=$Couple_Lib_exec_Dir/WRF/$gridname2/$gridname
        export Couple_Lib_exec_WW3_Dir=$Couple_Lib_exec_Dir/WW3/$gridname2/$gridname
  export Couple_Lib_grids_Dir=$Couple_Lib_Dir/grids/$gridname2/$gridname
	export Couple_Lib_grids_WRF_Dir=$Couple_Lib_grids_Dir/WRF
	export Couple_Lib_grids_ROMS_Dir=$Couple_Lib_grids_Dir/ROMS
	export Couple_Lib_grids_WW3_Dir=$Couple_Lib_grids_Dir/WW3
  export Couple_Lib_template_Dir=$Couple_Lib_Dir/template/$gridname2/$gridname
  export Couple_Lib_utils_Dir=$Couple_Lib_Dir/utils

export Couple_Model_Dir=/vortexfs1/home/hseo/SCOAR2/Model

	#WRF
        #export Couple_WRF_Dir=/vortexfs1/share/seolab/hseo/Model/WRF/$gridname2/$gridname/WRF-4.2.2/
        export Couple_WRF_Dir=/vortexfs1/share/seolab/hseo/Model/WRF/$gridname2/$gridname/WRF-4.2.2_with_WW3/
		echo "Make sure you have the correct WRF working directory."
			export Model_WRF_Dir=$Couple_WRF_Dir/test/em_real_$RUN_ID
			export Couple_WPS_grid_Dir=$Couple_WPS_Dir/domains/$gridname2/$gridname
		export Couple_WRF_Info_Dir=$Couple_WRF_Dir/Info
		export Couple_WRF_geog_Dir=$WRF_Info_Dir/geog #geogrid
	# Not needed, all we need is just an executable
	#ROMS
	#export Couple_ROMS_Dir=$Couple_Home_Dir/Model/ROMS$vROMS
	#	export Couple_ROMS_External_Dir=$Couple_ROMS_Dir/ROMS/External
	#	export Couple_ROMS_Include_Dir=$Couple_ROMS_Dir/ROMS/Include

# WRF_ROMS misc Data directory (containing ROMS/WRF initial/boundary files...)
#export Couple_Misc_Data_Dir=/vortexfs1/share/seolab/hseo/SCOAR2/Data/domains/$gridname2/$gridname
export Couple_Misc_Data_Dir=/vortexfs1/share/seolab/SCOAR2_share/scoar_ww3/Data/domains/$gridname2/$gridname
        export WRF_Input_Data=$Couple_Misc_Data_Dir/WRF_Input/
        export ROMS_Input_Data=$Couple_Misc_Data_Dir/ROMS_Input
        mkdir -p $Couple_Misc_Data_Dir $WRF_Input_Data $ROMS_Input_Data

	ROMS_BCFile_Dir=`eval echo $ROMS_BCFile_Dir`
		echo "ROMS BC Directory: $ROMS_BCFile_Dir"
	ROMS_ICFile=`eval echo $ROMS_ICFile`
		echo "ROMS IC: $ROMS_ICFile"

#General OUTPUT Directories
export Couple_Data_Dir=$Couple_Run_Dir/Data
 export Couple_Data_WRF_Dir=$Couple_Data_Dir/WRF 
 export Couple_Data_ROMS_Dir=$Couple_Data_Dir/ROMS
 export Couple_Data_WW3_Dir=$Couple_Data_Dir/WW3
 export Couple_Data_tempo_files_Dir=$Couple_Data_Dir/tempo_files

# ROMS2WRF LOG files
 export Couple_Log_Dir=$Couple_Data_Dir/LOG
 export Couple_Log_ROMS2WRF_Dir=$Couple_Log_Dir/ROMS2WRF
 export Couple_Log_WRF2ROMS_Dir=$Couple_Log_Dir/WRF2ROMS

   for DIR in $Couple_Run_Dir $Couple_Data_Dir $Couple_Data_WRF_Dir $Couple_Data_ROMS_Dir $Couple_Data_tempo_files_Dir $Couple_Log_Dir $Couple_Log_ROMS2WRF_Dir $Couple_Log_WRF2ROMS_Dir
    do 
    mkdir -p $DIR 2>/dev/null
   done

#ROMS OUTPUT Directories
export ROMS_His_Dir=$Couple_Data_ROMS_Dir/His
export ROMS_Avg_Dir=$Couple_Data_ROMS_Dir/Avg
export ROMS_Rst_Dir=$Couple_Data_ROMS_Dir/Rst
export ROMS_Qck_Dir=$Couple_Data_ROMS_Dir/Qck
        if [ $SmoothSST = yes -o $SmoothUV = yes ]; then
	export ROMS_Smooth_Dir=$Couple_Data_ROMS_Dir/Smooth
	export ROMS_Smooth_Before_Dir=$Couple_Data_ROMS_Dir/Smooth/before
	export ROMS_Smooth_After_Dir=$Couple_Data_ROMS_Dir/Smooth/after
	export ROMS_Smooth_Diff_Dir=$Couple_Data_ROMS_Dir/Smooth/diff
	mkdir -p $ROMS_Smooth_Dir
	mkdir -p $ROMS_Smooth_Before_Dir
	mkdir -p $ROMS_Smooth_After_Dir
	mkdir -p $ROMS_Smooth_Diff_Dir
	fi
export ROMS_Dia_Dir=$Couple_Data_ROMS_Dir/Dia
export ROMS_Misc_Dir=$Couple_Data_ROMS_Dir/Misc
export ROMS_Forc_Dir=$Couple_Data_ROMS_Dir/Forc
export ROMS_Runlog_Dir=$Couple_Data_ROMS_Dir/ROMS_Log

   for DIR in $ROMS_His_Dir $ROMS_Avg_Dir $ROMS_Rst_Dir $ROMS_Qck_Dir $ROMS_Runlog_Dir $ROMS_Forc_Dir $ROMS_Misc_Dir $ROMS_Dia_Dir
    do
    mkdir -p $DIR 2>/dev/null
   done

#WRF OUTPUT Directores
export WRF_Runlog_Dir=$Couple_Data_WRF_Dir/WRF_Log
export WRF_Output_Dir=$Couple_Data_WRF_Dir/WRF_Out
export WRF_Output2_Dir=$Couple_Data_WRF_Dir/WRF_Out2
export WRF_RST_Dir=$Couple_Data_WRF_Dir/WRF_RST
       if [ $WRF_PRS = yes ]; then
       export WRF_PRS_Dir=$Couple_Data_WRF_Dir/WRF_PRS
       fi
       if [ $WRF_AFWA = yes ]; then
       export WRF_AFWA_Dir=$Couple_Data_WRF_Dir/WRF_AFWA
       fi
       if [ $WRF_TS = yes ]; then
       export WRF_TS_Dir=$Couple_Data_WRF_Dir/WRF_TS
       fi
export WRF_NamelistInput_Dir=$Couple_Data_WRF_Dir/WRF_NamelistInput

   for DIR in $WRF_Runlog_Dir $WRF_Output_Dir $WRF_Output2_Dir $WRF_NamelistInput_Dir $WRF_RST_Dir $WRF_TS_Dir
    do
    mkdir -p $DIR 2>/dev/null
   done

if [ $parameter_run_WW3 = yes ]; then
#WW3 OUTPUT Directories
export WW3_Out_Dir=$Couple_Data_WW3_Dir/Out
export WW3_Outnc_Dir=$Couple_Data_WW3_Dir/Outnc
export WW3_Rst_Dir=$Couple_Data_WW3_Dir/Rst
export WW3_Frc_Dir=$Couple_Data_WW3_Dir/Frc
export WW3_Log_Dir=$Couple_Data_WW3_Dir/Log
export WW3_Exe_Dir=$Couple_Data_WW3_Dir/Exe # where WW3 will be run

   for DIR in $WW3_Out_Dir $WW3_Outnc_Dir $WW3_Rst_Dir $WW3_Frc_Dir $WW3_Log_Dir $WW3_Exe_Dir
    do
    mkdir -p $DIR 2>/dev/null
   done
fi

#####--------------------- END OF EXPORT -----------------------#####

#COPY NECESSARY FILES

##### 1. Copy coupler codes/scripts #####
rm -f $Couple_Run_Dir/*.sh 2>/dev/null

# Copy main_couple script
 cp $0 $Couple_Run_Dir

# Copy couple.sh
    cp $Couple_Shell_Dir/couple_with_ww3.sh $Couple_Run_Dir || exit 8

# Copy WRF2ROMS
    cp $Couple_Shell_Dir/WRF2ROMS_$BULK.sh $Couple_Run_Dir/WRF2ROMS.sh || exit 8
# THIS HAS TO BE FIXED TOO
    cp $Couple_Shell_Dir/WRF2ROMS_bulk_WRFONLY.sh $Couple_Run_Dir/WRF2ROMS_WRFONLY.sh || exit 8

# Copy prepareROMS.sh
 if [ $ROMS_Rst = yes ]; then
 cp $Couple_Shell_Dir_common/prepareROMS_Rst.sh $Couple_Run_Dir/prepareROMS.sh || exit 8
 cp $Couple_Shell_Dir_common/edit_ROMS_ocean_in.sh $Couple_Run_Dir/edit_ROMS_ocean_in.sh || exit 8
 else  # this should be removed in the future.. and call prepareROMS_Rst.sh prepareROMS.sh
 cp $Couple_Shell_Dir_common/prepareROMS.sh $Couple_Run_Dir/prepareROMS.sh || exit 8
 fi

# Copy ROMS2WRF (and associated shell scripts)
 cp $Couple_Shell_Dir/ROMS2WRF.sh $Couple_Run_Dir/ROMS2WRF.sh || exit 8
# this is to modify SST wrflowinp_d01 at intial time ; but let's not do this.
# 	cp $Couple_Shell_Dir_common/edit_sst_wrfinput.sh $Couple_Run_Dir || exit 8
##
        cp $Couple_Shell_Dir_common/edit_WRF_namelist.sh $Couple_Run_Dir || exit 8

##### 2. files for model run #####
#COPY NECESSARY FILES TO $Couple_Data_Dir

# WRF
cp $Couple_Shell_Dir_common/$WRF_Launch_Filename $Couple_Data_WRF_Dir || exit 8

# ROMS
rm -rf $Couple_Data_ROMS_Dir/*.in 
ln -fs $Couple_Lib_grids_ROMS_Dir/$ROMS_Grid_Filename $Couple_Data_ROMS_Dir/ocean_grd.nc || exit 8
cp $Couple_Lib_exec_ROMS_Dir/$ROMS_Input_Filename $Couple_Data_ROMS_Dir/ocean.in || exit 8
ln -fs $Couple_Lib_exec_ROMS_Dir/$ROMS_Executable_Filename $Couple_Data_ROMS_Dir/oceanM || exit 8
cp $Couple_Lib_exec_ROMS_Dir/$ROMS_Launch_Filename $Couple_Data_ROMS_Dir/$ROMS_Launch_Filename || exit 8
ln -fs $Couple_Lib_exec_ROMS_Dir/varinfo.dat_v$vROMS $Couple_Data_ROMS_Dir/varinfo.dat || exit 8
if [ $River = yes ]; then
	river_data=`eval echo $river_data`
        ln -fs $river_data $Couple_Data_ROMS_Dir/river.nc || exit 8
fi
if [ $Tide = yes ]; then
        tide_data=`eval echo $tide_data`
        ln -fs $tide_data $Couple_Data_ROMS_Dir/ocean_tide.nc || exit 8
fi

if [ $parameter_run_WW3 = yes ]; then
# WW3 namelist edit
cp $Couple_Shell_Dir_common/edit_ww3_prnc.sh $WW3_Exe_Dir/edit_ww3_prnc.sh || exit 8
cp $Couple_Shell_Dir_common/edit_ww3_shel.sh $WW3_Exe_Dir/edit_ww3_shel.sh || exit 8
cp $Couple_Shell_Dir_common/edit_ww3_ounf.sh $WW3_Exe_Dir/edit_ww3_ounf.sh || exit 8

# Copy WW32WRF 
cp $Couple_Shell_Dir/WW32WRF.sh $Couple_Run_Dir/WW32WRF.sh || exit 8

# Copy WW32ROMS
if [ $parameter_WW32ROMS = yes ]; then
cp $Couple_Shell_Dir/WW32ROMS.sh $Couple_Run_Dir/WW32ROMS.sh || exit 8
fi

# WW3 executables
ln -fs $Couple_Lib_exec_WW3_Dir/exec/$WW3_exe_Filename $WW3_Exe_Dir || exit 8
ln -fs $Couple_Lib_grids_WW3_Dir/*ww3 $WW3_Exe_Dir || exit 8

# WW3 namelist only what isused...
cp     $Couple_Lib_exec_WW3_Dir/ww3_prnc_wind.nml    $WW3_Exe_Dir || exit 8
cp     $Couple_Lib_exec_WW3_Dir/ww3_prnc_current.nml $WW3_Exe_Dir || exit 8
cp     $Couple_Lib_exec_WW3_Dir/ww3_shel.nml         $WW3_Exe_Dir || exit 8
cp     $Couple_Lib_exec_WW3_Dir/ww3_ounf.nml         $WW3_Exe_Dir || exit 8
cp     $Couple_Lib_exec_WW3_Dir/namelists.nml        $WW3_Exe_Dir || exit 8
fi

#####--------------------- END OF COPYING FILES  -----------------------#####

# COMPILE COUPLER CODES
# STARTING RUN
cd $Couple_Run_Dir || exit 8
   $Couple_Run_Dir/couple_with_ww3.sh || exit 8
echo "DONE"
