; ***********************************
; *                                 *
; *   Routines de simulation JUNO   *
; *                                 *
; ***********************************
; S. Hess (9/2006), P. Zarka (10/2006), B. Cecconi (10/2006)


; ------------------------------------------------------------------------------------
  pro SET_FREQUENCY, fmin=f1, fmax=f2, fstep=f3, parameters=p
; ------------------------------------------------------------------------------------

  p.freqs.n = fix((f2-f1)/f3)
  p.freqs.ramp = ptr_new(findgen(p.freqs.n)*f3+f1)
  
return
end

