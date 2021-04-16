      include 'netcdf.inc'
      parameter(nt=1)
! read grid details for grid.nc
! read 2D SST from avg.nc(nt=1), or forc.nc(nt=1)
! smooth the field with smooth2dgenf.F
! write smooth field onto grib (for coupler) or netcdf (for analysis)

      integer status, ncid
      real*8,dimension(:,:), allocatable :: xrin, yrin, mkrin
      real*8,dimension(:,:,:), allocatable :: varin
      real*8,dimension(:,:), allocatable :: zin, zout
      real*8,dimension(:), allocatable :: xin, yin
      real*8 :: spanx, spany
      real*8 nan

! 1 is to read grid.nc 2d-vars
      integer start1(2), count1(2), stride1(2) 
! 2 is to read temp from sst.nc 4dvars
      integer start2(3), count2(3), stride2(3)
      integer start3(3), count3(3), stride3(3)

      integer xrid, yrid, mkrid, varid
      integer nxx, nyy, nxxnyy
      integer nt, nd            !nt=1 time stepping, nd=depth layers
      character*17 ROMSvar ! ROMS variable to read
      character*17 RECvar !before/after variable name to record
      character*17 var_lon, var_lat, var_mask
 
      data stride1 /1,1/
      data stride2 /1,1,1/
      data stride3 /1,1,1/

       nan = 1.D35
!      nan = 0. 
!      nan = nan / nan

! get grid size of variable (2D)
      open(11,file='fort.11',form='formatted')
      read(11,*) nxx, nyy, nxxnyy
      count1(1)=nxx
      count1(2)=nyy
      allocate(xin(nxx))
      allocate(yin(nyy))
      allocate(xrin(nxx,nyy))
      allocate(yrin(nxx,nyy))
      allocate(mkrin(nxx,nyy))
      allocate(zin(nxx,nyy))
      allocate(zout(nxx,nyy))

! get smoothing half-span for x and y directions
      open(121, file='fort.12',form='formatted')
      read(121,*) spanx
      open(122, file='fort.13',form='formatted')
      read(122,*) spany
       !print *,'spanx = ',spanx
       !print *,'spany = ',spany
      
! get variable name
      open(14,file='fort.14',form='formatted')
      read(14,*) ROMSvar
      !print *,'ROMSvar= ',trim(ROMSvar)

      count2(1)=nxx
      count2(2)=nyy
      count2(3)=nt

       start3(1)=1
       start3(2)=1
       start3(3)=1
       count3(1)=nxx
       count3(2)=nyy
       count3(3)=1

! get number of depth layers in ocean (N)
      open(15,file='fort.16',form='formatted')
      read(15,*) nd
      allocate(varin(nxx,nyy,nt))
!     print *,'nd = ',nd

! get new variable name to be saved after
      open(32,file='fort.17',form='formatted')
      read(32,*) RECvar
!      print *,'RECvar = ',RECvar

      start1(1)=1
      start1(2)=1

      start2(1)=1
      start2(2)=1
      start2(3)=nt

      open(20,file='fort.20',form='formatted')
      read(20,*) var_lon
      open(21,file='fort.21',form='formatted')
      read(21,*) var_lat
      open(22,file='fort.22',form='formatted')
      read(22,*) var_mask

!print *, var_lon
!print *, var_lat
!print *, var_mask

! 1. open $Nameit_ROMS-grid.nc
      status = nf_open('fort.18',nf_nowrite,ncid)
      if (status .ne. nf_noerr) call handle_err(status,1)

! 2. get x/y/mask variable id
      !status = nf_inq_varid(ncid,'lon_rho',xrid)
      status = nf_inq_varid(ncid,var_lon,xrid)
      status = nf_inq_varid(ncid,var_lat,yrid)
      status = nf_inq_varid(ncid,var_mask,mkrid)
!      status = nf_inq_varid(ncid,'x_rho',xrid)
!      status = nf_inq_varid(ncid,'y_rho',yrid)
      if (status .ne. nf_noerr) call handle_err(status,2)
!print *, "xrid=",xrid
!print *, "yrid=",yrid

! 3. read xrin/yrin/maskin
      status=nf_get_vars_double(ncid,xrid,start1,count1,stride1,xrin)
      status=nf_get_vars_double(ncid,yrid,start1,count1,stride1,yrin)
      status=nf_get_vars_double(ncid,mkrid,start1,count1,stride1,mkrin)
      if (status .ne. nf_noerr) call handle_err(status,3)

! 4. close
      status = nf_close(ncid)
      if (status .ne. nf_noerr) call handle_err(status,4)

! 1d vector of x and y
      do i=1,nxx
       xin(i)=xrin(i,1)
      enddo
      do i=1,nyy
       yin(i)=yrin(1,i)
      enddo

! 5. open avg.nc (nt=1)
      status = nf_open('fort.19',nf_nowrite,ncid)
      if (status .ne. nf_noerr) call handle_err(status,5)

! 6.  get a varid from avg.nc
      status = nf_inq_varid(ncid,trim(ROMSvar),varid)
      if (status .ne. nf_noerr) call handle_err(status,6)

! 7. read in subsampled data
      status=nf_get_vars_double(ncid,varid,start2,count2,stride2,varin)
      if (status .ne. nf_noerr) call handle_err(status,7)

! 8. close
      status = nf_close(ncid)
      if (status .ne. nf_noerr) call handle_err(status,8)
	!print *, varin

! convert 3D to 2D array
!      do i=1,nxxnyy
!#         zin(i)=varin(i)
!#      enddo
      do i=1,nxx
        do j=1,nyy
         zin(i,j)=varin(i,j,nt)
        enddo
      enddo
!     print *,'zin = ',zin(19,19)

! find land mask and set zin(land_mask) to nan
      do i=1,nxx
        do j=1,nyy
         if (mkrin(i,j).eq.0) zin(i,j)=nan
      enddo
      enddo

!print *, mkrin
!     print *,'zin = ',zin(19,19)

! perform filter
      print *, "loess2 filtering..."
      call loess2(zin,xin,yin,nxx,nyy,spanx,spany,zout)

! check to see what values we get
!       print *, zin(130)
!       print *, zout(130)
!       print *, zin(355)
!       print *, zout(355)
!       print *, zin(2048)
!       print *, zout(2048)

! set land mask back to zero
      do i=1,nxx
      do j=1,nyy
         if (mkrin(i,j).eq.0) zout(i,j)=0
      enddo
      enddo
!print *, zout(19,19)

! fill land to zero
      do i=1,nxx
      do j=1,nyy
         if (zin(i,j).eq.nan) zin(i,j)=0
      enddo
      enddo


! #######################################################
! write values before smoothing (<--zout)
! 1. open forc file
      status = nf_open('fort.51',nf_write,ncid)
      if (status .ne. nf_noerr) call handle_err(status,7)

! 2. get varid 
      status = nf_inq_varid(ncid,RECvar,varid)
      if (status .ne. nf_noerr) call handle_err(status,8)

! 3.  write 
!print *, start1
!print *, count1
!print *, stride1
      status=nf_put_vars_double(ncid,varid,
     &               start3,count3,stride3,zin)
      if (status .ne. nf_noerr) call handle_err(status,10)

! 4. close 
      status = nf_close(ncid)
      if (status .ne. nf_noerr) call handle_err(status,12)
! ###########

! #######################################################
! write values after smoothing (<--zout)
! 1. open forc file
      status = nf_open('fort.52',nf_write,ncid)
      if (status .ne. nf_noerr) call handle_err(status,7)

! 2. get varid 
      status = nf_inq_varid(ncid,RECvar,varid)
      if (status .ne. nf_noerr) call handle_err(status,8)

! 3.  write 
      status=nf_put_vars_double(ncid,varid,
     &               start3,count3,stride3,zout)
      if (status .ne. nf_noerr) call handle_err(status,10)

! 4. close 
      status = nf_close(ncid)
      if (status .ne. nf_noerr) call handle_err(status,12)
! ###########

      stop
      end

      
      subroutine handle_err(status,Num)
      integer status, Num
      if (status .ne. nf_noerr) then
         print *, '*****************************'
         print *, 'failed! nc file not read correctly ',Num
         print *, '*****************************'
         print *, 'stop'
          stop
      endif
      end subroutine

