      include 'netcdf.inc'

      integer status, ncid, varid
      real*8 init_time, num_hour, cf
      character*10 time_name

! 2. open time_variable name
       open(12,file='fort.12',form='formatted')
       read(12,*) time_name

! 3. get the julian date (in seconds)
       open(13,file='fort.13',form='formatted')
       read(13,*) num_hour 

! 3. get the julian date (in seconds)
       open(15,file='fort.15',form='formatted')
       read(15,*) cf

! write the julian date for ocean_time
! num_hour is the total number of hours at current time since TIME_REF

! calculate time
        init_time= (num_hour - cf)*60*60! s
        print *, "init_time= ", init_time

! 1. open existing forc.nc file
       status = nf_open('fort.21',nf_write,ncid)
       if (status .ne. nf_noerr) call handle_err(status,1)
! 2.  get a varid from time variables
      status = nf_inq_varid(ncid,time_name,varid)
       if (status .ne. nf_noerr) call handle_err(status,2)
! 3. write 
      status = nf_put_var_double(ncid,varid,init_time)
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
         print *, 'failed! update time on forc.nc ',Num
         print *, '*****************************'
         print *, 'stop'
          call exit
      endif
      end subroutine handle_err
