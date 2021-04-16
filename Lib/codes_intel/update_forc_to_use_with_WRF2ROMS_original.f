      include 'netcdf.inc'

      integer status, ncid, varid
!      integer start(3), count(3)
      integer nx, ny, nxny, nt
      real, dimension(:), allocatable :: varin1
      real*8, dimension(:,:,:), allocatable :: varin2
      character*10 VarName

!      data start /1, 1, 1/

       open(11,file='fort.11',form='formatted')
       read(11,*) nx, ny, nxny
       allocate(varin1(nxny))

       open(12,file='fort.12',form='formatted')
       read(12,*) nt 
       allocate(varin2(nx,ny,nt))

!       start(1)=1 
!       start(2)=1
!       start(3)=1
!
!       count(1)=nx
!       count(2)=ny
!       count(3)=nt

       open(13,file='VARNAME',form='formatted')
       read(13,*) VarName

! open wrf forcing file
       open(14,file='VARNAME1',form='formatted')
       read(14,*) varin1

      ij=0
      do 10 j=1, ny
       do 10 i=1, nx
         ij=ij+1
         varin2(i,j,1)=varin1(ij)
10    continue
     
! 1. open existing forc.nc file
       status = nf_open('fort.21',nf_write,ncid)
       if (status .ne. nf_noerr) call handle_err(status,1)

! 2.  get a varid from forc.nc
      status = nf_inq_varid(ncid,trim(VarName),varid)
       if (status .ne. nf_noerr) call handle_err(status,2)

! 3. put an entire variable
!      status = nf_put_vars_double(ncid,varid,start,count,stride,varin2)
      status = nf_put_var_double(ncid,varid,varin2)
      !print *, 'updated :', VarName
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
         print *, 'failed! update forc.nc ',Num
         print *, '*****************************'
         print *, 'stop'
          call exit
      endif
      end subroutine handle_err
