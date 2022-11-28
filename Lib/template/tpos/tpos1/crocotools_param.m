isoctave=exist('octave_config_info');


%grdname  = ['./roms-amazon2-grid.nc'];
%topofile = [DATADIR,'Topo/etopo2.nc'];
%
%  CROCO title names and directories
%
CROCO_title  = 'TPOS';
CROCO_config = 'TPOS';
%
% Grid dimensions:
%
% Number of vertical Levels (! should be the same in param.h !)
%
N = 30;
%
%  Vertical grid parameters (! should be the same in croco.in !)
%
theta_s    =  7.;
theta_b    =  2;
hc         = 300.;
vtransform =  2.; % s-coordinate type (1: old- ; 2: new- coordinates)
                  % ! take care to define NEW_S_COORD cpp-key in cppdefs.h 
Vstretching = 4.;
%
% Topography: choice of filter
%
topo_smooth =  1; % 1: old ; 2: new filter (better but slower)
%
% Minimum depth at the shore [m] (depends on the resolution,
% rule of thumb: dl=1, hmin=300, dl=1/4, hmin=150, ...)
% This affect the filtering since it works on grad(h)/h.
%
hmin = 75;
%
% Maximum depth at the shore [m] (to prevent the generation
% of too big walls along the coast)
%
hmax_coast = 500;
%
% Maximum depth [m] (cut the topography to prevent
% extrapolations below WOA data)
%
hmax = 5000;
%
% Slope parameter (r=grad(h)/h) maximum value for topography smoothing
%
rtarget = 0.25;
%
% Number of pass of a selective filter to reduce the isolated
% seamounts on the deep ocean.
%
n_filter_deep_topo=4;
%
% Number of pass of a single hanning filter at the end of the
% smooting procedure to ensure that there is no 2DX noise in the 
% topography.
%
n_filter_final=2;
%
%  GSHSS user defined coastline (see m_map) 
%  XXX_f.mat    Full resolution data
%  XXX_h.mat    High resolution data
%  XXX_i.mat    Intermediate resolution data
%  XXX_l.mat    Low resolution data
%  XXX_c.mat    Crude resolution data
%
coastfileplot = 'coastline_l.mat';
coastfilemask = 'coastline_l_mask.mat';
%
% Objective analysis decorrelation scale [m]
% (if Roa=0: nearest extrapolation method; crude but much cheaper)
%
%Roa=300e3;
Roa=0;
%
interp_method = 'cubic';         % Interpolation method: 'linear' or 'cubic'
%
makeplot     = 0;                 % 1: create a few graphics after each preprocessing step
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%
