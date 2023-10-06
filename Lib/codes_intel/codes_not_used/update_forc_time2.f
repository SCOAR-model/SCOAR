      include 'netcdf.inc'

      integer status, ncid, varid
      integer nt
      real forc_time, nhour2, nhour, jd
      character*10 var_time

! 1. time index in ocean_frc.nc
       open(11,file='fort.11',form='formatted')
       read(11,*) nt

! 2. open time_variable name
       open(12,file='fort.12',form='formatted')
       read(12,*) var_time

! 3. get the julian date
       open(13,file='fort.13',form='formatted')
       read(13,*) jd

! 4. get the current nhour
       open(14,file='VARTIME',form='formatted')
       read(14,*) nhour

! write the julian date for the time variables in forcing files
! sms_time, shf_time, swf_time, sst_time, sss_time, srf_time
! wind_time, pair_time, qair_time, tair_time, cloud_time,
! rain_time, lrf_time

! 1. open existing forc.nc file
       status = nf_open('fort.21',nf_write,ncid)
       if (status .ne. nf_noerr) call handle_err(status,1)

! 2.  get a varid from time variables
      status = nf_inq_varid(ncid,var_time,varid)
       if (status .ne. nf_noerr) call handle_err(status,2)

! 3. insert jd
        nhour2 = mod(nhour,24.0)/24.0
! ocean time
        forc_time = (jd + nhour2)
	print *, "forc_time= ", forc_time
      !status = nf_put_var_int(ncid,varid,jd)
      status = nf_put_var_real(ncid,varid,forc_time)
!      print *, 'updated :', VarName
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
