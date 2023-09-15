/*
** svn $Id: voc.h 82 2007-07-12 03:13:42Z arango $
*******************************************************************************
** Copyright (c) 2002-2007 The ROMS/TOMS Group                               **
**   Licensed under a MIT/X style license                                    **
**   See License_ROMS.txt                                                    **
*******************************************************************************
** 
** Options for EXAMPLE1
** Input script:
*/

/* Options associated with momentum equations */
#define UV_ADV
#define UV_COR
#define UV_VIS2
#define UV_LDRAG

/* OPTIONS associated with tracer equations */
#define TS_U3HADVECTION
#define TS_C4VADVECTION
#define TS_DIF2
#undef QCORRECTION       
#undef SCORRECTION        
#undef SRELAXATION        
#define SOLAR_SOURCE
#define SALINITY
#define NONLIN_EOS

/* OPTIONS Pressure gradient algorithm */
#define DJ_GRADPS

/* OPTIONS for surface fluxes formulation using atmospheric boundary layer         */
#undef BULK_FLUXES
#undef NL_BULK_FLUXES       /*! use bulk fluxes computed by nonlinear model        */        
#undef COOL_SKIN
#undef EMINUSP
#undef LONGWAVE_OUT
#undef WIND_MINUS_CURRENT

/* OPTIONS for wave roughness formulation in bulk fluxes:                          */
#undef COARE_TAYLOR_YELLAND /* use Taylor and Yelland (2001) relation              */             
#undef COARE_OOST           /* use Oost et al (2002) relation                      */         
#undef DEEPWATER_WAVES      /* use Deep water waves approximation                  */ 

/* OPTIONS for shortwave radiation:                                                */
#undef ALBEDO             /* use if albedo equation for shortwave radiation        */
#undef DIURNAL_SRFLUX     /* use to impose shortwave radiation local diurnal cycle */

/* Model configuration OPTIONS:*/
#define SOLVE3D
#define CURVGRID
#define MASKING
#define AVERAGES

/* NetCDF input/output OPTIONS*/
#undef PERFECT_RESTART
#undef OUT_DOUBLE

/* OPTION to activate conservative, parabolic spline reconstruction of       **
** vertical derivatives. Notice that there also options (see above) for      **
** vertical advection of momentum and tracers using splines.                 **
** See https://www.myroms.org/projects/src/ticket/681  		 */
#define SPLINES_VDIFF
#define SPLINES_VVISC

/*    Any of the analytical expressions are coded in "analytical.F".         */
#define ANA_BSFLUX
#define ANA_BTFLUX

/*OPTIONS for horizontal mixing of momentum */
#undef VISC_GRID
#undef MIX_S_UV
#define MIX_GEO_UV

/*OPTIONS for horizontal mixing of tracers */
#undef MIX_S_TS
#define MIX_GEO_TS
#undef DIFF_GRID

/* OPTIONS for vertical turbulent mixing scheme of momentum and tracers      **
** (activate only one closure):                                               */

#undef MY25_MIXING /* use if Mellor/Yamada Level-2.5 closure                  */
#undef N2S2_HORAVG      /*   use if horizontal smoothing of buoyancy/shear    */
#undef KANTHA_CLAYSON   /*    use if Kantha and Clayson stability function    */

#undef LMD_MIXING  /* use if Large et al. (1994) interior closure             */
/* OPTIONS for the Large et al. (1994) K-profile parameterization mixing:     */
#undef LMD_BKPP
#undef LMD_CONVEC
#undef LMD_NONLOCAL
#undef LMD_RIMIX
#undef LMD_SKPP

#define GLS_MIXING       /* use if Generic Length-Scale mixing                */
/* OPTIONS for the Generic Length-Scale closure */
#define CANUTO_A         /* use if Canuto A-stability function formulation    */
#undef CANUTO_B          /* use if Canuto B-stability function formulation    */
#undef CHARNOK           /* use if Charnok surface roughness from wind stress */
#undef KANTHA_CLAYSON    /* use if Kantha and Clayson stability function      */
#undef K_C2ADVECTION     /* use if 2nd-order centered advection               */
#undef K_C4ADVECTION 	 /* use if 4th-order centered advection               */
#define N2S2_HORAVG 	 /* use if horizontal smoothing of buoyancy/shear     */
#define RI_SPLINES       /* use if splines reconstruction for vertical sheer  */

/* Options for lateral boundary conditions */
# undef IMPLICIT_NUDGING /* use if implicit nudging term in momentum radiation    */
# define RADIATION_2D    /* use if tangential phase speed in radiation conditions */

/* Tides                                                                       */
# define SSH_TIDES       /* use if imposing tidal elevation                    */ 
# define UV_TIDES        /* use if imposing tidal currents                     */
# undef RAMP_TIDES       /* use if ramping (over one day) tidal forcing        */
# undef FSOBC_REDUCED    /* use if SSH data and reduced physics conditions     */
# define ADD_FSOBC       /* use to add tidal elevation to processed OBC data   */
# define ADD_M2OBC       /* use to add tidal currents  to processed OBC data   */
                                                                                                    
