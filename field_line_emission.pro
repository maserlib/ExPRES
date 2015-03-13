; ************************************
; *                                  *
; *   Routines de simulation SERPE   *
; *                                  *
; ************************************
; S. Hess (9/2006), P. Zarka (10/2006), B. Cecconi (10/2006), L. Lamy (02/2008)


; ------------------------------------------------------------------------------------
pro FIELD_LINE_EMISSION, p, intensite, position, $
stop_flag=stop_flag,verbose=verbose,theta=theta2,theta_min=theta_min,theta_max=theta_max,ang_b=ang_b,fq_b=fq_b,step_b=step_b
print,step_b
; ------------------------------------------------------------------------------------
; +++++++++++ INPUT
; P         : parameter structure passed from main loop
; +++++++++++ OUTPUT
; Intensite : intensity for each freq and source defined in P (1=emission,0=no)
; Position  : DF trace
; +++++++++++ KEYWORD
; stop_flag : debug stop flag to stop execution just before end
; theta_min,max : limits leading to a linear variation of the beaming aperture with frequency
;                 theta_max <=> fmin & theta_min <=> fmax
; ------------------------------------------------------------------------------------

if keyword_set(verbose)  then verbose  = 1b else verbose  = 0b
if keyword_set(b_interp) then b_interp = 1b else b_interp = 0b

; ------------------------------------------------------------------------------------
; VARIABLE DEFINITIONS
; ------------------------------------------------------------------------------------

frequence = *p.freqs.ramp
xyz_obs   = p.obs.pos_xyz

nsrc      = p.src.nsrc
ntot      = p.src.ntot
nf        = n_elements(frequence)

chemin = strarr(ntot)
for isrc = 0,nsrc-1 do chemin((*p.src.nrange)(0,isrc):(*p.src.nrange)(1,isrc))=(*p.src.dirs)(isrc)
orbiting=fltarr(ntot)
for isrc = 0,nsrc-1 do orbiting((*p.src.nrange)(0,isrc):(*p.src.nrange)(1,isrc))=(*p.src.is_orbiting)(isrc)

longitude = (*(p.src.data)).longitude
pole      = (*(p.src.data)).pole
dt        = (*(p.src.data)).cone_thickness
cone      = (*(p.src.data)).cone_apperture
longi     = (*(p.src.data)).lag_active
v         = (*(p.src.data)).shape_cone
shp       = (*(p.src.data)).beam_shape
shield      = (*(p.src.data)).shielding

;intens    = (*(p.src.data)).intensite_opt

; ------------------------------------------------------------------------------------
; FIELD LINE LONGITUDE SELECTION
; ------------------------------------------------------------------------------------

lg=abs(longitude*pole+0.5-longi)    ; longitude ligne de champ

ww = where(lg ge 360,cntw)
if cntw ne 0 then lg(ww) = lg(ww) - 360.
ww = where(lg lt 0,cntw)
if cntw ne 0 then lg(ww) = lg(ww) + 360.

;wp = where(longitude*pole ge 0,cntp,complement=wm,ncomplement=cntm)


lg_fix = fix(lg)
dlg = lg-lg_fix
lg = [[lg_fix],[intarr(ntot)]]
lg(*,1) = lg(*,0)+1

w = where(lg ge 360,cnt)
if cnt ne 0 then lg(w) = lg(w)-360



; ------------------------------------------------------------------------------------
; SELECTING MAG FIELD LINE DATA
; ------------------------------------------------------------------------------------

b  = dblarr(3,nf,ntot)
wp0  = dblarr(nf,ntot)
b1 = dblarr(3,nf)
gb = dblarr(ntot)
x  = dblarr(3,nf,ntot)
maxf = fltarr(ntot)

for i=0,ntot-1 do begin
b(*,*,i) = *((*p.src.data)(i).mag_field_line(lg(i,0)).b)
b1       = *((*p.src.data)(i).mag_field_line(lg(i,1)).b)
x(*,*,i) = *((*p.src.data)(i).mag_field_line(lg(i,0)).x)


a1=xyz_to_rtp(b(*,fq_b,i))
a2=xyz_to_rtp(xyz_obs)
a3=[1.,a2(1),a2(2)-a1(2)]
a1=[1.,a1(1),0]
rtp_to_xyz,a3,a2
rtp_to_xyz,a1,a3
ang_b(0,i,step_b)=acos(total(a3*a2))*!radeg
ang_b(1,i,step_b)=asin(a2(1))*!radeg
if a2(0) lt 0 then ang_b(1,i,step_b)=180.-ang_b(1,i,step_b)


; Si la sourec est en orbite, il faut changer de referentiel

if (orbiting(i) eq 1) then begin
; on tourne la position des ources en fonction de la rotation du satellite
rtp_temp=XYZ_TO_RTP(x(*,*,i))

rtp_temp(2,*) +=((*p.src.data).phase_rot)(i)
x(0,*,i) = rtp_temp(0,*)*sin(rtp_temp(1,*))*cos(rtp_temp(2,*))
x(1,*,i) = rtp_temp(0,*)*sin(rtp_temp(1,*))*sin(rtp_temp(2,*))
x(2,*,i) = rtp_temp(0,*)*cos(rtp_temp(1,*))
; on tourne la direction du champ en fonction de la rotation du satellite
rtp_temp=XYZ_TO_RTP(b(*,*,i))
rtp_temp(2,*) +=((*p.src.data).phase_rot)(i)
b(0,*,i) = rtp_temp(0,*)*sin(rtp_temp(1,*))*cos(rtp_temp(2,*))
b(1,*,i) = rtp_temp(0,*)*sin(rtp_temp(1,*))*sin(rtp_temp(2,*))
b(2,*,i) = rtp_temp(0,*)*cos(rtp_temp(1,*))
rtp_temp=XYZ_TO_RTP(b1(*,*))
rtp_temp(2,*) +=((*p.src.data).phase_rot)(i)
b1(0,*) = rtp_temp(0,*)*sin(rtp_temp(1,*))*cos(rtp_temp(2,*))
b1(1,*) = rtp_temp(0,*)*sin(rtp_temp(1,*))*sin(rtp_temp(2,*))
b1(2,*) = rtp_temp(0,*)*cos(rtp_temp(1,*))

; on translate ala position du satellite
x(0,*,i) += ((*p.src.data).distance)(i)*cos((360.-((*p.src.data).phase_orb)(i))*!dtor)
x(1,*,i) += ((*p.src.data).distance)(i)*sin((360.-((*p.src.data).phase_orb)(i))*!dtor)
endif

if p.dense.n ne 0L then wp0(*,i) = *((*p.src.data)(i).mag_field_line(lg(i,0)).wp)

b(*,*,i) = b(*,*,i)+abs(dlg(i))*(b1-b(*,*,i))
maxf(i)  = (*p.src.data)(i).mag_field_line(lg(i,0)).fmax
maxf1=0. & maxf2=0.
if (*(p.src.data))(i).gradb_test eq 1 then begin
maxf1  = (*p.src.data)(i).mag_field_line(lg(i,1)).fmax
maxf2  = (*p.src.data)(i).mag_field_line(lg(i,0)).fmax
endif
if (*(p.src.data))(i).gradb_test eq 2 then begin
maxf1  = (*p.src.data)(0).mag_field_line(lg(0,1)).fmax
maxf2  = (*p.src.data)(0).mag_field_line(lg(0,0)).fmax
endif
if (*(p.src.data))(i).gradb_test eq 3 then begin
maxf1  = (*p.src.data)(1).mag_field_line(lg(1,1)).fmax
maxf2  = (*p.src.data)(1).mag_field_line(lg(1,0)).fmax
endif
if (*(p.src.data))(i).gradb_test eq 4 then begin
l=[lg(i,0)+longi(i)*pole(i),lg(i,1)+longi(i)*pole(i)]
if l[0] ge 360 then l[0]=l[0]-360
if l[1] ge 360 then l[1]=l[1]-360
maxf1  = (*p.src.data)(i).mag_field_line(l(1)).fIo
maxf2  = (*p.src.data)(i).mag_field_line(l(0)).fIo
endif
gb(i) = (maxf1-maxf2)
endfor

; ------------------------------------------------------------------------------------
; calcul de l'angle ligne de visee,B (theta2)
; ------------------------------------------------------------------------------------

xyzsat=x
x = rebin(reform(xyz_obs,3,1,1),3,nf,ntot) - x
x = x /rebin(reform(sqrt(total(x^2.,1)),1,nf,ntot),3,nf,ntot)

theta2 = acos(total(x*b,1))*!radeg
w = where(pole lt 0,cnt)
if cnt ne 0 then theta2(*,w)=180-theta2(*,w)    ; on inverse dans l'hemisphere sud
;  if lg lt 0 then theta2=!pi-theta2    ; on inverse dans l'hemisphere sud
; (on pourrait aussi prendre des cones d'emission avec ouverture >90¡)

vv  = rebin(reform(v,1,ntot),nf,ntot)
ff  = rebin(reform(frequence,nf,1),nf,ntot)
mff = rebin(reform(maxf,1,ntot),nf,ntot)
cc  = rebin(reform(cone,1,ntot),nf,ntot)
ddt = rebin(reform(dt,1,ntot),nf,ntot)
sshield = rebin(reform(shield,1,ntot),nf,ntot)
sshp= strarr(nf,ntot)

if size(shp,/n_dimensions) eq 1 then begin
for i_shp=0,nf-1 do sshp(i_shp,*)=shp(*) 
endif else begin
for i_shp=0,nf-1 do sshp(i_shp,*)=shp(0,*) ; cas satellite (1 dim supplŽmentaire)
endelse

th  = fltarr(nf,ntot)+cc
b2  = fltarr(nf,ntot)

; ------------------------------------------------------------------------------------
; profil de l'ouverture du cone d'emission
; ------------------------------------------------------------------------------------



res=STRMATCH(sshp,"*loss*")
wp = where((res eq 1) and (ff/mff lt 1),cntp)
if cntp ne 0 then begin
b2(wp) = vv(wp)/sqrt((1.-ff(wp)/mff(wp))>0) ; prendre max(f_read) et non max(frequence) !!!
th(wp) = th(wp)+10000.
w = where(b2(wp) lt 1.,cnt)
if cnt ne 0 then $
th(wp(w))=acos(b2(wp(w)))*180./!pi
endif

res=STRMATCH(sshp,"*rampe*")
wm = where((res eq 1) and (ff/mff lt 1),cntm)
if cntm ne 0 then begin
wp2 = where(vv(wm) eq 0,cntp2, compl=wm2, ncompl=cntm2)
if cntp2 ne 0 then  th(wm(wp2))=cc(wm(wp2))
if cntm2 ne 0 then  th(wm(wm2))=(cc(wm(wm2))+vv(wm(wm2)))*ff(wm(wm2))/mff(wm(wm2))+cc(wm(wm2))
endif

res=STRMATCH(sshp,"*ring*")
wp = where((res eq 1) and (ff/mff lt 1),cntp)
if cntp ne 0 then begin
b2(wp) = vv(wp)*sqrt((1.-ff(wp)/mff(wp))>0) ; prendre max(f_read) et non max(frequence) !!!
th(wp) = th(wp)+10000.
w = where(b2(wp) lt 1.,cnt)
if cnt ne 0 then $
th(wp(w))=acos(b2(wp(w)))*180./!pi
endif

res=STRMATCH(sshp,"*dens*")
wp = where((res eq 1) and (ff/mff lt 1),cntp)
if cntp ne 0 then begin
w = where(th(wp) lt 10000.,cnt)
if cnt ne 0 then $
cst_th=vv*0.
res=STRMATCH(sshp(wp(w)),"*loss*")
wpl = where((res eq 1),cntpl)
if cntpl ne 0 then cst_th(wp(w(wpl)))=1.
res=STRMATCH(sshp,"*ring*")
wpr = where((res eq 1),cntpr)
if cntpr ne 0 then cst_th(wp(w(wpr)))=(1.-ff(wp(w(wpr)))/mff(wp(w(wpr))))
nu_c =(1+(vv(wp(w))^2)*(cst_th(wp(w))-0.5))^(-2)
nu_p = wp0(wp(w))^2/(2*!pi*ff(wp(w)))^2*nu_c
khi=nu_c/(1.-nu_p)
theta_th=findgen(1000)*0.001*!pi/2.
for i_th=0,cnt-1 DO BEGIN
a=2*nu_p(i_th)/(2.-khi(i_th)*sin(theta_th)^2-sqrt(khi(i_th)^2*sin(theta_th)^4+4.*nu_c(i_th)*cos(theta_th)^2)) ; cf Appleton-Hartree
w_th=where(a le 0 or a gt 1)
res=(a-1.)*cos(theta_th)^2+nu_c(i_th)*cos(th(wp(w(i_th)))/180.*!pi)^2
if w_th[0] ne -1 then res(w_th)=1E10
b=where(abs(res) eq min(abs(res))) & b=b(0)
if abs(res(b)) lt 0.1 then th(wp(w(i_th)))=theta_th(b)*180./!pi else th(wp(w(i_th)))=1E4
endfor
endif

res=STRMATCH(sshp,"*asymp*")
wp = where((res eq 1) and (ff/mff lt 1),cntp)
if cntp ne 0 then begin
w = where(th(wp) lt 10000.,cnt)
if cnt ne 0 then $
th(wp(w))=cc(wp(w))/acos(vv(wp(w)))/(180./!pi)*th(wp(w))
endif

delta_theta = abs(th-theta2)

; ------------------------------------------------------------------------------------
; CALCUL DE L'INTENSITE
; ------------------------------------------------------------------------------------

; variation expo de l'intensite / epaisseur du cone, avec dt = epaisseur a 3 dB
; intensite = exp(-delta_theta/dt*2.*alog(2.))

; variation discrete de l'intensite / epaisseur du cone
if verbose then message,/info,'Grad(B) ['+strtrim(string(ntot),2)+'] = '+strcompress(strjoin(string(gb)))
;  gb = gb * (*(p.src.data)).gradb_test ; n'est plus necessaire car nul par defaut


w=where(delta_theta le ddt/2 and rebin(reform(gb,1,ntot),nf,ntot) le 0)
intensite=fltarr(nf,ntot)
if w[0] ne -1 then intensite(w)=1.


w=where(ff gt mff)
if w[0] ne -1 then intensite(w)=0.
;  if (~(intens)) then intensite=intensite*frequence    ; ~ = not
w=where(theta2 gt 90.)

; les ondes ne se propagent pas vers des gradients positifs
if w[0] ne -1 then intensite(w)=0.


sshield=sshield*intensite
ws=where(sshield eq 1)
if ws[0] ne -1 then begin
 xyzsat=reform(xyzsat,3,nf*ntot) & xyzsat=xyzsat(*,ws) &  x=reform(x,3,nf*ntot) & x=x(*,ws)
 point=xyzsat(*,*)+rebin(reform(abs(total(xyzsat(*,*)*x(*,*),1)),1,n_elements(ws)),3,n_elements(ws))*x(*,*)
 rtp=xyz_to_rtp(point(*,*))
 w2=where(rtp(0,*) lt 1,compl=w1)
 if w2[0] ne -1 then intensite(ws(w2))=0 
 if w1[0] ne -1 then begin
 rtp=rtp(*,ws(w1)) & ws=ws(w1)
 MAGNETIC_FIELD,RTP, B_SPH,B,br,mfl_model="TDS",/nocrt
 b=b*2.99
 dens=rtp(0,*)*0.
  for i_dens=0L,p.dense.n-1L do if (*(p.dense.data))(2,i_dens) eq 0 then dens=dens+(*(p.dense.data))(0,i_dens)/rtp(0,*)^2
  b=sqrt(b^2+(2.*!pi*9.*sqrt(dens)*1E-3)^2)
  w3=where(b gt ff(ws))
  if w3[0] ne -1 then intensite(ws(w3))=0
  endif 
endif

position=x       ; si on veut tester la goniopolarimetrie

if keyword_set(stop_flag) then stop
return
end

; ------------------------------------------------------------------------------------
