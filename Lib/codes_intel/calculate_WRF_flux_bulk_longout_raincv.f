! calculate flux field according to roms needs
! 1. calculate swrad (WRF only outputs swrad down)
! will have to go through radiaiton code to see how albedo is used
! 2. calculate lwrad (only need lwrad down)
! 3. calculate
!    Q2: kg/kg -> %
!    PSFC: Pa -> mb
!    T2: K -> C
!
! Notice that cloud frac, uswrf, ulwrf, lh are not used.
! Albedo is used instead to compute net swrad. 
! 
! input:
! 21. U10 m/s
! 22. V10 m/s
! 23. SWDOWN W/m2
! 24. GLW W/m2
! 25. T2 K
! 26. Q2 kg/kg
! 27. PSFC Pa
! 28. ALBEDO 0-1
! 29. RAINCV [mm/WRF_DT] e.g., mm/90s 
! 30. RAINNCV [mm/WRF_DT] e.g., mm/90s 
! 31. RAINSHV [mm/WRF_DT] e.g., mm/90s 

! output: 
! 51.swrad W/m2
! 52. lwrad (or lwrad_down) W/m2
! 53. Pair mb
! 54. Qair %
! 55. TairC C
! 56. rain kg/m**2/s
! 57. u10 m/s
! 58. v10 m/s

! constants
      integer :: WRF_DT

! read flux files at 1 time step
! input
      real, dimension(:,:), allocatable :: u101, v101
      real, dimension(:,:), allocatable :: swdown 
      real, dimension(:,:), allocatable :: glw
      real, dimension(:,:), allocatable :: t2, q2, psfc
      !real, dimension(:,:), allocatable :: rainnc, rainc, rainsh
      real, dimension(:,:), allocatable :: rainncv, raincv
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
      read(12,*) WRF_DT

! input
      allocate(u101(nx,ny),v101(nx,ny))
      allocate(swdown(nx,ny))
      allocate(glw(nx,ny))
      allocate(t2(nx,ny), q2(nx,ny), psfc(nx,ny))
      allocate(rainncv(nx,ny))
      allocate(raincv(nx,ny))
      !allocate(rainsh(nx,ny))
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
!      open(31,file='fort.31',form='formatted')

      read(21,*) u101
      read(22,*) v101
      read(23,*) swdown
      read(24,*) glw
      read(25,*) t2
      read(26,*) q2
      read(27,*) psfc
      read(28,*) albedo 
      read(29,*) raincv 
      read(30,*) rainncv 
      !read(31,*) rainsh

! define variable with different units
      TairC=t2-273.149
      PairM=psfc/100.

!      do i=1,nxny,200
!       print *, 'i, TairK, TairC, Pairpa, Pairmb'
!       print *, i, t2(i), TairC(i), psfc(i), PairM(i)
!      enddo

!1. u10 v10
      do i=1,nx
      do j=1,ny
       u10(i,j)=u101(i,j)
       v10(i,j)=v101(i,j)
      enddo
      enddo

!2.  compute "net" shortwave/longwave radiation
      do i=1,nx
      do j=1,ny
c since there is no upward shortwave
c net showrtwave is computed as folows using albedo and downard shortwave
       swrad(i,j) = (1-albedo(i,j)) * swdown(i,j)
c only downward longwave is available fro mwrf
c so let roms to compute upward longwave
c and provide only donwlad component from wrf
       lwrad(i,j) = glw(i,j)
      enddo
      enddo
      print *, 'note LONGWAVE_OUT is defined'
       print *, 'lwrad is downward longwave only!'
      
!3. compute Qair (2m relative humidity, [%]) from given specific humidity at 2M (kg/kg)
      do i=1,nx
      do j=1,ny
       call qrh2(Qair(i,j), q2(i,j), t2(i,j), PairM(i,j),1)
      enddo
      enddo
 
!4. rain is accumulated over the WRF_dt
! input: mm for wrf_dt (e.g., mm for 90s)
! output: kg/m**2/s
      do i=1, nx
      do j=1, ny
! mm / wrfdt * 1/1000(mm) * 1000 (kg/m3)
      rain(i,j)=(raincv(i,j)+rainncv(i,j))/(WRF_DT)
      enddo
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
