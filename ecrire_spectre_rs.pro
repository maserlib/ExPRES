; ------------------------------------------------------------------------------------
  pro ECRIRE_SPECTRE_RS, s, rs, f, titre, path
; ------------------------------------------------------------------------------------

fm=f*1e3
f1=min(fm)    & f2=max(fm) 
r1=min(rs)   & r2=max(rs)
sm=s(sort(rs),*)
nf=n_elements(f)
nr=n_elements(rs)

; Si echelle lineaire en frequence:
;U=findgen(nf)/(nf-1.)*1200. 

; Si echelle log en frequence:
U=10^(alog10(f1)+(findgen(nf)/(nf-1L)*(alog10(f2)-alog10(f1))))

image=fltarr(nr,nf)
for i=0,nr-1 do image(i,*)=interpol(sm(i,*),fm,U)

set_plot,'ps'
device,filename=path+'spectre.ps',/landscape,bits=8,/ENCAP,/COLOR
!p.font=1
!p.multi=[0,1,1]
spdynps,image,r1,r2,min(U),max(U),'r (Rsat)','f (kHz)',titre,1,0,0,0,0.98,/log
device,/close
set_plot,'x' 

return
end