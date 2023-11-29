      include 'netcdf.inc'
      parameter(nt=1)
      integer status, ncid, nd
      real*8,dimension(:,:,:,:), allocatable :: vWW3
      integer, dimension(:,:,:), allocatable :: land
      integer varid, varid2, nt2
      integer start(3) ,count(3), stride(3)
      integer start2(3) ,count2(3), stride2(3)
      
!     data start / 1, 1, nd, nt / 
      data stride / 1, 1, 1 /
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

! 2.  get a t02 varid from ww3 file
      status = nf_inq_varid(ncid,'t02',varid)
       if (status .ne. nf_noerr) call handle_err(status,2)

! 3. read t02: subsampled data of temp
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

! set land values to 0
! land=0 ocean=1
       do 200 j=1,ny
        do 200 i=1,nx
         if (land(i,j,1) .eq. 0) 
     &    vWW3(i,j,1,1) = 0.
  200    continue

!print *, vWW3
! #######################################################
! write to wrflowinp
! 1. open forc file
      status = nf_open('fort.14',nf_write,ncid2)
      if (status .ne. nf_noerr) call handle_err(status,7)

! 2. get varid from forc file
      status = nf_inq_varid(ncid2,'TP_WAVE',varid2)
      if (status .ne. nf_noerr) call handle_err(status,8)

! 3.  write t02
      status=nf_put_vars_double(ncid2,varid2,
     &               start2,count2,stride2,vWW3)
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
          print *, 'reading t02 from ww3.nc failed!!!'
          print *, 'stop'
          stop status
       endif
       end subroutine handle_err
