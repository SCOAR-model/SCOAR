cd /mara/scratch/hseo/WRF_ROMS/Model/WRF30/nasa/nasa1_run17/test/input_files_LBC_Runs/bdy
clear all;close all;

dir1='./';
%for year=1950:1982;disp(year);
for year=1983:2010;disp(year);
% do cp in mara; too slow to do in dara
unix(['cp ',dir1,'/wrfbdy_d01_',ns(year),' ',dir1,'wrfbdy_d01_',ns(year),'_chg_date_2004_2005']);
file2=[dir1,'wrfbdy_d01_',ns(year),'_chg_date_2004_2005'];

nc=netcdf(file2,'w');
time1=nc{'Times'}(:);
time2=nc{'md___thisbdytimee_x_t_d_o_m_a_i_n_m_e_t_a_data_'}(:);
time3=nc{'md___nextbdytimee_x_t_d_o_m_a_i_n_m_e_t_a_data_'}(:);

TT=size(time1,1);
% time1
for tt=1:TT;
time1(tt,1:4)=char(ns(2004));
end;
%for tt=245:724;
%time1(tt,1:4)=char(ns(2005));
%end;
nc{'Times'}(:)=time1;

% time2; same as time1
for tt=1:TT;
time2(tt,1:4)=char(ns(2004));
end;
%for tt=245:724;
%time2(tt,1:4)=char(ns(2005));
%end;
nc{'md___thisbdytimee_x_t_d_o_m_a_i_n_m_e_t_a_data_'}(:)=time2;

% time3 ; % 6 hr shift;
% 1-243
for tt=1:TT;
time3(tt,1:4)=(ns(2004));
end;
%for tt=244:724;
%time3(tt,1:4)=(ns(2005));
%end;
nc{'md___nextbdytimee_x_t_d_o_m_a_i_n_m_e_t_a_data_'}(:)=time3;

close(nc);

unix(['ncatted -O -h -a START_DATE,global,m,c,"2004-11-01_00:00:00" ',file2]);
end;% year
