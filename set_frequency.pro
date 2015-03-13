; ***********************************
; *                                 *
; *   Routines de simulation JUNO   *
; *                                 *
; ***********************************
; S. Hess (9/2006), P. Zarka (10/2006), B. Cecconi (10/2006), L. Lamy (02/2007)


; ------------------------------------------------------------------------------------
  pro SET_FREQUENCY, fmin=f1, fmax=f2, fstep=f3, framp=framp, parameters=p
; ------------------------------------------------------------------------------------
; rajouter mot clef : framp pour choisir rampe de frequence specifique
; ------------------------------------------------------------------------------------

if keyword_set(framp) then begin
  p.freqs.n = n_elements(framp)
  p.freqs.ramp = ptr_new(framp)
endif else begin
  if f3 eq 0. then f3=1.
  p.freqs.n = fix((f2-f1+1)/f3)
  p.freqs.ramp = ptr_new(findgen(p.freqs.n)*f3+f1)
endelse

return
end

