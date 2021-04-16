      include 'netcdf.inc'

! read u10 and v10 from forcing file at hour h
! read usfc and vsfc from avg/init file at hour h-dh
! compute urel=u10-usfc;, vrel=v10-vsfc;

!input: u10, v10, usfc, vsfc
!output: urel, vrel

      real, dimension(:,:), allocatable :: u10, v10
      real, dimension(:,:,:), allocatable :: U10m, V10m
      real, dimension(:,:), allocatable :: usfc, vsfc
      real, dimension(:,:,:,:), allocatable :: Us, Vs 
      real, dimension(:,:), allocatable :: urel, vrel
      real, dimension(:,:,:), allocatable :: Ur, Vr
      real  varidu, varidv
      integer nxr, nyr, nxnyr
!      integer nxu, nyu, nxnyu
!      integer nxv, nyv, nxnyv, nt, nd
       integer nt
!       integer  nd
      integer start(3), count(3), stride(3)
      real :: wind10mag(3), currentmag(3), percent(3)
      integer ii, jj, t 
 
      data stride / 1, 1, 1 /
      
!      open(11,file='fort.11',form='formatted')
!      read(11,*) nxu, nyu, nxnyu
!      open(12,file='fort.12',form='formatted')
!      read(12,*) nxv, nyv, nxnyv
      open(13,file='fort.13',form='formatted')
      read(13,*) nxr, nyr, nxnyr
      open(14,file='fort.14',form='formatted')
      read(14,*) nt
!     open(15,file='fort.15',form='formatted')
!     read(15,*) nd

      start(1)=1
      start(2)=1
      start(3)=nt

      count(1)=nx
      count(2)=ny
      count(3)=1

      allocate(u10(nxr,nyr),v10(nxr,nyr))
      allocate(U10m(nxr,nyr,1),V10m(nxr,nyr,1))

      allocate(usfc(nxr,nyr),vsfc(nxr,nyr))
      allocate(Us(nxr,nyr,1,1),Vs(nxr,nyr,1,1))

      allocate(urel(nxr,nyr),vrel(nxr,nyr))
      allocate(Ur(nxr,nyr,1), Vr(nxr,nyr,1))

! read u10 and v10 from forc.nc
! 1. open forcing file
      status = nf_open('fort.21',nf_nowrite,ncid)
      if (status .ne. nf_noerr) call handle_err(status,21)
! 2. get varid from forcing file
      status = nf_inq_varid(ncid,'Uwind',varidu)
      if (status .ne. nf_noerr) call handle_err(status,22)
! 3. get varid from forcing file
      status = nf_inq_varid(ncid,'Vwind',varidv)
      if (status .ne. nf_noerr) call handle_err(status,23)
! 4. rad u: subsampled data
      status = nf_get_var_real(ncid,varidu,U10m)
      if (status .ne. nf_noerr) call handle_err(status,24)
! 5. rad v: subsampled data
      status = nf_get_var_real(ncid,varidv,V10m)
      if (status .ne. nf_noerr) call handle_err(status,25)
! 6. close file
      status = nf_close(ncid)
      if (status .ne. nf_noerr) call handle_err(status,26)

! read Usfc from avg.nc (or init.nc)
! 1. open avg/init file
      status = nf_open('fort.22',nf_nowrite,ncid)
      if (status .ne. nf_noerr) call handle_err(status,1)
! 2. get varid from avg/init file
      status = nf_inq_varid(ncid,'u_sur_eastward',varidu)
      if (status .ne. nf_noerr) call handle_err(status,2)
! 3. get varid from avg/init file
      status = nf_inq_varid(ncid,'v_sur_northward',varidv)
      if (status .ne. nf_noerr) call handle_err(status,3)
! 4. rad u: subsampled data
!     status = nf_get_vars_real(ncid,varidu,start,count,stride,Us)
      status = nf_get_var_real(ncid,varidu,Us)
      if (status .ne. nf_noerr) call handle_err(status,4)
! 5. rad v: subsampled data
!     status = nf_get_vars_real(ncid,varidv,start,count,stride,Vs)
      status = nf_get_var_real(ncid,varidv,Vs)
      if (status .ne. nf_noerr) call handle_err(status,5)
! 6. close file
      status = nf_close(ncid)
      if (status .ne. nf_noerr) call handle_err(status,6)

! Us, Vs are in u/v grids if avg file
! Us, Vs are in rho  grids if qck file
      do 110 j=1,nyr
       do 110 i=1,nxr
         usfc(i,j)=Us(i,j,1,1)
  110   continue

      do 120 j=1,nyr
       do 120 i=1,nxr
         vsfc(i,j)=Vs(i,j,1,1)
  120   continue

! u10, v10
      do 170 j=1,nyr
       do 170 i=1,nxr
        u10(i,j)=U10m(i,j,1)
        v10(i,j)=V10m(i,j,1)
  170  continue

! compute urel, vrel
      do i=1,nxr
       do j=1,nyr
       urel(i,j)=u10(i,j)-usfc(i,j)
       vrel(i,j)=v10(i,j)-vsfc(i,j)
       enddo
      enddo

! convert from 2D to 3D matrix      
       do 130 j=1,nyr
        do 130 i=1,nxr 
          Ur(i,j,1)=urel(i,j)
          Vr(i,j,1)=vrel(i,j)
  130    continue

! write output
! 1. open forc file
      status = nf_open('fort.21',nf_write,ncid)
      if (status .ne. nf_noerr) call handle_err(status,7)

! 2. get varid from forc file
      status = nf_inq_varid(ncid,'Uwind',varidu)
      if (status .ne. nf_noerr) call handle_err(status,8)

! 3. get varid from forc file
      status = nf_inq_varid(ncid,'Vwind',varidv)
      if (status .ne. nf_noerr) call handle_err(status,9)

! 4. write Ur
       status = nf_put_var_real(ncid,varidu,Ur)
      if (status .ne. nf_noerr) call handle_err(status,10)

! 5. write Vr
      status = nf_put_var_real(ncid,varidv,Vr)
      if (status .ne. nf_noerr) call handle_err(status,11)

! 2019 06 04 keep absolute winds as a reference
! ##### write Uwind_abs and Vwind_abs
! 2. get varid from forc file
      status = nf_inq_varid(ncid,'Uwind_abs',varidu)
      if (status .ne. nf_noerr) call handle_err(status,8)

! 3. get varid from forc file
      status = nf_inq_varid(ncid,'Vwind_abs',varidv)
      if (status .ne. nf_noerr) call handle_err(status,9)

! 4. write U10m
       status = nf_put_var_real(ncid,varidu,U10m)
      if (status .ne. nf_noerr) call handle_err(status,10)

! 5. write V10m
      status = nf_put_var_real(ncid,varidv,V10m)
      if (status .ne. nf_noerr) call handle_err(status,11)
!############

! 6. close 
      status = nf_close(ncid)
      if (status .ne. nf_noerr) call handle_err(status,12)

! random pts 
      ii=100
      jj=100
      print *, '** result UaUo**'
      print *, 'u10m -> urel' 
      print *, u10(ii,jj),'->',Ur(ii,jj,1)
      print *, 'v10m -> vrel'
      print *, v10(ii,jj),'->',Vr(ii,jj,1)

       call exit
       end

       subroutine handle_err(status,n)
       integer status,n
       if (status .ne. nf_noerr) then
          print *, n,' ',status
          print *, 'reading uv @ sfc from forc.nc failed!!!'
          print *, 'stop'
          call exit
       endif
       end subroutine handle_err
