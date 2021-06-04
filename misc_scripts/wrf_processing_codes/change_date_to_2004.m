clear all
close all
cd /mara/scratch/hseo/WRF_ROMS/Model/WRF30/nasa/nasa1_run17/test/input_files_LBC_Runs/ini

Ys=1951;Ye=1982;
Ys=1983;Ye=2010;
for year=Ys:Ye;
disp(['changin date on the file of ',ns(year)]);

ifile=['wrfinput_d01_',ns(year)]
ofile=['wrfinput_d01_',ns(year),'_chgdte_2004']

unix(['cp ',ifile,' ',ofile]);

nc=netcdf(ofile,'w');
time=nc{'Times'}(:);
time(1)=ns(2);
time(2)=ns(0);
time(3)=ns(0);
time(4)=ns(4);

time(13)=ns(0);

nc{'Times'}(:)=time;
close(nc);

unix(['ncatted -O -h -a START_DATE,global,m,c,"2004-11-01_00:00:00" ',ofile]);
unix(['ncatted -O -h -a SIMULATION_START_DATE,global,m,c,"2004-11-01_00:00:00" ',  ofile]);
unix(['ncatted -O -h -a JULYR,global,m,c,"2004" ',ofile]);

unix(['rm ',ifile]);
end;% year

