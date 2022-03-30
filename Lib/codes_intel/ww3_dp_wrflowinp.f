      include 'netcdf.inc'
      parameter(nt=1)
      integer status, ncid, nd
      real*8,dimension(:,:,:,:), allocatable :: dpWW3,vWW3,uWW3
      real*8,dimension(:,:,:,:), allocatable :: dir_wind,angle
      integer, dimension(:,:,:), allocatable :: land
      integer varid, varid2, nt2, pi
      integer start(3) ,count(3), stride(3)
      integer start2(3) ,count2(3), stride2(3)
      
!     data start / 1, 1, nd, nt / 
      data stride / 1, 1, 1 /
      data stride2 / 1, 1, 1 /

        pi=3.1416

! fort.11: roms grid info
! fort.12: roms file
! fort.13: nd (# of vertical grid in roms)
! fort.14: wrflowinp
! fort.15: wrfinput (for reading landmask)

! need to add interpolation part later..

! #######################################################
! 1. read grid info
      open(11,file='fort.11',form='formatted')
      read(11,*) nx,ny
      allocate(dir_wind(nx,ny,1,1))
      allocate(angle(nx,ny,1,1))
      allocate(dpWW3(nx,ny,1,1))
      allocate(uWW3(nx,ny,1,1))
      allocate(vWW3(nx,ny,1,1))
      allocate(land(nx,ny,1))
      count(1)=nx
      count(2)=ny
      count(3)=1
       
      !print *, "nx,ny=",nx,ny

      start(1)=1
      start(2)=1
      start(3)=nt

      open(15,file='fort.15',form='formatted')
      read(15,*) nt2

! 2. open existing avg.nc file
       status = nf_open('fort.12',nf_nowrite,ncid)
       if (status .ne. nf_noerr) call handle_err(status,1)

! 2.  get a dp varid from ww3 file
      status = nf_inq_varid(ncid,'dp',varid)
       if (status .ne. nf_noerr) call handle_err(status,2)

! 3. read dp: subsampled data of temp
      status = nf_get_vars_double(ncid,varid,start,count,stride,dpWW3)
      if (status .ne. nf_noerr) call handle_err(status,3)

! 2.  get a uwind varid from ww3 file
      status = nf_inq_varid(ncid,'uwnd',varid)
       if (status .ne. nf_noerr) call handle_err(status,2)

! 3. read uwind: subsampled data of temp
      status = nf_get_vars_double(ncid,varid,start,count,stride,uWW3)
      if (status .ne. nf_noerr) call handle_err(status,3)
! 2.  get a vwind varid from ww3 file
      status = nf_inq_varid(ncid,'vwnd',varid)
       if (status .ne. nf_noerr) call handle_err(status,2)

! 3. read uwind: subsampled data of temp
      status = nf_get_vars_double(ncid,varid,start,count,stride,vWW3)
      if (status .ne. nf_noerr) call handle_err(status,3)

! 4 close file
      status = nf_close(ncid)
      if (status .ne. nf_noerr) call handle_err(status,4)

       start2(1)=1
       start2(2)=1
       start2(3)=nt2

       count2(1)=nx
       count2(2)=ny
       count2(3)=1
       
      open(16,file='fort.16',form='formatted')
      read(16,*) land
!	print *, land

! calcul wind angle
       do 201 j=1,ny
        do 201 i=1,nx
          dir_wind(i,j,1,1) = ATAN2(vWW3(i,j,1,1),uWW3(i,j,1,1))
          dir_wind(i,j,1,1) = dir_wind(i,j,1,1)*(180./3.14159)
! put dir between 0 and 360
          if (dir_wind(i,j,1,1) .lt. 0)
     &     dir_wind(i,j,1,1)=dir_wind(i,j,1,1)+360
! convert convention 
          dpWW3(i,j,1,1)=270-dpWW3(i,j,1,1)
! check no dp < 0
          if (dpWW3(i,j,1,1) .lt. 0)
     &       dpWW3(i,j,1,1)=dpWW3(i,j,1,1)+360
!calcul angle
          angle(i,j,1,1)=ABS(dpWW3(i,j,1,1)-dir_wind(i,j,1,1))
! put angle between 0 and 180
          if (angle(i,j,1,1) .gt. 180)
     &       angle(i,j,1,1)=ABS(angle(i,j,1,1)-360)
!convert radian
          angle(i,j,1,1)=angle(i,j,1,1)*(3.14159/180.)
!
  201    continue


! set land values to 0
! land=0 ocean=1
       do 200 j=1,ny
        do 200 i=1,nx
         if (land(i,j,1) .eq. 0) 
     &    angle(i,j,1,1) = 0.
  200    continue

!       print *, dir_wind(150,150,1,1)
!       print *, dpWW3(150,150,1,1)
!       print *, angle(150,150,1,1)
!print *, vWW3
! #######################################################
! write to wrflowinp
! 1. open forc file
      status = nf_open('fort.14',nf_write,ncid2)
      if (status .ne. nf_noerr) call handle_err(status,7)

! 2. get varid from forc file
      status = nf_inq_varid(ncid2,'THETA_WW',varid2)
      if (status .ne. nf_noerr) call handle_err(status,8)

! 3.  write theta
      status=nf_put_vars_double(ncid2,varid2,
     &               start2,count2,stride2,angle)
      if (status .ne. nf_noerr) call handle_err(status,10)

! 4. close 
      status = nf_close(ncid2)
      if (status .ne. nf_noerr) call handle_err(status,12)
! ###########
     
      call exit
      end
      
       subroutine handle_err(status,n)
       integer status,n
       if (status .ne. nf_noerr) then
          print *, n,' ',status
          print *, 'reading dp from ww3.nc failed!!!'
          print *, 'stop'
           call exit
       endif
       end subroutine handle_err
