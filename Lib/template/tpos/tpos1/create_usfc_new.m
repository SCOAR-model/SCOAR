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

nw('xi_u') = L;
nw('eta_u') = Mp;
nw('time') = length(time);
%
%  Create variables and attributes
%
nw{'time'} = ncdouble('time');
nw{'time'}.long_name = ncchar('time');
nw{'time'}.long_name = 'time';
nw{'time'}.units = ncchar('days');
nw{'time'}.units = 'days';

nw{'usfc'} = ncdouble('time', 'eta_u', 'xi_u');
nw{'usfc'}.long_name = ncchar('surface zonal current');
nw{'usfc'}.long_name = 'surface zonal current';
nw{'usfc'}.units = ncchar('meter second-1');
nw{'usfc'}.units = 'meter second-1';

result = endef(nw);

% Write time variables
%
nw{'time'}(:) = time;

close(nw);
