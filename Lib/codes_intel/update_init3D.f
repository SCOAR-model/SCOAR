      include 'netcdf.inc'

! update initial file for 3D variables
! ubar, vbar, zeta

      integer status, ncidi, ncido
      integer varidi, varido, nt
      integer nx, ny, nxny
      real, dimension(:,:,:), allocatable :: Var
!      real*8, dimension(:,:,:), allocatable :: Var
      character*6 VarName
      integer start(3), count(3), stride(3)
      data stride /1, 1, 1/

!     read grid info
      open(11,file='fort.11',form='formatted')
      read(11,*) nx, ny, nxny
      allocate(Var(nx,ny,1))

      count(1)=nx
      count(2)=ny
      count(3)=1
      
      open(12,file='fort.12',form='formatted')
      read(12,*) VarName

      open(13,file='fort.13',form='formatted')
      read(13,*) nt

      start(1)=1
      start(2)=1
      start(3)=nt
      
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
          print *, 'failed! update init ', Num
          print *, '*****************************'
           call exit
       endif
       end subroutine handle_err

