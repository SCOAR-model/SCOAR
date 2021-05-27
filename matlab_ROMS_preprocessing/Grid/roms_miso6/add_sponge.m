%clear all;close all;
nc=netcdf(grdname);
visc_factor=nc{'visc_factor'}(:,:)';
diff_factor=nc{'visc_factor'}(:,:)';
close all
%g=gr2(case_roms);
g=rnt_gridload2(case_roms,case_roms,case_roms_nolake,case_wrf,path_roms_case,path_roms_nolake_case,path_wrf_case)
[II JJ]=size(visc_factor);

%% factor
 %The values of visc_factor must be positive and defined at RHO-points. Usually their values are linearly tapered from one or zero at the inner sponge edge (interior points) to the desired maximum factor (>1) at the outer sponge edge (like domain perimeter). If a factor of zero is set over the interior points, the viscosity will be turned OFF over such points. Contrarily if a factor of one is set over the interior points, the viscosity will be that set in ocean.in (visc2/visc4) and post-processed in ini_hmixcoef.F (if scaled by grid size with VISC_GRID).

% in the interior; ratio to 1
visc0=1;
diff0=1;
fac=40;
width=20;

[II JJ]=size(visc_factor);
visc_factor=ones([II JJ]);
diff_factor=ones([II JJ]);
% south
for jj=1:min(width,JJ);
cff= (width-jj+1) * fac/width;
	for ii=1:II;
          visc_factor(ii,jj)=cff;
          diff_factor(ii,jj)=cff;
end;end;;
clf;pcolor(visc_factor'.*g.maskr');shf;

if 1==1;
%northern
    for  jj=JJ-width+1 : JJ;
        cff=fac*visc0 + (JJ-jj)*(visc0-fac*visc0)/width;
     for ii=1:II
          visc_factor(ii,jj)=cff;
          diff_factor(ii,jj)=cff;
        end;end;
clf;pcolor(visc_factor'.*g.maskr');shf;
end;

% west
for ii=1:min(width,II);
	for jj=max(1,ii):min(JJ-ii,JJ);
	cff= (width-ii+1) * fac/width;%
          visc_factor(ii,jj)=cff;
          diff_factor(ii,jj)=cff;
end;      end;      
clf;pcolor(visc_factor'.*g.maskr');shf;

% east
count=0;
for ii=max(1,II-width)+1:II;count=count+1;
	for jj = width - (count-1): (JJ-width) + (count);
	cff=fac*visc0 + (II-ii)*(visc0-fac*visc0)/width;
          visc_factor(ii,jj)=cff;
          diff_factor(ii,jj)=cff;
end;end;
clf;pcolor(visc_factor'.*g.maskr');shf;
%!!EAST
%!       DO i=MAX(IstrR,Lm(ng)+1-10),IendR
%!         DO j=MAX(IstrR,i),MIN(Lm(ng)+1-i,IendR)
%!         cff=fac*visc2(ng)+                                              &
%!      &      REAL(Lm(ng)+1-i,r8)*(visc2(ng)-fac*visc2(ng))/10.0_r8
%!           visc2_r(i,j)=cff
%!           visc2_p(i,j)=cff
%!         END DO
%!       END DO

visc2=10;
tnu2=10;
%g=gr2(case_roms);
g=rnt_gridload2(case_roms,case_roms,case_roms_nolake,case_wrf,path_roms_case,path_roms_nolake_case,path_wrf_case)
figure(1);clf;
subplot(2,2,1);pcolor(visc_factor'.*g.maskr'*visc2);shf;
subplot(2,2,2);pcolor(diff_factor'*tnu2);shf;
subplot(2,2,3);plot(1:JJ,visc_factor(30,:)*visc2,'ro-');
subplot(2,2,4);plot(1:II,visc_factor(:,20)*visc2,'ro-');

nc=netcdf(grdname,'w');
nc{'visc_factor'}(:,:)=visc_factor';
nc{'diff_factor'}(:,:)=diff_factor';
close(nc);

