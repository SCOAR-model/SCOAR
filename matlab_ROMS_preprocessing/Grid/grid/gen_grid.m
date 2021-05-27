%clear all
close all
%cd ~/bin/SCOAR2_Prep/prep/amazon/amazon2/grid
%cd /home/csauvage/Documents/so1_cesar/matlab_ROMS_preprocessing/SCOAR2_Prep/prep/amazon2/grid
%addpath /home/csauvage/Documents/so1_cesar/matlab_ROMS_preprocessing/SCOAR2_Prep/matlab_toolbox;start;
% *********************************************
!mkdir -p WRF
!mkdir -p ROMS
%WRF domain directory=
%wrfgeo='/Users/hseo/bin/SCOAR2_Prep/Grid/amazon/amazon2/roms_amazon2/';
%wrfgeo='/home/csauvage/Documents/so1_cesar/matlab_ROMS_preprocessing/SCOAR2_Prep/Grid/amazon/amazon2/roms_amazon2/';
%WRF geo_em.d01.nc
%file1=[wrfgeo,'/geo_em.d01.nc'];unix(['cp ',file1,' WRF/']);
file1=wrf_geo_grid;unix(['cp ',file1,' WRF/']);

%% this is from your rsim script.
%dx=18.;dy=18.;

%grd1=gr2(case_wrf);
grd1=rnt_gridload2(case_wrf,case_roms,case_roms_nolake,case_wrf,path_roms_case,path_roms_nolake_case,path_wrf_case);
%grd2=gr2(case_roms);
grd2=rnt_gridload2(case_roms,case_roms,case_roms_nolake,case_wrf,path_roms_case,path_roms_nolake_case,path_wrf_case);

% 1: wrf
% 2: roms
[I1r,J1r]=size(grd1.lonr);[I1u,J1u]=size(grd1.lonu);[I1v,J1v]=size(grd1.lonv);
[I2r,J2r]=size(grd2.lonr);[I2u,J2u]=size(grd2.lonu);[I2v,J2v]=size(grd2.lonv);

% WRF-NXNY
% wrf
fid=fopen(f1_wrf,'w');
fprintf(fid,'%i\n',I1r);fprintf(fid,'%i\n',J1r);fprintf(fid,'%i\n',I1r*J1r);
fclose(fid);
% wrf-r
fid=fopen(f2_wrf,'w');
fprintf(fid,'%i\n',I1r);fprintf(fid,'%i\n',J1r);fprintf(fid,'%i\n',I1r*J1r);
fclose(fid);
% wrf-u; u has 1 more (unlike ROMS)
fid=fopen(f3_wrf,'w');
fprintf(fid,'%i\n',I1r+1);fprintf(fid,'%i\n',J1r);fprintf(fid,'%i\n',(I1r+1)*J1r);
fclose(fid);
% wrf-v; v has 1 more (unlike ROMS)
fid=fopen(f4_wrf,'w');
fprintf(fid,'%i\n',I1r);fprintf(fid,'%i\n',J1r+1);fprintf(fid,'%i\n',I1r*(J1r+1));
fclose(fid);

% ROMS-NXNY
% roms-r
fid=fopen(f1_roms,'w');
fprintf(fid,'%i\n',I2r);fprintf(fid,'%i\n',J2r);fprintf(fid,'%i\n',I2r*J2r);
fclose(fid);
% roms-u
fid=fopen(f2_roms,'w');
fprintf(fid,'%i\n',I2u);fprintf(fid,'%i\n',J2u);fprintf(fid,'%i\n',I2u*J2u);
fclose(fid);
% roms-v
fid=fopen(f3_roms,'w');
fprintf(fid,'%i\n',I2v);fprintf(fid,'%i\n',J2v);fprintf(fid,'%i\n',I2v*J2v);
fclose(fid);

% WRF additional files
% griddata.dat: my guess.. confirm with dian
% lon1
% lat1
% dx
% dt
% 1
if 2==1;
fid=fopen(['WRF/',f5_wrf],'w');
fprintf(fid,'%f\n',grd1.lonr(1,1));
fprintf(fid,'%f\n',grd1.latr(1,1));
fprintf(fid,'%f\n',dx);
fprintf(fid,'%f\n',dy);
fprintf(fid,'%i\n',0);
fclose(fid);
end%2==1;

% wrf-amazon2-szs.dat
% wrf-amazon2-nzs.dat
% wrf-amazon2-nzn.dat
% my guess  from namelist.input

%if 2==1;
%szs: :soil
%nzs: e_vert
%nzn: num_metgrid_levels
%!echo 4 > wrf-amazon2-szs.dat
%!echo 28 > wrf-amazon2-nzs.dat
%!echo 27 > wrf-amazon2-nzn.dat
%end;%2==1;
%%%

% mask
mask11r=grd2.maskr;
mask11u=grd2.masku;
mask11v=grd2.maskv;
mask11r(isnan(mask11r)==1)=0; %land==0 ocean==1
mask11u(isnan(mask11u)==1)=0;
mask11v(isnan(mask11v)==1)=0;
fid=fopen(f4_roms,'w');
fprintf(fid,'%i\n',mask11r);
fclose(fid)
fid=fopen(f5_roms,'w');
fprintf(fid,'%i\n',mask11u);
fclose(fid)
fid=fopen(f6_roms,'w');
fprintf(fid,'%i\n',mask11v);
fclose(fid)

if 1==1;
%grd2b=gr2(case_roms_nolake);
grd2b=rnt_gridload2(case_roms_nolake,case_roms,case_roms_nolake,case_wrf,path_roms_case,path_roms_nolake_case,path_wrf_case);
mask11r=grd2b.maskr;
mask11u=grd2b.masku;
mask11v=grd2b.maskv;
mask11r(isnan(mask11r)==1)=0; %land==0 ocean==1
mask11u(isnan(mask11u)==1)=0;
mask11v(isnan(mask11v)==1)=0;
fid=fopen(f1_roms_nolake,'w');
fprintf(fid,'%i\n',mask11r);
fclose(fid)
fid=fopen(f2_roms_nolake,'w');
fprintf(fid,'%i\n',mask11u);
fclose(fid)
fid=fopen(f3_roms_nolake,'w');
fprintf(fid,'%i\n',mask11v);
fclose(fid)
end;

% WRF for amazon2 only
if 1==1;
%grd3=gr2(case_wrf);
grd3=rnt_gridload2(case_wrf,case_roms,case_roms_nolake,case_wrf,path_roms_case,path_roms_nolake_case,path_wrf_case);
mask11r=grd3.maskr;
mask11u=grd3.masku;
mask11v=grd3.maskv;
mask11r(isnan(mask11r)==1)=0; %land==0 ocean==1
mask11u(isnan(mask11u)==1)=0;
mask11v(isnan(mask11v)==1)=0;
fid=fopen(f6_wrf,'w');
fprintf(fid,'%i\n',mask11r);
fclose(fid)
fid=fopen(f7_wrf,'w');
fprintf(fid,'%i\n',mask11u);
fclose(fid)
fid=fopen(f8_wrf,'w');
fprintf(fid,'%i\n',mask11v);
fclose(fid)
end;

unix(['mv *roms*.dat ROMS']);
unix(['mv *wrf*.dat WRF']);

disp('do?');
unix(['cp ',grd1.grdfile,' WRF/']);
unix(['cp ',grd2.grdfile,' ROMS/']);
unix(['cp ',grd2b.grdfile,' ROMS/']);
unix(['cp ',grd3.grdfile,' WRF/']);
disp('do?');

