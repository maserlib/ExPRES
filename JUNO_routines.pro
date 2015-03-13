; ***********************************
; *                                 *
; *   Routines de simulation JUNO   *
; *                                 *
; ***********************************
; S. Hess (9/2006), P. Zarka (10/2006), B. Cecconi (10/2006)

; ------------------------------------------------------------------------------------
  pro JUNO, spdyn,verbose=verbose
; ------------------------------------------------------------------------------------

COMMON GLOBAL, n_pas, n_sources, nsat, longitude_sat, obs_mov, local_time, sim_time, $
	is_sat, pos_sat, xyz_obs, chemin, freq_scl, theta, dtheta, orbite_param, $
	obs_name, rtp_obs, source_intensite, src_nom, src_data, rpd, intensite_opt


if keyword_set(verbose) then verbose=1b else verbose=0b

JUNO_INIT
  print,""
  print,"********************************"
  print,'          Initialisation'
  print,"********************************"
  print,""

  print,'Simulation des emissions radio de Jupiter vue par un observateur '
  if obs_mov eq "fixe" then print,"fixe situe a r=",STRTRIM(rtp_obs(0),2),$
	"colatitude=", STRTRIM(rtp_obs(1),2)," longitude=", STRTRIM(rtp_obs(2),2)
  if obs_mov eq "orb" then begin
    print,"decrivant l'ORBITE:"
    ; a completer ...
  endif

  print,""
  print,"La simulation demarre a ",STRTRIM(local_time(0)/15.,2)," heure (meridien 0) et dure ", $
	STRTRIM(sim_time(0),2)," minutes"
  print,"par pas de ",STRTRIM(sim_time(1),2)," minute(s)"
  print,""
  print,"Cette simulation contient ",STRTRIM(n_sources,2)," sources d'emissions dont ", $
	STRTRIM(nsat,2)," satellites:"
  for i=0,n_sources-1 do if is_sat(i) then print,src_nom(i),"   satellite" else print,src_nom(i)

  xtmp=0. & ytmp=0. & ztmp=0.
  spdyn=fltarr(n_elements(freq_scl),n_pas+1)
  set_plot,'X'

  for boucle_temps=0L,n_pas do begin
    print, boucle_temps
    ROTATION_PLANETE_SAT,verbose=verbose
    for boucle_sources=0,n_sources-1 do begin
      if is_sat(boucle_sources) then begin
      
     ;stop
        FIELD_LINE_EMISSION, xyz_obs, longitude_sat(boucle_sources), chemin(boucle_sources), intensite, frequence, $
		position, theta, dtheta, src_data(*,boucle_sources*2), intensite_opt(boucle_sources), boucle_temps
;if boucle_temps eq 300 then stop
        SCALE_FREQUENCY, intensite, frequence, intensite_scl, freq_scl, intensite_opt(boucle_sources)
        spdyn(*,boucle_temps)=spdyn(*,boucle_temps)+intensite_scl*source_intensite(boucle_sources)
        FIELD_LINE_EMISSION, xyz_obs, -longitude_sat(boucle_sources), chemin(boucle_sources), intensite, frequence, $
		position, theta, dtheta, src_data(*,boucle_sources*2+1), intensite_opt(boucle_sources), boucle_temps
        SCALE_FREQUENCY, intensite, frequence, intensite_scl, freq_scl, intensite_opt(boucle_sources)
        spdyn(*,boucle_temps)=spdyn(*,boucle_temps)+intensite_scl*source_intensite(boucle_sources)
      endif else begin
        ; for longitude=0,359 do begin
        ; for longitude=220,220 do begin
        for longitude=0,300,60 do begin
	  FIELD_LINE_EMISSION, xyz_obs, longitude, chemin(boucle_sources), intensite, frequence, $
		position, theta, dtheta, src_data(*,boucle_sources*2), intensite_opt(boucle_sources), boucle_temps
	  SCALE_FREQUENCY, intensite, frequence, intensite_scl, freq_scl, intensite_opt(boucle_sources)
	  spdyn(*,boucle_temps)=spdyn(*,boucle_temps)+intensite_scl*source_intensite(boucle_sources)
        endfor	; boucle sur la longitude
      endelse
    endfor	; boucle sur les sources
    ; if obs_mov eq "orb" then ORBITE
    spdyn(*,0)=1.
    xtmp=[xtmp,xyz_obs(0)]
    ytmp=[ytmp,xyz_obs(1)]
    ztmp=[ztmp,xyz_obs(2)]
    if boucle_temps mod 20 eq 0 then begin
      if boucle_temps le 1000 then tvscl,-transpose(spdyn(2:*,0:*))
      if boucle_temps gt 1000 then tvscl,-transpose(spdyn(2:*,boucle_temps-1000:boucle_temps))
      ; if boucle_temps ne 0 then plot,xtmp(1:n_elements(xtmp)-1),ytmp(1:n_elements(xtmp)-1)
    endif
  endfor		; boucle sur le temps

;  ECRIRE_SPECTRE, -spdyn, local_time(0), sim_time(0), freq_scl

return
end

; ------------------------------------------------------------------------------------
  pro SET_LOCAL_TIME, t1, t2
; ------------------------------------------------------------------------------------

COMMON GLOBAL, n_pas, n_sources, nsat, longitude_sat, obs_mov, local_time, sim_time, $
	is_sat, pos_sat, xyz_obs, chemin, freq_scl, theta, dtheta, orbite_param, $
	obs_name, rtp_obs, source_intensite, src_nom, src_data, rpd, intensite_opt

  local_time=[t1,t2]

return
end

; ------------------------------------------------------------------------------------
  pro SET_OBSERVER, name, pos=pos, orb=orb
; ------------------------------------------------------------------------------------

COMMON GLOBAL, n_pas, n_sources, nsat, longitude_sat, obs_mov, local_time, sim_time, $
	is_sat, pos_sat, xyz_obs, chemin, freq_scl, theta, dtheta, orbite_param, $
	obs_name, rtp_obs, source_intensite, src_nom, src_data, rpd, intensite_opt

; inclure la variation en temps local
  if n_elements(orb) eq 0 then obs_mov="fixe" else begin
    obs_mov="orb"
    orbite_param = orb		; param=[a,b,phia,i,angle] 
    orbite_param[2:4] = orbite_param[2:4]*!pi/180.
  endelse

  obs_name=name

  if obs_mov eq "fixe" then begin
    rtp_obs=pos
    xyz_obs = [ cos(rtp_obs(1)*!pi/180.)*cos(rtp_obs(2)*!pi/180.), $
	-cos(rtp_obs(1)*!pi/180.)*sin(rtp_obs(2)*!pi/180.), sin(rtp_obs(1)*!pi/180.) ]
    xyz_obs=rtp_obs(0)*xyz_obs
  endif

  if obs_mov eq "orb" then begin
    CALC_ORBITE, orbite_param, rpd
    rtp_obs=[0.,rpd(1,0),0.]
    ORBITE, orbite_param, rpd, xyz_obs, rtp_obs(1), sim_time(1)
  endif

  print,xyz_obs
 
return
end

; ------------------------------------------------------------------------------------
  pro SET_SIMULATION_TIME, t1, t2
; ------------------------------------------------------------------------------------

COMMON GLOBAL, n_pas, n_sources, nsat, longitude_sat, obs_mov, local_time, sim_time, $
	is_sat, pos_sat, xyz_obs, chemin, freq_scl, theta, dtheta, orbite_param, $
	obs_name, rtp_obs, source_intensite, src_nom, src_data, rpd, intensite_opt

  sim_time = [t1,t2]
  n_pas = LONG(t1/t2)

return
end

; ------------------------------------------------------------------------------------
  pro SET_EMISSION_CONE, t1, t2
; ------------------------------------------------------------------------------------

COMMON GLOBAL, n_pas, n_sources, nsat, longitude_sat, obs_mov, local_time, sim_time, $
	is_sat, pos_sat, xyz_obs, chemin, freq_scl, theta, dtheta, orbite_param, $
	obs_name, rtp_obs, source_intensite, src_nom, src_data, rpd, intensite_opt

  theta = t1
  dtheta = t2

return
end

; ------------------------------------------------------------------------------------
  pro SET_FREQUENCY, f1, f2, f3
; ------------------------------------------------------------------------------------

COMMON GLOBAL, n_pas, n_sources, nsat, longitude_sat, obs_mov, local_time, sim_time, $
	is_sat, pos_sat, xyz_obs, chemin, freq_scl, theta, dtheta, orbite_param, $
	obs_name, rtp_obs, source_intensite, src_nom, src_data, rpd, intensite_opt

  freq_scl = findgen(fix((f2-f1)/f3))*f3+f1

return
end

; ------------------------------------------------------------------------------------
  pro SET_NEW_SOURCE, name, camino, sat=sat, intensity=intensity, $
	intensity_random=intensity_random, intensity_n_random=intensity_n_random, $
	intensity_local_time=intensity_local_time, cone_emission=ce, lag=lag, shape=v, intensite_norm=int_n
; ------------------------------------------------------------------------------------

COMMON GLOBAL, n_pas, n_sources, nsat, longitude_sat, obs_mov, local_time, sim_time, $
	is_sat, pos_sat, xyz_obs, chemin, freq_scl, theta, dtheta, orbite_param, $
	obs_name, rtp_obs, source_intensite, src_nom, src_data, rpd, intensite_opt

  if n_elements(is_sat) eq 0 then begin
    help,ce
    n_sources=1
    is_sat=n_elements(sat) ne 0
    if is_sat then begin
      nsat=1
      pos_sat=sat(0)
      longitude_sat=sat(1)
      src_data=fltarr(3,2)
      if n_elements(ce) ne 0 then src_data(0,*)=ce else src_data(0,*)=[-1.,-1]
      if n_elements(lag) ne 0 then src_data(1,*)=lag else src_data(1,*)=[0.,0.]
      if n_elements(v) ne 0 then src_data(2,*)=v else src_data(2,*)=[-1.,-1.]
    endif else begin
      nsat=0	
      pos_sat=0.
      longitude_sat=0.
      src_data=fltarr(3,2)
      if n_elements(ce) ne 0 then src_data(0,*)=[ce,-1] else src_data(0,*)=[-1.,-1]
      if n_elements(v) ne 0 then src_data(2,*)=[v,-1.] else src_data(2,*)=[-1.,-1.]
    endelse		; endelse si sat (premier)
    intensite_opt=(n_elements(int_n) ne 0)
    chemin=camino
    src_nom=name
    source_intensite=1
  endif else begin	; else si pas premier
    help,ce
    n_sources=n_sources+1
    is_sat=[is_sat,(n_elements(sat) ne 0)]
    if is_sat(n_sources-1) then begin
      nsat=nsat+1
      pos_sat=[pos_sat,sat(0)]
      longitude_sat=[longitude_sat,sat(1)]
;if n_elements(ce) eq 0 then ce=[-1.,-1]
;if n_elements(lag) eq 0 then lag=[0.,0.]
;if n_elements(v) eq 0 then v=[-1.,-1.]
      src_data=[[src_data(0,*),ce],[src_data(1,*),lag],[src_data(2,*),v]]
    endif else begin
      pos_sat=[pos_sat,0.]
      longitude_sat=[longitude_sat,0.]
      help,ce
      if n_elements(ce) ne 0 then ce=[ce,-1.] else ce=[-1.,-1]
      if n_elements(v) ne 0 then v=[v,-1.] else v=[-1.,-1.]
      help,ce,v
      src_data20=transpose(src_data(0,*))
      src_data20=[src_data20,ce]
      src_data21=transpose(src_data(1,*))
      src_data21=[src_data21,fltarr(2)]
      src_data22=transpose(src_data(2,*))
      src_data22=[src_data22,v]
      src_data=[[src_data20],[src_data21],[src_data22]]
    endelse
    intensite_opt=[intensite_opt,(n_elements(int_n) ne 0)]
    chemin=[chemin,camino]
    src_nom=[src_nom,name]
    if (n_elements(intensity)) eq 0 then x=2^(n_sources-1) else x=intensity
    source_intensite=[source_intensite,x]
  endelse

return
end

; ------------------------------------------------------------------------------------
  pro ROTATION_PLANETE_SAT,verbose=verbose
; ------------------------------------------------------------------------------------

COMMON GLOBAL, n_pas, n_sources, nsat, longitude_sat, obs_mov, local_time, sim_time, $
	is_sat, pos_sat, xyz_obs, chemin, freq_scl, theta, dtheta, orbite_param, $
	obs_name, rtp_obs, source_intensite, src_nom, src_data, rpd, intensite_opt

  if (obs_mov eq "fixe") then begin
    if verbose then message,/info,'++ FIX OBSERVER ++'
    if verbose then message,/info,'R,Lat,Lon (before) : '+strjoin(string(rtp_obs))
    rtp_obs=rtp_obs+[0.,0.,360./595.5*sim_time(1)]
    if rtp_obs[2] ge 360. then rtp_obs[2]=rtp_obs[2]-360.
    if rtp_obs[2] lt 0 then rtp_obs[2]=360.+rtp_obs[2]
    if verbose then message,/info,'R,Lat,Lon (after)  : '+strjoin(string(rtp_obs))
    if verbose then message,/info,'XYZ (before) : '+strjoin(string(xyz_obs))
    xyz_obs[0:1] = [ cos(rtp_obs(1)*!pi/180.)*cos(rtp_obs(2)*!pi/180.), $
	-cos(rtp_obs(1)*!pi/180.)*sin(rtp_obs(2)*!pi/180.)]
    xyz_obs[0:1]=rtp_obs(0)*xyz_obs[0:1]
    if verbose then message,/info,'XYZ (after)  : '+strjoin(string(xyz_obs))
    ;stop
  endif

  if obs_mov eq "orb" then begin
    if verbose then message,/info,'++ ORBITING OBSERVER ++'
    rtp_obs=rtp_obs+[0.,0.,-2.*!pi/595.5*sim_time(1)]
    tmpe=rtp_obs(1)
    ORBITE, orbite_param,rpd,xyz_obs,tmpe,sim_time(1)
    rtp_obs(1)=tmpe
    XYZ_TO_RTP,xyz_obs(0),xyz_obs(1),xyz_obs(2),a,b,c
    c=c+rtp_obs(2)
    xyz_obs=[sin(b)*cos(c),sin(b)*sin(c),cos(b)]
    xyz_obs=a*xyz_obs
    if verbose then message,/info,'XYZ    : '+strjoin(string(xyz_obs))
    if verbose then message,/info,'RTP    : '+strjoin(string(a,b,c))
    if verbose then message,/info,'phases : '+strjoin(string(rtp_obs))
;    print,xyz_obs
;    print,a,b,c
;    print,rtp_obs
  endif

  for boucle_sources=0,n_sources-1 do begin
    if (is_sat(boucle_sources)) then begin
      longitude_sat(boucle_sources) = $
	longitude_sat(boucle_sources)-sim_time(1)*360.*(1./(pos_sat(boucle_sources)^1.5*175.53)-1./595.5)
      if longitude_sat(boucle_sources) ge 360. then longitude_sat(boucle_sources)=longitude_sat(boucle_sources)-360.
       ;print,longitude_sat(boucle_sources)
    endif
  endfor
; inclure la variation en temps local
;stop
return
end

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
				position, theta, dt, src_data, intens, boucle_temps
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

  fsb=2.79924835996d0
  nomfichier="./"+chemin+"/"+strtrim(fix(lg),2)+".lsr"
  n=long(0)
  openr,unit, nomfichier,/get_lun,/swap_if_little_endian
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

;stop
; calcul de l'angle ligne de visee,B (theta2)
  x(0,*)=xyz_obs(0)-x(0,*)
  x(1,*)=xyz_obs(1)-x(1,*)
  x(2,*)=xyz_obs(2)-x(2,*)
  b2=(1./sqrt(total(x^2,1)))
  x(0,*)*=b2	; x(0,*)=x(0,*)*b2
  x(1,*)*=b2
  x(2,*)*=b2
  theta2=acos(total(x*b,1))*180./!pi
;  b=0
;  x=0
  if lg lt 0 then theta2=180-theta2	; on inverse dans l'hemisphere sud
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
;  if boucle_temps eq 300 then stop,'i=300'
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
return
end

; ------------------------------------------------------------------------------------
  pro ECRIRE_SPECTRE, spdyn, debt, dureet, y
; ------------------------------------------------------------------------------------

  ds=transpose(spdyn)
  x=findgen(n_elements(ds(*,0)))/float(n_elements(ds(*,0)))*dureet+debt
  fmin=min(y)
  fmax=max(y)
  set_plot,'PS'
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
  set_plot,'X'

return
end

; ------------------------------------------------------------------------------------
  pro CONVERT, brtp, bxyz, xyz, n
; ------------------------------------------------------------------------------------

  bxyz=brtp*0.
  XYZ_TO_RTP, xyz(0,*), xyz(1,*), xyz(2,*), r, theta, phi
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
  XYZ_TO_RTP, x, y, 0., r, theta, phi
  rpd(0,*)=r
; for i=0,3598 do if abs(phi(i)-phi(i+1)) gt 1. then phi(i+1)=phi(i+1)+2.*!pi
  rpd(1,*)=phi
  r=r*71900000.						; r en metres
  rpd(2,*)=sqrt(1.27E17*(2./r-1./(orb(0)*71900000)))/r	; dphi/dt

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
  XYZ_TO_RTP,x,y*cos(orb(3)),y*sin(orb(3)),r,theta,phi
  phi=phi+orb(2)

  xyz(2)=r*cos(theta)
  xyz(0)=r*sin(theta)*cos(phi)
  xyz(1)=r*sin(theta)*sin(phi)

return
end
