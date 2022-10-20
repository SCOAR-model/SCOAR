% (R)oms (N)umerical (T)oolbox
% 
% FUNCTION grdinfo = rnt_gridinfo(gridid)
%
% Loads the grid configuration for gridid
% To add new grid please edit this file.
% just copy an existing one and modify for
% your needs. It is simple.
%
% If you editing this file after using
% the Grid-pak scripts use the content 
% of variable "nameit" for gridid.
%
% Example: CalCOFI application
%
%    grdinfo = rnt_gridinfo('calc')
%
% RNT - E. Di Lorenzo (edl@ucsd.edu)


function gridindo=rnt_gridinfo(gridid,case_roms,case_roms_nolake,case_wrf,path_roms_case,path_roms_nolake_case,path_wrf_case)

crocotools_param
% initialize to defaults
%       gridindo.id      = gridid;
%       gridindo.name    = '';
%       gridindo.grdfile = '';	 	 
%	gridindo.N       = 20;
%       gridindo.thetas  = 5;  
%       gridindo.thetab  = 0.4;  	 	 
%       gridindo.tcline  = 200;
%	 gridindo.cstfile = '/d6/edl/ROMS-pak/Grid-pak/WorldCstLine.mat';

paccoast = which('rgrd_CoastlineWorldPacific.mat');
atlcoast = which('rgrd_CoastlineWorld.mat');
warning off MATLAB:DeprecatedLogicalAPI
warning off MATLAB:conversionToLogical
warning off MATLAB:divideByZero

%dir=['/Users/hseo/bin/SCOAR2_Prep/'];
%dir=['/home/csauvage/Documents/so1_cesar/matlab_ROMS_preprocessing/SCOAR2_Prep'];
    switch gridid
% 
   case case_roms
        gridindo.id      = gridid;
        gridindo.name    = case_roms;
%        gridindo.grdfile = [dir,'/Grid/atomic/atomic1/roms_atomic1/roms-atomic1-grid.nc'];
        gridindo.grdfile = path_roms_case;
        gridindo.N       = N;
        gridindo.thetas  = theta_s;
        gridindo.thetab  = theta_b;
       gridindo.tcline  = hc;
        gridindo.cstfile = paccoast;

   case case_roms_nolake
        gridindo.id      = gridid;
        gridindo.name    = case_roms_nolake;
%        gridindo.grdfile = [dir,'/Grid/atomic/atomic1/roms_atomic1_nolake/roms-atomic1-grid_nolake.nc'];
        gridindo.grdfile = path_roms_nolake_case;
        gridindo.N       = N;
        gridindo.thetas  = theta_s;
        gridindo.thetab  = theta_b;
       gridindo.tcline  = hc;
        gridindo.cstfile = paccoast;

   case case_wrf
        gridindo.id      = gridid;
        gridindo.name    = case_wrf;
%        gridindo.grdfile = [dir,'/Grid/atomic/atomic1/wrf_atomic1/wrf-atomic1-grid.nc'];
        gridindo.grdfile = path_wrf_case;
        gridindo.N       = N;
        gridindo.thetas  = theta_s;
        gridindo.thetab  = theta_b;


    otherwise
       gridindo.id      = gridid;
       gridindo.name    = 'null';
       gridindo.grdfile = '/dev/null';
         gridindo.N       = 0;
       gridindo.thetas  = 0;
       gridindo.thetab  = 0;
       gridindo.tcline  = 0;
         disp([' RNT_GRIDINFO - ',gridid,' not configured']);
    end
