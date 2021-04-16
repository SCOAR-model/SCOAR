      include 'netcdf.inc'
      parameter(nt=1)
      integer status, ncid, nd
      real*8,dimension(:,:,:,:), allocatable :: sstROMS
      real*8,dimension(:,:,:), allocatable :: land, sstWRF
      integer varid, varid2, nt2
      integer start(4) ,count(4), stride(4)
      integer start2(3) ,count2(3), stride2(3)
      
!     data start / 1, 1, nd, nt / 
      data stride / 1, 1, 1, 1 /
      data stride2 / 1, 1, 1 /

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
      allocate(sstROMS(nx,ny,1,1))
      allocate(sstWRF(nx,ny,1))
      allocate(land(nx,ny,1))
      count(1)=nx
      count(2)=ny
      count(3)=1
      count(4)=1
       
      !print *, "nx,ny=",nx,ny

      open(13,file='fort.13',form='formatted')
      read(13,*) nd
      start(1)=1
      start(2)=1
      start(3)=nd
      start(4)=nt

      open(15,file='fort.15',form='formatted')
      read(15,*) nt2

! 2. open existing avg.nc file
       status = nf_open('fort.12',nf_nowrite,ncid)
       if (status .ne. nf_noerr) call handle_err(status,1)

! 2.  get a varid from avg.nc
      status = nf_inq_varid(ncid,'temp',varid)
       if (status .ne. nf_noerr) call handle_err(status,2)

! 3. read sst: subsampled data of temp
! note convetion is [x y z t]!! not following netcdf convention!
      status = nf_get_vars_double(ncid,varid,start,count,stride,sstROMS)
      if (status .ne. nf_noerr) call handle_err(status,3)
      sstROMS=sstROMS+273.15

! 4 close file
      status = nf_close(ncid)
      if (status .ne. nf_noerr) call handle_err(status,4)

       start2(1)=1
       start2(2)=1
       start2(3)=nt2

       count2(1)=nx
       count2(2)=ny
       count2(3)=1
       
! read landmask from wrfinput_d01
! 1. open wrfinput_d01
      status = nf_open('fort.16',nf_nowrite,ncid2)
      if (status .ne. nf_noerr) call handle_err(status,7)
! 2. get varid from forc file
      status = nf_inq_varid(ncid2,'LANDMASK',varid2)
      if (status .ne. nf_noerr) call handle_err(status,8)
! 3. read landmask 
      status=nf_get_var_double(ncid2,varid2,land)
      if (status .ne. nf_noerr) call handle_err(status,10)
! 4. close 
      status = nf_close(ncid2)
      if (status .ne. nf_noerr) call handle_err(status,12)
! ###########
!print *, land
!print *, "land"

! read SST WRF
! #######################################################
! read sst value first 
      status = nf_open('fort.14',nf_nowrite,ncid2)
      if (status .ne. nf_noerr) call handle_err(status,7)

      status = nf_inq_varid(ncid2,'SST',varid2)
      if (status .ne. nf_noerr) call handle_err(status,8)
      status=nf_get_vars_double(ncid2,varid2,
     &               start2,count2,stride2,sstWRF)
      if (status .ne. nf_noerr) call handle_err(status,10)

      status = nf_close(ncid2)
      if (status .ne. nf_noerr) call handle_err(status,12)
! ###########

! treat land/mask
       do 200 j=1,ny
        do 200 i=1,nx
         if (int(land(i,j,1)) .eq. 1)
     &       sstROMS(i,j,1,1) = sstWRF(i,j,1)
  200    continue
!print *, sstROMS
! #######################################################
! write to wrflowinp
! 1. open forc file
      status = nf_open('fort.14',nf_write,ncid2)
      if (status .ne. nf_noerr) call handle_err(status,7)

! 2. get varid from forc file
      status = nf_inq_varid(ncid2,'SST',varid2)
      if (status .ne. nf_noerr) call handle_err(status,8)

! 3.  write SST
      status=nf_put_vars_double(ncid2,varid2,
     &               start2,count2,stride2,sstROMS)
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
          print *, 'reading sst from avg.nc failed!!!'
          print *, 'stop'
           call exit
       endif
       end subroutine handle_err
