! calculate flux fields according to roms needs
! modified from calculate_WRF_flux_nobulk_raincv.f
! main modifications:
! - rotation of wind stress vector components
! - use PREC_ACC_NC and PREC_ACC_C in swflux calculation
! - SST dependence of latent heat of vaporization

! input:
! fort.11: WRF grid dimensions
! fort.18: prec_acc_dt [s]: WRF precipiation accumulation interval
! fort.21: U10 [m s-1] on rho-points
! fort.22: V10 [m s-1] on rho-points
! fort.23: UST [m s-1]
! fort.24: GSW [W m-2]
! fort.25: GLW [W m-2]
! fort.26: SST [K]
! fort.27: LH [W m-2]
! fort.28: HFX [W m-2]
! fort.29: PREC_ACC_C [mm] - accumulated over prec_acc_dt
! fort.30: PREC_ACC_NC [mm] - accumulated over prec_acc_dt
! fort.31: COSALPHA [-]
! fort.32: SINALPHA [-]
! fort.34: ROMS grid file for angle

! output: 
! fort.51: sustr [N m-2] on u-points
! fort.52: svstr [N m-2] on v-points
! fort.53: shflux [W m-2]
! fort.54: swrad [W m-2]
! fort.55: swflux 

! shflux = GSW + GLW + LWu - LH - HFX

! swflux
! evap = LH / (Lv * rhow)
! rain = (PREC_ACC_NC + PREC_ACC_C) / prec_acc_dt
! swflux = evap - rain

      include 'netcdf.inc'

! variables to read NetCDF files
      integer :: ncid, varid, status
      integer :: start(2), count(2), stride(2)


! constants
      integer :: prec_acc_dt
      real*8 :: rhoa, cff, theta, LWu
      real*8 :: fac, Lv, rhow

! read flux files at 1 time step
! input
      real*8, dimension(:,:), allocatable :: u10, v10, ust
      real*8, dimension(:,:), allocatable :: gsw
      real*8, dimension(:,:), allocatable :: glw, sst
      real*8, dimension(:,:), allocatable :: lh, hfx
      real*8, dimension(:,:), allocatable :: prec_acc_nc, prec_acc_c
      real*8, dimension(:,:), allocatable :: cosa, sina, ROMSalpha

! output
      real*8, dimension(:,:), allocatable :: sustr, svstr
      real*8, dimension(:,:), allocatable :: sustri, svstri
      real*8, dimension(:,:), allocatable :: swrad, shflux, lwrad
      real*8, dimension(:,:), allocatable :: swflux, rain
      real*8 :: sustrWRF, svstrWRF, sustrtmp, svstrtmp, evap

      data stride / 1, 1 /

! ROMS rho-grid dimensions
      open(11,file='fort.11',form='formatted')
      read(11,*) nx,ny

! ROMS xi-grid dimensions
      nxu=nx-1
      nyu=ny
      nxnyu=nxu*nyu

! ROMS eta-grid dimensions
      nxv=nx
      nyv=ny-1
      nxnyv=nxv*nyv

! dimensions to read 2D field from NetCDF file
      start(1)=1
      start(2)=1
      count(1)=nx
      count(2)=ny

! allocate input arrays
      allocate(u10(nx,ny),v10(nx,ny),ust(nx,ny))
      allocate(gsw(nx,ny))
      allocate(glw(nx,ny),sst(nx,ny))
      allocate(prec_acc_nc(nx,ny),prec_acc_c(nx,ny),rain(nx,ny))
      allocate(cosa(nx,ny), sina(nx,ny), ROMSalpha(nx,ny))
      allocate(sustri(nx,ny),svstri(nx,ny)) 
      allocate(sustr(nxu,nyu),svstr(nxv,nyv)) 
      allocate(swrad(nx,ny),shflux(nx,ny))
      allocate(lwrad(nx,ny))
      allocate(swflux(nx,ny))
      allocate(lh(nx,ny),hfx(nx,ny))

! read prec_acc_dt
      open(18,file='fort.18',form='formatted')
      read(18,*) prec_acc_dt 

! read WRF fields
      open(21,file='fort.21',form='formatted')
      open(22,file='fort.22',form='formatted')
      open(23,file='fort.23',form='formatted')
      open(24,file='fort.24',form='formatted')
      open(25,file='fort.25',form='formatted')
      open(26,file='fort.26',form='formatted')
      open(27,file='fort.27',form='formatted')
      open(28,file='fort.28',form='formatted')
      open(29,file='fort.29',form='formatted')
      open(30,file='fort.30',form='formatted')
      open(31,file='fort.31',form='formatted')

      read(21,*) u10
      read(22,*) v10
      read(23,*) ust
      read(24,*) gsw
      read(25,*) glw
      read(26,*) sst
      read(27,*) lh
      read(28,*) hfx
      read(29,*) prec_acc_c
      read(30,*) prec_acc_nc
      read(31,*) cosa
      read(32,*) sina 

! 5. get ROMS angle from grid file
      status = nf_open('fort.34',nf_nowrite,ncid)
      if (status .ne. nf_noerr) call handle_err(status,7)
      status = nf_inq_varid(ncid,'angle',varid)
      if (status .ne. nf_noerr) call handle_err(status,8)
      status = nf_get_vars_double(ncid,varid,start,count,
     &                            stride,ROMSalpha)
      if (status .ne. nf_noerr) call handle_err(status,9)
      status = nf_close(ncid)
      if (status .ne. nf_noerr) call handle_err(status,10)


      ! density of air [kg m-3]
      rhoa=1.225

      ! Stefan-Boltzmann constant [W m-2 K-4]
      cff=5.67e-8 

! 1. wind stress: sustr, svstr
! ust= sqrt(tau/rhoa)
! tau = rhoa * ust^2

! THETA=atan2(U10,V10)
! UFLX = - (UST * rhoa ) * cos(THETA)
! VFLX = - (UST * rhoa ) * sin(THETA)
! rhoa=1.225;

      do i=1,nx
        do j=1,ny
          theta=atan2(v10(i,j),u10(i,j))
! tau=rho*ust^2;
! wind stress, rho-points, WRF grid-relaive
          sustrWRF = (rhoa*ust(i,j)*ust(i,j)) * cos(theta)
          svstrWRF = (rhoa*ust(i,j)*ust(i,j)) * sin(theta)
! from grid-relative to Earth-relative coordinates using the COSALPHA and
! SINALPHA from WRF
! see: ROMS/ROMS/Utility/uv_rotate.F  
          sustrtmp = sustrWRF*cosa(i,j) - svstrWRF*sina(i,j)
          svstrtmp = svstrWRF*cosa(i,j) + sustrWRF*sina(i,j)
! from Earth-relative to grid-relative coordinates using ROMS angle
! see: ROMS/ROMS/Nonlinear/set_data.F
          sustri(i,j) = sustrtmp*COS(ROMSalpha(i,j))
     &                 +svstrtmp*SIN(ROMSalpha(i,j))
          svstri(i,j) = svstrtmp*COS(ROMSalpha(i,j))
     &                 -sustrtmp*SIN(ROMSalpha(i,j))
        enddo
      enddo

! ROMS expects the wind stress forcing fields on u- and v-points
! regrid sustri to u-points - no filling of boundary values needed
      do i=1,nxu
        do j=1,nyu
          sustr(i,j) = 0.5 *(sustri(i,j)+sustri(i+1,j)) 
        enddo
      enddo
! regrid svstri to u-points - no filling of boundary values needed
      do i=1,nxv
        do j=1,nyv
          svstr(i,j) = 0.5 *(svstri(i,j)+svstri(i,j+1)) 
        enddo
      enddo

!2.  compute "net" shortwave/longwave radiation
      do i=1,nx
        do j=1,ny
          swrad(i,j) = gsw(i,j)
!         cff=5.67e-8; % Wm-2K-4.
          LWu  = -1 * cff * sst(i,j)*sst(i,j)*sst(i,j)*sst(i,j)
          lwrad(i,j) = glw(i,j) + LWu
        enddo
      enddo

!3. net surface heat flux: shflux
! make sure the sign..
      do i=1,nx
        do j=1,ny
          shflux(i,j) = swrad(i,j) + lwrad(i,j) - lh(i,j) - hfx(i,j)
        enddo
      enddo
  
!4. total precipitation rate: cm/day
! prec_acc_nc and prec_acc_c are accumulated over prec_acc_dt is accumulated
! over prec_acc_dt which should be equal to the coupling frequency

      print *, 'Using precipitation accumulated over prec_acc_dt...'
      print *, 'prec_acc_dt = ', prec_acc_dt, 's'

! calculate precipitation rate [cm day-1]
      ! factor to convert from mm to cm day-1
      ! prec_acc_dt is accumulation interval in seconds
      fac = (86400 / prec_acc_dt)/10
      do i=1,nx
        do j=1,ny
          rain(i,j) = fac * (prec_acc_nc(i,j)+prec_acc_c(i,j))
        enddo
      enddo

! 5.  calculate swflux
! evaporation from latent heat flux:
! evap = LH/Lv/rhow

      ! density of sea water [kg m-3]
      rhow = 1025

! LH =W/m2 = J/s/m2
! Lv=J/kg
! rhow=kg/m3 
! --> m/s ==> 100*86400 cm/dayr
!nw{'swflux'}.positive = ncchar('net evaporation');
!nw{'swflux'}.negative = ncchar('net precipitation');

      do i=1,nx
        do j=1,ny
          ! latent heat of vaporization [J kg-1]
          ! copied from ROMS/ROMS/Nonlinear/bulk_flux.F
          Lv = (2.501 - 0.00237*sst(i,j))*1.0e+6
          ! calculate evaporation [cm day-1]
          evap = -1*( lh(i,j) / (Lv * rhow))*86400*100
          swflux(i,j) = evap - rain(i,j)
        enddo 
      enddo 

! 7. print some vars
        print *, 'SWRAD, LWRAD, LH, SH'
        print *, swrad(30,30), lwrad(30,30), lh(30,30), hfx(30,30)
        print *, 'sustr, svstr'
        print *, sustr(30,30), svstr(30,30)

! write outputs
      open(51,file='fort.51',form='formatted',status='unknown')
      write(51,*) sustr
      open(52,file='fort.52',form='formatted',status='unknown')
      write(52,*) svstr
      open(53,file='fort.53',form='formatted',status='unknown')
      write(53,*) shflux
      open(54,file='fort.54',form='formatted',status='unknown')
      write(54,*) swrad
      open(55,file='fort.55',form='formatted',status='unknown')
      write(55,*) swflux

      call exit
      end


      subroutine handle_err(status,n)
      integer status,n
      if (status .ne. nf_noerr) then
         print *, n,' ',status
         print *, 'reading angle from ROMS grid file failed!!!'
         print *, 'stop'
          call exit
      endif
      end subroutine handle_err
