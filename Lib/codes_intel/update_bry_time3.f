      include 'netcdf.inc'

      integer status, ncid, varid
      real*8 bry_time, num_hour, cf
      character*10 time_name

! 1. open time_variable name
       open(12,file='fort.12',form='formatted')
       read(12,*) time_name

! 2. get the julian date (hours since TIME_REF)
       open(13,file='fort.13',form='formatted')
       read(13,*) num_hour

! 3. get coupling frequency (hours)
       open(15,file='fort.15',form='formatted')
       read(15,*) cf

! num_hour is the total number of hours at current time since TIME_REF
        bry_time = (num_hour - cf ) / 24
        print *, "bry_time= ", bry_time

! 1. open existing bry.nc file
       status = nf_open('fort.21',nf_write,ncid)
       if (status .ne. nf_noerr) call handle_err(status,1)
! 2.  get a varid from time variables
      status = nf_inq_varid(ncid,time_name,varid)
       if (status .ne. nf_noerr) call handle_err(status,2)
! 3. write
      status = nf_put_var_double(ncid,varid,bry_time)
      if (status .ne. nf_noerr) call handle_err(status,3)
! 4 close file
      status = nf_close(ncid)
      if (status .ne. nf_noerr) call handle_err(status,4)
     
      call exit
      end
      
      subroutine handle_err(status,Num)
      integer status, Num
      if (status .ne. nf_noerr) then
         print *, '*****************************'
         print *, 'failed! update time on bry.nc ',Num
         print *, '*****************************'
         print *, 'stop'
          call exit
      endif
      end subroutine handle_err
