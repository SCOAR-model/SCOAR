      include 'netcdf.inc'
      parameter(nt=1)
      integer status, ncid, ncid2, nd
      real*8,dimension(:,:,:,:), allocatable :: ust_ww
      real*8,dimension(:,:,:), allocatable :: uust,vust
      integer, dimension(:,:,:), allocatable :: land
      integer varid, varid2, nt2
      integer start(3) ,count(3), stride(3)
      integer start2(3) ,count2(3), stride2(3)
      
      data stride / 1, 1, 1 /
      data stride2 / 1, 1, 1 /

! synopsis
! read UST (total UST, UST_wave + UST_visc) from WW3 
! pass it on to wrflowinpt, which is then used in MYNN surface layer scheme

! fort.11: roms grid info
! fort.12: roms file
! fort.14: wrflowinp
! fort.16: wrfinput (for reading landmask)

! need to add interpolation part later..

! #######################################################
! 1. read grid info
      open(11,file='fort.11',form='formatted')
      read(11,*) nx,ny
      allocate(ust_ww(nx,ny,1,1))
      allocate(land(nx,ny,1))
      allocate(uust(nx,ny,1))
      allocate(vust(nx,ny,1))
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

! 2.  get a varid from ww3 file
      status = nf_inq_varid(ncid,'uust',varid)
       if (status .ne. nf_noerr) call handle_err(status,8)

! 3. read hs: subsampled data 
      status = nf_get_vars_double(ncid,varid,start,count,stride,uust)
      if (status .ne. nf_noerr) call handle_err(status,9)

! 2.  get a varid from ww3 file
      status = nf_inq_varid(ncid,'vust',varid)
       if (status .ne. nf_noerr) call handle_err(status,8)

! 3. read hs: subsampled data
      status = nf_get_vars_double(ncid,varid,start,count,stride,vust)
      if (status .ne. nf_noerr) call handle_err(status,9)

! 4 close file
      status = nf_close(ncid)
      if (status .ne. nf_noerr) call handle_err(status,10)

       start2(1)=1
       start2(2)=1
       start2(3)=nt2

       count2(1)=nx
       count2(2)=ny
       count2(3)=1
       
      open(16,file='fort.16',form='formatted')
      read(16,*) land
!	print *, land

! NaN (9.969209968386869E+036) values along the open boundaries
! in some variables (vectors, and even some scalar variables such as fws).
       do 300 j=1,ny
            uust(1,j,1) = uust(2,j,1)  ! west
            uust(nx,j,1) = uust(nx-1,j,1)  ! east
            vust(1,j,1) = vust(2,j,1)  ! west
            vust(nx,j,1) = vust(nx-1,j,1)  ! east
  300    continue
       do 301 i=1,nx
            uust(i,1,1) = uust(i,2,1)  ! south
            uust(i,ny,1) = uust(i,ny-1,1)  ! north
            vust(i,1,1) = vust(i,2,1)  ! south
            vust(i,ny,1) = vust(i,ny-1,1)  ! north
  301    continue

       do 100 j=1,ny
        do 100 i=1,nx
          !ust_ww(i,j,1,1)=sqrt(uust(i,j,1)**2 + vust(i,j,1)**2)
            ust_ww(i,j,1,1)=sqrt(uust(i,j,1)*uust(i,j,1) 
     &                        + vust(i,j,1)*vust(i,j,1))
  100    continue
		!print *, ust_ww

! set land values to 0
! land=0 ocean=1
       do 200 j=1,ny
        do 200 i=1,nx
         if (land(i,j,1) .eq. 0) 
     &    ust_ww(i,j,1,1) = 0.

! temporary fix: October 28, 2022
! there is still nan if the neighboring points have nan.
! this case, just set to zero
         if (ust_ww(i,j,1,1) .gt. 1E10)
     &    ust_ww(i,j,1,1) = 0.
  200    continue

! #######################################################
! write to wrflowinp

! 1. open file
      status = nf_open('fort.14',nf_write,ncid2)
      if (status .ne. nf_noerr) call handle_err(status,11)

! 2. get varid from file
      status = nf_inq_varid(ncid2,'UST_WW',varid2)
      if (status .ne. nf_noerr) call handle_err(status,12)

! 3.  write hs
      status=nf_put_vars_double(ncid2,varid2,
     &               start2,count2,stride2,ust_ww)
      if (status .ne. nf_noerr) call handle_err(status,13)

! 4. close 
      status = nf_close(ncid2)
      if (status .ne. nf_noerr) call handle_err(status,14)
! ###########
     
      call exit
      end
      
       subroutine handle_err(status,n)
       integer status,n
       if (status .ne. nf_noerr) then
          print *, n,' ',status
          print *, 'reading ust from ww3.nc failed!!!'
          print *, 'stop'
          stop status
       endif
       end subroutine handle_err
