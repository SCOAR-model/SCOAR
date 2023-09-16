! Add ROMS surface currents to wrflowinp file.
! Modified from uocea_wrflowinp_nolake_initial.f
! Main modifications:
! - replace both u- and v- currents in the same program
! - double rotation of current vector components

      include 'netcdf.inc'
      parameter(nt=1)
      integer status, ncid, nd
      real*8,dimension(:,:,:,:), allocatable :: uROMS, uROMSu
      real*8,dimension(:,:,:,:), allocatable :: vROMS, vROMSv
      real*8,dimension(:,:,:), allocatable :: uWRF, vWRF
      integer, dimension(:,:,:), allocatable :: land
      real*8,dimension(:,:,:), allocatable :: cosa, sina
      real*8,dimension(:,:), allocatable :: ROMSalpha
      real*8 :: utmp, vtmp
      integer varid, varid2, nt2
      integer start(4), count(4), stride(4), count3(4)
      integer start2(3), count2(3), stride2(3), start3(3)
      integer start2d(2), count2d(2), stride2d(2)
      
!     data start / 1, 1, nd, nt / 
      data stride / 1, 1, 1, 1 /
      data stride2 / 1, 1, 1 /
      data stride2d / 1, 1 /

! fort.11: ROMS grid dimensions
! fort.12: $SST_In = ROMS IC or output file
! fort.13: $nd = number of vertical levels in ROMS
! fort.14: $SST_Out = wrflowinp file
! fort.15: $nt2 = time stamp of wrflowinp where ROMS data will be entered
! fort.16: ROMS land mask
! fort.32: WRF grid file for COSALPHA and SINALPHA

! need to add interpolation part later..
! #######################################################
! 1. read grid info

! ROMS rho-grid dimensions
      open(11,file='fort.11',form='formatted')
      read(11,*) nx,ny

! ROMS xi-grid dimensions
      nxu=nx-1
      nyu=ny

! ROMS eta-grid dimensions
      nxv=nx
      nyv=ny-1

      allocate(uROMS(nx,ny,1,1))
      allocate(uROMSu(nxu,nyu,1,1))
      allocate(vROMS(nx,ny,1,1))
      allocate(vROMSv(nxv,nyv,1,1))
      allocate(uWRF(nx,ny,1))
      allocate(vWRF(nx,ny,1))
      allocate(land(nx,ny,1))
      allocate(cosa(nx,ny,1))
      allocate(sina(nx,ny,1))
      allocate(ROMSalpha(nx,ny))
      count(1)=nxu
      count(2)=nyu
      count(3)=1
      count(4)=1
      count3(1)=nxv
      count3(2)=nyv
      count3(3)=1
      count3(4)=1

      start2d(1)=1
      start2d(2)=1
      count2d(1)=nx
      count2d(2)=ny
       
      !print *, "nx,ny=",nx,ny

! ROMS number of vertical levels
      open(13,file='fort.13',form='formatted')
      read(13,*) nd
      start(1)=1
      start(2)=1
      start(3)=nd
      start(4)=nt

      start3(1)=1
      start3(2)=1
      start3(3)=1
     
      count2(1)=nx
      count2(2)=ny
      count2(3)=1

! time stamp of wflowinp at which ROMS data will be entered
      open(15,file='fort.15',form='formatted')
      read(15,*) nt2

! 2. open existing ini.nc file
      status = nf_open('fort.12',nf_nowrite,ncid)
      if (status .ne. nf_noerr) call handle_err(status,1)

! 3a. get 'u' varid from ini.nc
      status = nf_inq_varid(ncid,'u',varid)
      if (status .ne. nf_noerr) call handle_err(status,2)

! read subsampled data of 'u'
! note convetion is [x y z t]!! not following netcdf convention!
      status = nf_get_vars_double(ncid,varid,start,count,stride,uROMSu)
      if (status .ne. nf_noerr) call handle_err(status,3)

! 3b.  get 'v' varid from ini.nc
      status = nf_inq_varid(ncid,'v',varid)
      if (status .ne. nf_noerr) call handle_err(status,4)

! read subsampled data of 'v'
! note convetion is [x y z t]!! not following netcdf convention!
      status = nf_get_vars_double(ncid,varid,start,count3,stride,vROMSv)
      if (status .ne. nf_noerr) call handle_err(status,5)

! 4. close file
      status = nf_close(ncid)
      if (status .ne. nf_noerr) call handle_err(status,6)

! 5. get ROMS angle from grid file
      status = nf_open('fort.34',nf_nowrite,ncid)
      if (status .ne. nf_noerr) call handle_err(status,7)
      status = nf_inq_varid(ncid,'angle',varid)
      if (status .ne. nf_noerr) call handle_err(status,8)
      status = nf_get_vars_double(ncid,varid,start2d,count2d,
     &                            stride2d,ROMSalpha)
      if (status .ne. nf_noerr) call handle_err(status,9)
      status = nf_close(ncid)
      if (status .ne. nf_noerr) call handle_err(status,10)

! 6. get WRF COSALPHA and SINALPHA
      status = nf_open('fort.32',nf_nowrite,ncid)
      if (status .ne. nf_noerr) call handle_err(status,11)
      status = nf_inq_varid(ncid,'COSALPHA',varid)
      if (status .ne. nf_noerr) call handle_err(status,12)
      status = nf_get_vars_double(ncid,varid,start3,count2,stride2,cosa)
      if (status .ne. nf_noerr) call handle_err(status,13)
      status = nf_inq_varid(ncid,'SINALPHA',varid)
      if (status .ne. nf_noerr) call handle_err(status,14)
      status = nf_get_vars_double(ncid,varid,start3,count2,stride2,sina)
      if (status .ne. nf_noerr) call handle_err(status,15)
      status = nf_close(ncid)
      if (status .ne. nf_noerr) call handle_err(status,16)

! At this point, uROMSu and vROMSv are on their respective Arakawa C-grid position
! in grid-relative coordinates.
! We need to interpolate to rho-grid from u- and v-grid, respectively, and rotated
! the current vectors from grid- to Earth-relative coordinates using the ROMS angle.

! initialize
      do j=1,ny
        do i=1,nx
          uROMS(i,j,1,1)=0
          vROMS(i,j,1,1)=0
        enddo
      enddo

! interpolate from u- to rho-grid
      do j=1,ny
        do i=2,nx
         uROMS(i,j,1,1)=0.5 * (uROMSu(i-1,j,1,1)+uROMSu(i,j,1,1))
        enddo
      enddo

! fill western and eastern boundary
      do j=1,ny
        uROMS(1,j,1,1)=uROMS(2,j,1,1)
        uROMS(nx,j,1,1)=uROMS(nx-1,j,1,1)
      enddo

! interpolate from v- to rho-grid       
      do j=2,ny
        do i=1,nx
          vROMS(i,j,1,1)=0.5 * (vROMSv(i,j-1,1,1)+vROMSv(i,j,1,1))
        enddo
      enddo

! fill northern and southern boundary
      do i=1,nx
        vROMS(i,1,1,1)=vROMS(i,2,1,1)
        vROMS(i,ny,1,1)=vROMS(i,ny-1,1,1)
      enddo

! rotate current vectors
      do j=1,ny
        do i=1,nx
! from grid-relative to Earth-relative coordinates using the ROMS angle
! see: ROMS/ROMS/Utility/uv_rotate.F        
          utmp = uROMS(i,j,1,1)*COS(ROMSalpha(i,j))
     &          -vROMS(i,j,1,1)*SIN(ROMSalpha(i,j))
          vtmp = vROMS(i,j,1,1)*COS(ROMSalpha(i,j))
     &          +uROMS(i,j,1,1)*SIN(ROMSalpha(i,j))
! from Earth-relative to grid-relative coordinates using COSALPHA and
! SINALPHA from WRF
! see: ROMS/ROMS/Nonlinear/set_data.F        
           uWRF(i,j,1) = utmp*cosa(i,j,1) + vtmp*sina(i,j,1)
           vWRF(i,j,1) = vtmp*cosa(i,j,1) - utmp*sina(i,j,1)
        enddo
      enddo

! read mask with nolake; 
! ocean=1 land=0;
      open(21,file='fort.16',form='formatted')
      read(21,*) land 
! ###########
!print *, land
!print *, "land"

! treat land/mask
      do j=1,ny
        do i=1,nx
          if (land(i,j,1) .eq. 0) then
            uWRF(i,j,1) = 0.
            vWRF(i,j,1) = 0.
          endif
!! special case...
          if (land(i,j,1) .eq. 1 .and. uWRF(i,j,1)>500) then
             uWRF(i,j,1) = 0.
             vWRF(i,j,1) = 0.
          endif
        enddo
      enddo

      start2(1)=1
      start2(2)=1
      start2(3)=nt2

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
          print *, 'reading uoce/voce from IC file failed!!!'
          print *, 'stop'
           call exit
       endif
       end subroutine handle_err
