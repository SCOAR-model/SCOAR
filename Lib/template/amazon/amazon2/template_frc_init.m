clear all;close all
% create general forcing file
% all components are set to zeros.
%cd /Users/hseo/bin/SCOAR2_Prep/prep/amazon/amazon2/template
cd /home/csauvage/Documents/so1_cesar/matlab_ROMS_preprocessing/SCOAR2_Prep/prep/amazon2/template
nameit='roms-amazon2-nolake';nameit2='amazon2';
grd=rnt_gridload2(nameit);
grdname=grd.grdfile;
title='';


% FORC
% the following file will be made if it does not exist.
forcfile=['ROMS_ForcingGeneral-',nameit2,'.nc'];
smst=15;smsc=360;
create_forcing_new(forcfile,grdname,title,smst,smsc);
rnc_SetForcAllZero_hyodae(grd,forcfile);

% Set fill value for Wind fields (becuase it reads usfc and vsfc which have fill values)
        unix(['ncatted -O -a _FillValue,Uwind,o,f,-1.0e37 ',forcfile]);
        unix(['ncatted -O -a _FillValue,Vwind,o,f,-1.0e37 ',forcfile]);
        unix(['ncatted -O -a _FillValue,Uwind_abs,o,f,-1.0e37 ',forcfile]);
        unix(['ncatted -O -a _FillValue,Vwind_abs,o,f,-1.0e37 ',forcfile]);

% INIT
% CHEKC THIS!!
theta_s=grd.thetas;
theta_b=grd.thetab
Tcline=grd.tcline;
N=grd.N
Vtransform  =2;        %vertical transformation equation
Vstretching =4;        %vertical stretching function

Sinp.N           =N;            %number of vertical levels
Sinp.Vtransform  =Vtransform;   %vertical transformation equation
Sinp.Vstretching =Vstretching;  %vertical stretching function
Sinp.theta_s     =theta_s;      %surface control parameter
Sinp.theta_b     =theta_b;      %bottom  control parameter
Sinp.Tcline      =Tcline;       %surface/bottom stretching width
if (Vtransform==1)
  h=ncread(gridname,'h');
  hmin=min(h(:));
  hc=min(max(hmin,0),Tcline);
elseif (Vtransform==2)
  hc=Tcline;
end
Sinp.hc          =hc;           %stretching width used in ROMS

rmpath('/home/csauvage/Documents/so1_cesar/matlab_ROMS_preprocessing/SCOAR2_Prep/matlab_toolbox/Roms_tools/mask');
rmpath('/home/csauvage/Documents/so1_cesar/matlab_ROMS_preprocessing/SCOAR2_Prep/matlab_toolbox//matlib/rmask');
%rmpath('/Users/hseo/bin/matlab/manu_rnt/matlib/rmask/');
%rmpath('/Users/hseo/bin/matlab/manu_rnt/matlib/tools');
addpath /home/csauvage/Documents/ROMS/Tools_COAWST/mfiles/rutgers/grid
addpath /home/csauvage/Documents/ROMS/Tools_COAWST/mfiles/rutgers/netcdf
addpath /home/csauvage/Documents/ROMS/Tools_COAWST/mfiles/rutgers/
%addpath /Users/hseo/bin/matlab/ROMS_Matlab/utility
addpath /home/csauvage/Documents/ROMS/matlab_utility
gn=get_roms_grid(grd.grdfile,Sinp);

% create initial file
initfile=[nameit2,'-init.nc'];
create_roms_netcdf_init_mw_SCOAR(initfile,gn);

in=netcdf(initfile,'w');
variables={'u' 'v' 'temp' 'salt' 'zeta' 'ubar' 'vbar'};
for i=1:7
   disp(variables{i});
   in{variables{i}}(1,:,:,:)=0;
end

in{'ocean_time'}(1)=0;
in{'theta_s'}(:)=grd.thetas;
in{'theta_b'}(:)=grd.thetab;
in{'Tcline'}(:)=grd.tcline;
in{'Cs_r'}(:)=gn.Cs_r;
in{'Cs_w'}(:)=gn.Cs_w;
in{'sc_w'}(:)=gn.s_w
in{'sc_r'}(:)=gn.s_rho;
in{'hc'}(:)=gn.hc;
in{'Vtransform'}(:)=Vtransform;
in{'Vstretching'}(:)=Vstretching;
in{'spherical'}(:)=1;
close(in);

% create sst.nc usfc.nc vsfc.nc for interactive smoothing
% overwrite existing data
[I J]=size(grd.lonr);time=1;
create_sst_new('sst.nc',grdname,time);
create_usfc_new('usfc.nc',grdname,time);
create_vsfc_new('vsfc.nc',grdname,time);

ncw=netcdf('sst.nc');ncw{'sst'}(:,:)=0;close(ncw);
ncw=netcdf('usfc.nc');ncw{'usfc'}(:,:)=0;close(ncw);
ncw=netcdf('vsfc.nc');ncw{'vsfc'}(:,:)=0;close(ncw);
