      include 'netcdf.inc'

! read 4D var from rst.nc(nt=1)
! and write it to rst.nc at each time step

      integer status, ncid
      integer start1(4), start2(4), count(4), stride(4)
      real*8,dimension(:,:,:,:), allocatable :: varin
      integer nx, ny, nxny   	!grid dimensions
      integer nt, na	   	!nt=1 time stepping, na=vertical layers
      integer Nrecs1, Nrecs2	!Nrecs1 = NDay for rst.nc, Nrecs2= t for init.nc file
      integer varid, Tid    	!variable ID and time ID
      character*8 Tname      	!name for time
      character*12 VARIABLE   	!variable name
      character*12 VAROUT   	!variable name

      data stride /1,1,1,1/

! get grid size of variable (2D)
      open(11,file='fort.11',form='formatted')
      read(11,*) nx, ny, nxny

! get number of vertical levels
      open(12,file='fort.12',form='formatted')
      read(12,*) na
      allocate(varin(nx,ny,na,1))

! get Nrecs1 (time index for original .nc file)
      open(13,file='fort.13',form='formatted')
      read(13,*) Nrecs1

! get which time step to read (usually nt=1 for daily)
      open(14,file='fort.14',form='formatted')
      read(14,*) nt

! get variable name for rst.nc
      open(15,file='fort.15',form='formatted')
      read(15,*) VARIABLE

! get variable name for init.nc
      open(16,file='fort.16',form='formatted')
      read(16,*) VAROUT

! get time variable name (Tname)
      open(17,file='fort.17',form='formatted')
      read(17,*) Tname

      count(1)=nx
      count(2)=ny
      count(3)=na
      count(4)=1

      start1(1)=1
      start1(2)=1
      start1(3)=1
      start1(4)=nt

! read varin from rstfile.nc 
! 1. open rstfile.nc 
      status = nf_open('fort.21',nf_nowrite,ncid)
      if (status .ne. nf_noerr) call handle_err(status,1)

! 2. get varin varible id
      status = nf_inq_varid(ncid,trim(VARIABLE),varid)
      if (status .ne. nf_noerr) call handle_err(status,2)

! 3. read varin
      status = nf_get_vars_real(ncid,varid,start1,count,stride,varin)
      if (status .ne. nf_noerr) call handle_err(status,3)

! 4. close
      status = nf_close(ncid)
      if (status .ne. nf_noerr) call handle_err(status,4)

! 5. open init.nc
       status = nf_open('fort.22',nf_write,ncid)
       if (status .ne. nf_noerr) call handle_err(status,5)

! 6.  get a variid from init.nc
      status = nf_inq_varid(ncid,trim(VAROUT),varid)
       if (status .ne. nf_noerr) call handle_err(status,6)

! 7. get unlimited time dimension id
      status = nf_inq_unlimdim(ncid,Tid)
       if (status .ne. nf_noerr) call handle_err(status,7)

! 8. get unlimited dimension name and current length
      status = nf_inq_dim(ncid,Tid,trim(Tname),Nrecs2)
       if (status .ne. nf_noerr) call handle_err(status,8)

       start2(1)=1
       start2(2)=1
       start2(3)=1
       print *, 'Nrecs1 = ', Nrecs1
       print *, 'Nrecs2 = ', Nrecs2
!       if (Nrecs1 .gt. Nrecs2 ) then
!           Nrecs1=Nrecs2
!       endif
       start2(4)=Nrecs2
       print *, 'Nrecs = ',start2(4)

       count(1)=nx
       count(2)=ny
       count(3)=na
       count(4)=1

! 9 put subsamepled data
      status = nf_put_vars_real(ncid,varid,start2,count,stride,varin)
      if (status .ne. nf_noerr) call handle_err(status,9)

! 10 close 
      status = nf_close(ncid)
      if (status .ne. nf_noerr) call handle_err(status,10)

      call exit
      end

      subroutine handle_err(status,Num)
      integer status, Num
      if (status .ne. nf_noerr) then
         print *, '**************************************'
         print *, 'failed! update rst2init4D.nc ',Num
         print *, '**************************************'
         print *, 'stop'
         call exit 
      endif
      end subroutine

