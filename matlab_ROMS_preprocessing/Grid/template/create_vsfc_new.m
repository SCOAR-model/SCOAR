function  create_forcing(frcname,grdname,time);
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

nw('xi_v') = Lp;
nw('eta_v') = M;
nw('time') = length(time);
%
%  Create variables and attributes
%
nw{'time'} = ncdouble('time');
nw{'time'}.long_name = ncchar('time');
nw{'time'}.long_name = 'time';
nw{'time'}.units = ncchar('days');
nw{'time'}.units = 'days';

nw{'vsfc'} = ncdouble('time', 'eta_v', 'xi_v');
nw{'vsfc'}.long_name = ncchar('surface meridional current');
nw{'vsfc'}.long_name = 'surface meridional current';
nw{'vsfc'}.units = ncchar('meter second-1');
nw{'vsfc'}.units = 'meter second-1';

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
nw{'time'}(:) = time;

close(nw);
