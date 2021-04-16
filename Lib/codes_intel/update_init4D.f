      include 'netcdf.inc'

! update initial file for 4D variables
! u, v, temp, salt

      integer status, ncidi, ncido
      integer varidi, varido 
      integer nx, ny, nt, nd, nxny

      real, dimension(:,:,:,:), allocatable :: Var
!      real*8, dimension(:,:,:,:), allocatable :: Var
! initial file is float (not double!!)
      character*6 VarName
      integer start(4), count(4), stride(4)
      data stride / 1, 1, 1, 1/
      
!     read grid info
      open(11,file='fort.11',form='formatted')
      read(11,*) nx, ny, nxny
  
      open(12,file='fort.12',form='formatted')
      read(12,*) VarName

      open(13,file='fort.13',form='formatted')
      read(13,*) nt

      open(16,file='fort.16',form='formatted')
      read(16,*) nd

      allocate(Var(nx,ny,nd,1))
      count(1)=nx
      count(2)=ny
      count(3)=nd
      count(4)=1

      start(1)=1
      start(2)=1
      start(3)=1
      start(4)=nt

! variables(4D): temp, salt, u, v

! open netcdf to read from
      status = nf_open('fort.14',nf_nowrite,ncidi) 
      if (status .ne. nf_noerr) call handle_err(status,1)

! get varid from avg.nc file
      status = nf_inq_varid(ncidi,trim(VarName),varidi) 
      if (status .ne. nf_noerr) call handle_err(status,2)

! read values for varid
      status = nf_get_vars_real(ncidi,varidi,start,count,stride,Var)
      if (status .ne. nf_noerr) call handle_err(status,3)
! close
      status = nf_close(ncidi)
      if (status .ne. nf_noerr) call handle_err(status,4)

! open init file
      status = nf_open('fort.15',nf_write,ncido)
      if (status .ne. nf_noerr) call handle_err(status,5)
! get varid from init file
       status = nf_inq_varid(ncido,trim(VarName),varido)
      if (status .ne. nf_noerr) call handle_err(status,6)
! input value of varid to init file
       status = nf_put_vars_real(ncido,varido,start,count,stride,Var)
      if (status .ne. nf_noerr) call handle_err(status,7)
! close
      status = nf_close(ncido)
      if (status .ne. nf_noerr) call handle_err(status,8)

      call exit
      end

       subroutine handle_err(status,Num)
       integer status, Num
       if (status .ne. nf_noerr) then
          print *, '*****************************'
          print *, 'failed! update init: ',Num
          print *, '*****************************'
           call exit
       endif
       end subroutine handle_err

