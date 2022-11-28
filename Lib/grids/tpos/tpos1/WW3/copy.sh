# change WW3_DIR for each case
WW3_DIR1=/vortexfs1/share/seolab/hseo/SCOAR2/Model/WW3/tpos/tpos1/WW3-6.07.1/model/DATA/tpos/tpos1
ln -fs $WW3_DIR1/tpos1_xcoord.dat .
ln -fs $WW3_DIR1/tpos1_ycoord.dat .
ln -fs $WW3_DIR1/tpos1_bathy.bot .

WW3_DIR2=/vortexfs1/share/seolab/hseo/Model/WW3/tpos/tpos1/WW3-6.07.1/model/tpos1
ln -fs $WW3_DIR2/mask.ww3 .
ln -fs $WW3_DIR2/mod_def.ww3 .
ln -fs $WW3_DIR2/mapsta.ww3  .
ln -fs $WW3_DIR2/nest.ww3 .

ln -fs ../ROMS/roms-tpos1-grid_nolake.nc .
