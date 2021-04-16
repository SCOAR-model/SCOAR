function  create_forcing(fileout,grdname,time);
nc=netcdf(grdname);
L=length(nc('xi_psi'));
M=length(nc('eta_psi'));
result=close(nc);
Lp=L+1;
Mp=M+1;

nw = netcdf(fileout, 'clobber');
result = redef(nw);

%
%  Create dimensions
%

nw('xi_rho') = Lp;
nw('eta_rho') = Mp;
nw('time') = length(time);
%
%  Create variables and attributes
%
nw{'time'} = ncdouble('time');
nw{'time'}.long_name = ncchar('time');
nw{'time'}.long_name = 'time';
nw{'time'}.units = ncchar('days');
nw{'time'}.units = 'days';

nw{'sst'} = ncdouble('time', 'eta_rho', 'xi_rho');
nw{'sst'}.long_name = ncchar('sea surface temperature');
nw{'sst'}.long_name = 'sea surface temperature';
nw{'sst'}.units = ncchar('Celsius');
nw{'sst'}.units = 'Celsius';

result = endef(nw);

%
% Create global attributes
%
% Write time variables
%
nw{'time'}(:) = time;

close(nw);
