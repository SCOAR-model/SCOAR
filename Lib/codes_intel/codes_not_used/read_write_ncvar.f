      include 'netcdf.inc'
      integer status, ncid
      integer start(3), count(3), stride(3)
      integer nx, ny, nxny      !grid dimensions
      integer i, nt                !nt=1 time stepping
!      integer nda               !number of depth layers (atm)
      real*8,dimension(:,:,:), allocatable :: varin
!      integer Nrecs1		!Nrecs1 = NDay for wrfout.nc
      integer varid, Tid        !variable ID and time ID
      character*8 Tname         !name for time
      character*12 VARIABLE     !variable name

      data stride /1,1,1/

! 1. get all in grid related info
! get grid info
      open(11,file='fort.11',form='formatted')
      read(11,*) nx, ny, nxny

      allocate(varin(nx,ny,1))

! get variable name
      open(12,file='fort.12',form='formatted')
      read(12,*) VARIABLE

! get which time step to read (usually nt=1 for daily)
      open(13,file='fort.13',form='formatted')
      read(13,*) nt

      count(1)=nx
      count(2)=ny
      count(3)=1

      start(1)=1
      start(2)=1
      start(3)=nt

! I. READ
! 2. open existing wrfout.nc file
       status = nf_open('fort.21',nf_nowrite,ncid)
       if (status .ne. nf_noerr) call handle_err(status,1)
! 3.  get a varid from avg.nc
      status = nf_inq_varid(ncid,trim(VARIABLE),varid)
       if (status .ne. nf_noerr) call handle_err(status,2)
! 4. read sst: subsampled data of temp
! note convention is [x y t]!! not following netcdf convention!
      status = nf_get_vars_double(ncid,varid,start,count,stride,varin)
      if (status .ne. nf_noerr) call handle_err(status,3)
! 5.  close file
      status = nf_close(ncid)
      if (status .ne. nf_noerr) call handle_err(status,4)

! II. WRITE
! 2. open existing wrfout.nc file
       status = nf_open('fort.51',nf_write,ncid)
       if (status .ne. nf_noerr) call handle_err(status,1)
! 3.  get a varid from avg.nc
      status = nf_inq_varid(ncid,trim(VARIABLE),varid)
       if (status .ne. nf_noerr) call handle_err(status,2)
! 4. read sst: subsampled data of temp
! note convention is [x y t]!! not following netcdf convention!
      status = nf_put_vars_double(ncid,varid,start,count,stride,varin)
      if (status .ne. nf_noerr) call handle_err(status,3)
! 5.  close file
      status = nf_close(ncid)
      if (status .ne. nf_noerr) call handle_err(status,4)

      call exit
      end
      
       subroutine handle_err(status,n)
       integer status,n
       if (status .ne. nf_noerr) then
          print *, n,' ',status
          print *, 'reading variable from wrfout.nc failed!!!'
          print *, 'stop'
           call exit
       endif
       end subroutine handle_err
