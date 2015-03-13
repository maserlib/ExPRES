; ************************************
; *                                  *
; *   Routines de simulation SERPE   *
; *                                  *
; ************************************
; L. Lamy (10/2007)

; ------------------------------------------------------------------------------------
  pro ECRIRE_SPECTRE, s,x,xtit,suffixe, p=p,oversampling=oversampling
; ------------------------------------------------------------------------------------

sm=s
fm=*(p.freqs.ramp)

sz = size(sm) & if sz(4) eq 1 then sm=transpose(reform(sm)) else sm=transpose(total(sm, 3))

;restore,'f.sav'
;fm=f

flabel='Frequency (MHz)'
if p.output_type.kHz eq 1 then begin
  fm=fm*1e3
  flabel='Frequency (kHz)'
endif
f1=min(fm) & f2=max(fm)
x1=min(x)  & x2=max(x)
if ~keyword_set(oversampling) then nf=n_elements(fm) else nf=4*n_elements(fm) 
nx=n_elements(x)

; Lin or log frequency scale:
if p.output_type.log eq 0 then U=fm else $
U=10^(alog10(f1)+(findgen(nf)/(nf-1L)*(alog10(f2)-alog10(f1))))

image=fltarr(nx,nf)
for i=0l,nx-1l do image(i,*)=interpol(sm(i,*),fm,U)

titre=p.output_type.titre
nomfich=p.output_type.nom+suffixe+'.ps'

set_plot,'ps'
if nx gt nf then device,filename=p.output_path+nomfich,/landscape,bits=8
if nx le nf then device,filename=p.output_path+nomfich,bits=8,/ENCAP,/COLOR

!p.font=1
!p.multi=[0,1,1]

if p.output_type.log eq 1 then spdynps,image,x1,x2,min(U),max(U),xtit,flabel,titre,1,0,0,0,1.,/log else $
spdynps,image,x1,x2,min(U),max(U),xtit,flabel,titre,0,0,0,0,1.

device,/close

if p.output_type.pdf eq 1 then begin
;  spawn,'ps2pdf '+p.output_path+nomfich+' '+p.output_path+p.output_type.nom+suffixe+'.pdf'
;  spawn,'rm -f '+p.output_path+nomfich
endif
set_plot,p.display_mgr

return
end