      include 'netcdf.inc'

      integer status, ncid, varid
      real forc_time, num_hour
      character*10 time_name

! 2. open time_variable name
       open(12,file='fort.12',form='formatted')
       read(12,*) time_name

! 3. get the julian date
       open(13,file='fort.13',form='formatted')
       read(13,*) num_hour

! write the julian date for the time variables in forcing files
! sms_time, shf_time, swf_time, sst_time, sss_time, srf_time
! wind_time, pair_time, qair_time, tair_time, cloud_time,
! rain_time, lrf_time

! num_hour is the total number of hours at current time since TIME_REF

        forc_time = (num_hour - cf ) / 24
	print *, "forc_time= ", forc_time

! 1. open existing forc.nc file
       status = nf_open('fort.21',nf_write,ncid)
       if (status .ne. nf_noerr) call handle_err(status,1)
! 2.  get a varid from time variables
      status = nf_inq_varid(ncid,time_name,varid)
       if (status .ne. nf_noerr) call handle_err(status,2)
! 3. write
      status = nf_put_var_real(ncid,varid,forc_time)
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
