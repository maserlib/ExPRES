; ***********************************
; *                                 *
; *   Routines de simulation JUNO   *
; *                                 *
; ***********************************
; S. Hess (9/2006), P. Zarka (10/2006), B. Cecconi (10/2006)


; ------------------------------------------------------------------------------------
  pro CALC_ORBITE, orb, rpd
; ------------------------------------------------------------------------------------
; orb = see PRO orb_obs_param__define in set_observer.pro
; angles in RADIANS !!!!!

  n_steps_orb = 3600
  step_orb = 2.*!pi/n_steps_orb

  rpd=fltarr(3,n_steps_orb)
; repere x=grand axe, y=petit axe, foyer=origine
  alpha=findgen(n_steps_orb)*step_orb + (*(orb)).initial_phase

  x = (*(orb)).semi_major_axis*(cos(alpha) + $
       sqrt(1.-(*(orb)).semi_minor_axis^2 / (*(orb)).semi_major_axis^2))
  y = (*(orb)).semi_minor_axis*sin(alpha)
  
  z = fltarr(n_steps_orb)
  
; on passe en coordonnees spheriques dans le repere z=nord, x=longitude 0

  rtp = XYZ_TO_RTP(transpose([[x],[y],[z]]))
  rpd(0,*)=rtp(0,*)
; for i=0,3598 do if abs(phi(i)-phi(i+1)) gt 1. then phi(i+1)=phi(i+1)+2.*!pi
  rpd(1,*)=rtp(2,*)
  r=rtp(0,*)*71900000.						; r en metres
  rpd(2,*)=sqrt(1.27E17*(2./r-1./( (*(orb)).semi_major_axis  *71900000.)))/r	; dphi/dt

return
end

