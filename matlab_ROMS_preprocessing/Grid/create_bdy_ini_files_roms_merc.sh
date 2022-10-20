#!/bin/sh
################### USER DEFINTION ##############################

expname2='miso6'

#ROMS grid
#FOR SCOAR it can be the grid generated in expname2/roms_expname2/roms-expname2-grid.nc
main_folder=$(pwd)

#MERCATOR directory
mercator_dir='/vortexfs1/share/seolab/Data/MERCATOR/BoB/2019/'

#MERCATOR file prefix without date
#MERCATOR file name shoud be: $mercator_prefix$year$month$day.nc 
mercator_prefix='global-analysis-forecast-phy-001-030_'

#output name prefix
output_file_prefix='mercator.'

#start year
year=2019
#start month
month=1
#start day
day=2

#end month
monthe=1
#end day
day_end=31

#dealing with MERCATOR time offset...
#Don't really matter for couple SCOAR simulations
#DOES matter if boundary needed for ROMS only simulations

#(1950,1,1) => (2019,1,1)
spyear=1951
spmonth=1
spday=1


################### USER DEFINTION ##############################
#################################################
#matlab toolbox includind the mfiles toolbox with updated scripts to handle MERCATOR files
matlab_toolbox='/vortexfs1/share/seolab/SCOAR2_share/matlab_ROMS_preprocessing/SCOAR2_Prep/matlab_toolbox'
dirname_nolake="roms_${expname2}_nolake"
roms_grid_nolake="roms-${expname2}-grid_nolake.nc"
modelgrid="$main_folder/${dirname_nolake}/${roms_grid_nolake}"

dirname="mercator_bry_$expname2"

cp crocotools_param.m  $dirname/crocotools_param.m

cd $dirname

#Mercator daily file
index_t=1

#if day is not 1 then dayb=day otherwise dayb=1
if [ $day -gt 1 ]
then
	dayb=$day
else
	dayb=1
fi


for m in $(seq $month 1 $monthe)
do
        #check month
        if [ $m -lt 10 ]
        then
                mmonth='0'$m
        else
                mmonth=$m
        fi

        
	#number of days in month
       	if [ $m = 4 ] || [ $m = 6 ] || [ $m = 9 ] || [ $m = 11 ]
        then
                maxd=30
       	elif [ $m = 2 ]
        then	
		if [ $(($year%4)) = 0 ]
		then
               		maxd=29 
		else
			maxd=28
		fi
        else
                maxd=31
                
        fi	
	
	if [ $m -eq $monthe ]
	then
		#go to $day_end
       		maxd=$day_end
	fi


	#deal with sp month
        if [ $spmonth = 4 ] || [ $spmonth = 6 ] || [ $spmonth = 9 ] || [ $spmonth = 11 ]
        then
                maxspd=30
        elif [ $spmonth = 2 ]
        then
		if [ $(($spyear%4)) = 0 ]
		then
			maxspd=29
		else
			maxspd=28
		fi
        else
                maxspd=31
        fi

	
	for i in $(seq $dayb 1 $maxd)
        do
                #check days
                if [ $day -lt 10 ]
                then
                        dday='0'$day
                else
                        dday=$day
                fi

		echo 'call Matlab script to create files for '$year $mmonth $dday
		url_tmp=$mercator_dir$mercator_prefix$year$mmonth$dday".nc"
echo "processing: $url_tmp"
		echo 'MERCATOR FILE:' $url_tmp
	 	matlab -nodisplay -nodesktop -r "addpath(genpath('$matlab_toolbox/mfiles/'));  \
						addpath('./'); \
						T1=datenum($year,$mmonth,$dday,00,0,0); \
						t0=datenum($spyear,$spmonth,$spday);\
						tid1=$index_t;\
						url='$url_tmp';\
						modelgrid='$modelgrid';\
						run ./roms_master_climatology_coawst_mercator.m;\
						exit;" > matlab_log.out
		
		#echo 'rename output files'
		#rename output file
		mv './coawst_bdy.nc'  './bdy/'$output_file_prefix'bry_1dy_'$year$mmonth$dday'.nc'
		#mv './coawst_clm.nc'  './'$output_file_prefix'clm_1dy_'$year$mmonth$dday'.nc'
		rm './coawst_clm.nc'  
		mv './coawst_ini.nc'  './ini/'$output_file_prefix'ini_1dy_'$year$mmonth$dday'.nc'
                
		#add day
                if [ $day -eq $maxd ]
                then
                        day=1
			dayb=1
                else
                        day=$(( day + 1 ))
                fi

		#deal with spday and spmonth
                if [ $spday -eq $maxspd ]
                then
                        spday=1
			spmonth=$(( spmonth + 1 ))
                else
                        spday=$(( spday + 1 ))
                fi
		
		#deal with spyear
		if [ $spmonth -eq 13 ]
		then
			spmonth=1
			spyear=$(( spyear + 1 ))
		fi
		
		
	done
done
