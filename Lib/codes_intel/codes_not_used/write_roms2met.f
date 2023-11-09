      include 'netcdf.inc'

! read SST from 4D Temp from avg.nc 
! read SKT in WRF
! combine SST and SKT (SKT over land based on landsea mask)

      integer status, ncid
      integer start1(4), count1(4), stride1(4)
      integer start2(3), count2(3), stride2(3)
      integer start3(3)
      real*8,dimension(:,:,:,:), allocatable :: iSST 
      real*8,dimension(:,:,:), allocatable :: oSST, SKINTEMP, LANDMASK
      integer nx, ny, nxny      !grid dimensions
!     integer nt, nd            !nt=1 time stepping, nd=depth layers
      integer nd            !nt=1 time stepping, nd=depth layers
      integer NREC 
      integer varid, Tid        !variable ID and time ID
      character*8 TIME !name for time

      data stride1 /1,1,1,1/
      data stride2 /1,1,1/
! ##pgi     
!      parameter nt=1
      integer, parameter :: nt=1
! ##pgi     

! get grid size of variable (2D)
      open(11,file='fort.11',form='formatted')
      read(11,*) nx, ny, nxny

      allocate(iSST(nx,ny,1,1))
      allocate(oSST(nx,ny,1))
      allocate(SKINTEMP(nx,ny,1))
      allocate(LANDMASK(nx,ny,1))

! get number of depth layers in ocean (N)
      open(15,file='fort.15',form='formatted')
      read(15,*) nd

      count1(1)=nx
      count1(2)=ny
      count1(3)=1
      count1(4)=1
     
      start1(1)=1
      start1(2)=1
!surface=nd; bottom=1
      start1(3)=nd
      start1(4)=nt

! read SST from temperature from avg_Day.nc or avg_Hour.nc 
! 1.1. open avg_Day.nc
      status = nf_open('fort.21',nf_nowrite,ncid)
      if (status .ne. nf_noerr) call handle_err(status,1)

! 1.2. get Variable ID for temp
      status = nf_inq_varid(ncid,'temp',varid)
      if (status .ne. nf_noerr) call handle_err(status,2)

! 1.3. read iSST
      status = nf_get_vars_double(ncid,varid,
     &         start1,count1,stride1,iSST)
      if (status .ne. nf_noerr) call handle_err(status,3)

! 1.4. close
      status = nf_close(ncid)
      if (status .ne. nf_noerr) call handle_err(status,4)

!Get skin temp from met_em:$YYYY-$MM-$DD:$HH:$MN:$SS.nc
! 2.1 open met_em:$YYYY-$MM-$DD:$HH:$MN:$SS.nc
       status = nf_open('fort.22',nf_nowrite,ncid)
       if (status .ne. nf_noerr) call handle_err(status,5)

! 2.2  get a variid from met_em:$YYYY-$MM-$DD:$HH:$MN:$SS.nc
      status = nf_inq_varid(ncid,'SKINTEMP',varid)
       if (status .ne. nf_noerr) call handle_err(status,6)

      count2(1)=nx
      count2(2)=ny
      count2(3)=1
       
      start2(1)=1
      start2(2)=1
      start2(3)=1 

! 2.3 read SKINTEMP
      status = nf_get_vars_double(ncid,varid,
     &     start2,count2,stride2,SKINTEMP)
      if (status .ne. nf_noerr) call handle_err(status,7)

! 2.5 read landsea mask (Land==1, sea=0)
      status = nf_inq_varid(ncid,'LANDMASK',varid)
       if (status .ne. nf_noerr) call handle_err(status,6)

! 2.6 read LANDMASK
      status = nf_get_vars_double(ncid,varid,
     &     start2,count2,stride2,LANDMASK)
      if (status .ne. nf_noerr) call handle_err(status,7)

! 2.7 close
      status = nf_close(ncid)
      if (status .ne. nf_noerr) call handle_err(status,8)
 
!Over Ocean: Fill oSST with SST
      do 100 j=1,ny
       do 100 i=1,nx
        oSST(i,j,1)=iSST(i,j,1,1) + 273.149
 100    continue
!Over Land: Fill oSST with SKINTEMP
      do 200 j=1,ny
       do 200 i=1,nx
        if (LANDMASK(i,j,1) .eq. 1) oSST(i,j,1) = SKINTEMP(i,j,1) 
 200    continue 

C
C! treatment of lakes and isolated seas which is masked in ROMS grid..
C! read the differences in land-sea mask in ROMS (land==0, ocean==1) and WRF(land==1, ocean=0)
C! and for those lakes, I make the box averages of SKINTEMP to add in the lakes
C! this for now works for only the same grids in ROMS/WRF
C
C! roms mask file
C! get grid size of variable (2D)
C      open(19,file='fort.19',form='formatted')
C      read(19,*) maskr
C! land==1 ocean==0;
C      maskr= -1 * (maskr-1)
C      diff_mask=maskr-LANDMASK
C! lake: maskr==1, LANDMASK=0
C! diff_mask==1
C	
C      do 200 j=1,ny
C       do 200 i=1,nx
C          if (diff_mask(i,j,1) .eq. 1 ) 
C		
C! mean of 8 surrounding grid points execpt for the lake itself and neiboring grid of lake
C! 3 5 8 
C! 2 L 7
C! 1 4 6
C        ii2=0
C         if (oSST(i-1,j-1,1) .ne. 273.149) ii2=ii2+1 endif
C         if (oSST(i-1,j,1) .ne. 273.149) ii2=ii2+1 endif
C         if (oSST(i-1,j+1,1) .ne. 273.149) ii2=ii2+1 endif
C         if (oSST(i,j-1,1) .ne. 273.149) ii2=ii2+1 endif
C         if (oSST(i,j+1,1) .ne. 273.149) ii2=ii2+1 endif
C         if (oSST(i+1,j-1,1) .ne. 273.149) ii2=ii2+1 endif
C         if (oSST(i+1,j,1) .ne. 273.149) ii2=ii2+1 endif
C         if (oSST(i+1,j+1,1) .ne. 273.149) ii2=ii2+1 endif
C
C      oSST(i,j,1)= 1/ii2 * (oSST(i-1,j-1,1) + oSST(






! 9. open met_em:$YYYY-$MM-$DD:$HH:$MN:$SS.nc 
       status = nf_open('fort.22',nf_write,ncid)
       if (status .ne. nf_noerr) call handle_err(status,9)

!10.  get a variid from met_em:$YYYY-$MM-$DD:$HH:$MN:$SS.nc
       status = nf_inq_varid(ncid,'SST',varid)
       if (status .ne. nf_noerr) call handle_err(status,10)

!11. get unlimited time dimension id
      status = nf_inq_unlimdim(ncid,Tid)
       if (status .ne. nf_noerr) call handle_err(status,11)

!12. get unlimited dimension name and current length
      status = nf_inq_dim(ncid,Tid,'Time',NREC)
       if (status .ne. nf_noerr) call handle_err(status,12)
     
      start3(1)=1
      start3(2)=1
      start3(3)=NREC
      print *, "NREC=",NREC

!13 put subsamepled data
      status = nf_put_vars_double(ncid,varid,
     &                start3,count2,stride2,oSST)
      if (status .ne. nf_noerr) call handle_err(status,13)

!14 close 
      status = nf_close(ncid)
      if (status .ne. nf_noerr) call handle_err(status,14)

      call exit
      end

      subroutine handle_err(status,Num)
      integer status, Num
      if (status .ne. nf_noerr) then
         print *, '**************************************'
         print *, 'failed! update roms2met.nc ',Num
         print *, '**************************************'
         print *, 'stop'
          call exit
      endif
      end subroutine

