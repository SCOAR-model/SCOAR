# change WW3_DIR for each case
#WW3_DIR=/vortexfs1/share/seolab/SCOAR2_share/scoar_ww3/Model/WW3/amazon/amazon2/WW3-6.07.1/model/DATA/amazon
#cp $WW3_DIR/amazon_xcoord.dat .
#cp $WW3_DIR/amazon_ycoord.dat .
#cp $WW3_DIR/amazon_bathy.bot .

WW3_DIR=/vortexfs1/share/seolab/hseo/Model/WW3/WW3-6.07.1/model/amazon_hs
cp $WW3_DIR/mask.ww3 .
cp $WW3_DIR/mod_def.ww3 .
cp $WW3_DIR/mapsta.ww3  .
cp $WW3_DIR/nest.ww3 .

#ln -fs $WW3_DIR/roms_amazon_grid.nc .
