; ************************************
; *                                  *
; *   Routines de simulation SERPE   *
; *                                  *
; ************************************
; S. Hess (9/2006), P. Zarka (10/2006), B. Cecconi (10/2006), L. Lamy (10/2007)


; ------------------------------------------------------------------------------------
  pro SET_SIMULATION_TIME, simul_length=t1, simul_step=t2, parameters=p, real_xyz=real_xyz
; ------------------------------------------------------------------------------------

if ~keyword_set(real_xyz) then begin
  p.simul.length = t1
  p.simul.step   = t2
  p.simul.nsteps = LONG(t1/t2+0.001)
print,t1,t2,t1/t2,LONG(t1/t2+0.001)

endif else begin
  sz=size(*((*(p.obs.real_pos)).xyz)) 
  t=*((*(p.obs.real_pos)).time)
  p.simul.length = max(t)-min(t)
  p.simul.step   = t(1)-t(0)
  p.simul.nsteps = n_elements(t)
endelse

return
end
