; ====================================================================================
;    JUNO_LIBS.pro
; ====================================================================================

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

; ------------------------------------------------------------------------------------
  pro FIELD_LINE_EMISSION, xyz_obs, longitude, chemin, intensite, frequence, $
				position, theta, dt, src_data, intens
; ------------------------------------------------------------------------------------

  cone=src_data(0)		; ouverture du cone d'emission
  longi=src_data(1)		; decalage de la ligne de champ
  v=src_data(2)			; profil de l'ouverture du cone
  lg=longitude+0.5-longi	; longitude ligne de champ

  if longitude ge 0 then begin
	if lg lt 0 then lg=lg+360.
	if lg ge 360 then lg=lg-360
  endif else begin
	if lg gt -1 then lg=lg-360.
	if lg le -361 then lg=lg+360
  endelse

  fsb=2.79924835996
  nomfichier="./"+chemin+"/"+strtrim(fix(lg),2)+".lsr"
  n=long(0)
  openr,unit, nomfichier,/get_lun
	readu,unit,n
  b=dblarr(3,n)
  frequence=dblarr(n)
  x=dblarr(3,n)
  xt=dblarr(n)
	readu,unit,xt
  x(0,*)=xt
	readu,unit,xt
  x(1,*)=xt
	readu,unit,xt
  x(2,*)=xt
  xt=0
	readu,unit,b
	readu,unit,frequence
  close, unit & free_lun, unit

; calcul de l'angle ligne de visee,B (theta2)
  x(0,*)=xyz_obs(0)-x(0,*)
  x(1,*)=xyz_obs(1)-x(1,*)
  x(2,*)=xyz_obs(2)-x(2,*)
  b2=(1./sqrt(total(x^2,1)))
  x(0,*)*=b2	; x(0,*)=x(0,*)*b2
  x(1,*)*=b2
  x(2,*)*=b2
  theta2=acos(total(x*b,1))*180./!pi
  b=0
  x=0
  if lg lt 0 then theta2=180-theta2	; on inverse dans l'hemisphere sud
; (on pourrait aussi prendre des cones d'emission avec ouverture >90¡)

; profil de l'ouverture du cone d'emission
  if (v gt 0) then begin
	b2=v/sqrt(1.-frequence/max(frequence))
	if cone ne -1. then th=cone/acos(v)*acos(b2) else $
		th=theta/acos(v)*acos(b2)
	th(where(b2 ge 1.))=10000.
  endif else begin
	if cone ne -1. then th=cone+fltarr(n_elements(b2)) else $
		th=theta+fltarr(n_elements(b2))
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

  if (~(intens)) then intensite=intensite*frequence ; ~ = not
  w=where(theta2 gt 90.)
; les ondes ne se propagent pas vers des gradients positifs
  if w[0] ne -1 then intensite(w)=0.
  intensite(where(frequence lt 1.))=intensite(where(frequence lt 1.))*10. ; variation du pas de L_SHELL_TEST
  position=x		; si on veut tester la goniopolarimetrie

; print,'f',max(frequence)
; if lg gt 0 then begin
;	plot,th(where(th ne 10000)),frequence(where(th ne 10000)),xrange=[0,150]
;	oplot,theta2,frequence
; endif
; if lg lt 0 then begin
;	plot,th(where(th ne 10000)),frequence(where(th ne 10000)),xrange=[0,150]
;	oplot,theta2,frequence
; endif

return
end

; ------------------------------------------------------------------------------------
  pro ECRIRE_SPECTRE, dynsp, debt, dureet, y
; ------------------------------------------------------------------------------------

  ds=transpose(dynsp)
  x=findgen(n_elements(ds(*,0)))/float(n_elements(ds(*,0)))*dureet+debt
  fmin=min(y)
  fmax=max(y)
  set_plot,'ps'
  DEVICE, file='spectre.ps', /ENCAP,/COLOR,bits=8,/PORTRAIT,YOFFSET=2.,YSIZE=25.7                                                            
  CONTOUR, ds, x, y, title='spectre dynamique', xtitle='temp en minutes', $
	ytitle='frequence en MHz', /NODATA, xra=[debt,debt+dureet], yra=[fmin,fmax], $
	xsty=1, ysty=1
  TVSCL, ds, !X.WINDOW(0), !Y.WINDOW(0), XSIZE = !X.WINDOW(1) - !X.WINDOW(0), $
	YSIZE = !Y.WINDOW(1) - !Y.WINDOW(0), /NORM
  CONTOUR, ds, x, y, title='spectre dynamique', xtitle='temp en minutes', $
	ytitle='frequence en MHz', /NOERASE, /NODATA, xra=[debt,debt+dureet], $
	yra=[fmin,fmax], xsty=1, ysty=1
  device,/close  
  set_plot,'x'                                                                                                                              
return
end

; ------------------------------------------------------------------------------------
  pro CONVERT, brtp, bxyz, xyz, n
; ------------------------------------------------------------------------------------

  bxyz=brtp*0.
  xyz_to_rtp,xyz(0,*),xyz(1,*),xyz(2,*),r,theta,phi
  bxyz(2,*)=cos(theta)*brtp(0,*)-sin(theta)*brtp(1,*)
  bxyz(0,*)=sin(theta)*cos(phi)*brtp(0,*)+cos(theta)*cos(phi)*brtp(1,*)-sin(phi)*brtp(2,*)
  bxyz(1,*)=sin(theta)*sin(phi)*brtp(0,*)+cos(theta)*sin(phi)*brtp(1,*)+cos(phi)*brtp(2,*)
return
end

; ------------------------------------------------------------------------------------
  pro CALC_ORBITE, orb, rpd
; ------------------------------------------------------------------------------------
; orb=[a,b,phia,i,alpha] on suppose apojove et perijove dans le plan equatorial

  rpd=fltarr(3,3600)
; repere x=grand axe, y=petit axe, foyer=origine
  alpha=findgen(3600)*0.1*!pi/180.+orb(4)
  x=orb(0)*(cos(alpha)+sqrt(1.-orb(1)^2/orb(0)^2))
  y=orb(1)*sin(alpha)
; on passe en coordonnees spheriques dans le repere z=nord, x=longitude 0
  xyz_to_rtp,x,y,0.,r,theta,phi
  rpd(0,*)=r
; for i=0,3598 do if abs(phi(i)-phi(i+1)) gt 1. then phi(i+1)=phi(i+1)+2.*!pi
  rpd(1,*)=phi
  r=r*71900000. ; r en metres
  rpd(2,*)=sqrt(1.27E17*(2./r-1./(orb(0)*71900000)))/r		; dphi/dt
return
end

; ------------------------------------------------------------------------------------
  pro ORBITE, orb, rpd, xyz, p, dt
; ------------------------------------------------------------------------------------

  xyz=fltarr(3)
  w=where(abs(rpd(1,*)-p) eq min(abs(rpd(1,*)-p)))
  e=w[0]
  if rpd(1,e) gt p then e=e-1
  if e eq -1 then e=3599
  b=p-rpd(1,e)
  dpdt=(1.-b)*rpd(2,e)
  e=e+1
  if e eq 3600 then e=0
  dpdt=dpdt+b*rpd(2,e)
  p=p+dpdt*dt*60.
  if p gt 2.*!pi then p=p-2.*!pi
  if p lt 0. then p=p+2.*!pi
  w=where(abs(rpd(1,*)-p) eq min(abs(rpd(1,*)-p)))
  e=w[0]
  if rpd(1,e) gt p then e=e-1
  if e eq -1 then e=3599
  b=p-rpd(1,e)
  r=(1.-b)*rpd(0,e)
  e=e+1
  if e eq 3600 then e=0
  r=r+b*rpd(0,e)
  y=r*sin(p)
  x=r*cos(p)
  xyz_to_rtp,x,y*cos(orb(3)),y*sin(orb(3)),r,theta,phi
  phi=phi+orb(2)

  xyz(2)=r*cos(theta)
  xyz(0)=r*sin(theta)*cos(phi)
  xyz(1)=r*sin(theta)*sin(phi)
return
end
