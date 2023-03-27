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

#croco_tmp='crocotools_param.m'

#croco = sio.loadmat(croco_tmp)

# define vertical grd
#Vtrans=croco['Vtransform']
#theta_s=croco['theta_s']
#theta_b=croco['theta_b']
#Tcline=croco['Tcline']
#N=croco['N']
Vtrans = 2
theta_s = 7.0
theta_b = 2.
Tcline = 300
N = 30


fname = sys.argv[1]
bathyfile = sys.argv[2]
f2name = sys.argv[3]

#print(fname)
#print(f2name)
#print(bathyfile)


ncid = netCDF4.Dataset(fname, "r")

rlat = ncid.variables['XLAT_M'][0,:,:]
rlon = ncid.variables['XLONG_M'][0,:,:]
latv = ncid.variables['XLAT_V'][0,1:-1,:]
lonv = ncid.variables['XLONG_V'][0,1:-1,:]
latu = ncid.variables['XLAT_U'][0,:,1:-1]
lonu = ncid.variables['XLONG_U'][0,:,1:-1]
f = ncid.variables['F'][:]
cosang = ncid.variables['COSALPHA'][:]
sinang = ncid.variables['SINALPHA'][:]
mask = ncid.variables['LANDMASK'][:]
f = ncid.variables['F'][:]
corner_lats = ncid.corner_lats
corner_lons = ncid.corner_lons

map_proj = ncid.MAP_PROJ

#map_proj = 1
#print(map_proj)
#print(np.shape(rlon))
#print(np.shape(rlat))
#if (map_proj == 1):
my_proj = 'lcc'
lat_1 = ncid.TRUELAT1
lat_2 = ncid.TRUELAT2
lon_0 = ncid.STAND_LON
llcrnrlon = corner_lons[12]
llcrnrlat = corner_lats[12]
urcrnrlon = corner_lons[14]
urcrnrlat = corner_lats[14]

ncid.close()

#map = Basemap(projection=my_proj, lat_1=lat_1, lon_0=lon_0, \
#llcrnrlon=llcrnrlon, llcrnrlat=llcrnrlat, urcrnrlon=urcrnrlon, urcrnrlat=urcrnrlat, \
#resolution='h')

#map = Basemap(projection='lcc',boundinglat=10,lon_0=270,resolution='l')
map = Basemap(width=12000000,height=9000000,
            rsphere=(6378137.00,6356752.3142),\
            resolution='l',area_thresh=1000.,projection='lcc',\
            lat_1=45.,lat_2=55,lat_0=50,lon_0=-107.)
# define the 4 corners of the grid
# first point is the top left corner then counter clock wise rotation
lon0=corner_lons[13] ; lat0=corner_lats[13]
lon1=corner_lons[12] ; lat1=corner_lats[12]
lon2=corner_lons[15] ; lat2=corner_lats[15]
lon3=corner_lons[14] ; lat3=corner_lats[14]

#print(lon0)
#print(lon1)
#print(lon2)
#print(lon3)
#print('#####')
#print(lat0)
#print(lat1)
#print(lat2)
#print(lat3)
#print('#####')




#generate the new grid
lonp=np.array([lon0, lon1, lon2, lon3])
latp=np.array([lat0, lat1, lat2, lat3])

# shift data so lons go from 0 to 360 instead of -180 to 180.
###########################lonp = np.where(lonp < 0, lonp+360, lonp)

beta = np.array([1, 1, 1, 1]) 

Mp, Lp  = rlon.shape
hgrd = pyroms.grid.Gridgen(lonp, latp, beta, (Mp+1,Lp+1), proj=map)

lonv, latv = map(hgrd.x_vert, hgrd.y_vert, inverse=True)
hgrd = pyroms.grid.CGrid_geo(lonv, latv, map)
#######################hgrd.lon_rho = np.where(hgrd.lon_rho < 0, hgrd.lon_rho+360, hgrd.lon_rho)

hgrd.mask_rho = (1.0 - mask)

ncid = netCDF4.Dataset(bathyfile, "r")

lons = ncid.variables['lon'][:]
#lons_tmp = ncid.variables['lon'][:]
#lons=lons_tmp+360
lats = ncid.variables['lat'][:]
#lats=np.flip(lats)
#topo = ncid.variables['z'][:]
topo = ncid.variables['topo'][:]
ncid.close()

#print(lats)
#print(lons)


# depth positive
topo = -topo

# fix minimum depth
hmin = 15
#topo = pyroms_toolbox.change(topo, '>', hmin, hmin)
#topo=np.where(topo<hmin,hmin,topo)
# interpolate new bathymetry
lon, lat = np.meshgrid(lons, lats)

points =np.array( (lon.flatten(), lat.flatten()) ).T
values =topo.flatten()

#print("###")
#print(lat)
#print(lon)
#print(np.shape(lon))
#print(np.shape(lat))
#print(np.shape(np.ravel(lons)))
#print(np.shape(np.ravel(lats)))
#print(np.shape(np.ravel(topo)))
#print(np.shape((lon,lat)))
#h = griddata(lon.flat,lat.flat,topo.flat,hgrd.lon_rho,hgrd.lat_rho)
#h = griddata((lon,lat),topo.flat,(hgrd.lon_rho,hgrd.lat_rho),method='nearest')
#h = griddata((lon,lat),topo.flat,(rlon1,rlat1),method='nearest')
#interpf = interp2d(lons,lats,topo)
#lon_rho = np.reshape(hgrd.lon_rho,Lp*Mp)
#lat_rho = np.reshape(hgrd.lat_rho,Lp*Mp)
#lon_rho=np.ravel(rlon)
#lat_rho=np.ravel(rlat)
#print(np.shape(hgrd.lon_rho))
#print(np.shape(hgrd.lat_rho))
#print(np.shape(lons))
#print(np.shape(lats))

#print(np.shape(hgrd))

#for j in range(0,73):
#	h_tmp = interpf(hgrd.lon_rho[j,:],hgrd.lat_rho[j,:])
#	print(np.shape(h_tmp))
#	print(h_tmp)
#	h[j,:]=h_tmp[:]


#h = griddata(np.ravel(lon),np.ravel(topo),np.ravel(hgrd.lon_rho),method='cubic')

#h=np.zeros((Mp,Lp))
h = griddata(points,values,(hgrd.lon_rho,hgrd.lat_rho),method='cubic')

#h = ndimage.map_coordinates(topo[:], [lats[:], lons[:]], output=[hgrd.lat_rho[:], hgrd.lon_rho[:]])

#f = interpolate.RectBivariateSpline(lats[:],lons[:],topo[:])
#h = f(hgrd.lat_rho[:], hgrd.lon_rho[:])


#f=interpolate.RectBivariateSpline(lats,lons,topo,kx=1,ky=1)
#h = f(hgrd.lat_rho, hgrd.lon_rho)

#plt.imshow(h)
#plt.colorbar()
#plt.show()
#plt.savefig('interp.png')



# insure that depth is always deeper than hmin
#h = pyroms_toolbox.change(h, '<', hmin, hmin)
hraw = h.copy()
h=np.where(h<hmin,hmin,h)

###
hgrd.lon_rho = np.where(hgrd.lon_rho < 0, hgrd.lon_rho+360, hgrd.lon_rho)

# check bathymetry roughness
hgrd.mask_rho = np.reshape(hgrd.mask_rho, (Mp,Lp))
RoughMat = bathy_tools.RoughnessMatrix(h, hgrd.mask_rho)
print('Max Roughness value is: ', RoughMat.max())
#h = creep.cslf(h, nan, -200., 200.)
h = np.where(np.isnan(h), 5500.0, h)

# smooth the raw bathy using the direct iterative method from Martinho and Batteen
# (2006)
rx0_max = 0.35
h = bathy_smoothing.smoothing_Positive_rx0(hgrd.mask_rho, h, rx0_max)

# check bathymetry roughness again
RoughMat = bathy_tools.RoughnessMatrix(h, hgrd.mask_rho)
print('Max Roughness value is: ', RoughMat.max())
h = pyroms_toolbox.shapiro_filter.shapiro2(h, 2)

#print(np.shape(h))

hgrd.h = h
# define vertical grd
#Vtrans = 2
#theta_s = 7.0
#theta_b = 2.
#Tcline = 300
#N = 30
vgrd = pyroms.vgrid.s_coordinate_4(h, theta_b, theta_s, Tcline, N, hraw=hraw)
vgrd.h = h

#ROMS grid
grd_name = f2name
grd = pyroms.grid.ROMS_Grid(grd_name, hgrd, vgrd)


#write grid to netcdf file
#pyroms.grid.write_ROMS_grid(grd, filename=f2name)

