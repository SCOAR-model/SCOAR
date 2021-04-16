      include 'netcdf.inc'

      integer status, ncid, varid
      real bry_time, nhour2, nhour, nday 
      character*10 time_name

! 2. open time_variable name
       open(12,file='fort.12',form='formatted')
       read(12,*) time_name

! 3. get the julian date
       open(13,file='fort.13',form='formatted')
       read(13,*) nday

! 4. get the current nhour
       open(14,file='fort.14',form='formatted')
       read(14,*) nhour

! nday is the number of days since the TIME_REF.
! 3. insert nday
        nhour2 = mod(nhour,24.0)/24.0
! ocean time
        if (nhour2 .eq. 0)  then
! hour=24 == next day
        nday=nday+1
        endif
        bry_time = (nday -1  + nhour2)
        print *, "bry_time= ", bry_time

! 1. open existing bry.nc file
       status = nf_open('fort.21',nf_write,ncid)
       if (status .ne. nf_noerr) call handle_err(status,1)
! 2.  get a varid from time variables
      status = nf_inq_varid(ncid,time_name,varid)
       if (status .ne. nf_noerr) call handle_err(status,2)
! 3. write
      status = nf_put_var_real(ncid,varid,bry_time)
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
