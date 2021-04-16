      include 'netcdf.inc'

! read 2D var from rst.nc(nt=1)
! and write it to init.nc at each time step

      integer status, ncid, varid
      integer start1(2), start2(2), count(2), stride(2)
      real*8,dimension(:,:), allocatable :: varin
      integer ndim	                        !dimensions
!      integer nt                               	!nt=1 time stepping
!      integer Nrecs1, Nrecs2                  	!Nrecs1 = NDay for rst.nc, Nrecs2= t for init.nc
!      integer varid, Tid			!variable ID and time ID
!      character*8 Tname				!name for time
      character*12 VARIABLE			!variable name

      data stride /1,1/

! get dimensions
      open(11,file='fort.11',form='formatted')
      read(11,*) ndim
      allocate(varin(ndim,1))

! get variable name
      open(12,file='fort.12',form='formatted')
      read(12,*) VARIABLE

!! get Nrecs1 (time index for original .nc file)
!      open(13,file='fort.13',form='formatted')
!      read(13,*) Nrecs1
     
!! get which time step to read (usually nt=1 for daily)
!      open(14,file='fort.14',form='formatted')
!      read(14,*) nt

!! get time variable name (Tname)
!      open(15,file='fort.15',form='formatted')
!      read(15,*) Tname

      start1(1)=1
      start1(2)=1

      count(1)=ndim
      count(2)=1

! read varin from rst.nc 
! 1. open rst.nc 
      status = nf_open('fort.21',nf_nowrite,ncid)
      if (status .ne. nf_noerr) call handle_err(status,1)

! 2. get varin. varible id
      status = nf_inq_varid(ncid,trim(VARIABLE),varid)
      if (status .ne. nf_noerr) call handle_err(status,2)

! 3. read varin
      status = nf_get_vars_double(ncid,varid,start1,count,stride,varin)
      if (status .ne. nf_noerr) call handle_err(status,3)

! 4. close
      status = nf_close(ncid)
      if (status .ne. nf_noerr) call handle_err(status,4)

! 5. open init.nc 
       status = nf_open('fort.22',nf_write,ncid)
       if (status .ne. nf_noerr) call handle_err(status,5)

! 6.  get a varid from init.nc 
      status = nf_inq_varid(ncid,trim(VARIABLE),varid)
       if (status .ne. nf_noerr) call handle_err(status,6)

!! 7. get unlimited time dimension id
!      status = nf_inq_unlimdim(ncid,Tid)
!       if (status .ne. nf_noerr) call handle_err(status,7)

!! 8. get unlimited dimension name and current length
!      status = nf_inq_dim(ncid,Tid,Tname,Nrecs2)
!       if (status .ne. nf_noerr) call handle_err(status,8)

       start2(1)=1
       start2(2)=1

       count(1)=ndim
       count(2)=1

! 9 put subsamepled data
      status = nf_put_vars_double(ncid,varid,start2,count,stride,varin)
      if (status .ne. nf_noerr) call handle_err(status,9)

! 10 close 
      status = nf_close(ncid)
      if (status .ne. nf_noerr) call handle_err(status,10)

      call exit
      end

      subroutine handle_err(status,Num)
      integer status, Num
      if (status .ne. nf_noerr) then
         print *, '*****************************'
         print *, 'failed! update rst2init3D.nc ',Num
         print *, '*****************************'
         print *, 'stop'
          call exit
      endif
      end subroutine

