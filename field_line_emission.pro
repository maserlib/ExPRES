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

 ;  x1 = x_read
 ;  b1 = b_read
 ;  f1 = f_read

;; ===== calcul avec les donnees lues (pas interpolees) pour comparaison.
;; calcul de l'angle ligne de visee,B (theta2)
;  nf = n_elements(f1)
;  x1 = rebin(reform(xyz_obs,3,1),3,nf) - x1
;  x1 = x1 /rebin(reform(sqrt(total(x1^2.,1)),1,nf),3,nf)
;  theta2_1= acos(total(x1*b1,1))*!radeg
;  if lg lt 0 then theta2_1=180-theta2_1	; on inverse dans l'hemisphere sud
;;  if lg lt 0 then theta2=!pi-theta2	; on inverse dans l'hemisphere sud
;; (on pourrait aussi prendre des cones d'emission avec ouverture >90¡)

;; profil de l'ouverture du cone d'emission
;  if (v gt 0) then begin
;    b2_1=v/sqrt(1.-f1/max(f1))
;    if cone ne -1. then th_1=cone/acos(v)*acos(b2_1) else th_1=theta/acos(v)*acos(b2_1)
;    th_1(where(B2_1 ge 1.))=10000.
;  endif else begin
;    if cone ne -1. then th_1=cone+fltarr(n_elements(b2_1)) else th_1=theta+fltarr(n_elements(b2_1))
;  endelse;

;  delta_theta_1 = abs(th_1-theta2_1)

;; expression initiale de Sebastien (erreur sur l'epaisseur)
;; intensite = exp(-delta_theta/dt/sqrt(2.))

;; variation expo de l'intensite / epaisseur du cone, avec dt = epaisseur a 3 dB
;; intensite = exp(-delta_theta/dt*2.*alog(2.))	

;; variation discrete de l'intensite / epaisseur du cone
;  w_1=where(delta_theta_1 le dt/2)
;  intensite_1=fltarr(nf)
;  if w_1[0] ne -1 then intensite_1(w_1)=1.
;  if (~(intens)) then intensite_1=intensite_1*f1	; ~ = not
;  w_1=where(theta2_1 gt 90.)

;; les ondes ne se propagent pas vers des gradients positifs
;  if w_1[0] ne -1 then intensite_1(w_1)=0.
;;  intensite(where(frequence lt 1.))=intensite(where(frequence lt 1.))*10.	; variation du pas de L_SHELL_TEST;
;  position_1=x1		; si on veut tester la goniopolarimetrie



; INTERPOLATION DES DONNES LUES SUR L'ECHELLE DE FREQUENCE FOURNIES

  nf = n_elements(frequence)
  b = dblarr(3,nf)
  x = dblarr(3,nf)
  b(0,*) = interpol(b_read(0,*),f_read,frequence)
  b(1,*) = interpol(b_read(1,*),f_read,frequence)
  b(2,*) = interpol(b_read(2,*),f_read,frequence)

  x(0,*) = interpol(x_read(0,*),f_read,frequence)
  x(1,*) = interpol(x_read(1,*),f_read,frequence)
  x(2,*) = interpol(x_read(2,*),f_read,frequence)
 
; stop

; calcul de l'angle ligne de visee,B (theta2)

  x = rebin(reform(xyz_obs,3,1),3,nf) - x
  x = x /rebin(reform(sqrt(total(x^2.,1)),1,nf),3,nf)
  theta2 = acos(total(x*b,1))*!radeg
  if lg lt 0 then theta2=180-theta2	; on inverse dans l'hemisphere sud
;  if lg lt 0 then theta2=!pi-theta2	; on inverse dans l'hemisphere sud
; (on pourrait aussi prendre des cones d'emission avec ouverture >90¡)

; profil de l'ouverture du cone d'emission
  if (v gt 0) then begin
    b2=v/sqrt(1.-frequence/max(f_read)) ; prendre max(f_read) et non max(frequence) !!!
    th = fltarr(nf)+10000.
    w = where(b2 lt 1.)
    if w(0) ne -1 then $
      if cone ne -1. then th(w)=cone/acos(v)*acos(b2(w)) else th(w)=theta/acos(v)*acos(b2(w))
  endif else begin
    if cone ne -1. then th=cone+fltarr(nf) else th=theta+fltarr(nf)
  endelse

  delta_theta = abs(th-theta2)

; expression initiale de Sebastien (erreur sur l'epaisseur)
; intensite = exp(-delta_theta/dt/sqrt(2.))

; variation expo de l'intensite / epaisseur du cone, avec dt = epaisseur a 3 dB
; intensite = exp(-delta_theta/dt*2.*alog(2.))	

; variation discrete de l'intensite / epaisseur du cone
  w=where(delta_theta le dt/2)
  intensite=fltarr(nf)
  if w[0] ne -1 then intensite(w)=1.
;  if (~(intens)) then intensite=intensite*frequence	; ~ = not
  w=where(theta2 gt 90.)

; les ondes ne se propagent pas vers des gradients positifs
  if w[0] ne -1 then intensite(w)=0.
;  intensite(where(frequence lt 1.))=intensite(where(frequence lt 1.))*10.	; variation du pas de L_SHELL_TEST
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

if keyword_set(stop_flag) then stop
return
end

