;***********************************************************
;***                                                     ***
;***         SERPE V6.1                                  ***
;***                                                     ***
;***********************************************************
;***                                                     ***
;***       MODULE: SOURCE                                ***
;***                                                     ***
;***     function: LOSS_CONE; beaming d un cone de perte ***
;***     function: SHIELDING; ecrantage des sources      ***
;***     function: REFRACT; refraction des sources       *** /!\ -> a vérifier !!!!!!! /!\
;***     function: SHELL;                                ***
;***     INIT   [INIT_SRC]                               ***
;***     CALLBACK [CB_SRC]                               ***
;***                                                     ***
;***********************************************************

;************************************************************** SHIELDING
pro shielding,x,src,pol,dist,f,parameters,w 
;x: celui de cb_src
;src=obj src
;pol 0 nord 1 sud
;dist distance observateur
;f frequences
nobj=n_elements(parameters.objects)
nv=FIX(((*src).vmax-(*src).vmin)/(*src).vstep)+1
nlg=FIX(((*src).lgmax-(*src).lgmin)/(*src).lgstep)+1
nlat=FIX(((*src).latmax-(*src).latmin)/(*src).latstep)+1
n=nv*nlg*nlat
if (*((*((*src).parent)).parent)).motion then src_par=(*((*((*((*src).parent)).parent)).parent)).name else src_par=(*((*((*src).parent)).parent)).name

for i=0,nobj-1 do if TAG_NAMES(*(parameters.objects[i]),/str) eq 'BODY' then begin
	bd=(parameters.objects[i])

;x : vecteur de visee, et xb : distance source-body -> ca : projetee de la distance sur la ligne de visee
;puis ca = ca - xyz_bd = distance minimum entre ligne de visee et body
;rmin : norme de ca
	w=[-1]
	xyz_bd=rebin(reform((*((*src).parent)).rot#((*((*bd).trajectory_xyz))[*,parameters.time.istep]-(*((*src).parent)).pos_xyz),3,1,1),$
		3,parameters.freq.n_freq,nlg*nlat)-(*((*src).x))[*,*,*,pol]
	ca=rebin(reform(total(xyz_bd*x,1),1,parameters.freq.n_freq,nlg*nlat),3,parameters.freq.n_freq,nlg*nlat)*x
	tmp=sqrt(total(ca^2,1))
	w1=where(tmp gt dist)
	if w1[0] ne -1 then ca[*,w1]=ca[*,w1]/rebin(reform(tmp[w1],1,n_elements(w1)),3,n_elements(w1))*dist ;la ligne de visee s'arrete a l'observateur
	ca=ca-xyz_bd
	rmin=sqrt(total(ca^2,1))
	;cz=(xyz_bd[2]/x[2])*x-xyz_bd
	;zmin=abs(ca[2,*])
	;stop
	;body shielding ; on regarde si la distance (ca) est plus petite que le rayon du corps.
	if (*bd).name ne src_par then begin
		w0=where(rmin lt (*bd).radius)
		if w0[0] ne -1 then w=[w,w0]
	endif

	nd=n_elements(*(*bd).density)
	for j=0,nd-1 do begin
		ds=(*(*bd).density)[j]
		if (*ds).type eq 'stellar' then begin
			w2=where(9E-3*sqrt((*ds).rho0/rmin^2) ge f)
			if w2[0] ne -1 then w=[w,w2]
		endif
		if (*ds).type eq 'ionospheric' then begin
			w2=where(9E-3*sqrt((*ds).rho0*exp(-rmin/(*ds).height)) ge f)
			if w2[0] ne -1 then w=[w,w2]
		endif
	endfor
endif

if n_elements(w) gt 1 then w=w[1:*]
return
end

;************************************************************** REFRACT
function refrac,th,thz,gb,v,vp,hot,cosa,islc
; ****************************
; If it is SHELL, the effect at the output of the source has already been calculated in the SHELL function, since the n is calculated for the mode x, which leaves the source.
; In the case of losscone as in the constant case, it is necessary to calculate the effects of refraction here
; ****************************

if islc eq 0 then begin
	gam=1./sqrt(1.+(v^2+hot))
	n=gam*v/cosa/cos(th*!dtor) ; equation (10) Hess A&A (2017), ExPRES: a tool to simulate planetary and exoplanetary radio emissions
;************************
; If it is SHELL, the effect at the output of the source has already been calculated in the SHELL function, since the n is calculated for the mode x, which leaves the source.
; In the case of losscone as in the constant case, it is necessary to calculate the effects of refraction here
endif else n=1 
;************************

w1=where(~FINITE(th))
w2=where(th lt 0)
i=th*!dtor-gb*cos(thz) ; changement de referentiel
di=((i-0.5*!pi)>0) 
wi=where(di gt 0)
if wi[0] ne -1 then di[wi]=2.*di[wi]
;*********************************
; Modification CL - 28/05/15
; In order not to take into account the effects of reflection on the iso surface of the fce: let + di
; To take them into account, remove it
;*********************************
; Without the effects of reflection :
;th=(gb*cos(thz)+asin(((n*sin(i))<1))+di)*!radeg
; With the effects of reflection :
th=(gb*cos(thz)+asin(((n*sin(i))<1)))*!radeg
;di=fltarr(n_elements(i))
;wi1=where(i gt !pi/2.)
;di[wi1]=!pi
;i[wi1]=-i[wi1]
;th[w2]=(gb[w2]*cos(thz[w2])+asin(((n[w2]*sin(i+di)))))*!radeg

;*********************************

w=where(~FINITE(n))
w3=where(~FINITE(th))
;----- valeur de -1.0e+31 pour etre en adequation avec les CDF crees a la sortie -----
if w[0] ne -1 then th[w]=-1.0e+31
if w1[0] ne -1 then th[w1]=-1.0e+31
if w2[0] ne -1 then th[w2]=-1.0e+31
if w3[0] ne -1 then th[w3]=-1.0e+31



return,th
end

;************************************************************** LOSS_CONE
function Loss_cone,v,vp,temp,cosa,error
; Analytically calculates beaming for loss-cone
v=double(v)
vp=double(vp);=wp^2/wc^2 
vh2=v^2+temp
un=double(1)
deux=double(2)
half=double(0.5)
cosa=double(cosa)

;****************************************
gam=1./sqrt(1.+vh2) ; The + sign here gives a better approximation in the calculation of the khi than the DL at the order 1 of the "official" gamma
khi2=(gam*v/cosa)^2 ; With the gamma above, we have the right ratio w_c /w

s=un-deux*vp/vh2 
p=un-vp/(1.+half*v^2) 
d=vp*deux*(1-v^2)/vh2 

a=(p*(s^2-d^2)-khi2*(p*s-s^2+d^2))
b=-(khi2^2*(p-s)-khi2*(p*s+s^2-d^2))
c=s*khi2^2

d=acos(sqrt(khi2))*!radeg
f=acos(sqrt((b+sqrt(abs(b^2-4.*a*c)))/(2.*a)))*!radeg

rt=-1.0e+31+dblarr(n_elements(d[*,0]),n_elements(d[0,*]))
w1=where(FINITE(d)and FINITE(f) and ((b^2-4.*a*c)/b^2 ge (-0.0001)) and (sqrt(khi2)/cos(f*!dtor) lt 1.001) and (s gt 0))
;  tolerance sur les erreurs d arrondi

if (w1(0) ne -1) then begin
	w2=where(f(w1) le d(w1))
	if (w2(0) ne -1) then begin
		rt(w1(w2))=f(w1(w2))
	endif
endif
error=where(rt lt 0.)

return,rt
end


;************************************************************** SHELL
;********************************
; Comments CL - 22/05/15
; If we are in a cavity, we must leave the calculation of the n here
; If we are not in a cavity, we must leave theta = 90 ° here, and calculate n in refract
; Thus add a key word to choose if we want a cavity in the SHELL or not
;********************************
function shell,v,vp,hot,cold,error

;Calcule analytiquement le beaming pour le shell
v=double(v)
vp=double(vp)*sqrt(cold/(hot+v^2));=wp^2/wc^2 ; equation (17) - Hess A&A (2017), ExPRES: a tool to simulate planetary and exoplanetary radio emissions
un=double(1)
vh=hot
n2=un-vp*(un-vp)/(vh-vp) ; equation (18) - Hess A&A (2017), ExPRES: a tool to simulate planetary and exoplanetary radio emissions

rt=asin(sqrt(n2))*!radeg
error=where((vh-vp) le vp*(un-vp))
return,rt
end

;************************************************************** INIT_SRC
pro init_src,obj,parameters
nv=FIX(((*obj).vmax-(*obj).vmin)/(*obj).vstep)+1
nlg=FIX((*obj).lgnbr)
nlat=FIX(((*obj).latmax-(*obj).latmin)/(*obj).latstep)+1
n=nv*nlg*nlat
(*obj).nsrc=n
(*((*obj).lg))=rebin(reform(findgen(nlg)*(*obj).lgstep+(*obj).lgmin,1,nlg,1),nv,nlg,nlat)
(*((*obj).v))=rebin(reform(findgen(nv)*(*obj).vstep+(*obj).vmin,nv,1,1),nv,nlg,nlat)+(*obj).lgtov*((*((*obj).lg))-min(*((*obj).lg)))
(*((*obj).lat))=rebin(reform(findgen(nlat)*(*obj).latstep+(*obj).latmin,1,1,nlat),nv,nlg,nlat)
*((*obj).spdyn)=bytarr(parameters.freq.n_freq,(*obj).nsrc,2)
*((*obj).th)=dblarr(parameters.freq.n_freq,(*obj).nsrc,2)
(*((*obj).azimuth))=dblarr(parameters.freq.n_freq,(*obj).nsrc,2)
*((*obj).fp)=dblarr(parameters.freq.n_freq,(*obj).nsrc,2)
*((*obj).f)=dblarr(parameters.freq.n_freq,(*obj).nsrc,2)
*((*obj).fmax)=dblarr((*obj).nsrc,2)
*((*obj).fmaxCMI)=dblarr((*obj).nsrc,2)
*((*obj).x)=fltarr(3,parameters.freq.n_freq,(*obj).nsrc,2)
return
end

;************************************************************** CB_SRC
pro cb_src,obj,parameters
(*((*obj).spdyn))[*,*,*]=0
nobj=n_elements(parameters.objects)
for i=0,nobj-1 do if TAG_NAMES(*(parameters.objects[i]),/str) eq 'OBSERVER' then obs=(*(parameters.objects[i]))
t=parameters.time.istep

;nombre de vitesses, de longitudes et de latitude et nombre total de sources
nv=FIX(((*obj).vmax-(*obj).vmin)/(*obj).vstep)+1
nlg=FIX((*obj).lgnbr)
nlat=FIX(((*obj).latmax-(*obj).latmin)/(*obj).latstep)+1
n=nv*nlg*nlat
; We turn the direction of the observer and not the sources: it is shorter
if (obs.predef eq 1) then xyz_obs=rebin((*obs.trajectory_xyz)(*,t),3,parameters.freq.n_freq,nlg*nlat) else $
xyz_obs=rebin(reform((*((*obj).parent)).rot#((*obs.trajectory_xyz)[*,t]-(*((*obj).parent)).pos_xyz),3,1,1), $
	3,parameters.freq.n_freq,nlg*nlat)
	
;************** Calcul auto du lead angle pour Io *******
if ((*obj).lgauto eq "on") then begin
	(*((*obj).lg))[0,*,*]=calc_lag((*obj).north,(*((*obj).parent)).lg,satellite=(*(*(*obj).parent).parent).name)
	i=1
	while (i lt nlg) do begin
		if i eq 1 then (*((*obj).lg))[0,1,*]=(*((*obj).lg))[0,1,*]-4.
		if i eq 2 then (*((*obj).lg))[0,2,*]=(*((*obj).lg))[0,2,*]-14.
		i=i+1
	endwhile
endif
if ((*obj).lgauto eq "on-3") then begin
	(*((*obj).lg))[0,*,*]=calc_lag((*obj).north,(*((*obj).parent)).lg,satellite=(*(*(*obj).parent).parent).name)-3.
endif
if ((*obj).lgauto eq "on+3") then begin
	(*((*obj).lg))[0,*,*]=calc_lag((*obj).north,(*((*obj).parent)).lg,satellite=(*(*(*obj).parent).parent).name)+3.
endif
;********************************************************

lg=reform((*((*obj).lg))[0,*,*]+(*((*obj).parent)).lg,nlg*nlat)
lg=(lg+360.) mod 360.
lg0=fix(lg) & lg1=(lg0+1) mod 360 & c=lg-lg0  & lgc=lg0*0.
wlg=where (abs((*((*obj).parent)).longitude[lg0]-(*((*obj).parent)).longitude[lg1]) gt 10) 
if wlg[0] ne -1 then lgc[wlg]=360
lg=((*((*obj).parent)).longitude[lg0]*(1.-c)+c*(lgc+(*((*obj).parent)).longitude[lg1])) mod 360
lat=reform((*((*obj).lat))[0,*,*]+(*((*obj).parent)).latitude[lg]-(*((*obj).parent)).loffset,nlg*nlat)

; **** Calcul des coefficients d interpolation ***
coef=fltarr(nlg*nlat,4)
a=lg-fix(lg)
b=lat-fix(lat)
coef[*,0]=(1.-a)*(1.-b)
coef[*,1]=(1.-a)*b
coef[*,2]=a*(1.-b)
coef[*,3]=a*b
coef=reform(rebin(reform(coef,1,1,nlg,nlat,4),3,parameters.freq.n_freq,nlg,nlat,4),3,parameters.freq.n_freq,nlg*nlat,4)

b=fltarr(3,parameters.freq.n_freq,nlg*nlat)		 ;vecteur champ unitaire
bz=fltarr(3,parameters.freq.n_freq,nlg*nlat)	 ;vecteur direction normale au L-shell
x=fltarr(3,parameters.freq.n_freq,nlg*nlat)		;position
d=fltarr(parameters.freq.n_freq,nlg*nlat)		;densite = wp^2/wc^2
gb=fltarr(parameters.freq.n_freq,nlg*nlat)		;gradient angle
f=fltarr(nlg*nlat);frequence max
fCMI=fltarr(nlg*nlat);frequence max avec condition CMI wp/wc<0.1
if (*obj).north then begin ; Magnetic north pole
	var=0
	for i=0,3 do begin
		lg2=((fix(lg)+fix(0.5*i)) mod 360)
		lat2=(fix(lat)+ (i mod 2))<((*((*obj).parent)).nlat-1)
		b=b+(*((*((*obj).parent)).b_n))[*,*,lg2,lat2]*coef[*,*,*,i]
		bz=bz+(*((*((*obj).parent)).bz_n))[*,*,lg2,lat2]*coef[*,*,*,i]
		x=x+(*((*((*obj).parent)).x_n))[*,*,lg2,lat2]*coef[*,*,*,i]
		d=d+(*((*((*obj).parent)).dens_n))[*,lg2,lat2]*coef[0,*,*,i]
		gb=gb+(*((*((*obj).parent)).gb_n))[*,lg2,lat2]*coef[0,*,*,i]
		f=f+(*((*((*obj).parent)).fmax))[var,lg2,lat2]*coef[0,0,*,i]
		fCMI=fCMI+(*((*((*obj).parent)).fmaxCMI))[var,lg2,lat2]*coef[0,0,*,i]
	endfor
endif else begin if (*obj).south then begin				; Magnetic south pole
	var=1
	for i=0,3 do begin
		lg2=((fix(lg)+fix(0.5*i)) mod 360)
		lat2=(fix(lat)+ (i mod 2))<((*((*obj).parent)).nlat-1)
		b=b-(*((*((*obj).parent)).b_s))[*,*,lg2,lat2]*coef[*,*,*,i]
		bz=bz+(*((*((*obj).parent)).bz_s))[*,*,lg2,lat2]*coef[*,*,*,i]
		x=x+(*((*((*obj).parent)).x_s))[*,*,lg2,lat2]*coef[*,*,*,i]
		d=d+(*((*((*obj).parent)).dens_s))[*,lg2,lat2]*coef[0,*,*,i]
		gb=gb+(*((*((*obj).parent)).gb_s))[*,lg2,lat2]*coef[0,*,*,i]
		f=f+(*((*((*obj).parent)).fmax))[var,lg2,lat2]*coef[0,0,*,i]
		fCMI=fCMI+(*((*((*obj).parent)).fmaxCMI))[var,lg2,lat2]*coef[0,0,*,i]
	endfor
endif
endelse
coef=0b

(*(*obj).fmax)[*,var]=f
(*(*obj).fmaxCMI)[*,var]=fCMI
; *** positions des sources sauvegardees pour les animations ***
(*((*obj).x))[*,*,*,var]=reform(rebin(reform(x,3,parameters.freq.n_freq,nlg*nlat,1),3,parameters.freq.n_freq,nlg*nlat,nv),$
		3,parameters.freq.n_freq,nlg*nlat*nv)

;**** Calculation of the line of sight vector
; Vector of the distance between the observer and the source
x=xyz_obs-x 
; *** distance observateur-source ***
dist=rebin(reform(sqrt(total(x^2,1)),1,parameters.freq.n_freq,nlg*nlat),3,parameters.freq.n_freq,nlg*nlat) 
; *** normalisation du vecteur distance par la distance ***
x=x/dist 
;**** th : angle entre la ligne de champ b et la direction de l observateur ***
th=reform(rebin(reform(acos(total(x*b,1)),parameters.freq.n_freq,1,nlg*nlat),parameters.freq.n_freq,nv,nlg*nlat),parameters.freq.n_freq,nv*nlg*nlat)


xy=x*(1.-b*rebin(reform(cos(th),1,parameters.freq.n_freq,nv*nlg*nlat),3,parameters.freq.n_freq,nv*nlg*nlat))
;**** b*cos(th) -> Projection of the unit field vector onto the line of sight of the observer
;**** xy : Distance from the projected unit vector field to the observer.
;**** x-b*cos(th)would be enough (it is the distance). But since x is normalized, then x(1-b*cos(th)) is not false


b=0b

dist2=rebin(reform(sqrt(total(xy^2,1)),1,parameters.freq.n_freq,nlg*nlat),3,parameters.freq.n_freq,nlg*nlat)
xy=xy/dist2
dist2=0b

;**** thz is the azimuth angle for non-axisymetric cones
thz=reform(rebin(reform(acos(total(xy*bz,1)),parameters.freq.n_freq,1,nlg*nlat),parameters.freq.n_freq,nv,nlg*nlat),parameters.freq.n_freq,nv*nlg*nlat)
 

bz=0b
xy=0b


d=rebin(reform(d,parameters.freq.n_freq,nlg*nlat),parameters.freq.n_freq,nv*nlg*nlat)
 	; *** f = w_ce/w_ce_max ***
f=rebin(reform(*(parameters.freq.freq_tab),parameters.freq.n_freq,1,1),parameters.freq.n_freq,nv*nlg*nlat)/$
reform(rebin(reform(f,1,1,nlg*nlat),parameters.freq.n_freq,nv,nlg*nlat),parameters.freq.n_freq,nv*nlg*nlat)
	; *** w2=pas d emissions selon le type de sources ***
w2=[-1]
if (*obj).lossbornes ne 0 then begin 
	w2inf=[-1]
	w2sup=[-1]
endif

; ****** ici d=wp^2/wc^2 ***
if (*obj).loss ne 0 then th2=Loss_cone(rebin(reform((*((*obj).v)),1,nv*nlg*nlat),parameters.freq.n_freq,nv*nlg*nlat),d,(*obj).temp,sqrt(1.-f),w2)
if (*obj).cavity ne 0 then th2=shell(rebin(reform((*((*obj).v)),1,nv*nlg*nlat),parameters.freq.n_freq,nv*nlg*nlat),d,(*obj).temp,(*obj).cold,w2)
if (*obj).constant ne 0 then th2=(*obj).constant
if (*obj).ring ne 0 then th2=90.

; *************
; rampe a tester
; *************
if (*obj).rampe ne 0 then th2=f*((*obj).constant-(*obj).asymp)+(*obj).asymp 
; *************



if (*obj).lossbornes ne 0 then begin 
	th2sup=Loss_cone(rebin(reform((*((*obj).v)),1,nv*nlg*nlat),parameters.freq.n_freq,nv*nlg*nlat),d,(*obj).temp,sqrt(1.-f),w2sup)+10.
	wsup=where(th2sup ge 90.)
	th2sup(wsup)=89.9
	th2inf=Loss_cone(rebin(reform((*((*obj).v)),1,nv*nlg*nlat),parameters.freq.n_freq,nv*nlg*nlat),d,(*obj).temp,sqrt(1.-f),w2inf)-10.
endif


if (*obj).refract then $
th2=refrac(th2,thz,gb,rebin(reform((*((*obj).v)),1,nv*nlg*nlat),parameters.freq.n_freq,nv*nlg*nlat),d,(*obj).temp,sqrt(1.-f),(*obj).cavity)

th=(th2-th*!radeg)/(((*obj).width)/2.)

; **** refract borne inf et sup ***
if (*obj).lossbornes ne 0 then begin 
	if (*obj).refract then $
	th2inf=refrac(th2inf,thz,gb,rebin(reform((*((*obj).v)),1,nv*nlg*nlat),parameters.freq.n_freq,nv*nlg*nlat),d,(*obj).temp,sqrt(1.-f),(*obj).cavity)
	thinf=(th2inf-th*!radeg)/(((*obj).width)/2.)
	if (*obj).refract then $
	th2sup=refrac(th2sup,thz,gb,rebin(reform((*((*obj).v)),1,nv*nlg*nlat),parameters.freq.n_freq,nv*nlg*nlat),d,(*obj).temp,sqrt(1.-f),(*obj).cavity)
	thsup=(th2sup-th*!radeg)/(((*obj).width)/2.)
endif

if w2[0] ne -1 then th[w2]=1000.
if (*obj).lossbornes ne 0 then begin
	if w2sup[0] ne -1 then thsup[w2sup]=1000.
	if w2inf[0] ne -1 then thinf[w2inf]=1000.
endif


;**** Th is already the difference between the angle of emission and the angle of observation
;**** We interpolate here for cases where th changes very quickly (e.g. ionosphere)
th[0:parameters.freq.n_freq-2,*]=(abs(0.5*(th[0:parameters.freq.n_freq-2,*]+th[1:parameters.freq.n_freq-1,*]))<abs(th[0:parameters.freq.n_freq-2,*]))
th[parameters.freq.n_freq-1,*]=abs(th[parameters.freq.n_freq-1,*])


if (*obj).lossbornes ne 0 then begin
	thsup[0:parameters.freq.n_freq-2,*]=(abs(0.5*(th[0:parameters.freq.n_freq-2,*]+thsup[1:parameters.freq.n_freq-1,*]))<abs(thsup[0:parameters.freq.n_freq-2,*]))
	thsup[parameters.freq.n_freq-1,*]=abs(thsup[parameters.freq.n_freq-1,*])

	thinf[0:parameters.freq.n_freq-2,*]=(abs(0.5*(thinf[0:parameters.freq.n_freq-2,*]+thinf[1:parameters.freq.n_freq-1,*]))<abs(thinf[0:parameters.freq.n_freq-2,*]))
	thinf[parameters.freq.n_freq-1,*]=abs(thinf[parameters.freq.n_freq-1,*])
endif


w=where(th ge 1.,compl=w2)
if w[0] ne -1 then th[w]=0
if w2[0] ne -1 then th[w2]=1

if (*obj).lossbornes ne 0 then begin 
	wsup=where(thsup ge 1.,compl=w2sup)
	if wsup[0] ne -1 then thsup[wsup]=0
	if w2sup[0] ne -1 then thsup[w2sup]=1

	winf=where(thinf ge 1.,compl=w2inf)
	if winf[0] ne -1 then thinf[winf]=0
	if w2inf[0] ne -1 then thinf[w2inf]=1
endif
; shielding,x,obj,var,dist,rebin(reform((*((*obj).v)),1,nv*nlg*nlat),parameters.freq.n_freq,nv*nlg*nlat),parameters,w3 ;faux c est pas v ici!!
; a la place de v, il faut que ca soit la frequence (fce), afin de comparer cette frequence a la frequence plasma dans shielding
;if w3[0] ne -1 then th[w3]=0
x=0b

if (*obj).lossbornes ne 0 then begin
	spdynsup=(*((*obj).spdyn))[*,*,*]
	spdyninf=(*((*obj).spdyn))[*,*,*]
	
	spdynsup[*,*,var]=reform(thsup,parameters.freq.n_freq,nv*nlg*nlat,1)
	spdyninf[*,*,var]=reform(thinf,parameters.freq.n_freq,nv*nlg*nlat,1)
endif

; ***** intensite *****
(*((*obj).spdyn))[*,*,var]=reform(th,parameters.freq.n_freq,nv*nlg*nlat,1)
;***** valeur de theta *****
thfin=th*th2
w00=where(thfin le 0.)
thfin(w00)=-1.0e+31
(*((*obj).th))[*,*,var]=reform(thfin,parameters.freq.n_freq,nv*nlg*nlat,1)
fp=sqrt(d)
for i=0,n_elements(fp(0,*))-1 do fp(*,i)=fp(*,i)*(*parameters.freq.freq_tab)
(*((*obj).fp))[*,*,var]=reform(fp,parameters.freq.n_freq,nv*nlg*nlat,1)
fem=transpose(sqrt(1-(rebin(reform(*(*obj).v),n_elements(reform(*(*obj).v)),parameters.freq.n_freq))^2))
for i=0,n_elements(f(0,*))-1 do fem(*,i)=fem(*,i)*(*parameters.freq.freq_tab)

(*((*obj).f))[*,*,var]=reform(fem,parameters.freq.n_freq,nv*nlg*nlat,1)
(*((*obj).azimuth))[*,*,var]=reform(thz,parameters.freq.n_freq,nv*nlg*nlat,1)

for k=0,nv*nlg*nlat-1 do begin
	w0=where(f[*,k] gt 1)
	if w0[0] ne -1 then (*((*obj).spdyn))[w0,k,var]=0

	if (*obj).lossbornes ne 0 then begin
		w0sup=where(f[*,k] gt 1)
		if w0sup[0] ne -1 then spdynsup[w0,k,var]=0

		w0inf=where(f[*,k] gt 1)
		if w0inf[0] ne -1 then spdyninf[w0,k,var]=0
	endif
	
endfor

; **** condition sur les gradient ****
if abs((*obj).grad_eq) then begin
	w0=where(rebin(reform(fix(abs((*((*((*obj).parent)).grad_b_eq))[var,lg,lat]+0.5*(*obj).grad_eq)),nlg*nlat),nv*nlg*nlat) gt 0.9)
	if w0[0] ne -1 then (*((*obj).spdyn))[*,w0,var]=0.
endif
if abs((*obj).grad_in) then begin
	w0=where(rebin(reform(fix(abs((*((*((*obj).parent)).grad_b_in))[var,lg,lat]+0.5*(*obj).grad_in)),nlg*nlat),nv*nlg*nlat) gt 0.9)
	if w0[0] ne -1 then (*((*obj).spdyn))[*,w0,var]=0.
endif

;*********************************
;sauvegarde pour fichier out.sav
;*********************************

nsrc=0
bornes='off'
for i=0,nobj-1 do if TAG_NAMES(*(parameters.objects[i]),/str) eq 'SOURCE' then begin
		nsrc=nsrc+1
		if (*(parameters.objects)[i]).lossbornes then begin
			nsrc=nsrc+2
			bornes='on'
	endif
endif
srcstep=float(strsplit((*obj).name,'Source',/EXTRACT))
for i=0,nobj-1 do if TAG_NAMES(*(parameters.objects[i]),/str) eq 'SPDYN' then spdyn=*(parameters.objects[i])

if bornes eq 'off' then begin
(*(*spdyn.out)[srcstep[0]-1])[t,*,*]=th2*(*((*obj).spdyn))[*,*,var]
(*(*spdyn.out)[srcstep[0]-1+nsrc])[t,*,*]=thz*(*((*obj).spdyn))[*,*,var]
(*(*spdyn.out)[srcstep[0]-1+nsrc*2])[t,*]=lg
endif else begin

	(*(*spdyn.out)[srcstep[0]-1])[t,*,*]=th2*(*((*obj).spdyn))[*,*,var]
	(*(*spdyn.out)[srcstep[0]-1+nsrc])[t,*,*]=thz*(*((*obj).spdyn))[*,*,var]
	(*(*spdyn.out)[srcstep[0]-1+nsrc*2])[t,*]=lg

	(*(*spdyn.out)[srcstep[0]-1+3])[t,*,*]=th2inf*spdyninf[*,*,var]
	(*(*spdyn.out)[srcstep[0]-1+3+nsrc])[t,*,*]=thz*spdyninf[*,*,var]
	(*(*spdyn.out)[srcstep[0]-1+3+nsrc*2])[t,*]=lg

	(*(*spdyn.out)[srcstep[0]-1+6])[t,*,*]=th2sup*spdynsup[*,*,var]
	(*(*spdyn.out)[srcstep[0]-1+6+nsrc])[t,*,*]=thz*spdynsup[*,*,var]
	(*(*spdyn.out)[srcstep[0]-1+6+nsrc*2])[t,*]=lg
endelse

;*********************************
return
end
