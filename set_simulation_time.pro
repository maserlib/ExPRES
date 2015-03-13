; ***********************************
; *                                 *
; *   Routines de simulation JUNO   *
; *                                 *
; ***********************************
; S. Hess (9/2006), P. Zarka (10/2006), B. Cecconi (10/2006)


; ------------------------------------------------------------------------------------
  pro SET_SIMULATION_TIME, simul_length=t1, simul_step=t2, parameters=p
; ------------------------------------------------------------------------------------

  p.simul.length = t1
  p.simul.step   = t2
  p.simul.nsteps = LONG(t1/t2)

return
end
