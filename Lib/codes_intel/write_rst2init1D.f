      include 'netcdf.inc'

! read 1D var from rst.nc(nt=1)
! and write it to init.nc at each time step

      integer status, ncid, varid
!      integer start1(1), start2(1), count(1), stride(1)
      integer start1, start2, count, stride
      real*8 varin
      character*20 VARIABLE			!variable name

      data stride /1/

! get variable name
      open(12,file='fort.12',form='formatted')
      read(12,*) VARIABLE

!      start1(1)=1
      start1=1

!      count(1)=1
      count=1

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

!       start2(1)=1
       start2=1

!       count(2)=1
       count=1

! 7 put subsamepled data
      status = nf_put_vars_double(ncid,varid,start2,count,stride,varin)
      if (status .ne. nf_noerr) call handle_err(status,7)

! 8 close 
      status = nf_close(ncid)
      if (status .ne. nf_noerr) call handle_err(status,8)

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

