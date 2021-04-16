! to account for bad qair values, aka less than 0 or greater than 100.
! Set values less than 0 to 0, set values greater than 100 to 100.

	integer nx, ny, nxny
!        real*8, dimension(:), allocatable :: varin
        real, dimension(:), allocatable :: varin

        open(11,file='fort.11',form='formatted')
        read(11,*) nx,ny,nxny
        
        allocate(varin(nxny))
        open(21,file='fort.21',form='formatted')
        read(21,*) varin

        do i=1,nxny
         if (varin(i) .lt. 0.) then
          print *, 'RH=',varin(i)
             varin(i) = 0.
          print *, 'warning: variable is less than 0: set it 0 @ i=',i
         else if (varin(i) .gt. 100. ) then
          print *, 'RH=',varin(i)
             varin(i) = 100.
          print *, 'varin is greater than 100: set it 100 @ i=',i
         endif
        enddo

        open(51,file='fort.51',form='formatted')
        write(51,*) varin

        call exit
        end

