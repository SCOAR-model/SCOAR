C A set of subroutines for 2-d local weighted quadratic smoothing

      subroutine loess2(z,xin,yin,nx,ny,span_x,span_y,zout)
C-------------------------------------------------------------------
C
C Usage: CALL LOESS2(Z,XIN,YIN,NX,NY,SPAN_X,SPAN_Y,ZOUT)
C
C Z is the input data array to be smoothed with NX rows and NY columns
C XIN is the input x-grid vector with NX elements (can be non-uniform)
C YIN is the input y-grid vector with NY elements (can be non-uniform)
C NX is an input integer with the number of x grid points
C NY is an input integer with the number of y grid points
C SPAN_X is the smoothing half-span in the x-direction
C SPAN_Y is the smoothing half-span in the y-direction
C ZOUT is the output double-precision data array the same size as Z
C
C     Subroutine to use a FORTRAN-based loess 2d-smoother.
C     This function takes a 2-dimensional gridded field and smooths
C     it. The amount of smoothing is specified by the distances 
C     SPAN_X and SPAN_Y. This function does not require a uniform 
C     spatial grid but can handle a grid with varying grid spacings.
C
C     2001: Written into a MEX-function by Larry O'Neill
C     2005: Extensively rewritten to handle non-uniform grids by
C           Larry O'Neill
C            
C     Fortran loess subroutine based on one written by Michael Schlax for 
C     data on a regularly-spaced grid. 
C
C-------------------------------------------------------------------
C-------------------------------------------------------------------

C
C     Input/output variables
C

      integer, intent(in) :: nx, ny
      real*8, intent(in) :: xin(nx), yin(ny)      
      real*8, dimension(nx,ny), intent(in) :: z
      real*8, intent(in) :: span_x, span_y
      real*8, dimension(nx,ny), intent(out) :: zout

C
C     Local variables
C

      integer i, j, ii, jj, ilo, ihi, jlo, jhi
C     integer, parameter :: maxreg=20000
      integer, parameter :: maxreg=40000
      real*8, parameter :: amiss=1.D35
      real*8, dimension(maxreg,2) :: des
      real*8, dimension(maxreg) :: zsel, w
      real*8, dimension(nx,ny) :: zhat
      real*8 :: dist, tem 
      real*8 :: dx(nx)
      real*8 :: dy(ny)

C--------------------------------------------------------------------

      zhat = amiss

      do j=1,ny
!     do j=18,23

	 dy = yin - yin(j)
!         print *,'dy = ', dy
!         print *,'spanyneg=', -span_y
         jlo = max(1,minval(maxloc(dy,MASK=dy<-span_y)))
!         print *,'jlo = ', jlo
         jhi = maxval(minloc(dy,MASK=dy>span_y))
!         print *,'jhi = ', jhi
!        if(jhi==0) jhi=ny
! edit by hyodae: 2020, apr 23
	 if(jhi==1) jhi=ny
         
         do i=1,nx
!          do i=80,85
!               print *, 'z(',i,',',j,') = ',z(i,j)

            if (z(i,j) .ne. amiss) then
	       dx = xin - xin(i)
!               print *,'dx = ', dx
               ilo = max(1,minval(maxloc(dx,MASK=dx<-span_x)))
!               print *,'ilo = ', ilo
	       ihi = maxval(minloc(dx,MASK=dx>span_x))
!               print *,'ihi = ', ihi
!              if(ihi==0) ihi=nx
! edit by hyodae: 2020, apr 23
	       if(ihi==1) ihi=nx
!               print *,'ihi = ', ihi

	       nreg = 0
	       
               do 50 jj=jlo,jhi
                  do 40 ii=ilo,ihi                    
C               do 50 jj=jlo,2
C                  do 40 ii=ilo,2                    
		     if(z(ii,jj) .ne. amiss)then

                        dist = dsqrt((dx(ii)/span_x)**2+
     &                               (dy(jj)/span_y)**2)

			if(dist .le. 1.D0)then
!                        print *, 'z(',ii,',',jj,') = ',z(ii,jj)
!                        print *,'Dist. include in filter ', dist 

                           nreg=nreg+1
!                        print *,'# of regression ', nreg

                           if(nreg .gt. maxreg) then
                              write(*,*)'Dim error in loess2',i,j,nreg
                              return
                           endif

                           des(nreg,1)=dx(ii)
                           des(nreg,2)=dy(jj)
                           zsel(nreg)=z(ii,jj)
                           tem=(1.D0-dist**3)
                           w(nreg)=tem*tem*tem

!                       print *, 'des(',nreg,',1) = ',des(nreg,1)
!                       print *, 'des(',nreg,',2) = ',des(nreg,2)
!                       print *, 'zsel(',nreg,') = ',zsel(nreg)
!                       print *, 'w(',nreg,') = ',w(nreg)

                        endif
                     endif
   40             continue
   50          continue

!               print *,'# of regression ', nreg
               if(nreg .lt. 3)then
                  zhat(i,j)=amiss
                  print *,'doh! Less than 3pts in regression' 
!                 print *,'doh! ii=',ii,' jj=',jj
C		  write(*,*) 'doh! Less than 3pts in regression'
               else
!                  print *,'perform regression'
	          call regsm2(nreg,zsel,des,w,zhat(i,j),amiss,maxreg)
!                  print *,'zhat(',i,',',j,') = ',zhat(i,j)
!                  print *, 'z(',i,',',j,') = ',z(i,j)
               endif

               if (abs(zhat(i,j)-z(i,j)) .gt. 5) then
!                 print *,'zhat(',i,',',j,') = ',zhat(i,j)
!                 print *,'z(',i,',',j,') = ',z(i,j)
               endif

           end if
	 end do
      end do
     
      zout = zhat
      return
      end
      	   
c
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc 
c
      subroutine regsm2(n,z,des,w,zhat,amiss,lddes)
   
c
      parameter(np=6)
      real*8 z(lddes),des(lddes,2),w(lddes)
      real*8 a(np),xtx(np,np),tem(np)
      real*8 d, zmax, zmin, zi, zhat, amiss
      integer indx(np)
c
c make the x-matrix
c
      do 20 j=1,np
         a(j)=0.D0
         do 10 i=1,np
            xtx(i,j)=0.D0
   10    continue
   20 continue
      zmax=-1.D35
      zmin=1.D35

      do 100 i=1,n

         if(z(i) .gt. zmax)zmax=z(i)
         if(z(i) .lt. zmin)zmin=z(i)

         zi=z(i)*w(i)

         tem(1)=w(i)
         tem(2)=des(i,1)*w(i)
         tem(3)=des(i,1)*des(i,1)*w(i)
         tem(4)=des(i,2)*w(i)
         tem(5)=des(i,2)*des(i,2)*w(i)
         tem(6)=des(i,1)*des(i,2)*w(i)

         do 40 k=1,np
            a(k)=a(k)+tem(k)*zi
            do 30 j=1,np
               xtx(j,k)=xtx(j,k)+tem(j)*tem(k)
   30       continue
   40    continue
  100 continue    

c
c now solve it
c

      call ludcmp(xtx,np,np,indx,d,ier)
      if(ier .ne. 0)then
         zhat=amiss
         return
      endif
      call lubksb(xtx,np,np,indx,a)
      zhat=a(1)
c      ibad=0
      if(zhat.ge.zmax .or. zhat.le.zmin)then
C         write(*,*)'loess1 bad ',zmin,zhat,zmax
C         zhat=amiss
c         ibad=1
      endif
      return
      end
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      SUBROUTINE LUDCMP(A,N,NP,INDX,D,ier)
      IMPLICIT REAL*8(A-H,O-Z)
      PARAMETER (NMAX=100)
      INTEGER INDX(N)
      REAL*8 A(NP,NP),VV(NMAX)
      REAL*8, PARAMETER :: TINY=1.D-20
      ier=0
      D=1.D0
      DO 12 I=1,N
        AAMAX=0.D0
        DO 11 J=1,N
          IF (DABS(A(I,J)).GT.AAMAX) AAMAX=DABS(A(I,J))
11      CONTINUE
        IF (AAMAX.EQ.0.D0)then
            ier=1
c            write(*,*)'Singular matrix.'
            return
        endif
        VV(I)=1.D0/AAMAX
12    CONTINUE
      DO 19 J=1,N
        IF (J.GT.1) THEN
          DO 14 I=1,J-1
            SUM=A(I,J)
            IF (I.GT.1)THEN
              DO 13 K=1,I-1
                SUM=SUM-A(I,K)*A(K,J)
13            CONTINUE
              A(I,J)=SUM
            ENDIF
14        CONTINUE
        ENDIF
        AAMAX=0.D0
        DO 16 I=J,N
          SUM=A(I,J)
          IF (J.GT.1)THEN
            DO 15 K=1,J-1
              SUM=SUM-A(I,K)*A(K,J)
15          CONTINUE
            A(I,J)=SUM
          ENDIF
          DUM=VV(I)*ABS(SUM)
          IF (DUM.GE.AAMAX) THEN
            IMAX=I
            AAMAX=DUM
          ENDIF
16      CONTINUE
        IF (J.NE.IMAX)THEN
          DO 17 K=1,N
            DUM=A(IMAX,K)
            A(IMAX,K)=A(J,K)
            A(J,K)=DUM
17        CONTINUE
          D=-D
          VV(IMAX)=VV(J)
        ENDIF
        INDX(J) = IMAX
        IF(J.NE.N)THEN
          IF(A(J,J).EQ.0.D0)A(J,J)=TINY
          DUM=1.D0/A(J,J)
          DO 18 I=J+1,N
            A(I,J)=A(I,J)*DUM
18        CONTINUE
        ENDIF
19    CONTINUE
      IF(A(N,N).EQ.0.D0)A(N,N)=TINY
      RETURN
      END

cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc

      SUBROUTINE LUBKSB(A,N,NP,INDX,B)
      IMPLICIT REAL*8(A-H,O-Z)
      DIMENSION A(NP,NP),INDX(N),B(N)
      II=0
      DO 12 I=1,N
        LL=INDX(I)
        SUM=B(LL)
        B(LL)=B(I)
        IF (II.NE.0)THEN
          DO 11 J=II,I-1
            SUM=SUM-A(I,J)*B(J)
11        CONTINUE
        ELSE IF (SUM.NE.0.D0) THEN
          II=I
        ENDIF
        B(I)=SUM
12    CONTINUE
      DO 14 I=N,1,-1
        SUM=B(I)
        IF(I.LT.N)THEN
          DO 13 J=I+1,N
            SUM=SUM-A(I,J)*B(J)
13        CONTINUE
        ENDIF
        B(I)=SUM/A(I,I)
14    CONTINUE
      RETURN
      END
