!% calculate flux field according to roms needs
!for WRF2ROMS coupler
! 2017 8 30 revised
! Hyodae Seo

! input:
! 21. U10 m/s
! 22. V10 m/s
! 23. UST m/s
! 24. GSW W/m2
! 25. GLW W/m2
! 26. SST: K
! 26. LH: W/m2
! 27. HFX: W/m2
! 29. RAINCV [mm/WRF_DT] e.g., mm/90s 
! 30. RAINNCV [mm/WRF_DT] e.g., mm/90s 
!########### 31. SFCEVP kg/m2 :not used

! output: 
! 51 ustr N/m2
! 52 svstr N/m2
! 53 shflux W/m2
! 54 swrad W/m2
! 55 swflux cm/day

! ##############3
! Nov 22, 2022 Hyodae Seo
! if ROMS_wave=yes and parameter_WW32ROMS=yes
! sustr and svstr is tau_oc = tau_a - tau_w - tau_ds
! tau_a is computed from UST from WRF which is the total friction velocity from WW3
! tau_w is from WW3, wave-supported stress (utaw, vtaw in vector)
! tau_ds is from WW3, momentum flux from wave to ocean interior via wave breaking (utwo, vtwo)

! read additional inputs
! 31. UTAW
! 32. VTAW
! 33. UTOW
! 34. VTOW

! then, the output sustr and svstr now represent tau_ocx and tau_ocy
! ########


! shflux= GSW + GLW + LWu - LH - HFX

! swflux
! SFCEVP [kg m-2] - PRECIP [kg m-2]

! constants
       integer :: WRF_DT
       real :: rhoa, rhoo, cff, theta, LWu

! read flux files at 1 time step
! input
      real, dimension(:,:), allocatable :: u10, v10, ust
      real, dimension(:,:), allocatable :: gsw
      real, dimension(:,:), allocatable :: glw, sst
      real, dimension(:,:), allocatable :: lh, hfx
      real, dimension(:,:), allocatable :: rainncv, raincv
      real, dimension(:,:), allocatable :: utaw, vtaw
      real, dimension(:,:), allocatable :: utwo, vtwo

! output
      real, dimension(:,:), allocatable :: sustr, svstr
      real, dimension(:,:), allocatable :: sustri, svstri
      real, dimension(:,:), allocatable :: swrad, shflux, lwrad
      real, dimension(:,:), allocatable :: swflux, rain
!     real, dimension(:,:), allocatable :: masku, maskv

      open(11,file='fort.11',form='formatted')
      read(11,*) nx, ny, nxny

       nxu=nx-1
       nyu=ny
       nxnyu=nxu*nyu

        nxv=nx
        nyv=ny-1
        nxnyv=nxv*nyv

! input
      allocate(u10(nx,ny),v10(nx,ny),ust(nx,ny))
      allocate(gsw(nx,ny))
      allocate(glw(nx,ny),sst(nx,ny))
      allocate(rainncv(nx,ny),raincv(nx,ny),rain(nx,ny))
! #### tau_w and tau_ds
      allocate(utaw(nx,ny),vtaw(nx,ny))
      allocate(utwo(nx,ny),vtwo(nx,ny))
!####

      allocate(sustri(nx,ny),svstri(nx,ny)) 
      allocate(sustr(nxu,nyu),svstr(nxv,nyv)) 
!     allocate(masku(nxu,nyu),maskv(nxv,nyv)) 
      allocate(swrad(nx,ny),shflux(nx,ny))
      allocate(lwrad(nx,ny))
      allocate(swflux(nx,ny))
      allocate(lh(nx,ny),hfx(nx,ny))
      
! read mask with nolake; ! ocean=1 land=0;
      open(16,file='fort.16',form='formatted')
      read(16,*) WRF_DT 

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

      open(31,file='fort.31',form='formatted') !utaw
      open(32,file='fort.32',form='formatted') !vtaw
      open(33,file='fort.33',form='formatted') !utwo
      open(34,file='fort.34',form='formatted') !vtwo

      read(21,*) u10
      read(22,*) v10
      read(23,*) ust
      read(24,*) gsw
      read(25,*) glw
      read(26,*) sst
      read(27,*) lh
      read(28,*) hfx
      read(29,*) raincv
      read(30,*) rainncv
!
      read(31,*) utaw
      read(32,*) vtaw
      read(33,*) utwo
      read(34,*) vtwo

       rhoa=1.225
       rhoo=1023
       cff=5.67e-8

      do i=1,nx
        do j=1,ny
!1. sustr, svstr
! ust= sqrt(tau/rhoa)
! tau = rhoa * ust^2

! THETA=atan2(U10,V10)
! REMARK: remain to be seen if U10 and V10 are to be rotated
! UFLX = - (UST * rhoa ) * cos(THETA)
! VFLX = - (UST * rhoa ) * sin(THETA)
! rhoa=1.225;
! in principle u10 and v10 should be rotated to earth relative grid
! but since SCOAR onl use the mercator grid, rotation doesn't do anything
! rather than repeating this meaningless rotation every coupling step
! we skep this.
! scoar dos not have coupling over non-mercator grid yet.
! aug 31 2017
        theta=atan2(v10(i,j),u10(i,j))
! tau=rho*ust^2;

! total stress
        sustri(i,j) = 1 * (rhoa*ust(i,j)*ust(i,j)) * cos(theta)
        svstri(i,j) = 1 * (rhoa*ust(i,j)*ust(i,j)) * sin(theta)
      enddo
      enddo

! WW3 outputs have nan valiues over land (1E30)
       do 200 j=1,ny
        do 200 i=1,nx
         if (utaw(i,j) .gt. 1E10)
     &    utaw(i,j) = 0.
         if (vtaw(i,j) .gt. 1E10)
     &    vtaw(i,j) = 0.
         if (utwo(i,j) .gt. 1E10)
     &    utwo(i,j) = 0.
         if (vtwo(i,j) .gt. 1E10)
     &    vtwo(i,j) = 0.
  200    continue

! substract tau_w and tau_dis from total stress 
! to get tau_oc
        do i=1,nx
        do j=1,ny
! need to check the sign : 
       !sustri(i,j) =  sustri(i,j) + rhoo*utaw(i,j) + rhoo*utwo(i,j)
       !svstri(i,j) =  svstri(i,j) + rhoo*vtaw(i,j) + rhoo*vtwo(i,j)
        sustri(i,j) =  sustri(i,j) - rhoo*utaw(i,j) + rhoo*utwo(i,j)
        svstri(i,j) =  svstri(i,j) - rhoo*vtaw(i,j) + rhoo*vtwo(i,j)
        enddo
        enddo

! regrid on to u and v grids
       do i=1,nxu
         do j=1,nyu
         sustr(i,j) = 0.5 *(sustri(i,j)+sustri(i+1,j)) 
          enddo
       enddo
      do i=1,nxv
         do j=1,nyv
         svstr(i,j) = 0.5 *(svstri(i,j)+svstri(i,j+1)) 
          enddo
       enddo

!2.  compute "net" shortwave/longwave radiation
      do i=1,nx
        do j=1,ny
       swrad(i,j) = gsw(i,j)
!      cff=5.67e-8;% Wm-2K-4.
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
  
!4. swflux: cm/day
!4. rain is accumulated over coupling time
! ignore rainsh (too small)
      do i=1,nx
      do j=1,ny

! raincv and rainncv are mm/wrf_dt (model time-step in! second)
! mm/wrf_dt (e.g., mm/90s) --> cm/day
        rain(i,j)=(raincv(i,j)+rainncv(i,j))*(86400/WRF_DT)/10
      enddo
      enddo

! 5.  calculate swflux
      do i=1,nx
      do j=1,ny
!LH/Lv/rhow
!LH =W/m2 = J/s/m2
!Lv=J/kg
!rhow=kg/m3 
! --> m/s ==> 100*86400 cm/dayr
!nw{'swflux'}.positive = ncchar('net evaporation');
!nw{'swflux'}.negative = ncchar('net precipitation');
       swflux(i,j)=(-1*lh(i,j)/(2.5*10**6)/1025)*86400*100 - rain(i,j)
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

      subroutine qrh2(r,q,t,p,idum)
c
c  prog adapted from j. alpert
c  relatiive humidity and specific humidity converter  
c  Roads (SIO)  10/14/93
c  INPUT  -----
c
c     q   = specific humidity (Kg/Kg)
c     r   = relative humidity (%)
c     t   = temperature in K
c     p   = pressure in mb
c     idum=1 q to rh
c          2 rh to q
c
c
c       real r, q, t, p, es, pq, vpq
!      parameter(rlrv=5.4320774e+03,const=2.645144e+11)
!      real*8,dimension(:,:), allocatable :: es, vpq
        data rlrv,const/5.4320774e+03,2.645144e+11/

        es=const/exp(rlrv/t)
        pq=p*100.
c idum=1 qtorh, idum=2 rhtoq

        if(idum.eq.1)then
        vpq=(.622*es+.378*es*q)/pq
        r=100.*q/vpq
        endif

        if(idum.eq.2)then
        vp=.622*es/(pq-.378*r*es/100.)
        q=vp*r/100.
        endif
        
! addition from hyodae
! RH is sometimes greater than 100 or less than 0.
! Correct this.
       if ( r .gt. 100. ) then
!       print*, 'warining: RH is greater than 100'
!       print *, r
          r = 100.
       else if ( r .lt. 0. ) then
!       print *, 'warining: RH is less than 0 '
!       print *, r
          r = 0.
       endif

        return
        end subroutine qrh2
