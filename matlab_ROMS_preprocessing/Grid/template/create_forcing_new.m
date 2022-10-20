function  create_forcing(frcname,grdname,title,smst,smsc);
nc=netcdf(grdname);
L=length(nc('xi_psi'));
M=length(nc('eta_psi'));
result=close(nc);
Lp=L+1;
Mp=M+1;

nw = netcdf(frcname, 'clobber');
result = redef(nw);

%
%  Create dimensions
%

nw('xi_u') = L;
nw('eta_u') = Mp;
nw('xi_v') = Lp;
nw('eta_v') = M;
nw('xi_rho') = Lp;
nw('eta_rho') = Mp;
nw('xi_psi') = L;
nw('eta_psi') = M;
nw('sms_time') = length(smst);
nw('shf_time') = length(smst);
nw('swf_time') = length(smst);
nw('sst_time') = length(smst);
nw('srf_time') = length(smst);
nw('sss_time') = length(smst);

nw('wind_time') = length(smst);
nw('pair_time') = length(smst);
nw('tair_time') = length(smst);
nw('qair_time') = length(smst);
nw('cloud_time') =length(smst);
nw('rain_time') = length(smst);
nw('lrf_time') =length(smst);
nw('lhf_time') = length(smst);
nw('shf_time') =length(smst);

nw('wave_time') =length(smst);

%
%  Create variables and attributes
%
nw{'sms_time'} = ncdouble('sms_time');
nw{'sms_time'}.long_name = ncchar('surface momentum stress time');
nw{'sms_time'}.long_name = 'surface momentum stress time';
nw{'sms_time'}.units = ncchar('days');
nw{'sms_time'}.units = 'days';
nw{'sms_time'}.cycle_length = smsc;

nw{'shf_time'} = ncdouble('shf_time');
nw{'shf_time'}.long_name = ncchar('surface heat flux time');
nw{'shf_time'}.long_name = 'surface heat flux time';
nw{'shf_time'}.units = ncchar('days');
nw{'shf_time'}.units = 'days';
nw{'shf_time'}.cycle_length =smsc ;

nw{'wave_time'} = ncdouble('wave_time');
nw{'wave_time'}.long_name = ncchar('wave time');
nw{'wave_time'}.long_name = 'wave time';
nw{'wave_time'}.units = ncchar('days');
nw{'wave_time'}.units = 'days';
nw{'wave_time'}.cycle_length =smsc ;

nw{'swf_time'} = ncdouble('swf_time');
nw{'swf_time'}.long_name = ncchar('surface freshwater flux time');
nw{'swf_time'}.long_name = 'surface freshwater flux time';
nw{'swf_time'}.units = ncchar('days');
nw{'swf_time'}.units = 'days';
nw{'swf_time'}.cycle_length = smsc;


nw{'sst_time'} = ncdouble('sst_time');
nw{'sst_time'}.long_name = ncchar('sea surface temperature time');
nw{'sst_time'}.long_name = 'sea surface temperature time';
nw{'sst_time'}.units = ncchar('days');
nw{'sst_time'}.units = 'days';
nw{'sst_time'}.cycle_length = smsc;

nw{'sss_time'} = ncdouble('sss_time');
nw{'sss_time'}.long_name = ncchar('sea surface salinity time');
nw{'sss_time'}.long_name = 'sea surface salinity time';
nw{'sss_time'}.units = ncchar('days');
nw{'sss_time'}.units = 'days';
nw{'sss_time'}.cycle_length = smsc;

nw{'srf_time'} = ncdouble('srf_time');
nw{'srf_time'}.long_name = ncchar('solar shortwave radiation time');
nw{'srf_time'}.long_name = 'solar shortwave radiation time';
nw{'srf_time'}.units = ncchar('days');
nw{'srf_time'}.units = 'days';
nw{'srf_time'}.cycle_length = smsc;

% bulk
nw{'wind_time'} = ncdouble('wind_time'); %% 12 elements.
nw{'wind_time'}.long_name = ncchar('surface wind time');
nw{'wind_time'}.units = ncchar('days');
nw{'wind_time'}.cycle_length = smsc;
nw{'wind_time'}.field = ncchar('time, scalar, series');

nw{'pair_time'} = ncdouble('pair_time'); %% 12 elements.
nw{'pair_time'}.long_name = ncchar('surface air pressure time');
nw{'pair_time'}.units = ncchar('days');
nw{'pair_time'}.cycle_length = smsc;
nw{'pair_time'}.field = ncchar('time, scalar, series');

nw{'qair_time'} = ncdouble('qair_time'); %% 12 elements.
nw{'qair_time'}.long_name = ncchar('surface relative humidity time');
nw{'qair_time'}.units = ncchar('days');
nw{'qair_time'}.cycle_length = smsc;
nw{'qair_time'}.field = ncchar('time, scalar, series');

nw{'tair_time'} = ncdouble('tair_time'); %% 12 elements.
nw{'tair_time'}.long_name = ncchar('surface air temperature time');
nw{'tair_time'}.units = ncchar('days');
nw{'tair_time'}.cycle_length = smsc;
nw{'tair_time'}.field = ncchar('time, scalar, series');

nw{'cloud_time'} = ncdouble('cloud_time'); %% 12 elements.
nw{'cloud_time'}.long_name = ncchar('cloud fraction time');
nw{'cloud_time'}.units = ncchar('days');
nw{'cloud_time'}.cycle_length = smsc;
nw{'cloud_time'}.field = ncchar('time, scalar, series');

nw{'rain_time'} = ncdouble('rain_time'); %% 12 elements.
nw{'rain_time'}.long_name = ncchar('rain fall rate time');
nw{'rain_time'}.units = ncchar('days');
nw{'rain_time'}.cycle_length = smsc;
nw{'rain_time'}.field = ncchar('time, scalar, series');

nw{'lrf_time'} = ncdouble('lrf_time'); %% 12 elements.
nw{'lrf_time'}.long_name = ncchar('net longwave radiation flux time');
nw{'lrf_time'}.units = ncchar('days');
nw{'lrf_time'}.cycle_length = smsc;
nw{'lrf_time'}.field = ncchar('time, scalar, series');

nw{'sustr'} = ncdouble('sms_time', 'eta_u', 'xi_u');
nw{'sustr'}.long_name = ncchar('surface u-momentum stress');
nw{'sustr'}.long_name = 'surface u-momentum stress';
nw{'sustr'}.units = ncchar('Newton meter-2');
nw{'sustr'}.units = 'Newton meter-2';

nw{'svstr'} = ncdouble('sms_time', 'eta_v', 'xi_v');
nw{'svstr'}.long_name = ncchar('surface v-momentum stress');
nw{'svstr'}.long_name = 'surface v-momentum stress';
nw{'svstr'}.units = ncchar('Newton meter-2');
nw{'svstr'}.units = 'Newton meter-2';

nw{'shflux'} = ncdouble('shf_time', 'eta_rho', 'xi_rho');
nw{'shflux'}.long_name = ncchar('surface net heat flux');
nw{'shflux'}.long_name = 'surface net heat flux';
nw{'shflux'}.units = ncchar('Watts meter-2');
nw{'shflux'}.units = 'Watts meter-2';

nw{'swflux'} = ncdouble('swf_time', 'eta_rho', 'xi_rho');
nw{'swflux'}.long_name = ncchar('surface freshwater flux (E-P)');
nw{'swflux'}.long_name = 'surface freshwater flux (E-P)';
nw{'swflux'}.units = ncchar('centimeter day-1');
nw{'swflux'}.units = 'centimeter day-1';
nw{'swflux'}.positive = ncchar('net evaporation');
nw{'swflux'}.positive = 'net evaporation';
nw{'swflux'}.negative = ncchar('net precipitation');
nw{'swflux'}.negative = 'net precipitation';

nw{'SST'} = ncdouble('sst_time', 'eta_rho', 'xi_rho');
nw{'SST'}.long_name = ncchar('sea surface temperature');
nw{'SST'}.long_name = 'sea surface temperature';
nw{'SST'}.units = ncchar('Celsius');
nw{'SST'}.units = 'Celsius';

nw{'SSS'} = ncdouble('sss_time', 'eta_rho', 'xi_rho');
nw{'SSS'}.long_name = ncchar('sea surface salinity');
nw{'SSS'}.long_name = 'sea surface salinity';
nw{'SSS'}.units = ncchar('PSU');
nw{'SSS'}.units = 'PSU';

nw{'dQdSST'} = ncdouble('sst_time', 'eta_rho', 'xi_rho');
nw{'dQdSST'}.long_name = ncchar('surface net heat flux sensitivity to SST');
nw{'dQdSST'}.long_name = 'surface net heat flux sensitivity to SST';
nw{'dQdSST'}.units = ncchar('Watts meter-2 Celsius-1');
nw{'dQdSST'}.units = 'Watts meter-2 Celsius-1';

nw{'swrad'} = ncdouble('srf_time', 'eta_rho', 'xi_rho');
nw{'swrad'}.long_name = ncchar('solar shortwave radiation');
nw{'swrad'}.long_name = 'solar shortwave radiation';
nw{'swrad'}.units = ncchar('Watts meter-2');
nw{'swrad'}.units = 'Watts meter-2';
nw{'swrad'}.positive = ncchar('downward flux, heating');
nw{'swrad'}.positive = 'downward flux, heating';
nw{'swrad'}.negative = ncchar('upward flux, cooling');
nw{'swrad'}.negative = 'upward flux, cooling';

% bulk
nw{'Uwind'} = ncdouble('wind_time', 'eta_rho', 'xi_rho'); %% 113760 elements.
nw{'Uwind'}.long_name = ncchar('surface u-wind component, if uauo is on, it is relative wind');
nw{'Uwind'}.units = ncchar('meter second-1');
nw{'Uwind'}.field = ncchar('u-wind , scalar, series');

nw{'Vwind'} = ncdouble('wind_time', 'eta_rho', 'xi_rho'); %% 113760 elements.
nw{'Vwind'}.long_name = ncchar('surface v-wind component, if uauo is on, it is relative wind');
nw{'Vwind'}.units = ncchar('meter second-1');
nw{'Vwind'}.field = ncchar('v-wind , scalar, series');

nw{'Uwind_abs'} = ncdouble('wind_time', 'eta_rho', 'xi_rho'); %% 113760 elements.
nw{'Uwind_abs'}.long_name = ncchar('surface u-wind component, if uauo is on, it is absolute wind');
nw{'Uwind_abs'}.units = ncchar('meter second-1');
nw{'Uwind_abs'}.field = ncchar('u-wind , scalar, series');

nw{'Vwind_abs'} = ncdouble('wind_time', 'eta_rho', 'xi_rho'); %% 113760 elements.
nw{'Vwind_abs'}.long_name = ncchar('surface v-wind component, if uauo is on, it is absolute wind');
nw{'Vwind_abs'}.units = ncchar('meter second-1');
nw{'Vwind_abs'}.field = ncchar('v-wind , scalar, series');

nw{'Pair'} = ncdouble('pair_time', 'eta_rho', 'xi_rho'); %% 113760 elements.
nw{'Pair'}.long_name = ncchar('surface pair pressure');
nw{'Pair'}.units = ncchar('milibar');
nw{'Pair'}.field = ncchar('Pair , scalar, series');

nw{'Tair'} = ncdouble('tair_time', 'eta_rho', 'xi_rho'); %% 113760 elements.
nw{'Tair'}.long_name = ncchar('surface air temperature');
nw{'Tair'}.units = ncchar('Celcius');
nw{'Tair'}.field = ncchar('Tair , scalar, series');

nw{'Qair'} = ncdouble('qair_time', 'eta_rho', 'xi_rho'); %% 113760 elements.
nw{'Qair'}.long_name = ncchar('surface air relative humidity');
nw{'Qair'}.units = ncchar('percentage');
nw{'Qair'}.field = ncchar('Qair , scalar, series');

nw{'cloud'} = ncdouble('cloud_time', 'eta_rho', 'xi_rho'); %% 113760 elements.
nw{'cloud'}.long_name = ncchar('cloud fraction');
nw{'cloud'}.units = ncchar('nondimensional');
nw{'cloud'}.field = ncchar('cloud , scalar, series');

nw{'rain'} = ncdouble('rain_time', 'eta_rho', 'xi_rho'); %% 113760 elements.
nw{'rain'}.long_name = ncchar('rain fall rate');
nw{'rain'}.units = ncchar('kilogram meter-2 second-1');
nw{'rain'}.field = ncchar('rain , scalar, series');

nw{'lwrad'} = ncdouble('lrf_time', 'eta_rho', 'xi_rho'); %% 115200 elements.
nw{'lwrad'}.long_name = ncchar('net longwave radiation flux');
nw{'lwrad'}.units = ncchar('Watts meter-2');
nw{'lwrad'}.field = ncchar('longwave radiation, scalar, series');
nw{'lwrad'}.positive = ncchar('downward flux, heating');
nw{'lwrad'}.negative = ncchar('upward flux, cooling');

nw{'lwrad_down'} = ncdouble('lrf_time', 'eta_rho', 'xi_rho'); %% 115200 elements.
nw{'lwrad_down'}.long_name = ncchar('downwelling longwave radiation flux');
nw{'lwrad_down'}.units = ncchar('Watts meter-2');
nw{'lwrad_down'}.field = ncchar('downwelling longwave radiation, scalar, series');

nw{'latent'} = ncdouble('lhf_time', 'eta_rho', 'xi_rho'); %% 115200 elements.
nw{'latent'}.long_name = ncchar('net latent heat flux');
nw{'latent'}.units = ncchar('Watts meter-2');
nw{'latent'}.field = ncchar('latent heat flux, scalar, series');

nw{'sensible'} = ncdouble('shf_time', 'eta_rho', 'xi_rho'); %% 115200 elements.
nw{'sensible'}.long_name = ncchar('net sensible heat flux');
nw{'sensible'}.units = ncchar('Watts meter-2');
nw{'sensible'}.field = ncchar('sensible heat flux, scalar, series');

% wave dissipation: WW3 to ROMS
nw{'Wave_dissip'} = ncdouble('wave_time', 'eta_rho', 'xi_rho'); %% 115200 elements.
nw{'Wave_dissip'}.long_name = ncchar('wave dissipation');
nw{'Wave_dissip'}.units = ncchar('Watts meter-2');
nw{'Wave_dissip'}.field = ncchar('Wave_dissip, scalar, series');

% wave dissipation: WW3 to ROMS
nw{'Hwave'} = ncdouble('wave_time', 'eta_rho', 'xi_rho'); %% 115200 elements.
nw{'Hwave'}.long_name = ncchar('wind-induced significant wave height');
nw{'Hwave'}.units = ncchar('meter');
nw{'Hwave'}.field = ncchar('Hwave, scalar, series');



result = endef(nw);

%
% Create global attributes
%

%nw.title = ncchar(title);
%nw.title = title;
%nw.date = ncchar(date);
%nw.date = date;
%nw.grd_file = ncchar(grdname);
%nw.grd_file = grdname;
%nw.type = ncchar('ROMS forcing file');
%nw.type = 'ROMS forcing file';

%
% Write time variables
%
nw{'sms_time'}(:) = smst;

close(nw);
