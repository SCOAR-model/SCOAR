
  <h2 align="center"> SCOAR TUTORIAL: NORTH ATLANTIC 10 KM </h2>

![figure](map_scoar_tutorial_norus.gif)


This tutorial aims to showcase how to run the SCOAR Regional Coupled system using a simple case over the North Atlantic. The chosen domain is illustrated in the figure above. Data are available to run 2 days starting December 1st, 2018.<br>
Currently, this tutorial works using:
<ul>
  <li> WRF version 4.2.2 </li>
  <li> ROMS version 3.9 </li>
  <li> WW3 version 6.01 </li>
</ul>

<h3> 1. Input Data </h3>
The inputs data for each model are located under <em>Data/domains/tutorial/tutorial1/ </em>

<h4>1.1. WRF inputs</h4>
Under <em>WRF_Input</em> are the initial, boundary and lower input conditions necessary to run WRF. These data have been pre-processed using 3-hourly ECMWF ERA5 reanalysis data. The files included here are:<br>
<br>
<ul>
  <li> wrfinput_d01</li>
  <li> wrfbdy_d01</li>
  <li> wrflowinp_d01</li>
</ul>

<h4>1.2. ROMS inputs</h4>
Under <em>ROMS_Input</em> are the initial and boundary conditions necessary to run ROMS. These data have been pre-processed using daily Mercator-International GLORYS reanalysis dataset. A forcing file for tides input is also provided. No rivers are included in this tutorial but if any, it would be placed in this directory as well. The files included here are:<br>
 <br>
<ul>
  <li> mercator.ini_1dy_20181201.nc </li>
  <li> mercator/1day/2018/mercator.bry_1dy_2018120*.nc </li>
  <li> tides.nc </li>
</ul>

<h4>1.3. WW3 inputs</h4>
Under <em>WW3_Input</em> are the initial and boundary conditions necessary to run WW3 as well as initial wave conditions that will be used be ROMS and WRF. The boundary conditions have been pre-processed using 3-hourly wave spectral points from IFREMER global hindcast runs. The initial conditions have been produced via a spin-up of the wave model. The files included here are:<br>
 <br>
<ul>
  <li> restart_file_ww3.zip </li>
  <li> ww3_norus_spinup_2018.201812.nc </li>
  <li> nest.ww3 </li>
</ul>

<em> restart_file_ww3.zip </em> needs to be unzipped, it should contain: restart030_20181201.ww3. This restart file have been produced using the WHOI HPC Poseidon, it may not work when used on another HPC. In that case, coupling with WW3 may not be available for the purpose of the tutorial and can eventually be turned off when setting the main SCOAR options in section 3.

<h4> 1.4. Grids and Template </h4>
Grids and Template can be found respectively under <em> Lib/grids/tutorial/tutorial1 </em> and <em> Lib/template/tutorial/tutorial1 </em>. These files gather informations on the grids used by each model as well as divers masks and templates used in the SCOAR's couple routine. These files have been generated using the SCOAR preprocess procedure.  
 

<h3> 2. Executables </h3>
<h4>2.1. Fortran codes compilation </h4>
Fortran codes used during SCOAR's couple routines have to be compiled before running the models. <br>
First, under <em>Lib/utils </em>: 
<ul>
  <li><em>./compile_utils_intel.sh </em></li>
</ul>
Executables are kept in the same directory. <br>
<br>
Second, under <em>Lib/codes_intel</em> : 
<ul>
  <li><em>./codes_compile.sh </em></li>
</ul>
Here, executables are moved to <em> Lib/exec/Coupler_intel </em>

<h4>2.2. Models</h4>
Model source codes are generally placed under their respective folders under <em> Model/*/tutorial/tutorial1 </em><br>
Then, for each model some necessary files and executables are moved under <em> Lib/exec/*/tutorial/tutorial1 </em><br>
For the tutorial to work as intended, ROMS and WW3 may need to compiled using the same options used whend first designed. <br>
CPPDEF options file for ROMS and switch options file for WW3 can be found here:<br>
<ul>
  <li> <em> Model/ROMS/tutorial/tutorial1/tutorial_cpp.h </em> </li>
  <li> <em> Model/WW3/tutorial/tutorial1/tutorial_switch.h </em></li>
</ul>

<h5>2.2.1. WRF</h5>
Under <em> Lib/exec/WRF/tutorial/tutorial1 </em> the one necessary file is the main WRF namelist:
<ul>
  <li> namelist.input </li>
</ul>

And optional files are:
<ul>
  <li> my_file_d01.txt (allow to add/remove output fromt the regular WRF output file.) </li>
  <li> tslist (list of locations for high frequency output.) </li>
  <li> wind-turbine-1.tbl (used if windfarm param. is turned on) </li>
  <li> windturbines.txt (used if windfarm param. is turned on) </li>
</ul>

<h5> 2.2.2. ROMS</h5>
Under <em> Lib/exec/ROMS/tutorial/tutorial1 </em> the necessary files are:
<ul>
  <li> romsM (main ROMS executable, need to be produced by the user and placed here.) </li>
  <li> ocean.in (main ROMS namelist.) </li>
  <li> romslaunch (bash script running ROMS.) </li>
  <li> varinfo.dat_v38 (ROMS variable information.) </li>
</ul>

<h5>2.2.3. WW3</h5>
Under <em> Lib/exec/WW3/tutorial/tutorial1 </em> the necessary files are namelists and executables:

- ww3_shel.nml (main WW3 namelist.) 
- ww3_prnc_wind.nml (namelist for wind forcing file.) 
- ww3_prnc_current.nml (namelist for ocean current forcing file.)
- ww3_ounf.nml (namelist for netcdf 2d outputs.)
- namelists.nml  (namelist for additional options.)
- exec/ww3_* (main WW3 executables, need to be produced by the user and placed here.)

And optional files are:

- points.list (list of locations for spectral point outputs.) 
- ww3_ounp.nml (namelist for netcdf spectral point outputs.) 


<h3> 3. Run SCOAR </h3>

The main SCOAR namelist and job submission script are located here: <em> main_scripts/tutorial/tutorial1 </em>

- main_tutorial1_r01.sh
- submit_main_tutorial1_r01a_poseidon.sh 


The main namelist sets all the coupling options and necessary paths to run SCOAR. <br>
For this tutorial, only few parameters need to be modified before starting the run.<br>

- export NCO=path_to_NCO_bin 

- export parameter_run_WW3=yes (can be set to 'no' if no wave coupling is wanted) 

- export tide_data=path_to_tides_input_file

- export ROMS_ICFile=path_to_roms_initial_conditions_input_file 

- export WW3_ICFile=path_to_ww3_restart_input_file 

- export WW3_ICFile_NC=path_to_ww3_initial_conditions_input_file 

- export WW3_BCFile=path_to_ww3_boundary_conditions_input_file 

- export Couple_Run_Dir=path_to_SCOAR_Tun_directory (i.e. /vortexfs1/share/seolab/csauvage/SCOAR/Run/$gridname2/$gridname/$RUN_ID)

- export Couple_Home_Dir=path_to_SCOAR_directory (i.e. /vortexfs1/share/seolab/csauvage/SCOAR)

- export Couple_WRF_Dir=path_to_WRF_directory (i.e. $Couple_Model_Dir/WRF/$gridname2/$gridname/WRF-4.2.2_march2022)

Other coupling options (i.e. different wave coupling parameterizations, ocean coupling, wind farm parameterization...) can eventually be tested here as well. Some options, like choosing or not to couple WW3 to ROMS might require ROMS to be compiled accordingly.

When the namelist is ready, it is time to run the model via the submission script. <br>
The submission script is based on SLURM syntax and can be adapted depending on user's needs and HPC.<br> 
Two paths need to be updated:
- scoar_dir=path_to_main_SCOAR_dir_namelist (i.e. /vortexfs1/share/seolab/csauvage/SCOAR/main_scripts/tutorial/tutorial1)

- Couple_Run_Dir=path_to_current_runID_directory (i.e. /vortexfs1/share/seolab/csauvage/SCOAR//Run/tutorial/tutorial1/tuto_r01)

- export RESTART=no (eventually turn to 'yes' if it is a restart)

This is also where the end date of the run is set, for this tutorial only 2 days worth of data are available. <br>
<ins>Note:</ins> currently, the end date minimum for a SCOAR run has to be at least one day after initial conditions. <br>
<ins>Note:</ins> If a different number of processors is used, the partitioning of processors in X and Y directions needs to be updated for ROMS in the ocean.in namelist. <br>
<br>
When ready, submit the job. <br>
<br>
If any error occurred during the run, a logfile is produced here and can be investigated to find the source of the error.<br> 
<br>
Once finished, the outputs for each model can be found under their respective folders here: <em> Run/tutorial/tutorial1/Data/* </em> and can be post-processed.
