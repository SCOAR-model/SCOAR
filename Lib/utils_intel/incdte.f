      program incdte
c$$$  main program documentation block
c
c main program:  incdte    add increment date
c   prgmmr: kanamitsu          org: w/np51     date: 01-03-31
c
c abstract: compute the increment of date 
c
c program history log:
c   01-03-31  hann-ming juang  add w3tag calls for nco implementation
c
c namelists:
c   namin:      parameters determining new date
c
c input files:
c   unit   11  sigma file(s)
c
c output files:
c   unit   51  sigma file
c
c subprograms called:
c
c attributes:
c   language: fortran
c
c$$$
c
c
      read (5,*) iyv,imv,idv,ihv,inc
c
      if(inc.ge.0) then
        incdy=inc/24
        ihv=ihv+mod(inc,24)
        incdy=incdy+ihv/24
        ihv=mod(ihv,24)
        n=1
        dowhile(n.le.incdy)
          idv=idv+1
          if(imv.eq.4.or.imv.eq.6.or.imv.eq.9.or.imv.eq.11) then
            mondy=30
          elseif(imv.eq.2) then
            if(mod(iyv,4).eq.0) then
              mondy=29
            else
              mondy=28
            endif
          else
            mondy=31
          endif
          if(idv.gt.mondy) then
            imv=imv+1
            idv=1
            if(imv.gt.12) then
              iyv=iyv+1
              imv=1
            endif
          endif
          n=n+1
        enddo
c
      else
        if(inc+ihv.lt.0) then
          incdy=(ihv+inc+1)/24-1
          ihv=ihv+inc-24*incdy
        else
          incdy=0
          ihv=ihv+inc
        endif
        n=incdy
        dowhile(n.lt.0)
          idv=idv-1
          if(idv.le.0) then
            imv=imv-1
            if(imv.le.0) then
              iyv=iyv-1
              imv=12
            endif
            if(imv.eq.4.or.imv.eq.6.or.imv.eq.9.or.imv.eq.11) then
              mondy=30
            elseif(imv.eq.2) then
              if(mod(iyv,4).eq.0) then
                 mondy=29
              else
                 mondy=28
              endif
            else
              mondy=31
            endif
            idv=mondy
          endif
          n=n+1
        enddo
      endif
c
      write(6,100) iyv,imv,idv,ihv
  100 format(4i5)
c
      stop
      end
