      program inchour
c$$$  main program documentation block
c
c main program:  inchour    get increment hour
c   prgmmr: kanamitsu          org: w/np51     date: 01-03-31
c
c abstract:  compute increment hour
c
c program history log:
c   01-03-31  hann-ming juang  add w3tag calls for nco implementation
c
c namelists:
c   namin:      parameters determining new date
c
c input files:
c
c output files:
c
c subprograms called:
c
c attributes:
c   language: fortran
c
c$$$
c
c
c  given two dates, compute hour increment
c
      read(5,*) iys,ims,ids,ihs,iye,ime,ide,ihe
      call compjd(iye,ime,ide,ihe,0,jde,fjde)
      call compjd(iys,ims,ids,ihs,0,jds,fjds)
      inc=(float(jde-jds)+fjde-fjds)*24
      print *,inc
      stop
      end
c
      subroutine compjd(jyr,jmnth,jday,jhr,jmn,jd,fjd)
c
      dimension ndm(12)
      data jdor/2415019/,jyr19/1900/
      data ndm/0,31,59,90,120,151,181,212,243,273,304,334/
c     
      jd=jdor
      jyrm9=jyr-jyr19
      lp=jyrm9/4
      if(lp.gt.0) then
        jd=jd+1461*lp
      endif
      ny=jyrm9-4*lp
      ic=0
      if(ny.gt.0) then
        jd=jd+365*ny+1
      else
        if(jmnth.gt.2) ic=1
      endif
      jd=jd+ndm(jmnth)+jday+ic
      if(jhr.ge.12) then
        fjd=.041666667e0*float(jhr-12)+.00069444444e0*float(jmn)
      else
        jd=jd-1
        fjd=.5e0+.041666667e0*float(jhr)+.00069444444e0*float(jmn)
      endif
      return
      end
