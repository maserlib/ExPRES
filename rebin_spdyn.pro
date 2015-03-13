; ************************************
; *                                  *
; *   Routines de simulation SERPE   *
; *                                  *
; ************************************
; LL (10/2007)

; ------------------------------------------------------------------------------------
PRO REBIN_SPDYN,parameters,spdyn,x,spdyn2,x2,tl=tl,lat=lat,rs=rs;,real_f=real_f
; ------------------------------------------------------------------------------------

; Resampling in regular dynamic spectra
; Step dimension: tl=min, lat=deg, rs=Rp

tmp=spdyn
sz = size(tmp) & if sz(4) eq 1 then tmp=transpose(reform(tmp)) else tmp=transpose(total(tmp, 3))

if ~keyword_set(tl) and ~keyword_set(lat) and ~keyword_set(rs) then begin
  print,'Please enter keyword (/tl,/lat,/rs)'
  return
endif

if keyword_set(tl)  then begin
  step=parameters.output_type.step_tl/60.
  x2=findgen(round(24/step))*step
endif
  
if keyword_set(lat) then begin
  step=parameters.output_type.step_lati
  x2=findgen(round((max(x)-min(x))/step))*step+min(x)
endif

if keyword_set(rs)  then begin
  step=parameters.output_type.step_dist
  x2=findgen(round((max(x)-min(x))/step))*step
endif

nf     = n_elements(*(parameters.freqs.ramp))
nx2    = n_elements(x2)
spdyn2 = fltarr(nx2,nf)

for i=0l,nx2-2l do begin
  w = where(x ge x2(i) and x lt (x2(i)+step),count)
  if count gt 0 then spdyn2(i,*) = rebin(tmp(w,*),1,nf)
endfor

;if real_f then begin
;  w1 = where(real_f le min(*(parameters.freqs.ramp)),count1)
;  w2 = where(real_f le max(*(parameters.freqs.ramp)),count2)
;  tmp=fltarr(nx2,n_elements(real_f))
;  tmp(*,count1-1l:count2-1l) = spdyn2
;  spdyn2=tmp
;endif



end