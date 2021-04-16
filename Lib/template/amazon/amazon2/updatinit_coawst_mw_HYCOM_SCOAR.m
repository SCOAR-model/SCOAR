function updatinit_coawst_mw(fn,gn,ini,wdr,T1,ocean_time)
% script create_roms_init

    init_file=[ini];

      ocean_time=0;

    theta_s   = gn.theta_s;
    theta_b   = gn.theta_b;
    Tcline    = gn.Tcline;
    N         = gn.N;
    Vtransform= gn.Vtransform;
    Vstretching=gn.Vstretching;

%5) Obtain grid information.
   h=gn.h;
   hmin=min(h(:));
%  hc=min([hmin,Tcline]);
   hc=gn.hc;
   [LP,MP]=size(gn.lon_rho);
   L=LP-1;
   Lm=L-1;
   M=MP-1;
   Mm=M-1;
   L  = Lm+1;
   M  = Mm+1;
   xi_psi  = L;
   xi_rho  = LP;
   xi_u    = L;
   xi_v    = LP;
   eta_psi = M;
   eta_rho = MP;
   eta_u   = MP;
   eta_v   = M;
   s       = gn.N;
   Cs_r=gn.Cs_r;
   Cs_w=gn.Cs_w;
   sc_r=gn.s_rho;
   sc_w=gn.s_w;
    
%6) Initialize zeta, salt, temp, u, v, ubar, vbar.
create_roms_netcdf_init_mw_SCOAR(init_file,grd);

nc_init=netcdf.open(init_file,'NC_WRITE');

disp(' ## Filling Variables in netcdf file with data...')

% copy clm time to init time
  tempid = netcdf.inqVarID(nc_init,'ocean_time');  %get id
  netcdf.putVar(nc_init,tempid,ocean_time);        %set variable

%
% *** Init values, ONLY WORKS FOR VALUES ON SAME GRID ****************
% *** ADD Interpolation if grids are not the same ********************
vars2d={'zeta','ubar','vbar'};
vars3d={'u','v','temp','salt'};
%% 2D variables
for i=1:length(vars2d)
    eval(['tempclmid = netcdf.inqVarID(nc_clm,''',vars2d{i},''');']);%get id
    eval([vars2d{i},'=netcdf.getVar(nc_clm,tempclmid);']);%get data   
    eval(['tempid = netcdf.inqVarID(nc_init,''',vars2d{i},''');']);%get id
    eval(['netcdf.putVar(nc_init,tempid,',vars2d{i},');']);%set variable
end
%% 3D variables
for i=1:length(vars3d)
    eval(['tempclmid = netcdf.inqVarID(nc_clm,''',vars3d{i},''');']);%get id
    eval([vars3d{i},'=netcdf.getVar(nc_clm,tempclmid);']);%get data
    eval(['tempid = netcdf.inqVarID(nc_init,''',vars3d{i},''');']);%get id
    eval(['netcdf.putVar(nc_init,tempid,',vars3d{i},');']);%set variable
    clear temp3 tempv tempt
end

spherical=1;
morvars={'theta_s','theta_b','Tcline','Cs_r','Cs_w','sc_w','sc_r','hc', ...
         'Vtransform','Vstretching','spherical',...
         'ocean_time'};
for i=1:length(morvars)
    eval(['tempid = netcdf.inqVarID(nc_init,''',morvars{i},''');']);%get id
    eval(['netcdf.putVar(nc_init,tempid,',morvars{i},');']);%set variable
    eval(['clear ',morvars{i},';']);
end

netcdf.close(nc_init)
netcdf.close(nc_clm)
