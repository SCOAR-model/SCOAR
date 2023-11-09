! calculate flux field according to roms needs
! for WRF2ROMS coupler
! 2012 Aug 18 
! Hyodae Seo

! input:
! 21. U10 m/s
! 22. V10 m/s
! 23. UST m/s
! 24. SWDOWN W/m2
! 25. GSW W/m2
! 25. GLW W/m2
! 26. ALBEDO [fra]
! 27. TSK
! 28. LH
! 29. HFX: W/m2
! 30. RAINC [mm/CF] !note input rains are already in rain-rate check WRF2ROMS.sh
! 31. RAINNC [mm/CF] !mm/24hr or mm/6hr for example

! output: 
! 51.uflx
! 52. vlx
! 53 shflux
! 54 swflux
! 55 swrad

! to be done
! FOR Wind stress
! THETA=atan2(U10,V10)
! REMARK: remain to be seen if U10 and V10 are to be rotated
! UFLX = - (UST * rhoa ) * cos(THETA)
! VFLX = - (UST * rhoa ) * sin(THETA)
! rhoa=1.225;

! UPWARD LONGWAVE AT THE SFC
! constant=5.67e-8;% Wm-2K-4.
! LWu=-constant.*TSK^4;

! shflux= GSW + GLW + LWu - LH - HFX

! swflux
! SFCEVP [kg m-2] - PRECIP [kg m-2]

! constants
      integer :: CF

! read flux files at 1 time step
! input
      real, dimension(:,:), allocatable :: u101, v101
      real, dimension(:,:), allocatable :: swdown 
      real, dimension(:,:), allocatable :: glw
      real, dimension(:,:), allocatable :: t2, q2, psfc
      real, dimension(:,:), allocatable :: rainnc, rainc, rainsh
      real, dimension(:,:), allocatable :: albedo

! output
      real, dimension(:,:), allocatable :: u10, v10
      real, dimension(:,:), allocatable :: swrad, lwrad
      real, dimension(:,:), allocatable :: PairM
      real, dimension(:,:), allocatable :: TairC
      real, dimension(:,:), allocatable :: Qair
      real, dimension(:,:), allocatable :: rain

      open(11,file='fort.11',form='formatted')
      read(11,*) nx, ny, nxny

      open(12,file='fort.12',form='formatted')
      read(12,*) CF 

! input
      allocate(u101(nx,ny),v101(nx,ny))
      allocate(swdown(nx,ny))
      allocate(glw(nx,ny))
      allocate(t2(nx,ny), q2(nx,ny), psfc(nx,ny))
      allocate(rainnc(nx,ny))
      allocate(rainc(nx,ny))
      allocate(rainsh(nx,ny))
      allocate(albedo(nx,ny))

! ouput
      allocate(swrad(nx,ny),lwrad(nx,ny))
      allocate(PairM(nx,ny))
      allocate(TairC(nx,ny))
      allocate(Qair(nx,ny))
      allocate(u10(nx,ny),v10(nx,ny))
      allocate(rain(nx,ny))
      
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

      read(21,*) u101
      read(22,*) v101
      read(23,*) swdown
      read(24,*) glw
      read(25,*) t2
      read(26,*) q2
      read(27,*) psfc
      read(28,*) albedo 
      read(29,*) rainc 
      read(30,*) rainnc 
      read(31,*) rainsh

! define variable with different units
      TairC=t2-273.149
      PairM=psfc/100.

!      do i=1,nxny,200
!       print *, 'i, TairK, TairC, Pairpa, Pairmb'
!       print *, i, t2(i), TairC(i), psfc(i), PairM(i)
!      enddo

!1. u10 v10
      do i=1,nxny
       u10(i)=u101(i)
       v10(i)=v101(i)
      enddo

!2.  compute "net" shortwave/longwave radiation
      do i=1,nxny
c since there is no upward shortwave
c net showrtwave is computed as folows using albedo and downard shortwave
       swrad(i) = (1-albedo(i)) * swdown(i)
c only downward longwave is available fro mwrf
c so let roms to compute upward longwave
c and provide only donwlad component from wrf
       lwrad(i) = glw(i)
      enddo
      print *, 'note LONGWAVE_OUT is defined'
       print *, 'lwrad is downward longwave only!'
      
!3. compute Qair (2m relative humidity, [%]) from given specific humidity at 2M (kg/kg)
      do i=1,nxny
       call qrh2(Qair(i), q2(i), t2(i), PairM(i),1)
      enddo
 
!4. rain is accumulated over coupling time
!rain [mm] for $CF hr--> we need to change to kg/m2/s
!rain(mm/CF) *(1hr/3600s)*(1m/1000mm)*rho(1000kg/m3)
!result: -->rain =(rainc+rainnc+rainsh)/CF/60/60
!outcompe: rain (kg/m**2/s)    
      do i=1, nxny
      rain(i)=(rainc(i)+rainnc(i)+rainsh(i))/CF/3600
      enddo

! 7. print some vars
!      do i=1,nxny,200
!        print *, 'i, SWRAD, LWRAD, u10, v10'
!        print *, i, swrad(i), lwrad(i), u10(i), v10(i)
!        print *, 'i, Qair, Pair, Tair, RAIN'
!        print *, i, Qair(i), PairM(i), TairC(i), rain(i)
!      enddo

! write outputs
      open(51,file='fort.51',form='formatted',status='unknown')
      write(51,*) swrad
      open(52,file='fort.52',form='formatted',status='unknown')
      write(52,*) lwrad
      open(53,file='fort.53',form='formatted',status='unknown')
      write(53,*) PairM
      open(54,file='fort.54',form='formatted',status='unknown')
      write(54,*) Qair
      open(55,file='fort.55',form='formatted',status='unknown')
      write(55,*) TairC
      open(56,file='fort.56',form='formatted',status='unknown')
      write(56,*) rain
      open(57,file='fort.57',form='formatted',status='unknown')
      write(57,*) u10
      open(58,file='fort.58',form='formatted',status='unknown')
      write(58,*) v10

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
