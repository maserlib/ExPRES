; ************************************
; *                                  *
; *   Routines de simulation SERPE   *
; *                                  *
; ************************************
; S. Hess (9/2006), P. Zarka (10/2006), B. Cecconi (10/2006), L. Lamy (02/2008)


; ------------------------------------------------------------------------------------
  pro FIELD_LINE_EMISSION, p, intensite, position, $
          stop_flag=stop_flag,verbose=verbose,theta=theta2,theta_min=theta_min,theta_max=theta_max
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

longitude = (*(p.src.data)).longitude
pole      = (*(p.src.data)).pole
dt        = (*(p.src.data)).cone_thickness
cone      = (*(p.src.data)).cone_apperture
longi     = (*(p.src.data)).lag_active
v         = (*(p.src.data)).shape_cone
shp       = (*(p.src.data)).beam_shape
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

x = rebin(reform(xyz_obs,3,1,1),3,nf,ntot) - x
x = x /rebin(reform(sqrt(total(x^2.,1)),1,nf,ntot),3,nf,ntot)

theta2 = acos(total(x*b,1))*!radeg
w = where(pole lt 0,cnt)
if cnt ne 0 then theta2(*,w)=180-theta2(*,w)    ; on inverse dans l'hemisphere sud
;  if lg lt 0 then theta2=!pi-theta2    ; on inverse dans l'hemisphere sud
; (on pourrait aussi prendre des cones d'emission avec ouverture >90°)

vv  = rebin(reform(v,1,ntot),nf,ntot)
ff  = rebin(reform(frequence,nf,1),nf,ntot)
mff = rebin(reform(maxf,1,ntot),nf,ntot)
cc  = rebin(reform(cone,1,ntot),nf,ntot)
ddt = rebin(reform(dt,1,ntot),nf,ntot)
sshp= strarr(nf,ntot)
 
if size(shp,/n_dimensions) eq 1 then begin
  for i_shp=0,nf-1 do sshp(i_shp,*)=shp(*) 
endif else begin
  for i_shp=0,nf-1 do sshp(i_shp,*)=shp(0,*) ; cas satellite (1 dim supplémentaire)
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

; Beaming linéaire en fréquence:
;res=STRMATCH(sshp,"*lin*")
;sz=size(res) & wp = where((total(res,1) eq sz(1)),cntp)
;if cntp ne 0 then begin
;  for isrc=0,cntp-1l do begin
;    pente=(theta_min-theta_max)/(frequence(nf-1l)-frequence(0))
;    temp=pente*(findgen(nf)/(nf-1)*max(frequence)+min(frequence))+theta_max
;    th(*,isrc)=interpol(temp,(findgen(nf)/(nf-1)*max(frequence)+min(frequence)),frequence)
;  endfor
;endif

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
;  intensite(where(frequence lt 1.))=intensite(where(frequence lt 1.))*10.  ; variation du pas de L_SHELL_TEST
  position=x       ; si on veut tester la goniopolarimetrie

if keyword_set(stop_flag) then stop
return
end

; ------------------------------------------------------------------------------------
