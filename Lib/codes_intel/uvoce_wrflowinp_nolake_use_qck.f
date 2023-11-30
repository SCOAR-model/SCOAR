! Add ROMS surface currents to wrflowinp file.
! Modified from uocea_wrflowinp_nolake_use_qck.f
! Main modifications:
! - replace both u- and v- currents in the same program
! - double rotation of current vector components
! - filling boundary values

      include 'netcdf.inc'
      parameter(nt=1)
      integer status, ncid, nd
      real*8,dimension(:,:,:), allocatable :: uROMS, vROMS
      real*8,dimension(:,:,:), allocatable :: uWRF, vWRF
      integer, dimension(:,:,:), allocatable :: land
      real*8,dimension(:,:,:), allocatable :: cosa, sina
      real*8 :: utmp, vtmp
      integer varid, varid2, nt2
      integer start(3) ,count(3), stride(3)
      integer start2(3) ,count2(3), stride2(3)
      integer start2d(2), count2d(2), stride2d(2)
      
!     data start / 1, 1, nd, nt / 
      data stride / 1, 1, 1 /
      data stride2 / 1, 1, 1 /
      data stride2d / 1, 1 /

! fort.11: ROMS grid dimensions
! fort.12: $SST_In = ROMS IC or output file
! fort.14: $SST_Out = wrflowinp file
! fort.15: $nt2 = time stamp of wrflowinp where ROMS data will be entered
! fort.16: ROMS land mask
! fort.32: WRF grid file for COSALPHA and SINALPHA

! #######################################################
! 1. read grid info

! ROMS rho-grid dimensions
      open(11,file='fort.11',form='formatted')
      read(11,*) nx,ny

      allocate(uROMS(nx,ny,1))
      allocate(vROMS(nx,ny,1))
      allocate(uWRF(nx,ny,1))
      allocate(vWRF(nx,ny,1))
      allocate(land(nx,ny,1))
      allocate(cosa(nx,ny,1))
      allocate(sina(nx,ny,1))

      count(1)=nx
      count(2)=ny
      count(3)=1

      start(1)=1
      start(2)=1
      start(3)=nt

      start2d(1)=1
      start2d(2)=1
      count2d(1)=nx
      count2d(2)=ny
       
      !print *, "nx,ny=",nx,ny

! time stamp of wflowinp at which ROMS data will be entered
      open(15,file='fort.15',form='formatted')
      read(15,*) nt2

! 2. open existing qck.nc file
       status = nf_open('fort.12',nf_nowrite,ncid)
       if (status .ne. nf_noerr) call handle_err(status,1)

! 3a. get 'u_sur_eastward' varid from ini.nc
      status = nf_inq_varid(ncid,'u_sur_eastward',varid)
      if (status .ne. nf_noerr) call handle_err(status,2)

! read subsampled data of 'u_sur_eastward'
! note convetion is [x y z t]!! not following netcdf convention!
      status = nf_get_vars_double(ncid,varid,start,count,stride,uROMS)
      if (status .ne. nf_noerr) call handle_err(status,3)

! 3a. get 'v_sur_northward' varid from ini.nc
      status = nf_inq_varid(ncid,'v_sur_northward',varid)
      if (status .ne. nf_noerr) call handle_err(status,4)

! read subsampled data of 'v_sur_northward'
! note convetion is [x y z t]!! not following netcdf convention!
      status = nf_get_vars_double(ncid,varid,start,count,stride,vROMS)
      if (status .ne. nf_noerr) call handle_err(status,5)

! 4. close file
      status = nf_close(ncid)
      if (status .ne. nf_noerr) call handle_err(status,6)

! 5. get WRF COSALPHA and SINALPHA
      status = nf_open('fort.32',nf_nowrite,ncid)
      if (status .ne. nf_noerr) call handle_err(status,11)
      status = nf_inq_varid(ncid,'COSALPHA',varid)
      if (status .ne. nf_noerr) call handle_err(status,12)
      status = nf_get_vars_double(ncid,varid,start,count,stride,cosa)
      if (status .ne. nf_noerr) call handle_err(status,13)
      status = nf_inq_varid(ncid,'SINALPHA',varid)
      if (status .ne. nf_noerr) call handle_err(status,14)
      status = nf_get_vars_double(ncid,varid,start,count,stride,sina)
      if (status .ne. nf_noerr) call handle_err(status,15)
      status = nf_close(ncid)
      if (status .ne. nf_noerr) call handle_err(status,16)

! At this point, uROMS and vROMS are on rho-points in Earth-relative coordinates.
! WRF expects vectors in grid-relative coordinates, so we perform a rotation from 
! Earth- to grid-relative using COSALPHA and SINALPHA from WRF.

! rotate current vectors
      do j=1,ny
        do i=1,nx
! from Earth-relative to grid-relative coordinates using COSALPHA and
! SINALPHA from WRF
! see: ROMS/ROMS/Nonlinear/set_data.F        
          uWRF(i,j,1) = uROMS(i,j,1)*cosa(i,j,1) 
     &                 +vROMS(i,j,1)*sina(i,j,1)
          vWRF(i,j,1) = vROMS(i,j,1)*cosa(i,j,1)
     &                 -uROMS(i,j,1)*sina(i,j,1)
        enddo
      enddo

! Note that u_sur_eastward and v_sur_northward in ROMS qck.nc files are zero
! along the outer edges of the domain, so we have to fill the boundaries.

! fill western and eastern boundary
      do j=1,ny
        uWRF(1,j,1)=uWRF(2,j,1)
        uWRF(nx,j,1)=uWRF(nx-1,j,1)
        vWRF(1,j,1)=vWRF(2,j,1)
        vWRF(nx,j,1)=vWRF(nx-1,j,1)
      enddo

! fill northern and southern boundary
      do i=1,nx
        uWRF(i,1,1)=uWRF(i,2,1)
        uWRF(i,ny,1)=uWRF(i,ny-1,1)
        vWRF(i,1,1)=vWRF(i,2,1)
        vWRF(i,ny,1)=vWRF(i,ny-1,1)
      enddo

! read mask with nolake; 
! ocean=1 land=0;
      open(21,file='fort.16',form='formatted')
      read(21,*) land 
! ###########
!print *, land
!print *, "land"

! treat land/mask
! Also check for bad value of U and V 
! i.e., possibly due to filling the boundaries with land value 1.e+37
      do j=1,ny
        do i=1,nx
            if (int(land(i,j,1)) .eq. 0) then
            uWRF(i,j,1) = 0.
            vWRF(i,j,1) = 0.
          endif
        enddo
      enddo

      do j=1,ny
        do i=1,nx
            if (abs(uWRF(i,j,1)) .gt. 1000.) then
            uWRF(i,j,1) = 0.
            endif
            if (abs(vWRF(i,j,1)) .gt. 1000.) then
            vWRF(i,j,1) = 0.
            endif
        enddo
      enddo



      start2(1)=1
      start2(2)=1
      start2(3)=nt2

      count2(1)=nx
      count2(2)=ny
      count2(3)=1

! #######################################################
! write to wrflowinp
! 1. open forc file
      status = nf_open('fort.14',nf_write,ncid2)
      if (status .ne. nf_noerr) call handle_err(status,17)

! 2a. get varid from forc file
      status = nf_inq_varid(ncid2,'UOCE',varid2)
      if (status .ne. nf_noerr) call handle_err(status,18)

! 2b.  write UOCE
      status=nf_put_vars_double(ncid2,varid2,
     &               start2,count2,stride2,uWRF)
      if (status .ne. nf_noerr) call handle_err(status,19)

! 3a. get varid from forc file
      status = nf_inq_varid(ncid2,'VOCE',varid2)
      if (status .ne. nf_noerr) call handle_err(status,20)

! 3b.  write VOCE
      status=nf_put_vars_double(ncid2,varid2,
     &               start2,count2,stride2,vWRF)
      if (status .ne. nf_noerr) call handle_err(status,21)

! 4. close 
      status = nf_close(ncid2)
      if (status .ne. nf_noerr) call handle_err(status,22)
! ###########
     
      call exit
      end
      
       subroutine handle_err(status,n)
       integer status,n
       if (status .ne. nf_noerr) then
          print *, n,' ',status
          print *, 'reading uoce from qck.nc failed!!!'
          print *, 'stop'
          stop 999
       endif
       end subroutine handle_err
