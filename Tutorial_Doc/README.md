
  <h2 align="center"> SCOAR TUTORIAL: NORTH ATLANTIC 10 KM </h2>

![figure](map_scoar_tutorial_norus.png)


<p>This tutorial aims to showcase how to run the SCOAR Regional Coupled system using a simple case over the North Atlantic. The chosen domain is illustrated in the figure above. Data are avaialble to run 2 days starting December 1st, 2018.</p>

<h3> 1. Input Data </h3>
The inputs data for each model are located under <em>Data/domains/tutorial/tutorial1/ </em>

<h4>WRF inputs</h4>
Under <em>WRF_Input</em> are the initial, boundary and lower input conditions necessary to run WRF. These data have been pre-processed using 3-hourly ECMWF ERA5 reanalysis data. The files included here are:<br>
<br>
<ul>
  <li> wrfinput_d01</li>
  <li> wrfbdy_d01</li>
  <li> wrflowinp_d01</li>
</ul>

<h4>ROMS inputs</h4>
Under <em>ROMS_Input</em> are the initial and boundary conditions necessary to run ROMS. These data have been pre-processed using daily Mercator-International GLORYS reanalysis dataset. A forcing file for tides input is also provided. No rivers are included in this tutorial but if any, it would be placed in this directory as well. The files included here are:<br>
 <br>
<ul>
  <li> mercator.ini_1dy_20181201.nc </li>
  <li> mercator/1day/2018/mercator.bry_1dy_2018120*.nc </li>
  <li> tides.nc </li>
</ul>

<h4>WW3 inputs</h4>
Under <em>WW3_Input</em> are the initial and boundary conditions necessary to run WW3 as well as initial wave conditions that will be used be ROMS and WRF. The boundary conditions have been pre-processed using 3-hourly wave spectral points from IFREMER global hindcast runs. The initial conditions have been produced via a spin-up of the wave model. The files included here are:<br>
 <br>
<ul>
  <li> restart_file_ww3.zip </li>
  <li> ww3_norus_spinup_2018.201812.nc </li>
  <li> nest.ww3 </li>
</ul>

<em> restart_file_ww3.zip </em> needs to be unzipped, it should contain: restart030_20181201.ww3. This restart file have been produced using the WHOI HPC Poseidon, it may not work when used on another HPC. In that case, coupling with WW3 may not be available for the purpose of the tutorial and can be eventually turned off when setting the main SCOAR options in section 3.

<h4> Grids and Template </h4>
Grids and Template can be found respectively under <em> Lib/grids/tutorial/tutorial1 </em> and <em> Lib/template/tutorial/tutorial1 </em>. These files gather informations on the grids used by each model as well as divers masks and templates used in the SCOAR's couple routine. 
 

<h3> 2. Executables </h3>
<h4> Fortran codes compilation </h4>

<h4>Models</h4>
<h5>WRF</h5>
<h5>ROMS</h5>
<h5>WW3</h5>

<h3> 3. Run SCOAR </h3>

main namelist and job submission

output in Run/ directory and post-process
