;***********************************************************
;***                                                     ***
;***         SERPE V6.1                                  ***
;***                                                     ***
;***********************************************************
;***                                                     ***
;***       MODULE: BODY                                  ***
;***                                                     ***
;***     INIT   [INIT_BODY]                              ***
;***     CALLBACK [CB_BODY]                              ***
;***                                                     ***
;***********************************************************
;***                                                     ***
;***       MODULE: ORB                                   ***
;***                                                     ***
;***     INIT   [INIT_ORB]                               ***
;***     CALLBACK [CB_ORB]                               ***
;***                                                     ***
;***********************************************************

;************************************************************** INIT_BODY
pro init_body,obj,parameters

; initialise les donnees d un objet BODY ou SAT
(*obj).rot=[[cos(!pi/180.*(*obj).lg0),-sin(!pi/180.*(*obj).lg0),0.],$
[sin(!pi/180.*(*obj).lg0),cos(!pi/180.*(*obj).lg0),0.],[0.,0.,1.]]

; CML du corp parent
(*obj).lct=PTR_NEW((*obj).lg0+findgen(parameters.time.n_step)*360.*parameters.time.step/(*obj).period)

; longitude x=0
(*obj).lg=PTR_NEW((*obj).lg0+findgen(parameters.time.n_step)*360.*parameters.time.step/(*obj).period)

end

;************************************************************** CB_BODY
pro cb_body,obj,parameters

; fait tourner la planete ou le satellite
lg=(*obj).lg0+360.*parameters.time.time/(*obj).period
(*obj).rot=[[cos(!pi/180.*lg),-sin(!pi/180.*lg),0.],[sin(!pi/180.*lg),cos(!pi/180.*lg),0.],[0.,0.,1.]]
end

;************************************************************** INIT_ORB
PRO init_orb,obj,parameters

; Calcule la trajectoire de l objet en orbite
ns=parameters.time.n_step
traj_xyz=fltarr(3,ns)
traj_rtp=fltarr(3,ns)


if (*obj).traj_file eq '' then begin
	n_steps_orb = 3600
	step_orb = 2.*!pi/n_steps_orb
	rpd=fltarr(3,n_steps_orb)
	alpha=findgen(n_steps_orb)*step_orb + (*(obj)).initial_phase*!dtor
	if ~((TAG_NAMES(*(obj),/str) eq 'BODY') and ((*obj).motion eq 0 )) then alpha=alpha+(*((*(obj)).parent)).lg0*!dtor

	c = sqrt((*(obj)).semi_major_axis^2-(*(obj)).semi_minor_axis^2)
	x = (*(obj)).semi_major_axis*cos(alpha)+c
	y = (*(obj)).semi_minor_axis*sin(alpha)
	z = fltarr(n_steps_orb)
	r=sqrt(x^2+y^2+z^2)
	rp=shift(r,-1)
	corec=2.*abs(rp-r)/(rp+r)*3600./2./!pi+1.
	rtp = XYZ_TO_RTP(transpose([[x],[y],[z]]))

	if (*obj).motion eq 0 then begin
		rtp=rtp(*,0)
		rtp[1]=!pi*0.5-(*(obj)).apoapsis_declination*!dtor
  
		xyz=fltarr(3)
		xyz(2)=rtp(0)*cos(rtp(1))
		xyz(0)=rtp(0)*sin(rtp(1))*cos(rtp(2))
		xyz(1)=rtp(0)*sin(rtp(1))*sin(rtp(2))
		traj_rtp[*,*]=rebin(rtp,3,ns)
		traj_xyz[*,*]=rebin(xyz,3,ns)
	endif else begin

		rpd(0,*)=rtp(0,*)
		rpd(1,*)=rtp(2,*)
		rpd(2,*)=2.*!pi/((*((*obj).parent)).orb_1r)*sqrt(2./rtp(0,*)-1./(*(obj)).semi_major_axis)/rtp(0,*)/corec

		p=rtp[2,0]
		for i=0,ns-1 do begin
			rtp=fltarr(3)
			xyz=fltarr(3)

;*********** on cherche quel element (e) de rpd(1,*) correspond a la phase p
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
			if i ne 0 then p=p+dpdt*parameters.time.step 
			if p gt 2.*!pi then p=p-2.*!pi
			if p lt 0. then p=p+2.*!pi
;*********** et le nouveau e correspondant a p
			w=where(abs(rpd(1,*)-p) eq min(abs(rpd(1,*)-p)))
			e=w[0]
			if rpd(1,e) gt p then e=e-1
			if e eq -1 then e=3599
			b=p-rpd(1,e)
			r=(1.-b)*rpd(0,e)
			e=e+1

			if e eq 3600 then e=0
			r=r+b*rpd(0,e)
;***********

;*********** on passe de la phase a x et y (dans le plan de l orbite)
			y=r*sin(p)
			x=r*cos(p)
;*********** puis a r,t,p en utilisant (*orb).orbit_inclination  et (*orb).apoapsis_longitude
			rtp = XYZ_TO_RTP(transpose([[x],[y*cos((*obj).orbit_inclination*!dtor)],[y*sin((*obj).orbit_inclination*!dtor)]]))
			rtp(1) += (*obj).apoapsis_declination*!dtor*cos(rtp(2))
			rtp(2) -= (*obj).apoapsis_longitude*!dtor
;************
;*********** conversion rtp en xyz
			xyz(2)=rtp(0)*cos(rtp(1))
			xyz(0)=rtp(0)*sin(rtp(1))*cos(rtp(2))
			xyz(1)=rtp(0)*sin(rtp(1))*sin(rtp(2))
			traj_xyz[*,i]=xyz
			traj_rtp[*,i]=rtp
		endfor
	endelse

endif else begin


;*********** At eacg t step we have the value of the distance, longitude and inclination to the central body
	alpha=(*(obj)).initial_phase*!dtor
	c = sqrt((*(obj)).semi_major_axis(*)^2-(*(obj)).semi_minor_axis(*)^2)
	x = (*(obj)).semi_major_axis(*)*cos(alpha(*))+c
	y = (*(obj)).semi_minor_axis(*)*sin(alpha(*))
	z = fltarr(ns)

	r=sqrt(x^2+y^2+z^2)
	rp=shift(r,-1)
	corec=2.*abs(rp-r)/(rp+r)*360./2./!pi+1.
	rtp = XYZ_TO_RTP(transpose([[x],[y],[z]]))

	rtp[1,*]=!pi*0.5-(*(obj)).apoapsis_declination(*)*!dtor

	xyz=fltarr(3,ns)
	xyz(2,*)=rtp(0,*)*cos(rtp(1,*))
	xyz(0,*)=rtp(0,*)*sin(rtp(1,*))*cos(rtp(2,*))
	xyz(1,*)=rtp(0,*)*sin(rtp(1,*))*sin(rtp(2,*))
	traj_rtp[*,*]=rebin(rtp,3,ns)
	traj_xyz[*,*]=rebin(xyz,3,ns)
endelse
; ****************
help,*((*obj).parent),out=out
if n_elements(out) eq 2 then out=out[0]+out[1]
if ~total(STRMATCH(out,'*UNDEF*',/fold)) then begin
	pxyz=(*((*((*obj).parent)).trajectory_xyz))
endif else begin
	pxyz=0.
endelse

if tag_names(*obj,/str) eq 'BODY' then begin
	l=((*((*obj).lct))-(traj_rtp[2,*]-traj_rtp[2,0])/!pi*180.) mod 360.
	w=where(l lt 0) & if w[0] ne -1 then l[w]=360.+l[w]

	(*obj).lct=PTR_NEW(l)
endif

(*obj).trajectory_xyz=PTR_NEW(traj_xyz+pxyz)
traj_rtp=xyz_to_rtp(traj_xyz)
(*obj).trajectory_rtp=PTR_NEW(traj_rtp)


if tag_names(*obj,/str) eq 'OBSERVER' then begin
	if (*obj).predef then *((*obj).lg)=-(*obj).initial_phase $
		else *((*obj).lg)=fltarr(parameters.time.n_step)
endif


return
end

;************************************************************** CB_ORB
pro cb_orb,obj,parameters
t=fix(parameters.time.istep)
;*************
; si obs.predef = 1 alors on a déjà défini plus haut (init_orb) la longitude de l observer a chaque pas de temps
; reste juste le cas donc où observer.predef = 0, qui est comme avant 
;*************
if (*obj).predef eq 0 then (*((*obj).lg))[t]=((*((*obj).parent)).lg0+360.*parameters.time.time/(*((*obj).parent)).period-(*((*obj).trajectory_rtp))[2,t]*!radeg) mod 360.
if (*((*obj).lg))[t] lt 0. then (*((*obj).lg))[t]=360.+(*((*obj).lg))[t]
return
end

