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

function gridindo=rnt_gridinfo(gridid)

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

dir=['/Users/hseo/bin/SCOAR2_Prep/'];
    switch gridid

% AMAZON1
   case 'roms-amazon1'
        gridindo.id      = gridid;
        gridindo.name    = 'roms-amazon1';
        gridindo.grdfile = [dir,'/Grid/amazon/amazon1/roms_amazon1/roms-amazon1-grid.nc'];
        gridindo.N       = 30;
        gridindo.thetas  = 7;
        gridindo.thetab  = 2.
       gridindo.tcline  = 300;
        gridindo.cstfile = paccoast;

   case 'roms-amazon1-nolake'
        gridindo.id      = gridid;
        gridindo.name    = 'roms-amazon1-nolake';
        gridindo.grdfile = [dir,'/Grid/amazon/amazon1/roms_amazon1_nolake/roms-amazon1-grid_nolake.nc'];
        gridindo.N       = 30;
        gridindo.thetas  = 7;
        gridindo.thetab  = 2;
       gridindo.tcline  = 300;
        gridindo.cstfile = paccoast;

   case 'wrf-amazon1'
        gridindo.id      = gridid;
        gridindo.name    = 'wrf-amazon1';
        gridindo.grdfile = [dir,'/Grid/amazon/amazon1/wrf_amazon1/wrf-amazon1-grid.nc'];
        gridindo.N       = 30;
        gridindo.thetas  = 7;
        gridindo.thetab  = 2;
       gridindo.tcline  = 300;
        gridindo.cstfile = paccoast;


% SO1
   case 'roms-so1'
        gridindo.id      = gridid;
        gridindo.name    = 'roms-so1';
        gridindo.grdfile = [dir,'/Grid/so/so1/roms_so1/roms-so1-grid.nc'];
        gridindo.N       = 30;
        gridindo.thetas  = 7;
        gridindo.thetab  = 2.
       gridindo.tcline  = 300;
        gridindo.cstfile = paccoast;

   case 'roms-so1-nolake'
        gridindo.id      = gridid;
        gridindo.name    = 'roms-so1-nolake';
        gridindo.grdfile = [dir,'/Grid/so/so1/roms_so1_nolake/roms-so1-grid_nolake.nc'];
        gridindo.N       = 30;
        gridindo.thetas  = 7;
        gridindo.thetab  = 2;
       gridindo.tcline  = 300;
        gridindo.cstfile = paccoast;

   case 'wrf-so1'
        gridindo.id      = gridid;
        gridindo.name    = 'wrf-so1';
        gridindo.grdfile = [dir,'/Grid/so/so1/wrf_so1/wrf-so1-grid.nc'];
        gridindo.N       = 30;
        gridindo.thetas  = 7;
        gridindo.thetab  = 2;
       gridindo.tcline  = 300;
        gridindo.cstfile = paccoast;

        gridindo.grdfile = [dir,'/Grid/mc/mc2/wrf_mc2/wrf-mc2-grid.nc'];
        gridindo.N       = 30;
        gridindo.thetas  = 10;
        gridindo.thetab  = 0.4;
       gridindo.tcline  = 10;
        gridindo.cstfile = paccoast;

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
