; ***********************************
; *                                 *
; *   Routines de simulation JUNO   *
; *                                 *
; ***********************************
; S. Hess (9/2006), P. Zarka (10/2006), B. Cecconi (10/2006)


; ------------------------------------------------------------------------------------
  pro SCALE_FREQUENCY, in, f, out, freq_scl, intens
; ------------------------------------------------------------------------------------

  nf=n_elements(freq_scl)
  nrm=fltarr(nf)
  out=fltarr(nf)
  df=freq_scl(1)-freq_scl(0)
  nf2=n_elements(in)
  f=(f-freq_scl(0))/df
  for i=0,nf2-1 do begin
    a=fix(f(i))
    b=f(i)-float(a)
    c=1.-b
    if ((a lt nf) and (a ge 0)) then out(a)=out(a)+c*in(i)
    if ((a+1 lt nf) and (a ge -1)) then out(a+1)=out(a+1)+b*in(i)
    if ((a lt nf) and (a ge 0)) then nrm(a)=nrm(a)+c
    if ((a+1 lt nf) and (a ge -1)) then nrm(a+1)=nrm(a+1)+b
  endfor
  if (intens) then out(where(nrm ne 0))=out(where(nrm ne 0))/nrm(where(nrm ne 0))

return
end
