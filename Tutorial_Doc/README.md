
  <h2 align="center"> SCOAR TUTORIAL: NORTH ATLANTIC 10 KM </h2>

![figure](map_scoar_tutorial_norus.png)

<h3>Case summary </h3>
<p>This tutorial aims to showcase how to run the SCOAR Regional Coupled system using a simple case over the North Atlantic. The chosen domain is illustrated in the figure above. Data are avaialble to run 2 days starting December 1st, 2018.</p>

<h3>Input Data </h3>
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
Under <em>WW3_Input</em> are the initial and boundary conditions necessary to run WW3. These data have been pre-processed using daily Mercator-International GLORYS reanalysis dataset. A forcing file for tides input is also provided. No rivers are included in this tutorial but if any, it would be placed in this directory as well. The files included here are:<br>
 <br>

<h4>Grids and Templates</h4>

<h3>Executables</h3>
<h4> Fortran codes compilation </h4>

<h4>Models</h4>
<h5>WRF</h5>
<h5>ROMS</h5>
<h5>WW3</h5>

<h3>Run SCOAR</h3>

main namelist and job submission

output in Run/ directory and post-process
