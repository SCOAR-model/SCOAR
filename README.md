The SCOAR regional coupled modeling system couples WRF, ROMS, and WW3 via COARE3.5 bulk flux algorithm implemented in WRF surface-layer modules.  The SCOAR coupler is a flexible and efficient input-output file coupler, with 2-D online smoothing for eddy filtering. The code is available through this repository. See the coupling flowchart at: https://hseo.whoi.edu/scoar/
  
The SCOAR has been used to study the physics and impacts of air-sea-wave interactions in various regions; for the publication, please see https://hseo.whoi.edu/publications/.

The SCOAR system was originally developed by Hyodae Seo (hseo@whoi.edu) by coupling WRF (and RSM)and ROMS. Dr. Cesar Sauvage has introduced wave coupling, through the project funded by the NOAA CVP program for ATOMIC.

This repository contains
1. SCOAR Source codes: mainly in Shell and Lib and main*.sh
2. ROMS and WW3 matlab-based preprocessing toolbox: matlab_ROMS_preprocessing
3. SCOAR Working Manual is on google shared drive. The manual will be released soon.

Note: WRF, ROMS, and WW3 should be downloaded and installed separately.
  WRF: https://github.com/wrf-model/WRF
  ROMS: https://github.com/kshedstrom/roms
  WW3: https://github.com/NOAA-EMC/WW3
  
**Issues that we are working on:**
Wave-induced stress (tau_stress) is computed within WW3 as integral (wavenumber and angle) of wave energy spectra. Inputs to this are wind/air density from WRF and ocean current from ROMS. This will take into account the direction of wave propagation, which is not necessarily aligned with the wind direction. Note COARE3.5 assumes that waves and winds are in the same direction. This assumption is likely to be violated in strong mesoscale flows, fronts and hurricane conditions (See Chen et al. 2013). Tau_smooth is computed from WRF SL scheme based viscous shear and can be assumed to be aligned with local wind. The total stress tau = tau_stress + tau_smooth (Edson et al. 2013). 
