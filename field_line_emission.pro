; ***********************************
; *                                 *
; *   Routines de simulation JUNO   *
; *                                 *
; ***********************************
; S. Hess (9/2006), P. Zarka (10/2006), B. Cecconi (10/2006)


; ------------------------------------------------------------------------------------
  pro FIELD_LINE_EMISSION, xyz_obs, longitude, chemin, intensite, frequence, $
				position, theta, dt, cone, longi, v, intens, $
				stop_flag=stop_flag
; ------------------------------------------------------------------------------------

;   cone  = cone_in/!radeg		; ouverture du cone d'emission
;   longi = longi_in/!radeg		; decalage de la ligne de champ
;   v     = v_in/!radeg			; profil de l'ouverture du cone
;  lg=longitude/!radeg+0.5/!radeg-longi	; longitude ligne de champ

;  if longitude ge 0 then begin
;    if lg lt 0            then lg = lg + (2.*!pi)
;    if lg ge 360./!radeg  then lg = lg - (2.*!pi)
;  endif else begin
;    if lg gt -1./!radeg   then lg = lg - (2.*!pi)
;    if lg le -361./!radeg then lg = lg + (2.*!pi)
;  endelse

  lg=longitude+0.5-longi	; longitude ligne de champ
  if longitude ge 0 then begin
    if lg lt 0     then lg = lg + 360.
    if lg ge 360.  then lg = lg - 360.
  endif else begin
    if lg gt -1.   then lg = lg - 360.
    if lg le -361. then lg = lg + 360.
  endelse

  fsb=2.79924835996d0
  nomfichier="./"+chemin+"/"+strtrim(fix(lg),2)+".lsr"
  n=long(0)
  openr,unit, nomfichier,/get_lun,/swap_if_little_endian
	readu,unit,n
    b_read    = dblarr(3,n)
    f_read    = dblarr(n)
    x_read    = dblarr(3,n)
    xt        = dblarr(n)
	readu,unit, xt
    x_read(0,*) = xt
	readu,unit, xt
    x_read(1,*) = xt
	readu,unit, xt
    x_read(2,*) = xt
    xt        = 0
	readu,unit, b_read
	readu,unit, f_read
  close, unit & free_lun, unit

;  B = dblarr(3,n_elements(frequence))
;  B = interpol(B_read,freq_)

  b = b_read
  x = x_read
  frequence = f_read
 
; stop

; calcul de l'angle ligne de visee,B (theta2)
  x(0,*)=xyz_obs(0)-x(0,*)
  x(1,*)=xyz_obs(1)-x(1,*)
  x(2,*)=xyz_obs(2)-x(2,*)
  b2=(1./sqrt(total(x^2,1)))
  x(0,*)*=b2	; x(0,*)=x(0,*)*b2
  x(1,*)*=b2
  x(2,*)*=b2
  theta2=acos(total(x*b,1))*!radeg
;  b=0
;  x=0
  if lg lt 0 then theta2=180-theta2	; on inverse dans l'hemisphere sud
;  if lg lt 0 then theta2=!pi-theta2	; on inverse dans l'hemisphere sud
; (on pourrait aussi prendre des cones d'emission avec ouverture >90¡)

; profil de l'ouverture du cone d'emission
  if (v gt 0) then begin
    b2=v/sqrt(1.-frequence/max(frequence))
    if cone ne -1. then th=cone/acos(v)*acos(b2) else th=theta/acos(v)*acos(b2)
    th(where(b2 ge 1.))=10000.
  endif else begin
    if cone ne -1. then th=cone+fltarr(n_elements(b2)) else th=theta+fltarr(n_elements(b2))
  endelse

  delta_theta = abs(th-theta2)

; expression initiale de Sebastien (erreur sur l'epaisseur)
; intensite = exp(-delta_theta/dt/sqrt(2.))

; variation expo de l'intensite / epaisseur du cone, avec dt = epaisseur a 3 dB
; intensite = exp(-delta_theta/dt*2.*alog(2.))	

; variation discrete de l'intensite / epaisseur du cone
  w=where(delta_theta le dt/2)
  intensite=fltarr(n_elements(delta_theta))
  if w[0] ne -1 then intensite(w)=1.
  if (~(intens)) then intensite=intensite*frequence	; ~ = not
  w=where(theta2 gt 90.)

; les ondes ne se propagent pas vers des gradients positifs
  if w[0] ne -1 then intensite(w)=0.
  intensite(where(frequence lt 1.))=intensite(where(frequence lt 1.))*10.	; variation du pas de L_SHELL_TEST
  position=x		; si on veut tester la goniopolarimetrie

; print,'f',max(frequence)
; if lg gt 0 then begin
;  plot,th(where(th ne 10000)),frequence(where(th ne 10000)),xrange=[0,150]
;  oplot,theta2,frequence
; endif
; if lg lt 0 then begin
;  plot,th(where(th ne 10000)),frequence(where(th ne 10000)),xrange=[0,150]
;  oplot,theta2,frequence
; endif
;stop
if keyword_set(stop_flag) then stop

return
end

