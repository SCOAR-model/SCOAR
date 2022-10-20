function create_roms_netcdf_init_mw(init_file,gn);

%create init file
nc_init=netcdf.create(init_file,'clobber');
 
%% Global attributes:

disp(' ## Defining Global Attributes...')
netcdf.putAtt(nc_init,netcdf.getConstant('NC_GLOBAL'),'history', ['Created by updatclim on ' datestr(now)]);
netcdf.putAtt(nc_init,netcdf.getConstant('NC_GLOBAL'),'type', 'initial forcing file from http://hycom.coaps.fsu.edu:8080/thredds/dodsC/glb_analysis');


%% Dimensions:

disp(' ## Defining Dimensions...')
 
%get some grid info
  %[LP,MP]=size(gn.lon_rho);
  [LP,MP]=size(gn.lon_rho);
  L=LP-1;
  Lm=L-1;
  M=MP-1;
  Mm=M-1;
  L  = Lm+1;
  M  = Mm+1;
  xpsi  = L;
  xrho  = LP;
  xu    = L;
  xv    = LP;
  epsi = M;
  erho = MP;
  eu   = MP;
  ev   = M;
  N       = gn.N;
  
psidimID = netcdf.defDim(nc_init,'xpsi',L);
xrhodimID = netcdf.defDim(nc_init,'xrho',LP);
xudimID = netcdf.defDim(nc_init,'xu',L);
xvdimID = netcdf.defDim(nc_init,'xv',LP);

epsidimID = netcdf.defDim(nc_init,'epsi',M);
erhodimID = netcdf.defDim(nc_init,'erho',MP);
eudimID = netcdf.defDim(nc_init,'eu',MP);
evdimID = netcdf.defDim(nc_init,'ev',M);

s_rhodimID = netcdf.defDim(nc_init,'sc_r',N);
s_wdimID = netcdf.defDim(nc_init,'sc_w',N+1);
timedimID = netcdf.defDim(nc_init,'time',1);

%% Variables and attributes:
disp(' ## Defining Dimensions, Variables, and Attributes...')

sphericalID = netcdf.defVar(nc_init,'spherical','short',timedimID);
netcdf.putAtt(nc_init,sphericalID,'long_name','grid type logical switch');
netcdf.putAtt(nc_init,sphericalID,'flag_meanings','spherical Cartesian');
netcdf.putAtt(nc_init,sphericalID,'flag_values','1, 0');

VtransformID = netcdf.defVar(nc_init,'Vtransform','long',timedimID);
netcdf.putAtt(nc_init,VtransformID,'long_name','vertical terrain-following transformation equation');

VstretchingID = netcdf.defVar(nc_init,'Vstretching','long',timedimID);
netcdf.putAtt(nc_init,VstretchingID,'long_name','vertical terrain-following stretching function');
 
theta_bID = netcdf.defVar(nc_init,'theta_b','double',timedimID);
netcdf.putAtt(nc_init,theta_bID,'long_name','S-coordinate bottom control parameter');
netcdf.putAtt(nc_init,theta_bID,'units','1');

theta_sID = netcdf.defVar(nc_init,'theta_s','double',timedimID);
netcdf.putAtt(nc_init,theta_sID,'long_name','S-coordinate surface control parameter');
netcdf.putAtt(nc_init,theta_sID,'units','1');

tcline_ID = netcdf.defVar(nc_init,'Tcline','double',timedimID);
netcdf.putAtt(nc_init,tcline_ID,'long_name','S-coordinate surface/bottom layer width');
netcdf.putAtt(nc_init,tcline_ID,'units','meter');

hc_ID = netcdf.defVar(nc_init,'hc','double',timedimID);
netcdf.putAtt(nc_init,hc_ID,'long_name','S-coordinate parameter, critical depth');
netcdf.putAtt(nc_init,hc_ID,'units','meter');

Cs_rID = netcdf.defVar(nc_init,'Cs_r','double',s_rhodimID);
netcdf.putAtt(nc_init,Cs_rID,'long_name','S-coordinate stretching curves at RHO-points');
netcdf.putAtt(nc_init,Cs_rID,'units','1');
netcdf.putAtt(nc_init,Cs_rID,'valid_min',-1);
netcdf.putAtt(nc_init,Cs_rID,'valid_max',0);
netcdf.putAtt(nc_init,Cs_rID,'field','Cs_r, scalar');

Cs_wID = netcdf.defVar(nc_init,'Cs_w','double',s_wdimID);
netcdf.putAtt(nc_init,Cs_wID,'long_name','S-coordinate stretching curves at W-points');
netcdf.putAtt(nc_init,Cs_wID,'units','1');
netcdf.putAtt(nc_init,Cs_wID,'valid_min',-1);
netcdf.putAtt(nc_init,Cs_wID,'valid_max',0);
netcdf.putAtt(nc_init,Cs_wID,'field','Cs_w, scalar');

sc_rID = netcdf.defVar(nc_init,'sc_r','double',s_rhodimID);
netcdf.putAtt(nc_init,sc_rID,'long_name','S-coordinate at RHO-points');
netcdf.putAtt(nc_init,sc_rID,'units','1');
netcdf.putAtt(nc_init,sc_rID,'valid_min',-1);
netcdf.putAtt(nc_init,sc_rID,'valid_max',0);
netcdf.putAtt(nc_init,sc_rID,'field','sc_r, scalar');

sc_wID = netcdf.defVar(nc_init,'sc_w','double',s_wdimID);
netcdf.putAtt(nc_init,sc_wID,'long_name','S-coordinate at W-points');
netcdf.putAtt(nc_init,sc_wID,'units','1');
netcdf.putAtt(nc_init,sc_wID,'valid_min',-1);
netcdf.putAtt(nc_init,sc_wID,'valid_max',0);
netcdf.putAtt(nc_init,sc_wID,'field','sc_w, scalar');

ocean_timeID = netcdf.defVar(nc_init,'ocean_time','double',timedimID);
netcdf.putAtt(nc_init,ocean_timeID,'long_name','time since initialization');
netcdf.putAtt(nc_init,ocean_timeID,'units','second');
netcdf.putAtt(nc_init,ocean_timeID,'field','ocean_time, scalar, series');

saltID = netcdf.defVar(nc_init,'salt','float',[xrhodimID erhodimID s_rhodimID timedimID]);
netcdf.putAtt(nc_init,saltID,'long_name','salinity');
netcdf.putAtt(nc_init,saltID,'units','PSU');
netcdf.putAtt(nc_init,saltID,'field','salinity, scalar, series');

tempID = netcdf.defVar(nc_init,'temp','float',[xrhodimID erhodimID s_rhodimID timedimID]);
netcdf.putAtt(nc_init,tempID,'long_name','temperature');
netcdf.putAtt(nc_init,tempID,'units','C');
netcdf.putAtt(nc_init,tempID,'field','temperature, scalar, series');

uID = netcdf.defVar(nc_init,'u','float',[xudimID eudimID s_rhodimID timedimID]);
netcdf.putAtt(nc_init,uID,'long_name','u-momentum component');
netcdf.putAtt(nc_init,uID,'units','meter second-1');
netcdf.putAtt(nc_init,uID,'field','u-velocity, scalar, series');

ubarID = netcdf.defVar(nc_init,'ubar','float',[xudimID eudimID timedimID]);
netcdf.putAtt(nc_init,ubarID,'long_name','vertically integrated u-momentum component');
netcdf.putAtt(nc_init,ubarID,'units','meter second-1');
netcdf.putAtt(nc_init,ubarID,'field','ubar-velocity, scalar, series');

vID = netcdf.defVar(nc_init,'v','float',[xvdimID evdimID s_rhodimID timedimID]);
netcdf.putAtt(nc_init,vID,'long_name','v-momentum component');
netcdf.putAtt(nc_init,vID,'units','meter second-1');
netcdf.putAtt(nc_init,vID,'field','v-velocity, scalar, series');

vbarID = netcdf.defVar(nc_init,'vbar','float',[xvdimID evdimID timedimID]);
netcdf.putAtt(nc_init,vbarID,'long_name','vertically integrated v-momentum component');
netcdf.putAtt(nc_init,vbarID,'units','meter second-1');
netcdf.putAtt(nc_init,vbarID,'field','vbar-velocity, scalar, series');
 
zetaID = netcdf.defVar(nc_init,'zeta','float',[xrhodimID erhodimID timedimID]);
netcdf.putAtt(nc_init,zetaID,'long_name','free-surface');
netcdf.putAtt(nc_init,zetaID,'units','meter');
netcdf.putAtt(nc_init,zetaID,'field','free-surface, scalar, series');
 
netcdf.close(nc_init)



