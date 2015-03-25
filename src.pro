;***********************************************************
;***                                                     ***
;***         SERPE V6.0                                  ***
;***                                                     ***
;***********************************************************
;***                                                     ***
;***       MODULE: SOURCE                                ***
;***                                                     ***
;***     function: LOSS_CONE; beaming d'un cone de perte ***
;***     function: SHIELDING; ecrantage des sources      ***
;***     function: REFRACT; refraction des sources       ***
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
	;body shielding
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
if islc ne 0 then begin
	gam=1./sqrt(1.+(v^2+hot))
	n=gam*v/cosa/cos(th*!dtor)
endif else n=1

w1=where(~FINITE(th))
w2=where(th lt 0)
i=th*!dtor-gb*cos(thz)

;reflexion a verifier
;eps=1-(0.5*v^2-vp)/3.
;i=(asin((sin((((i-0.5*!pi)>0)+0.5*!pi))/eps)<1))*2.-!pi+i  
di=((i-0.5*!pi)>0)
wi=where(di gt 0)
if wi[0] ne -1 then di[wi]=2.*di[wi]

th=(gb*cos(thz)+asin(((n*sin(i))<1))+di)*!radeg
w=where(~FINITE(n))
w3=where(~FINITE(th))
if w[0] ne -1 then th[w]=-1000.
if w1[0] ne -1 then th[w1]=-1000.
if w2[0] ne -1 then th[w2]=-1000.
if w3[0] ne -1 then th[w3]=-1000.

;if islc eq -10 then begin
;if (total(th[0:65]) >0) then begin
;if (parameters.time.time  gt 25) then begin
;save,filename="tmp.sav"
;stop
;endif

return,th
end

;************************************************************** LOSS_CONE
function Loss_cone,v,vp,temp,cosa,error
;Calcule analytiquement le beaming pour le loss-cone
v=double(v)
vp=double(vp);=wp^2/wc^2
vh2=v^2+temp
un=double(1)
deux=double(2)
half=double(0.5)
cosa=double(cosa)


gam=1./sqrt(1.+vh2)
khi2=(gam*v/cosa) ^2
s=un-deux*vp/vh2
p=un-vp/(1.+half*v^2)
d=vp*deux*(1-v^2)/vh2

a=(p*(s^2-d^2)-khi2*(p*s-s^2+d^2))
b=-(khi2^2*(p-s)-khi2*(p*s+s^2-d^2))
c=s*khi2^2

d=acos(sqrt(khi2))*!radeg
f=acos(sqrt((b+sqrt(abs(b^2-4.*a*c)))/(2.*a)))*!radeg


rt=-1000+fltarr(n_elements(d[*,0]),n_elements(d[0,*]))
w1=where(FINITE(d)and FINITE(f) and ((b^2-4.*a*c)/b^2 ge (-0.0001)) and (sqrt(khi2)/cos(f*!dtor) lt 1.001) and (s gt 0))
;      on est tolerant avec les erreurs d'arrondi ^^^
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
function shell,v,vp,hot,cold,error
;Calcule analytiquement le beaming pour le shell
v=double(v)
vp=double(vp)*sqrt(cold/(hot+v^2));=wp^2/wc^2
un=double(1)
vh=hot
n2=un-vp*(un-vp)/(vh-vp)
rt=asin(sqrt(n2))*!radeg

error=where((vh-vp) le vp*(un-vp))
return,rt
end

;************************************************************** INIT_SRC
pro init_src,obj,parameters
nv=FIX(((*obj).vmax-(*obj).vmin)/(*obj).vstep)+1
nlg=FIX(((*obj).lgmax-(*obj).lgmin)/(*obj).lgstep)+1
nlat=FIX(((*obj).latmax-(*obj).latmin)/(*obj).latstep)+1
n=nv*nlg*nlat
(*obj).nsrc=n
(*((*obj).lg))=rebin(reform(findgen(nlg)*(*obj).lgstep+(*obj).lgmin,1,nlg,1),nv,nlg,nlat)
(*((*obj).v))=rebin(reform(findgen(nv)*(*obj).vstep+(*obj).vmin,nv,1,1),nv,nlg,nlat)+(*obj).lgtov*((*((*obj).lg))-min(*((*obj).lg)))
(*((*obj).lat))=rebin(reform(findgen(nlat)*(*obj).latstep+(*obj).latmin,1,1,nlat),nv,nlg,nlat)
*((*obj).spdyn)=bytarr(parameters.freq.n_freq,(*obj).nsrc,2)
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
nlg=FIX(((*obj).lgmax-(*obj).lgmin)/(*obj).lgstep)+1
nlat=FIX(((*obj).latmax-(*obj).latmin)/(*obj).latstep)+1
n=nv*nlg*nlat
; on tourne la direction de l'observateur et pas les sources: c'est moins long
xyz_obs=rebin(reform((*((*obj).parent)).rot#((*obs.trajectory_xyz)[*,t]-(*((*obj).parent)).pos_xyz),3,1,1),$
	3,parameters.freq.n_freq,nlg*nlat)

; Calcul des coefficients d'interpolation
coef=fltarr(nlg*nlat,4)
lg=reform((*((*obj).lg))[0,*,*]+(*((*obj).parent)).lg,nlg*nlat)
lg=lg mod 360.
lg0=fix(lg) & lg1=(lg0+1) mod 360 & c=lg-lg0  & lgc=lg0*0.
wlg=where (abs((*((*obj).parent)).longitude[lg0]-(*((*obj).parent)).longitude[lg1]) gt 10) 
if wlg[0] ne -1 then lgc[wlg]=360
lg=((*((*obj).parent)).longitude[lg0]*(1.-c)+c*(lgc+(*((*obj).parent)).longitude[lg1])) mod 360
lat=reform((*((*obj).lat))[0,*,*]+(*((*obj).parent)).latitude[lg]-(*((*obj).parent)).loffset,nlg*nlat)
a=lg-fix(lg)
b=lat-fix(lat)
coef[*,0]=(1.-a)*(1.-b)
coef[*,1]=(1.-a)*b
coef[*,2]=a*(1.-b)
coef[*,3]=a*b
coef=reform(rebin(reform(coef,1,1,nlg,nlat,4),3,parameters.freq.n_freq,nlg,nlat,4),3,parameters.freq.n_freq,nlg*nlat,4)

; pole nord magnetique
if (*obj).north then begin
	b=fltarr(3,parameters.freq.n_freq,nlg*nlat);vecteur champ unitaire
	bz=fltarr(3,parameters.freq.n_freq,nlg*nlat);vecteur direction normale au L-shell
	x=fltarr(3,parameters.freq.n_freq,nlg*nlat);position
	d=fltarr(parameters.freq.n_freq,nlg*nlat);densite
	gb=fltarr(parameters.freq.n_freq,nlg*nlat);gradient angle
	f=fltarr(nlg*nlat);frequence max
	for i=0,3 do begin
		lg2=((fix(lg)+fix(0.5*i)) mod 360)
		lat2=(fix(lat)+ (i mod 2))<((*((*obj).parent)).nlat-1)
		b=b+(*((*((*obj).parent)).b_n))[*,*,lg2,lat2]*coef[*,*,*,i]
		bz=bz+(*((*((*obj).parent)).bz_n))[*,*,lg2,lat2]*coef[*,*,*,i]
		x=x+(*((*((*obj).parent)).x_n))[*,*,lg2,lat2]*coef[*,*,*,i]
		d=d+(*((*((*obj).parent)).dens_n))[*,lg2,lat2]*coef[0,*,*,i]
		gb=gb+(*((*((*obj).parent)).gb_n))[*,lg2,lat2]*coef[0,*,*,i]
		f=f+(*((*((*obj).parent)).fmax))[0,lg2,lat2]*coef[0,0,*,i]
	endfor


	(*((*obj).x))[*,*,*,0]=reform(rebin(reform(x,3,parameters.freq.n_freq,nlg*nlat,1),3,parameters.freq.n_freq,nlg*nlat,nv),$
		3,parameters.freq.n_freq,nlg*nlat*nv);positions des ources sauvegardees pour les animations

;on calcule le vecteur ligne de visee
	x=xyz_obs-x
	dist=rebin(reform(sqrt(total(x^2,1)),1,parameters.freq.n_freq,nlg*nlat),3,parameters.freq.n_freq,nlg*nlat)
	x=x/dist
	th=reform(rebin(reform(acos(total(x*b,1)),parameters.freq.n_freq,1,nlg*nlat),parameters.freq.n_freq,nv,nlg*nlat),parameters.freq.n_freq,nv*nlg*nlat)
	xy=x*(1.-b*rebin(reform(cos(th),1,parameters.freq.n_freq,nv*nlg*nlat),3,parameters.freq.n_freq,nv*nlg*nlat))
	b=0b

	dist2=rebin(reform(sqrt(total(xy^2,1)),1,parameters.freq.n_freq,nlg*nlat),3,parameters.freq.n_freq,nlg*nlat)
	xy=xy/dist2
	dist2=0b
	thz=reform(rebin(reform(acos(total(xy*bz,1)),parameters.freq.n_freq,1,nlg*nlat),parameters.freq.n_freq,nv,nlg*nlat),parameters.freq.n_freq,nv*nlg*nlat)
	bz=0b;thz est l'angle azimuthal pour les cones non axisymmetriques
	xy=0b

	d=rebin(reform(d,parameters.freq.n_freq,nlg*nlat),parameters.freq.n_freq,nv*nlg*nlat)
	f=rebin(reform(*(parameters.freq.freq_tab),parameters.freq.n_freq,1,1),parameters.freq.n_freq,nv*nlg*nlat)/$
	reform(rebin(reform(f,1,1,nlg*nlat),parameters.freq.n_freq,nv,nlg*nlat),parameters.freq.n_freq,nv*nlg*nlat)


	w2=[-1];w2=pas d'emissions selon le type de sources
	if (*obj).loss ne 0 then th2=Loss_cone(rebin(reform((*((*obj).v)),1,nv*nlg*nlat),parameters.freq.n_freq,nv*nlg*nlat),d,(*obj).temp,sqrt(1.-f),w2)
	if (*obj).cavity ne 0 then th2=shell(rebin(reform((*((*obj).v)),1,nv*nlg*nlat),parameters.freq.n_freq,nv*nlg*nlat),d,(*obj).temp,(*obj).cold,w2)
	if (*obj).constant ne 0 then th2=(*obj).constant
	if (*obj).rampe ne 0 then th2=f*((*obj).constant-(*obj).asymp)+(*obj).asymp

;if (parameters.time.time  gt 24) then ccx=-10
;refraction outside the source
	th2=refrac(th2,thz,gb,rebin(reform((*((*obj).v)),1,nv*nlg*nlat),parameters.freq.n_freq,nv*nlg*nlat),d,(*obj).temp,sqrt(1.-f),(*obj).loss)
	th=((th2-th*!radeg)/(*obj).width)

	if w2[0] ne -1 then th[w2]=1000.

;th est deja la difference entre l'angle d'emission et l'angle d'observation
;on interpole ici pour les cas ou th change tres vite (ionosphere par exemple)
	th[0:parameters.freq.n_freq-2,*]=(abs(0.5*(th[0:parameters.freq.n_freq-2,*]+th[1:parameters.freq.n_freq-1,*]))<abs(th[0:parameters.freq.n_freq-2,*]))
	th[parameters.freq.n_freq-1,*]=abs(th[parameters.freq.n_freq-1,*])

	w=where(th ge 1.,compl=w2)
	if w[0] ne -1 then th[w]=0
	if w2[0] ne -1 then th[w2]=1


	shielding,x,obj,0,dist,rebin(reform((*((*obj).v)),1,nv*nlg*nlat),parameters.freq.n_freq,nv*nlg*nlat),parameters,w3;;faux c'est pas v ici!!
	if w3[0] ne -1 then th[w3]=0
	x=0b

	(*((*obj).spdyn))[*,*,0]=reform(th,parameters.freq.n_freq,nv*nlg*nlat,1)
	for k=0,nv*nlg*nlat-1 do begin
		w0=where(f[*,k] gt 1)
		if w0[0] ne -1 then (*((*obj).spdyn))[w0,k,0]=0.
	endfor

;condition sur les gradient
	if abs((*obj).grad_eq) then begin
		w0=where(rebin(reform(fix(abs((*((*((*obj).parent)).grad_b_eq))[0,lg,lat]+0.5*(*obj).grad_eq)),nlg*nlat),nv*nlg*nlat) gt 0.9)
		if w0[0] ne -1 then (*((*obj).spdyn))[*,w0,0]=0.
	endif
	if abs((*obj).grad_in) then begin
		w0=where(rebin(reform(fix(abs((*((*((*obj).parent)).grad_b_in))[0,lg,lat]+0.5*(*obj).grad_in)),nlg*nlat),nv*nlg*nlat) gt 0.9)
		if w0[0] ne -1 then (*((*obj).spdyn))[*,w0,0]=0.
	endif
endif

;***************************************************************************************************************************

if (*obj).south then begin
	b=fltarr(3,parameters.freq.n_freq,nlg*nlat)
	bz=fltarr(3,parameters.freq.n_freq,nlg*nlat);vecteur direction normale au L-shell
	x=fltarr(3,parameters.freq.n_freq,nlg*nlat)
	d=fltarr(parameters.freq.n_freq,nlg*nlat)
	gb=fltarr(parameters.freq.n_freq,nlg*nlat);gradient angle
	f=fltarr(nlg*nlat)
	for i=0,3 do begin
		lg2=((fix(lg)+fix(0.5*i)) mod 360)
		lat2=(fix(lat)+ (i mod 2))<((*((*obj).parent)).nlat-1)
		b=b-(*((*((*obj).parent)).b_s))[*,*,lg2,lat2]*coef[*,*,*,i]
		x=x+(*((*((*obj).parent)).x_s))[*,*,lg2,lat2]*coef[*,*,*,i]
		d=d+(*((*((*obj).parent)).dens_s))[*,lg2,lat2]*coef[0,*,*,i]
		f=f+(*((*((*obj).parent)).fmax))[1,lg2,lat2]*coef[0,0,*,i]
		bz=bz+(*((*((*obj).parent)).bz_s))[*,*,lg2,lat2]*coef[*,*,*,i]
		gb=gb+(*((*((*obj).parent)).gb_s))[*,lg2,lat2]*coef[0,*,*,i]
	endfor

	coef=0b
	(*((*obj).x))[*,*,*,1]=reform(rebin(reform(x,3,parameters.freq.n_freq,nlg*nlat,1),3,parameters.freq.n_freq,nlg*nlat,nv),$
		3,parameters.freq.n_freq,nlg*nlat*nv)
	x=xyz_obs-x
	dist=rebin(reform(sqrt(total(x^2,1)),1,parameters.freq.n_freq,nlg*nlat),3,parameters.freq.n_freq,nlg*nlat)
	x=x/dist
	th=reform(rebin(reform(acos(total(x*b,1)),parameters.freq.n_freq,1,nlg*nlat),parameters.freq.n_freq,nv,nlg*nlat),parameters.freq.n_freq,nv*nlg*nlat)
	xy=x*(1.-b*rebin(reform(cos(th),1,parameters.freq.n_freq,nv*nlg*nlat),3,parameters.freq.n_freq,nv*nlg*nlat))
	b=0b

	dist2=rebin(reform(sqrt(total(xy^2,1)),1,parameters.freq.n_freq,nlg*nlat),3,parameters.freq.n_freq,nlg*nlat)
	xy=xy/dist2
	dist2=0b
	thz=reform(rebin(reform(acos(total(xy*bz,1)),parameters.freq.n_freq,1,nlg*nlat),parameters.freq.n_freq,nv,nlg*nlat),parameters.freq.n_freq,nv*nlg*nlat)
	bz=0b;thz est l'angle azimuthal pour les cones non axisymmetriques
	xy=0b

	d=rebin(reform(d,parameters.freq.n_freq,nlg*nlat),parameters.freq.n_freq,nv*nlg*nlat)
	f=rebin(reform(*(parameters.freq.freq_tab),parameters.freq.n_freq,1,1),parameters.freq.n_freq,nv*nlg*nlat)/$
	reform(rebin(reform(f,1,1,nlg*nlat),parameters.freq.n_freq,nv,nlg*nlat),parameters.freq.n_freq,nv*nlg*nlat)

	w2=[-1];w2=pas d'emissions selon le type de sources
	if (*obj).loss ne 0 then th2=Loss_cone(rebin(reform((*((*obj).v)),1,nv*nlg*nlat),parameters.freq.n_freq,nv*nlg*nlat),d,(*obj).temp,sqrt(1.-f),w2)
	if (*obj).cavity ne 0 then th2=shell(rebin(reform((*((*obj).v)),1,nv*nlg*nlat),parameters.freq.n_freq,nv*nlg*nlat),d,(*obj).temp,(*obj).cold,w2)
	if (*obj).constant ne 0 then th2=(*obj).constant
	if (*obj).rampe ne 0 then th2=f*((*obj).constant-(*obj).asymp)+(*obj).asymp

;refraction outside the source
	th2=refrac(th2,thz,gb,rebin(reform((*((*obj).v)),1,nv*nlg*nlat),parameters.freq.n_freq,nv*nlg*nlat),d,(*obj).temp,sqrt(1.-f),(*obj).loss)
	th=((th2-th*!radeg)/(*obj).width)
	

	if w2[0] ne -1 then th[w2]=1000.

;th est deja la difference entre l'angle d'emission et l'angle d'observation
;on interpole ici pour les cas ou th change tres vite (ionosphere par exemple)
	th[0:parameters.freq.n_freq-2,*]=(abs(0.5*(th[0:parameters.freq.n_freq-2,*]+th[1:parameters.freq.n_freq-1,*]))<abs(th[0:parameters.freq.n_freq-2,*]))
	th[parameters.freq.n_freq-1,*]=abs(th[parameters.freq.n_freq-1,*])

	w=where(th ge 1.,compl=w2)
	if w[0] ne -1 then th[w]=0
	if w2[0] ne -1 then th[w2]=1

	shielding,x,obj,1,dist,rebin(reform((*((*obj).v)),1,nv*nlg*nlat),parameters.freq.n_freq,nv*nlg*nlat),parameters,w3
	if w3[0] ne -1 then th[w3]=0
	x=0b
	
	(*((*obj).spdyn))[*,*,1]=reform(th,parameters.freq.n_freq,nv*nlg*nlat,1)
	for k=0,nv*nlg*nlat-1 do begin
		w0=where(f[*,k] gt 1)
		if w0[0] ne -1 then (*((*obj).spdyn))[w0,k,1]=0.
	endfor
	if abs((*obj).grad_eq) then begin
		w0=where(rebin(reform(fix(abs((*((*((*obj).parent)).grad_b_eq))[1,lg,lat]+0.5*(*obj).grad_eq)),nlg*nlat),nv*nlg*nlat) gt 0.9)
		if w0[0] ne -1 then (*((*obj).spdyn))[*,w0,1]=0.
	endif
	if abs((*obj).grad_in) then begin
		w0=where(rebin(reform(fix(abs((*((*((*obj).parent)).grad_b_in))[1,lg,lat]+0.5*(*obj).grad_in)),nlg*nlat),nv*nlg*nlat) gt 0.9)
		if w0[0] ne -1 then (*((*obj).spdyn))[*,w0,1]=0.
	endif
endif


return
end
