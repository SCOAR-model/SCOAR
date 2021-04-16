!2345

!------------------------------------------------------------------------
! performs 1D or 2D interpolation
! Original code is based on NCAR REGRID PACK
! Hyodae Seo
! 1.26.05 
!------------------------------------------------------------------------                

!    parameter(nx1=65,nx2=68,ny1=108,ny2=114)

    parameter(intptpe=1) ! linear interpolation
    parameter(bad=999) ! missing value

!    real, dimension(nx1) :: lon1
!    real, dimension(nx2) :: lat1
!    real, dimension(ny1) :: lon2
!    real, dimension(ny2) :: lat2
!    real, dimension(nx1,nx2) :: data1
!    real, dimension(ny1,ny2) :: data2

    real, dimension(:), allocatable :: lon1
    real, dimension(:), allocatable:: lat1
    real, dimension(:), allocatable :: lon2
    real, dimension(:), allocatable :: lat2
    real, dimension(:,:), allocatable :: data1
    real, dimension(:,:), allocatable :: data2


! read rsm20-SCalif gridnumber info
          open(11,file='fort.11',form='formatted')
          read(11,*) nx1, nx2
          allocate(lon1(nx1),lat1(nx2))
          allocate(data1(nx1,nx2))

! read roms12-SCalif gridnumber info
          open(12,file='fort.12',form='formatted')
          read(12,*) ny1, ny2
          allocate(lon2(ny1),lat2(ny2))
          allocate(data2(ny1,ny2))

!   read rsm20 lon
          open (unit=13, file='fort.13',form='formatted')
          read (13,*) lon1

!   read rsm20 lat
         open (unit=14, file='fort.14',form='formatted')
         read (14,*) lat1

!   read roms12 lon
         open (unit=15, file='fort.15',form='formatted')
         read (15,*) lon2

!   read roms12 lat
         open (unit=16, file='fort.16',form='formatted')
         read (16,*) lat2

!   read rsm20 data : to be interpolated
         open (unit=17,file='fort.17', form='formatted')
         read (17,*) data1

    call int2d(nx1,nx2,lon1,lat1,data1,ny1,ny2,lon2,lat2,data2,&
               intptpe,intptpe,bad)

!   write output data : roms12 (interopolated)
        open (unit=51,file='fort.51', form='formatted')
        write(51,*) data2
    stop
    end

! --
 
    subroutine int2d(n1,n2,x1,x2,f,m1,m2,y1,y2,g,intpol1,intpol2,bad)

!------------------------------------------------------------------------
!
!   Intepolation 2-dimensional data f to another 2-dimensional grid (y)
!   Original data is defined on grid (x) 
!
!------------------------------------------------------------------------

    implicit none

    integer, parameter :: r8 = selected_real_kind(12)

    integer, intent(in) :: n1, n2, m1, m2
    integer, intent(in) :: intpol1, intpol2
    integer, dimension(2) :: intpol
    real, dimension(n1)   , intent(in)    :: x1 
    real, dimension(n2)   , intent(in)    :: x2
    real, dimension(n1,n2), intent(in)    :: f
    real, dimension(m1)   , intent(in)    :: y1
    real, dimension(m2)   , intent(in)    :: y2
    real, dimension(m1,m2), intent(inout) :: g
    real,                   intent(in)    :: bad 

    integer :: i,j,k,l,m,lw,lwx,lwy,liw,ier,length
    integer :: istrt, iend, jstrt, jend
    logical :: incx1, incx2, incy1, incy2
    integer, allocatable, dimension(:) :: iw
    real(r8), dimension(n1) :: x1d
    real(r8), dimension(n2) :: x2d
    real(r8), dimension(n1,n2) :: fd, fd2
    real(r8), allocatable, dimension(:) :: y1d
    real(r8), allocatable, dimension(:) :: y2d
    real(r8), allocatable, dimension(:,:) :: gd, gd2
    real(r8), allocatable, dimension(:) :: w

    call index(n1,x1,m1,y1,incx1,incy1,istrt,iend)
    call index(n2,x2,m2,y2,incx2,incy2,jstrt,jend)

!    print *, incx1, incy1, istrt, iend
!    print *, incx2, incy2, jstrt, jend

    liw = m1+m2+1

    if ( intpol1 == 1 ) then
      lwx = m1
    else if ( intpol1 == 3 ) then
      lwx = 4*m1
    else
      print *,'Invalid interpolation option'
      print *,'intpol = 1: Linear interpolation'
      print *,'intpol = 3: Cubic interpolation'
      stop
    end if

    if ( intpol2 == 1 ) then
      lwy = m2+2*m1
    else if ( intpol2 == 3 ) then
      lwy = 4*(m1+m2)
    else
      print *,'Invalid interpolation option'
      print *,'intpol = 1: Linear interpolation'
      print *,'intpol = 3: Cubic interpolation'
      stop
    end if

    intpol(1) = intpol1
    intpol(2) = intpol2

    lw = lwx+lwy+1

    allocate(iw(1:liw))
    allocate(w(1:lw))
    allocate(y1d(1:iend-istrt+1))
    allocate(y2d(1:jend-jstrt+1))
    allocate(gd(1:iend-istrt+1,1:jend-jstrt+1))

    if ( .not. incx1 ) then
      do j=1,n2
        do i=1,n1
          x1d(i) = dble(x1(n1-i+1))
          fd(i,j) = dble(f(n1-i+1,j))
        end do
      end do
    else
      do j=1,n2
        do i=1,n1
          x1d(i) = dble(x1(i))
          fd(i,j) = dble(f(i,j))
        end do
      end do
    end if

    if ( .not. incx2 ) then
      do i=1,n1
        do j=1,n2
          x2d(j) = dble(x2(n2-j+1))
          fd2(i,j) = fd(i,n2-j+1)
        end do
      end do
    else
      do i=1,n1
        do j=1,n2
          x2d(j) = dble(x2(j))
          fd2(i,j) = fd(i,j)
        end do
      end do
    end if

    if ( .not. incy1 ) then
      l = 1
      do i=iend,istrt,-1
        y1d(l) = dble(y1(i))
        l = l+1
      end do
    else
      l = 1
      do i=istrt,iend
        y1d(l) = dble(y1(i))
        l = l+1
      end do
    end if 

    if ( .not. incy2 ) then
      l = 1
      do j=jend,jstrt,-1
        y2d(l) = dble(y2(j))
        l = l+1
      end do
    else
      l = 1
      do j=jstrt,jend
        y2d(l) = dble(y2(j))
        l = l+1
      end do
    end if

    call rgrd2(n1,n2,x1d,x2d,fd2,iend-istrt+1,jend-jstrt+1,y1d,y2d,gd,intpol,  &
               w, lw, iw, liw, ier)

    do i=1,m1
    do j=1,m2
      g(i,j) = bad
    end do
    end do

    if ( incy1 ) then
     
      if ( incy2 ) then

        do i=istrt,iend
          do j=jstrt,jend
            g(i,j) = real(gd(i-istrt+1,j-jstrt+1))
          end do
        end do

      else

        do i=istrt,iend
          l = 1
          do j=jend,jstrt,-1
            g(i,j) = real(gd(i-istrt+1,l))
            l = l+1
          end do
        end do

      end if

    else

      if ( incy2 ) then

        k = 1
        do i=iend,istrt,-1
          do j=jstrt,jend
            g(i,j) = real(gd(k,j-jstrt+1))
          end do
          k = k+1
        end do

      else

        k = 1
        do i=iend,istrt,-1
          l = 1
          do j=jend,jstrt,-1
            g(i,j) = real(gd(k,l))
            l = l+1
          end do
          k = k+1
        end do

      end if

    end if      

    return
    end subroutine int2d 

    subroutine index(n,x,m,y,incx,incy,istrt,iend)

!-----------------------------------------------------------------------
!
!   Check whether input and output grid are the increasing grid or not.
!
!   INPUT
!
!   n       : The number of grids in input grid (x)
!   x       : Input grid
!   m       : The number of grids in output grid (y)
!   y       : Output grid
!
!   OUTPUT
!
!   incx    : .TRUE.    if the input grid is increasing
!   incx    : .FALSE.   if the input grid is decreasing
!   incy    : .TRUE.    if the input grid is increasing
!   incy    : .FALSE.   if the input grid is decreasing
!   istrt   : the start index of output grid (y) which is included 
!             in the input grid (x)
!   iend    : the end index of output grid (y) which is included 
!             in the input grid (y)
!
!-----------------------------------------------------------------------
 
    implicit none

    integer, intent(in) :: n, m
    real, dimension(n) :: x
    real, dimension(m) :: y
    logical, intent(inout) :: incx, incy
    integer, intent(inout) :: istrt, iend

    integer :: i
 
    incx = .true.
    incy = .true.

    do i=1,n-1
      if ( x(i+1) < x(i) ) then 
        incx = .false.
      else
        incx = .true.
      end if
    end do

    do i=1,m-1
      if ( y(i+1) < y(i) ) then
        incy = .false.
      else
        incy = .true.
      end if
    end do 

    istrt = 0
    iend  = 0

    if ( incx ) then

      if ( incy ) then

        do i=1,m
          if (y(i) >= x(1)) then
            istrt = i
            goto 10
          end if
        end do
10      continue
        do i=m,1,-1
          if (y(i) <= x(n)) then
            iend = i
            goto 11
          end if
        end do
11      continue

      else

        do i=1,m
          if (y(i) <= x(n)) then
            istrt = i
            goto 20
          end if
        end do
20      continue
        do i=m,1,-1
          if (y(i) >= x(1)) then
            iend = i
            goto 21
          end if
        end do
21      continue

      end if

    else
  
      if ( incy ) then

        do i=1,m
          if (y(i) >= x(n)) then
            istrt = i 
            goto 30
          end if
        end do
30      continue
        do i=m,1,-1
          if (y(i) <= x(1)) then
            iend = i
            goto 31
          end if
        end do
31      continue

      else

        do i=1,m
          if (y(i) <= x(1)) then
            istrt = i
            goto 40
          end if
        end do
40      continue
        do i=m,1,-1
          if (y(i) >= x(n)) then
            iend = i
            goto 41
          end if
        end do
41      continue

      end if             

    end if

    return
    end subroutine index

    subroutine rgrd1(nx,x,p,mx,xx,q,intpol,w,lw,iw,liw,ier)

      implicit none
      integer, parameter :: r8 = selected_real_kind(12)

      real(r8) x(*),p(*),xx(*),q(*),w(*)
      integer iw(*)
      integer nx,mx,ier,intpol,lw,liw,i,ii,i1,i2,i3,i4
!
!     check arguments for errors
!
      ier = 1
!
!     check xx grid resolution
!
      if (mx .lt. 1) return
!
!     check intpol
!
      ier = 6
      if (intpol.ne.1 .and. intpol.ne.3) return
!
!     check x grid resolution
!
      ier = 2
      if (intpol.eq.1 .and. nx.lt.2) return
      if (intpol.eq.3 .and. nx.lt.4) return
!
!     check xx grid contained in x grid
!
      ier = 3
      if (xx(1).lt.x(1) .or. xx(mx).gt.x(nx)) return
!
!     check montonicity of grids
!
      do i=2,nx
	if (x(i-1).ge.x(i)) then
	  ier = 4
	  return
	end if
      end do
      do ii=2,mx
	if (xx(ii-1).gt.xx(ii)) then
	  ier = 4
	  return
	end if
      end do
!
!     check minimum work space lengths
!
      if (intpol.eq.1) then
	if (lw .lt. mx) return
      else
	if (lw .lt. 4*mx) return
      end if
      if (liw .lt. mx) return
!
!     arguments o.k.
!
      ier = 0

      if (intpol.eq.1) then
!
!     linear interpolation in x
!
      call linmx(nx,x,mx,xx,iw,w)
      call lint1(nx,p,mx,q,iw,w)
      return
      else
!
!     cubic interpolation in x
!
      i1 = 1
      i2 = i1+mx
      i3 = i2+mx
      i4 = i3+mx
      call cubnmx(nx,x,mx,xx,iw,w(i1),w(i2),w(i3),w(i4))
      call cubt1(nx,p,mx,q,iw,w(i1),w(i2),w(i3),w(i4))
      return
      end if
    end subroutine rgrd1

    subroutine lint1(nx,p,mx,q,ix,dx)
      implicit none
      integer, parameter :: r8 = selected_real_kind(12)
      integer mx,ix(mx),nx,ii,i
      real(r8) p(nx),q(mx),dx(mx)
!
!     linearly interpolate p on x onto q on xx
!
      do ii=1,mx
	i = ix(ii)
	q(ii) = p(i)+dx(ii)*(p(i+1)-p(i))
      end do
      return
    end subroutine lint1

    subroutine cubt1(nx,p,mx,q,ix,dxm,dx,dxp,dxpp)
      implicit none
      integer, parameter :: r8 = selected_real_kind(12)
      integer mx,ix(mx),nx,i,ii
      real(r8) p(nx),q(mx),dxm(mx),dx(mx),dxp(mx),dxpp(mx)
!
!     cubically interpolate p on x to q on xx
!
      do ii=1,mx
	i = ix(ii)
	q(ii) = dxm(ii)*p(i-1)+dx(ii)*p(i)+dxp(ii)*p(i+1)+dxpp(ii)*p(i+2)
      end do
      return
    end subroutine cubt1

    subroutine linmx(nx,x,mx,xx,ix,dx)
!
!     Let x grid pointers for xx grid and interpolation scale terms
!
      implicit none
      integer, parameter :: r8 = selected_real_kind(12)
      real(r8) x(*),xx(*),dx(*)
      integer ix(*),isrt,ii,i,nx,mx
      isrt = 1
      do ii=1,mx
!
!     find x(i) s.t. x(i) < xx(ii) <= x(i+1)
!
	do i=isrt,nx-1
	  if (x(i+1) .ge. xx(ii)) then
	    isrt = i
	    ix(ii) = i
	    go to 3
	  end if
	end do
    3   continue
      end do
!
!     set linear scale term
!
      do ii=1,mx
	i = ix(ii)
	dx(ii) = (xx(ii)-x(i))/(x(i+1)-x(i))
      end do
      return
    end subroutine linmx

    subroutine cubnmx(nx,x,mx,xx,ix,dxm,dx,dxp,dxpp)
      implicit none
      integer, parameter :: r8 = selected_real_kind(12)
      real(r8) x(*),xx(*),dxm(*),dx(*),dxp(*),dxpp(*)
      integer ix(*),mx,nx,i,ii,isrt

      isrt = 1
      do ii=1,mx
!
!     set i in [2,nx-2] closest s.t.
!     x(i-1),x(i),x(i+1),x(i+2) can interpolate xx(ii)
!
	do i=isrt,nx-1
	  if (x(i+1) .ge. xx(ii)) then
	    ix(ii) = min0(nx-2,max0(2,i))
	    isrt = ix(ii)
	    go to 3
	  end if
	end do
    3   continue
      end do
!
!     set cubic scale terms
!
      do ii=1,mx
	i = ix(ii)
	dxm(ii) = (xx(ii)-x(i))*(xx(ii)-x(i+1))*(xx(ii)-x(i+2))/  &
                ((x(i-1)-x(i))*(x(i-1)-x(i+1))*(x(i-1)-x(i+2)))
	dx(ii) = (xx(ii)-x(i-1))*(xx(ii)-x(i+1))*(xx(ii)-x(i+2))/  &
                ((x(i)-x(i-1))*(x(i)-x(i+1))*(x(i)-x(i+2)))
	dxp(ii) = (xx(ii)-x(i-1))*(xx(ii)-x(i))*(xx(ii)-x(i+2))/  &
                ((x(i+1)-x(i-1))*(x(i+1)-x(i))*(x(i+1)-x(i+2)))
	dxpp(ii) = (xx(ii)-x(i-1))*(xx(ii)-x(i))*(xx(ii)-x(i+1))/  &
                ((x(i+2)-x(i-1))*(x(i+2)-x(i))*(x(i+2)-x(i+1)))
      end do
      return
    end subroutine cubnmx

    subroutine rgrd2(nx,ny,x,y,p,mx,my,xx,yy,q,intpol,w,lw,iw,liw,ier)
      implicit none
      integer, parameter :: r8 = selected_real_kind(12)
      integer nx,ny,mx,my,lw,liw,ier
      integer intpol(2),iw(liw)
      real(r8) x(nx),y(ny),p(nx,ny),xx(mx),yy(my),q(mx,my),w(lw)
      integer i,ii,j,jj,j2,j3,j4,j5,j6,j7,j8,j9,i2,i3,i4,i5
      integer jy,lwx,lwy
!
!     check input arguments
!
      ier = 1
!
!     check (xx,yy) grid resolution
!
      if (min0(mx,my) .lt. 1) return
!
!     check intpol
!
      ier = 6
      if (intpol(1).ne.1 .and. intpol(1).ne.3) return
      if (intpol(2).ne.1 .and. intpol(2).ne.3) return
!
!     check (x,y) grid resolution
!
      ier = 2
      if (intpol(1).eq.1 .and. nx.lt.2) return
      if (intpol(1).eq.3 .and. nx.lt.4) return
      if (intpol(2).eq.1 .and. ny.lt.2) return
      if (intpol(2).eq.3 .and. ny.lt.4) return
!
!     check work space lengths
!
      ier = 5
      if (intpol(1).eq.1) then
      lwx = mx
      else
      lwx = 4*mx
      end if
      if (intpol(2).eq.1) then
      lwy = my+2*mx
      else
      lwy = 4*(mx+my)
      end if
      if (lw .lt. lwx+lwy) return
      if (liw .lt. mx+my) return
!
!     check (xx,yy) grid contained in (x,y) grid
!
      ier = 3
      if (xx(1).lt.x(1) .or. xx(mx).gt.x(nx)) return
      if (yy(1).lt.y(1) .or. yy(my).gt.y(ny)) return
!
!     check montonicity of grids
!
      ier = 4
      do i=2,nx
	if (x(i-1).ge.x(i)) return
      end do
      do j=2,ny
	if (y(j-1).ge.y(j)) return
      end do
      do ii=2,mx
	if (xx(ii-1).gt.xx(ii)) return
      end do
      do jj=2,my
	if (yy(jj-1).gt.yy(jj)) return
      end do
!
!     arguments o.k.
!
      ier = 0
!
!     set pointer in integer work space
!
      jy = mx+1
      if (intpol(2) .eq.1) then
!
!     linearly interpolate in y
!
      j2 = 1
      j3 = j2
      j4 = j3+my
      j5 = j4
      j6 = j5
      j7 = j6
      j8 = j7+mx
      j9 = j8+mx
!
!     set y interpolation indices and scales and linearly interpolate
!
      call linmx(ny,y,my,yy,iw(jy),w(j3))
      i2 = j9
!
!     set work space portion and indices which depend on x interpolation
!
      if (intpol(1) .eq. 1) then
      i3 = i2
      i4 = i3
      i5 = i4
      call linmx(nx,x,mx,xx,iw,w(i3))
      else
      i3 = i2+mx
      i4 = i3+mx
      i5 = i4+mx
      call cubnmx(nx,x,mx,xx,iw,w(i2),w(i3),w(i4),w(i5))
      end if
      call lint2(nx,ny,p,mx,my,q,intpol,iw(jy),w(j3),   &
                  w(j7),w(j8),iw,w(i2),w(i3),w(i4),w(i5))
      return

      else
!
!     cubically interpolate in y, set indice pointers
!
      j2 = 1
      j3 = j2+my
      j4 = j3+my
      j5 = j4+my
      j6 = j5+my
      j7 = j6+mx
      j8 = j7+mx
      j9 = j8+mx
      call cubnmx(ny,y,my,yy,iw(jy),w(j2),w(j3),w(j4),w(j5))
      i2 =  j9+mx
!
!     set work space portion and indices which depend on x interpolation
!
      if (intpol(1) .eq. 1) then
      i3 = i2
      i4 = i3
      i5 = i4
      call linmx(nx,x,mx,xx,iw,w(i3))
      else
      i3 = i2+mx
      i4 = i3+mx
      i5 = i4+mx
      call cubnmx(nx,x,mx,xx,iw,w(i2),w(i3),w(i4),w(i5))
      end if
      call cubt2(nx,ny,p,mx,my,q,intpol,iw(jy),w(j2),w(j3),   &
       w(j4),w(j5),w(j6),w(j7),w(j8),w(j9),iw,w(i2),w(i3),w(i4),w(i5))
      return
      end if
    end subroutine rgrd2

    subroutine lint2(nx,ny,p,mx,my,q,intpol,jy,dy,pj,pjp,   &
                       ix,dxm,dx,dxp,dxpp)
      implicit none
      integer, parameter :: r8 = selected_real_kind(12)
      integer nx,ny,mx,my,intpol(2),jy(my),ix(mx)
      integer jsave,j,jj,ii
      real(r8) p(nx,ny),q(mx,my)
      real(r8) pj(mx),pjp(mx),dy(my)
      real(r8) dxm(mx),dx(mx),dxp(mx),dxpp(mx)
!
!     linearly interpolate in y
!
      if (intpol(1).eq.1) then
!
!     linear in x
!
      jsave = -1
      do jj=1,my
	j = jy(jj)
	if (j.eq.jsave) then
!
!       j pointer has not moved since last pass (no updates or interpolation)
!
	else if (j.eq.jsave+1) then
!
!       update j and interpolate j+1
!
	  do ii=1,mx
	    pj(ii) = pjp(ii)
	  end do
	  call lint1(nx,p(1,j+1),mx,pjp,ix,dx)
	else
!
!       interpolate j,j+1in pj,pjp on xx mesh
!
	call lint1(nx,p(1,j),mx,pj,ix,dx)
	call lint1(nx,p(1,j+1),mx,pjp,ix,dx)
	end if
!
!       save j pointer for next pass
!
	jsave = j
!
!       linearly interpolate q(ii,jj) from pjp,pj in y direction
!
	do ii=1,mx
	  q(ii,jj) = pj(ii)+dy(jj)*(pjp(ii)-pj(ii))
	end do
      end do

      else
!
!     cubic in x
!
      jsave = -1
      do jj=1,my
	j = jy(jj)
	if (j.eq.jsave) then
!
!       j pointer has not moved since last pass (no updates or interpolation)
!
	else if (j.eq.jsave+1) then
!
!       update j and interpolate j+1
!
	  do ii=1,mx
	    pj(ii) = pjp(ii)
	  end do
	  call cubt1(nx,p(1,j+1),mx,pjp,ix,dxm,dx,dxp,dxpp)
	else
!
!       interpolate j,j+1 in pj,pjp on xx mesh
!
	  call cubt1(nx,p(1,j),mx,pj,ix,dxm,dx,dxp,dxpp)
	  call cubt1(nx,p(1,j+1),mx,pjp,ix,dxm,dx,dxp,dxpp)
	end if
!
!       save j pointer for next pass
!
	jsave = j
!
!       linearly interpolate q(ii,jj) from pjp,pj in y direction
!
	do ii=1,mx
	  q(ii,jj) = pj(ii)+dy(jj)*(pjp(ii)-pj(ii))
	end do
      end do
      return
      end if
    end subroutine lint2

    subroutine cubt2(nx,ny,p,mx,my,q,intpol,jy,dym,dy,dyp,  &
      dypp,pjm,pj,pjp,pjpp,ix,dxm,dx,dxp,dxpp)
      implicit none
      integer, parameter :: r8 = selected_real_kind(12)
      integer nx,ny,mx,my,intpol(2),jy(my),ix(mx)
      integer jsave,j,jj,ii
      real(r8) p(nx,ny),q(mx,my)
      real(r8) pjm(mx),pj(mx),pjp(mx),pjpp(mx)
      real(r8) dym(my),dy(my),dyp(my),dypp(my)
      real(r8) dxm(mx),dx(mx),dxp(mx),dxpp(mx)
      if (intpol(1).eq.1) then
!
!     linear in x
!
      jsave = -3
      do jj=1,my
!
!       load closest four j lines containing interpolate on xx mesh
!       for j-1,j,j+1,j+2 in pjm,pj,pjp,pjpp
!
	j = jy(jj)
	if (j.eq.jsave) then
!
!       j pointer has not moved since last pass (no updates or interpolation)
!
	else if (j.eq.jsave+1) then
!
!       update j-1,j,j+1 and interpolate j+2
!
	  do ii=1,mx
	    pjm(ii) = pj(ii)
	    pj(ii) = pjp(ii)
	    pjp(ii) = pjpp(ii)
	  end do
	  call lint1(nx,p(1,j+2),mx,pjpp,ix,dx)
	else if (j.eq.jsave+2) then
!
!     update j-1,j and interpolate j+1,j+2
!
	  do ii=1,mx
	    pjm(ii) = pjp(ii)
	    pj(ii) = pjpp(ii)
	  end do
	  call lint1(nx,p(1,j+1),mx,pjp,ix,dx)
	  call lint1(nx,p(1,j+2),mx,pjpp,ix,dx)
	else if (j.eq.jsave+3) then
!
!       update j-1 and interpolate j,j+1,j+2
!
	  do ii=1,mx
	    pjm(ii) = pjpp(ii)
	  end do
	  call lint1(nx,p(1,j),mx,pj,ix,dx)
	  call lint1(nx,p(1,j+1),mx,pjp,ix,dx)
	  call lint1(nx,p(1,j+2),mx,pjpp,ix,dx)
	else
!
!       interpolate all four j-1,j,j+1,j+2
!
	  call lint1(nx,p(1,j-1),mx,pjm,ix,dx)
	  call lint1(nx,p(1,j),mx,pj,ix,dx)
	  call lint1(nx,p(1,j+1),mx,pjp,ix,dx)
	  call lint1(nx,p(1,j+2),mx,pjpp,ix,dx)
	end if
!
!     save j pointer for next pass
!
	jsave = j
!
!     cubically interpolate q(ii,jj) from pjm,pj,pjp,pjpp in y direction
!
	do ii=1,mx
	  q(ii,jj) = dym(jj)*pjm(ii)+dy(jj)*pj(ii)+dyp(jj)*pjp(ii)+   &
                     dypp(jj)*pjpp(ii)
	end do
      end do
      return

      else
!
!     cubic in x
!
	jsave = -3
	do jj=1,my
!
!       load closest four j lines containing interpolate on xx mesh
!       for j-1,j,j+1,j+2 in pjm,pj,pjp,pjpp
!
	  j = jy(jj)
	  if (j.eq.jsave) then
!
!         j pointer has not moved since last pass (no updates or interpolation)
!
	  else if (j.eq.jsave+1) then
!
!         update j-1,j,j+1 and interpolate j+2
!
	    do ii=1,mx
	      pjm(ii) = pj(ii)
	      pj(ii) = pjp(ii)
	      pjp(ii) = pjpp(ii)
	    end do
	    call cubt1(nx,p(1,j+2),mx,pjpp,ix,dxm,dx,dxp,dxpp)
	  else if (j.eq.jsave+2) then
!
!         update j-1,j and interpolate j+1,j+2
!
	    do ii=1,mx
	      pjm(ii) = pjp(ii)
	      pj(ii) = pjpp(ii)
	    end do
	    call cubt1(nx,p(1,j+1),mx,pjp,ix,dxm,dx,dxp,dxpp)
	    call cubt1(nx,p(1,j+2),mx,pjpp,ix,dxm,dx,dxp,dxpp)
	  else if (j.eq.jsave+3) then
!
!         update j-1 and interpolate j,j+1,j+2
!
	    do ii=1,mx
	      pjm(ii) = pjpp(ii)
	    end do
	    call cubt1(nx,p(1,j),mx,pj,ix,dxm,dx,dxp,dxpp)
	    call cubt1(nx,p(1,j+1),mx,pjp,ix,dxm,dx,dxp,dxpp)
	    call cubt1(nx,p(1,j+2),mx,pjpp,ix,dxm,dx,dxp,dxpp)
	  else
!
!         interpolate all four j-1,j,j+1,j+2
!
	    call cubt1(nx,p(1,j-1),mx,pjm,ix,dxm,dx,dxp,dxpp)
	    call cubt1(nx,p(1,j),mx,pj,ix,dxm,dx,dxp,dxpp)
	    call cubt1(nx,p(1,j+1),mx,pjp,ix,dxm,dx,dxp,dxpp)
	    call cubt1(nx,p(1,j+2),mx,pjpp,ix,dxm,dx,dxp,dxpp)
	  end if
!
!       save j pointer for next pass
!
	jsave = j
!
!       cubically interpolate q(ii,jj) from pjm,pj,pjp,pjpp in y direction
!
	do ii=1,mx
	  q(ii,jj) = dym(jj)*pjm(ii)+dy(jj)*pj(ii)+dyp(jj)*pjp(ii)+  &
                     dypp(jj)*pjpp(ii)
	end do
      end do
      return
      end if
    end subroutine cubt2

!    end module interpolation
