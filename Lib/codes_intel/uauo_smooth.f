      include 'netcdf.inc'

! read u10 and v10 from forcing file at hour h
! read usfc and vsfc from avg/init file at hour h-dh
! compute urel=u10-usfcr;, vrel=v10-vsfcr;

!input: u10, v10, usfc, vsfc
!output: urel, vrel

! note that u10, v10 are rho points
! wheareas usfc, vsfc are u and v points
! so usfcr, vsfcr are created such that
! Lm, L, Lp
! nx-2, nx-1, nx
! usfcr(2:nx-1,:)=0.5*(usfc(1:nx-2,:)+usfc(2:nx-1,:));
! usfcr(1,:)=usfcr(2,:);
! usfcr(nx,:)=usfcr(nx-1,:);

! Mm, M, Mp
! ny-2, ny-1,  ny
! vsfcr=0
! vsfcr(:,2:ny-1)=0.5*(vsfc(:,1:ny-2)+vsfc(:,2:ny-1));
! vsfcr(:,1)=vsfcr(:,2);
! vsfcr(:,ny)=vsfcr(:,ny-1);

      real, dimension(:,:), allocatable :: u10, v10
      real, dimension(:,:,:), allocatable :: U10m, V10m
      real, dimension(:,:), allocatable :: usfc, vsfc
      real, dimension(:,:), allocatable :: usfcr, vsfcr
      real, dimension(:,:,:,:), allocatable :: Us, Vs 
      real, dimension(:,:), allocatable :: urel, vrel
      real, dimension(:,:,:), allocatable :: Ur, Vr
      real  varidu, varidv
      integer nxr, nyr, nxnyr
      integer nxu, nyu, nxnyu
      !integer nxv, nyv, nxnyv, nt, nd
      integer nxv, nyv, nxnyv, nt
      integer start(4), countu(4), countv(4), stride(4)
      real :: wind10mag(3), currentmag(3), percent(3)
      integer ii(3), jj(3), t 
 
      data stride / 1, 1, 1, 1 /
      
      open(11,file='fort.11',form='formatted')
      read(11,*) nxu, nyu, nxnyu
      open(12,file='fort.12',form='formatted')
      read(12,*) nxv, nyv, nxnyv
      open(13,file='fort.13',form='formatted')
      read(13,*) nxr, nyr, nxnyr
      open(14,file='fort.14',form='formatted')
      read(14,*) nt
      !open(15,file='fort.15',form='formatted')
      !read(15,*) nd

      start(1)=1
      start(2)=1
      !start(3)=nd
      start(3)=nt

      countu(1)=nxu
      countu(2)=nyu
      countu(3)=1
!     countu(4)=1
      countv(1)=nxv
      countv(2)=nyv
      countv(3)=1
!     countv(4)=1

      allocate(u10(nxr,nyr),v10(nxr,nyr))
      allocate(U10m(nxr,nyr,1),V10m(nxr,nyr,1))

      allocate(usfc(nxu,nyu),vsfc(nxv,nyv))
      allocate(Us(nxu,nyu,1,1),Vs(nxv,nyv,1,1))

      allocate(usfcr(nxr,nyr),vsfcr(nxr,nyr))
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
      status = nf_inq_varid(ncid,'usfc',varidu)
      if (status .ne. nf_noerr) call handle_err(status,2)
! 4. read u: subsampled data
      status = nf_get_vars_real(ncid,varidu,start,countu,stride,Us)
      if (status .ne. nf_noerr) call handle_err(status,4)
! 6. close file
      status = nf_close(ncid)
      if (status .ne. nf_noerr) call handle_err(status,6)

! read Vsfc from avg.nc (or init.nc)
! 1. open avg/init file
      status = nf_open('fort.23',nf_nowrite,ncid)
      if (status .ne. nf_noerr) call handle_err(status,1)
! 3. get varid from avg/init file
      status = nf_inq_varid(ncid,'vsfc',varidv)
      if (status .ne. nf_noerr) call handle_err(status,3)
! 5. read v: subsampled data
      status = nf_get_vars_real(ncid,varidv,start,countv,stride,Vs)
      if (status .ne. nf_noerr) call handle_err(status,5)
! 6. close file
      status = nf_close(ncid)
      if (status .ne. nf_noerr) call handle_err(status,6)

! Us, Vs are in u/v grids

      do 110 j=1,nyu
       do 110 i=1,nxu
         usfc(i,j)=Us(i,j,1,1)
  110   continue

      do 120 j=1,nyv
       do 120 i=1,nxv
         vsfc(i,j)=Vs(i,j,1,1)
  120   continue

! usfc : convert from u grid to r grid 
! Lm, L, Lp
! nx-2, nx-1, nx
! usfcr(2:nx-1,:)=0.5*(usfc(1:nx-2,:)+usfc(2:nx-1,:));
! usfcr(1,:)=usfcr(2,:);
! usfcr(nx,:)=usfcr(nx-1,:);

! Mm, M, Mp
! ny-2, ny-1,  ny
! vsfcr=0
! vsfcr(:,2:ny-1)=0.5*(vsfc(:,1:ny-2)+vsfc(:,2:ny-1));
! vsfcr(:,1)=vsfcr(:,2);
! vsfcr(:,ny)=vsfcr(:,ny-1);

! initialize usfcr and vsfcr
      do i=1,nxr
       do j=1,nyr
        usfcr(i,j)=0
        vsfcr(i,j)=0
       enddo
      enddo

! usfcr
      do i=2,nxr-1
       do j=1,nyr
        usfcr(i,j)= 0.5 * ( usfc(i-1,j) + usfc(i,j))
       enddo
      enddo
       do j=1,nyr
        usfcr(1,j)= usfcr(2,j)
      enddo
      do j=1,nyr
        usfcr(nxr,j)= usfcr(nxr-1,j)
      enddo

! vsfcr
      do j=2,nyr-1
       do i=1,nxr
        vsfcr(i,j)= 0.5 * ( vsfc(i,j-1) + vsfc(i,j))
       enddo
      enddo
       do i=1,nxr
        vsfcr(i,1)= vsfcr(i,2)
       enddo
       do i=1,nxr
        vsfcr(i,nyr)= vsfcr(i,nyr-1)
       enddo

! u10, v10
      do 170 j=1,nyr
       do 170 i=1,nxr
        u10(i,j)=U10m(i,j,1)
        v10(i,j)=V10m(i,j,1)
  170  continue

! compute urel, vrel
      do i=1,nxr
       do j=1,nyr
       urel(i,j)=u10(i,j)-usfcr(i,j)
       vrel(i,j)=v10(i,j)-vsfcr(i,j)
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

! 6. close 
      status = nf_close(ncid)
      if (status .ne. nf_noerr) call handle_err(status,12)

!! three random pts (usw2 case)
!! offshore
!      ii(1)=10
!      jj(1)=60
!! random
!      ii(2)=30
!      jj(2)=60
!! onshore
!      ii(3)=50
!      jj(3)=60

!      do t=1,3
!      wind10mag(t)=sqrt(u10(ii(t),jj(t))*u10(ii(t),jj(t)) 
!     &                + v10(ii(t),jj(t))*v10(ii(t),jj(t)))
!      currentmag(t)=sqrt(usfc(ii(t),jj(t))*usfc(ii(t),jj(t)) 
!     &                + vsfc(ii(t),jj(t))*vsfc(ii(t),jj(t)))
!      percent(t)=( currentmag(t)/wind10mag(t) )* 100
!      enddo
!      print *, '** aftermath of UaUo**'
!      print *, 'ratio of (current speed) / (wind 10m)'
!      print *, 'at (x,y)=(',ii(1),',',jj(1),') '
!      print *, percent(1),'%',':',currentmag(1),wind10mag(1)
!      print *, 'at (x,y)=(',ii(2),',',jj(2),') '
!      print *, percent(2),'%',':',currentmag(2),wind10mag(2)
!      print *, 'at (x,y)=(',ii(3),',',jj(3),') '
!      print *, percent(3),'%',':',currentmag(3),wind10mag(3)
      
!     print *, 'u10m -> urel' 
!     print *, u10(ii(1),jj(1)),'->',Ur(ii(1),jj(1),1)
!     print *, u10(ii(2),jj(2)),'->',Ur(ii(2),jj(2),1)
!     print *, u10(ii(3),jj(3)),'->',Ur(ii(3),jj(3),1)

!     print *, 'v10m -> vrel'
!     print *, v10(ii(1),jj(1)),'->',Vr(ii(1),jj(1),1)
!     print *, v10(ii(2),jj(2)),'->',Vr(ii(2),jj(2),1)
!     print *, v10(ii(3),jj(3)),'->',Vr(ii(3),jj(3),1)

! random pts (usw2 case)
      ii=100
      jj=100

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
