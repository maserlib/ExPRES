; ***********************************
; *                                 *
; *   Routines de simulation JUNO   *
; *                                 *
; ***********************************
; S. Hess (9/2006), P. Zarka (10/2006), B. Cecconi (10/2006)


; ------------------------------------------------------------------------------------
  pro ORBITE, orb, rpd, xyz, p, dt
; ------------------------------------------------------------------------------------
; orb = see PRO orb_obs_param__define in set_observer.pro

  xyz=fltarr(3)

; ********** on cherche quel element (e) de rpd(1,*) correspond a la phase p
  w=where(abs(rpd(1,*)-p) eq min(abs(rpd(1,*)-p)))
  e=w[0]
  if rpd(1,e) gt p then e=e-1
  if e eq -1 then e=3599
;***********

;*********** on interpole dpdt(deplacement en phase) entre e et e+1
  b=p-rpd(1,e)
  dpdt=(1.-b)*rpd(2,e)
  e=e+1
  if e eq 3600 then e=0
  dpdt=dpdt+b*rpd(2,e)
;*********** et on calcule la nouvelle phase p
  p=p+dpdt*dt;*60. ; directement en min dans calc_orbite SH(12/06)
   if p gt 2.*!pi then p=p-2.*!pi
  if p lt 0. then p=p+2.*!pi
;*********** et le nouveau e correspondant a p
  w=where(abs(rpd(1,*)-p) eq min(abs(rpd(1,*)-p)))
  e=w[0]
  if rpd(1,e) gt p then e=e-1
  if e eq -1 then e=3599
;***********

;*********** on passe de la phase a x et y (dans le plan de l'orbite)  
  b=p-rpd(1,e)
  r=(1.-b)*rpd(0,e)
  e=e+1
  
  if e eq 3600 then e=0
  
  r=r+b*rpd(0,e)
  y=r*sin(p)
  x=r*cos(p)
;*********** puis a r,t,p en utilisant (*orb).orbit_inclination  et (*orb).apoapsis_longitude
  rtp = XYZ_TO_RTP(transpose([[x],[y*cos( (*orb).orbit_inclination )],[y*sin( (*orb).orbit_inclination )]]))
  rtp(1) += (*orb).apoapsis_declination*cos(rtp(2))
  rtp(2) += (*orb).apoapsis_longitude

;************

;*********** conversion rtp en xyz
  xyz(2)=rtp(0)*cos(rtp(1))
  xyz(0)=rtp(0)*sin(rtp(1))*cos(rtp(2))
  xyz(1)=rtp(0)*sin(rtp(1))*sin(rtp(2))

return
end
