import numpy as np
import netCDF4
import sys
import os
from mpl_toolkits.basemap import Basemap
import matplotlib.colors as colors
from scipy.signal import medfilt2d
from scipy.interpolate import griddata
from scipy import interpolate
import matplotlib.pyplot as plt
import pyroms
import pyroms_toolbox
from bathy_smoother import *
import creep
import scipy.io as sio
import netCDF4 as ncd  

#file1data=ncd.Dataset('roms-gs_highRes-grid.nc','a')
file1data=ncd.Dataset('roms-gs_highRes-grid_nolake.nc','a')

visc=file1data.createVariable('visc_factor','float64',('eta_rho', 'xi_rho'))
diff=file1data.createVariable('diff_factor','float64',('eta_rho', 'xi_rho'))

visc_factor=np.ones((275,425))
diff_factor=np.ones((275,425))


II=425
JJ=275

visc0=1
diff0=1
fac=50
width=30

#south
for jj in range(0,width):
	cff= (width-jj+1) * fac/width
	for ii in range(0,II):
		visc_factor[jj,ii]=cff
		diff_factor[jj,ii]=cff

#north
for jj in range(JJ-width+1,JJ):
#        cff= (width-jj+1) * fac/width
	cff=fac*visc0 + (JJ-jj)*(visc0-fac*visc0)/width;
	for ii in range(0,II):
		visc_factor[jj,ii]=cff
		diff_factor[jj,ii]=cff


#east
count=0
for ii in range(max(1,II-width)+1,II):#II-width+1,II):
	count+=1
	cff=fac*visc0 + (II-ii)*(visc0-fac*visc0)/width;
	for jj in range(width-(count-1),(JJ-width)+(count)):#))width+1,JJ-width):
		visc_factor[jj,ii]=cff
		diff_factor[jj,ii]=cff

#west
for ii in range(0,width):
	cff= (width-ii+1) * fac/width
	#for jj in range(width+1,JJ-width):
	for jj in range(max(1,ii),min(JJ-ii,JJ)):#width+1,JJ-width):
		visc_factor[jj,ii]=cff
		diff_factor[jj,ii]=cff


visc[:]=visc_factor[:]
diff[:]=diff_factor[:]

