#!/bin/sh
set -ax
#### BEGINNING: USER DEFINITIONS ####
expname2='miso6'
# absolte path
wrf_geo_grid='/nara/data/hseo/miso/miso6/roms_preprocessing/Grid/geo_em.d01.nc'

do_roms='no'
do_roms_nolake='no'
do_gen_grid='yes'
do_template='no'
#roms grid is needed to process WW3 grid files
do_WW3_grid='no'
#### END: USER DEFINITIONS ####

# toolbox and roms topofile
main_path_matlab_toolbox='/vortexfs1/share/seolab/SCOAR2_share/matlab_ROMS_preprocessing/SCOAR2_Prep/matlab_toolbox'
topopath="${main_path_matlab_toolbox}/Roms_tools/Topo/etopo2.nc"

#grid info case
case_roms_nolake="roms-${expname2}-nolake"
case_roms="roms-${expname2}"
case_wrf="wrf-${expname2}"

#grids names
roms_grid="roms-${expname2}-grid.nc"
roms_grid_nolake="roms-${expname2}-grid_nolake.nc"
wrf_grid="wrf-${expname2}-grid.nc"


#directories names
dirname="roms_${expname2}"
dirname_wrf="wrf_${expname2}"
dirname_nolake="roms_${expname2}_nolake"

#get main folder path
main_folder=$(pwd)

path_roms_case="$main_folder/${dirname}/${roms_grid}"
path_roms_nolake_case="$main_folder/${dirname_nolake}/${roms_grid_nolake}"
path_wrf_case="$main_folder/${dirname_wrf}/${wrf_grid}"


if [ $do_roms = 'yes' ]; then

	echo "Process $roms_grid ..."

	cp crocotools_param.m $dirname/crocotools_param.m

	cd $dirname

	matlab -nodisplay -nodesktop -r "               clear all;\
						        addpath(genpath('$main_path_matlab_toolbox/matlib/'));\
	                                                addpath(genpath('$main_path_matlab_toolbox/croco_tools-v1.1/'));\
							addpath(genpath('../'));\
	                                                topofile='$topopath';\
	                                                wrf_geo_grid='$wrf_geo_grid';\
	                                                grdname='$roms_grid';\
	                                                case_roms='$case_roms';\
							case_roms_nolake='$case_roms_nolake';\
                                                        case_wrf='$case_wrf';\
                                                        path_roms_case='$path_roms_case';\
                                                        path_roms_nolake_case='$path_roms_nolake_case';\
                                                        path_wrf_case='$path_wrf_case';\
	                                                run ./make_grid.m;\
	                                                exit;" > matlab_log_grid.out

	cd ../


	#wrf_grid is the same as roms_grid, just link it with another name
	echo "Copy $wrf_grid ..."
	cp $dirname/$roms_grid $dirname_wrf/$wrf_grid

fi

if [ $do_roms_nolake = 'yes' ]; then

	echo "Process $roms_grid_nolake ..."

	cp crocotools_param.m $dirname_nolake/crocotools_param.m

	cd $dirname_nolake

	#need display here to edit the mask if needed
	matlab -r 	 "                             clear all;\
					        addpath(genpath('$main_path_matlab_toolbox/matlib/'));\
                                                addpath(genpath('$main_path_matlab_toolbox/croco_tools-v1.1/'));\
						addpath(genpath('../'));\
                                                topofile='$topopath';\
                                                wrf_geo_grid='$wrf_geo_grid';\
                                                grdname='$roms_grid_nolake';\
                                                case_roms='$case_roms';\
						case_roms_nolake='$case_roms_nolake';\
                                                case_wrf='$case_wrf';\
                                                path_roms_case='$path_roms_case';\
                                                path_roms_nolake_case='$path_roms_nolake_case';\
                                                path_wrf_case='$path_wrf_case';\
                                                run ./make_grid_nolake.m;\
                                                exit;" > matlab_log_grid.out

	cd ../
fi

if [ $do_gen_grid = 'yes' ]; then

	echo "Process gen-grid ... "
	cd grid/

	#definitions of all the needed files with the right name
	f1_wrf="${case_wrf}-nxny.dat"
	f2_wrf="${case_wrf}-nxnyr.dat"
	f3_wrf="${case_wrf}-nxnyu.dat"
	f4_wrf="${case_wrf}-nxnyv.dat"
	f5_wrf="${case_wrf}-griddata.dat"
	f6_wrf="${case_wrf}-maskr.dat"
	f7_wrf="${case_wrf}-masku.dat"
	f8_wrf="${case_wrf}-maskv.dat"

	f1_roms="${case_roms}-nxnyr.dat"
	f2_roms="${case_roms}-nxnyu.dat"
	f3_roms="${case_roms}-nxnyv.dat"
	f4_roms="${case_roms}-maskr.dat"
	f5_roms="${case_roms}-masku.dat"
	f6_roms="${case_roms}-maskv.dat"

	f1_roms_nolake="${case_roms_nolake}-maskr.dat"
	f2_roms_nolake="${case_roms_nolake}-masku.dat"
	f3_roms_nolake="${case_roms_nolake}-maskv.dat"

	matlab -nodisplay -nodesktop -r "               clear all;\
        	                                        addpath(genpath('$main_path_matlab_toolbox/matlib/'));\
                	                                addpath(genpath('$main_path_matlab_toolbox/croco_tools-v1.1/'));\
                        	                        addpath(genpath('$main_path_matlab_toolbox/netcdf_toolbox/'));\
                                	                addpath(genpath('../'));\
                                        	        wrf_geo_grid='$wrf_geo_grid';\
	                                                case_roms='$case_roms';\
        	                                        case_roms_nolake='$case_roms_nolake';\
                	                                case_wrf='$case_wrf';\
							path_roms_case='$path_roms_case';\
                                                        path_roms_nolake_case='$path_roms_nolake_case';\
                                                        path_wrf_case='$path_wrf_case';\
							f1_wrf='$f1_wrf';\
							f2_wrf='$f2_wrf';\
							f3_wrf='$f3_wrf';\
							f4_wrf='$f4_wrf';\
							f5_wrf='$f5_wrf';\
							f6_wrf='$f6_wrf';\
							f7_wrf='$f7_wrf';\
							f8_wrf='$f8_wrf';\
							f1_roms='$f1_roms';\
							f2_roms='$f2_roms';\
							f3_roms='$f3_roms';\
							f4_roms='$f4_roms';\
							f5_roms='$f5_roms';\
							f6_roms='$f6_roms';\
							f1_roms_nolake='$f1_roms_nolake';\
							f2_roms_nolake='$f2_roms_nolake';\
							f3_roms_nolake='$f3_roms_nolake';\
                	                                run ./gen_grid.m;\
                        	                        exit;" > matlab_log_grid.out


	cd ../
fi

if [ $do_template = 'yes' ]; then
	
	cp crocotools_param.m template/crocotools_param.m

	echo "Process templates ... "
	cd template/

	matlab -nodisplay -nodesktop -r "               clear all;\
        	                                        addpath(genpath('$main_path_matlab_toolbox/matlib/'));\
                	                                addpath(genpath('$main_path_matlab_toolbox/croco_tools-v1.1/'));\
                        	                        addpath(genpath('$main_path_matlab_toolbox/netcdf_toolbox/'));\
                                	                addpath(genpath('$main_path_matlab_toolbox/mexcdf/'));\
							addpath $main_path_matlab_toolbox/mfiles/rutgers/grid;\
							addpath $main_path_matlab_toolbox/mfiles/rutgers/netcdf;\
							addpath $main_path_matlab_toolbox/mfiles/rutgers/;\
							addpath $main_path_matlab_toolbox/matlab_utility;\
							addpath(genpath('../'));\
                                	                case_roms_nolake='$case_roms_nolake';\
                                	                case_roms='$case_roms';\
                                	                case_wrf='$case_wrf';\
                                        	        expname2='$expname2';\
							path_roms_case='$path_roms_case';\
							path_roms_nolake_case='$path_roms_nolake_case';\
							path_wrf_case='$path_wrf_case';\
                                                	run ./template_frc_init.m;\
	                                                exit;" > matlab_log_grid.out

	cd ../

fi

if [ $do_WW3_grid = 'yes' ]; then


        echo "Process WW3 grid files ... "
        cd grid/
	#full_roms_grid_path="${main_folder}/${path_roms_nolake_case}"
	full_roms_grid_path="${path_roms_nolake_case}"
	ww3_xcoord_file="${main_folder}/grid/WW3/${expname2}_xcoord.dat"
	ww3_ycoord_file="${main_folder}/grid/WW3/${expname2}_ycoord.dat"
	ww3_bath_file="${main_folder}/grid/WW3/${expname2}_bathy.bot"
	ww3_mask_file="${main_folder}/grid/WW3/${expname2}_mapsta.inp"
        
	matlab -nodisplay -nodesktop -r "               clear all;\
                                                        addpath(genpath('$main_path_matlab_toolbox/mfiles/'));\
                                                        addpath(genpath('../'));\
                                                        full_roms_grid_path='$full_roms_grid_path';\
                                                        ww3_xcoord='$ww3_xcoord_file';\
                                                        ww3_ycoord='$ww3_ycoord_file';\
                                                        ww3_bath='$ww3_bath_file';\
                                                        ww3_mask='$ww3_mask_file';\
                                                        run ./create_ww3_grid.m;\
                                                        exit;" > matlab_log_grid.out

        cd ../

fi

