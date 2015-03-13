; ------------------------------------------------------------------------------------
  pro ECRIRE_SPECTRE, s,lat,xtit,suffixe, p=p
; ------------------------------------------------------------------------------------
n_sources=n_elements(s(0,0,*))
sm=s(*,*)
for i=1,n_sources-1 do sm=sm+s(*,*,i)
sm=transpose(sm)
fm=*(p.freqs.ramp)
flabel='Frequency (MHz)'
if p.output_type.kHz eq 1 then begin
fm=fm*1e3
flabel='Frequency (kHz)'
endif
f1=min(fm)     & f2=max(fm)
lat1=min(lat)  & lat2=max(lat)
sm=sm(sort(lat),*)
nf=n_elements(fm)
nl=n_elements(lat)

; Si echelle lineaire en frequence:
if p.output_type.log eq 0 then U=fm else $
U=10^(alog10(f1)+(findgen(nf)/(nf-1L)*(alog10(f2)-alog10(f1))))

image=fltarr(nl,nf)
for i=0,nl-1 do image(i,*)=interpol(sm(i,*),fm,U)

titre=p.output_type.titre
nomfich=p.output_type.nom+suffixe+'.ps'

set_plot,'ps'
if nl gt nf then device,filename=p.output_path+nomfich,/landscape,bits=8
if nl le nf then device,filename=p.output_path+nomfich,bits=8,/ENCAP,/COLOR
!p.font=1
!p.multi=[0,1,1]
if p.output_type.log eq 1 then spdynps,image,lat1,lat2,min(U),max(U),xtit,flabel,titre,1,0,0,0,0.98,/log else $
spdynps,image,lat1,lat2,min(U),max(U),xtit,flabel,titre,1,0,0,0,0.98
device,/close
if p.output_type.pdf eq 1 then begin
spawn,'ps2pdf '+p.output_path+nomfich+' '+p.output_path+p.output_type.nom+suffixe+'.pdf'
spawn,'rm -f '+p.output_path+nomfich
endif

  set_plot,p.display_mgr

return
end