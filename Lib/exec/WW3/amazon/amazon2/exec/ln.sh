# change WW3_DIR for each case
WW3_DIR=/vortexfs1/share/seolab/WW3/WW3-6.07.1/model

ln -fs $WW3_DIR/exe/ww3_* .
cd nml
ln -fs $WW3_DIR/nml/ww3_* ./
cd -
