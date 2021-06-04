cd /nara/data/hseo/nasa1/pre_process/change_met_em_date
clear all;close all;

dir1='/mara/data1/hseo/Data/NCEP1/met/nasa1/LBC_Runs/';

% NOV files to fix
% 1951 1953 1956 1959 1969 1974
%nov_year = [1951 1953 1956 1959 1969 1974 1996];

% DEC file to fix
% 1953 1956 1958 1960 1961 1968 1975 1978 1980
%dec_year= [ 1953 1956 1958 1960 1961 1968 1975 1978 1980 1990 1991];
dec_year= [1985];

do_nov=0;
do_dec=1;
if do_nov==1;
% copy 11/1 and 12/1 files  from 6 hr later fields and overwrite the feidsl other than SM and ST
year=nov_year ; ly=length(year);

for iy=1:ly;
year=nov_year(iy);
disp(['fixing: ', ns(year),'/11/01/06 --> ',ns(year),'/11/01/00']);

% November
mm=11;
file1=[dir1,ns(year),'/met_em.d01.',ns(year),'-',ns(mm),'-01_00:00:00.nc'];
file1_bkp=[dir1,ns(year),'/met_em.d01.',ns(year),'-',ns(mm),'-01_00:00:00.nc_bkp'];
file2=[dir1,ns(year),'/met_em.d01.',ns(year),'-',ns(mm),'-01_06:00:00.nc'];
file3=[dir1,ns(year),'/met_em.d01.',ns(year),'-',ns(mm),'-01_06:00:00.nc_imsi'];

unix(['cp ',file2,' ',file3]);
unix(['cp ',file1,' ',file1_bkp]);

ncw=netcdf(file3,'w');
ncr=netcdf(file1);

met_vars_list;ll=length(vars);
for ii=1:ll;disp(vars{ii});
%ncw{vars{ii}}(:,:,:,:,:,:) = 0;
ncw{vars{ii}}(:,:,:,:,:,:) = ncr{vars{ii}}(:,:,:,:,:,:);
end;

Times=ncw{'Times'}(:,:);
% 06h ==> 00h
Times(12:13)=ns(00);
ncw{'Times'}(:,:)=Times;
close(ncw);

times=char([ns(year),'-11-01_00:00:00']);
%change the date in met.nc 
unix(['ncatted -O -h -a SIMULATION_START_DATE,global,m,c,',times,' ',file3]);
unix(['mv ',file3,' ',file1]);
end;% iy;
end;% do_nov;

if do_dec==1;
% #######################3
% repeat for december
year=dec_year ; ly=length(year);
for iy=1:ly;year=dec_year(iy);
disp(['fixing: ', ns(year),'/12/01/06 --> ',ns(year),'/12/01/00']);

mm=12;
file1=[dir1,ns(year),'/met_em.d01.',ns(year),'-',ns(mm),'-01_00:00:00.nc'];
file1_bkp=[dir1,ns(year),'/met_em.d01.',ns(year),'-',ns(mm),'-01_00:00:00.nc_bkp'];
file2=[dir1,ns(year),'/met_em.d01.',ns(year),'-',ns(mm),'-01_06:00:00.nc'];
file3=[dir1,ns(year),'/met_em.d01.',ns(year),'-',ns(mm),'-01_06:00:00.nc_imsi'];
file4=[dir1,ns(year),'/met_em.d01.',ns(year),'-',ns(mm),'-01_00:00:00.nc_chgdte'];

unix(['cp ',file2,' ',file3]);
unix(['cp ',file1,' ',file1_bkp]);

ncw=netcdf(file3,'w');
ncr=netcdf(file1);

met_vars_list;ll=length(vars);
for ii=1:ll;disp(vars{ii});
%ncw{vars{ii}}(:,:,:,:,:,:) = 0;
ncw{vars{ii}}(:,:,:,:,:,:) = ncr{vars{ii}}(:,:,:,:,:,:);
end;

Times=ncw{'Times'}(:,:);
% 06h ==> 00h
Times(12:13)=ns(00);
ncw{'Times'}(:,:)=Times;
close(ncw);

%change the date in met.nc 
times=char([ns(year),'-12-01_00:00:00']);
unix(['ncatted -O -h -a SIMULATION_START_DATE,global,m,c,',times,' ',file3]);
unix(['mv ',file3,' ',file1]);
end;% iy
% #######################3
end;% do_dec
return
