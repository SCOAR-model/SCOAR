      include 'netcdf.inc'
      parameter(nt=1)
      integer status, ncid, nd
      real*8,dimension(:,:,:,:), allocatable :: uROMS, uROMSu
      real*8,dimension(:,:,:), allocatable :: land, uWRF
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
      open(17,file='fort.17',form='formatted')
      read(17,*) nxu,nyu
      open(11,file='fort.11',form='formatted')
      read(11,*) nx,ny
      allocate(uROMS(nx,ny,1,1))
      allocate(uROMSu(nxu,nyu,1,1))
      allocate(uWRF(nx,ny,1))
      allocate(land(nx,ny,1))
      count(1)=nxu
      count(2)=nyu
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
      status = nf_inq_varid(ncid,'u',varid)
       if (status .ne. nf_noerr) call handle_err(status,2)

! 3. read subsampled data of u 
! note convetion is [x y z t]!! not following netcdf convention!
      status = nf_get_vars_double(ncid,varid,start,count,stride,uROMSu)
      if (status .ne. nf_noerr) call handle_err(status,3)

! 4 close file
      status = nf_close(ncid)
      if (status .ne. nf_noerr) call handle_err(status,4)

! u to rho grid
       do j=1,ny
        do i=1,nx
        uROMS(i,j,1,1)=0
        enddo
        enddo

       do j=1,ny
        do i=2,nx-1
        uROMS(i,j,1,1)=0.5 * (uROMSu(i-1,j,1,1)+uROMSu(i,j,1,1))
        enddo
        enddo

       do j=1,ny
        uROMS(1,j,1,1)=uROMSu(2,j,1,1)
        uROMS(nx,j,1,1)=uROMSu(nx-1,j,1,1)
        enddo

       start2(1)=1
       start2(2)=1
       start2(3)=nt2

       count2(1)=nx
       count2(2)=ny
       count2(3)=1
       
! read mask with nolake; 
! ocean=1 land=0;
        open(21,file='fort.16',form='formatted')
        read(21,*) land 
! ###########
!print *, land
!print *, "land"

! treat land/mask
       do 200 j=1,ny
        do 200 i=1,nx
         if (int(land(i,j,1)) .eq. 0)
     &       uROMS(i,j,1,1) = 0.
  200    continue

! #######################################################
! write to wrflowinp
! 1. open forc file
      status = nf_open('fort.14',nf_write,ncid2)
      if (status .ne. nf_noerr) call handle_err(status,7)

! 2. get varid from forc file
      status = nf_inq_varid(ncid2,'UOCE',varid2)
      if (status .ne. nf_noerr) call handle_err(status,8)

! 3.  write UOCE
      status=nf_put_vars_double(ncid2,varid2,
     &               start2,count2,stride2,uROMS)
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
          print *, 'reading uoce from avg.nc failed!!!'
          print *, 'stop'
           call exit
       endif
       end subroutine handle_err
