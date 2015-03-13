; ***********************************
; *                                 *
; *   Routines de simulation JUNO   *
; *                                 *
; ***********************************
; S. Hess (9/2006), P. Zarka (10/2006), B. Cecconi (10/2006)


; ------------------------------------------------------------------------------------
  pro FIELD_LINE_EMISSION, p, intensite, position, $
				stop_flag=stop_flag,b_interp=b_interp,verbose=verbose
; ------------------------------------------------------------------------------------
; +++++++++++ INPUT  
; P         : parameter structure passed from main loop
; +++++++++++ OUTPUT  
; Intensite : intensity for each freq and source defined in P (1=emission,0=no)
; Position  : DF trace
; +++++++++++ KEYWORD
; stop_flag : debug stop flag to stop execution just before end
; ------------------------------------------------------------------------------------

if keyword_set(verbose) then verbose=1b else verbose=0b
if keyword_set(b_interp) then b_interp=1b else b_interp=0b

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
;intens    = (*(p.src.data)).intensite_opt

; ------------------------------------------------------------------------------------
; FIELD LINE LONGITUDE SELECTION
; ------------------------------------------------------------------------------------

lg=longitude*pole+0.5-longi	; longitude ligne de champ

wp = where(longitude*pole ge 0,cntp,complement=wm,ncomplement=cntm)

; adjusting value (0 to 359) for Northern sources
if cntp ne 0 then begin
  lgp = lg(wp)
  ww = where(lgp ge 360,cntw)
  if cntw ne 0 then lgp(ww) = lgp(ww) - 360.
  ww = where(lgp lt 0,cntw)
  if cntw ne 0 then lgp(ww) = lgp(ww) + 360.
  lg(wp)=lgp
endif 

; adjusting value (-360 to -1) for Southern sources
if cntm ne 0 then begin
  lgm = lg(wm)
  ww = where(lgm gt -1.,cntw)
  if cntw ne 0 then lgm(ww) = lgm(ww) - 360.
  ww = where(lgp le -361,cntw)
  if cntw ne 0 then lgm(ww) = lgm(ww) + 360.
  lg(wm)=lgm
endif 

if b_interp then begin
  lg_fix = fix(lg)
  dlg = lg-lg_fix
  lg = [[lg_fix],[intarr(ntot)]]
  wp = where(lg_fix ge 0,cntp,compl=wm,ncompl=cntm)
  if cntp gt 0 then begin 
    lg(wp,1) = lg(wp,0)+1
    w = where(lg ge 360,cnt)
    if cnt ne 0 then lg(w) = lg(w)-360
  endif
  if cntm gt 0 then begin
    lg(wm,1) = lg(wm,0)-1
    w = where(lg le -361,cnt)
    if cnt ne 0 then lg(w) = lg(w)+360
  endif
endif

; ------------------------------------------------------------------------------------
; LOADING MAG FIELD LINE DATA
; ------------------------------------------------------------------------------------

fsb=2.79924835996d0

if b_interp then nomfichier=[["./"+chemin+"/"+strtrim(lg(*,0),2)+".lsr"], $
                             ["./"+chemin+"/"+strtrim(lg(*,1),2)+".lsr"]] $
else nomfichier="./"+chemin+"/"+strtrim(fix(lg),2)+".lsr"

b  = dblarr(3,nf,ntot)
b1 = dblarr(3,nf,ntot)
gb = dblarr(ntot)
x  = dblarr(3,nf,ntot)
maxf = fltarr(ntot)

for i=0,ntot-1 do begin  n=long(0)
  openr,unit, nomfichier(i),/get_lun,/swap_if_little_endian
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
; -- INTERPOLATION DES DONNES LUES SUR L'ECHELLE DE FREQUENCE FOURNIES

  b(0,*,i) = interpol(b_read(0,*),f_read,frequence)
  b(1,*,i) = interpol(b_read(1,*),f_read,frequence)
  b(2,*,i) = interpol(b_read(2,*),f_read,frequence)

  x(0,*,i) = interpol(x_read(0,*),f_read,frequence)
  x(1,*,i) = interpol(x_read(1,*),f_read,frequence)
  x(2,*,i) = interpol(x_read(2,*),f_read,frequence)
    
  maxf(i)  = max(f_read)
  if verbose then message,/info,nomfichier(i)+' : max(f) = '+string(maxf(i))
  if b_interp then begin
    openr,unit, nomfichier(i,1),/get_lun,/swap_if_little_endian
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
    
; -- INTERPOLATION DES DONNES LUES SUR L'ECHELLE DE FREQUENCE FOURNIES

    b1(0,*,i) = interpol(b_read(0,*),f_read,frequence)
    b1(1,*,i) = interpol(b_read(1,*),f_read,frequence)
    b1(2,*,i) = interpol(b_read(2,*),f_read,frequence)
    
    if verbose then message,/info,nomfichier(i,1)+' : max(f+1) = '+string(max(f_read))

    gb(i) = max(f_read)-maxf(i)
;    if gb(i) ne 0 then gb(i) = gb(i)/abs(gb(i))
    
    b(0,*,i) = b(0,*,i)+abs(dlg(i))*(b1(0,*,i)-b(0,*,i))
    b(1,*,i) = b(1,*,i)+abs(dlg(i))*(b1(1,*,i)-b(1,*,i))
    b(2,*,i) = b(2,*,i)+abs(dlg(i))*(b1(2,*,i)-b(2,*,i))
  endif
endfor

;stop
; ------------------------------------------------------------------------------------
; calcul de l'angle ligne de visee,B (theta2)
; ------------------------------------------------------------------------------------

x = rebin(reform(xyz_obs,3,1,1),3,nf,ntot) - x
x = x /rebin(reform(sqrt(total(x^2.,1)),1,nf,ntot),3,nf,ntot)

theta2 = acos(total(x*b,1))*!radeg
w = where(lg lt 0,cnt)
if cnt ne 0 then theta2(*,w)=180-theta2(*,w)	; on inverse dans l'hemisphere sud
;  if lg lt 0 then theta2=!pi-theta2	; on inverse dans l'hemisphere sud
; (on pourrait aussi prendre des cones d'emission avec ouverture >90¡)

vv  = rebin(reform(v,1,ntot),nf,ntot)
ff  = rebin(reform(frequence,nf,1),nf,ntot)
mff = rebin(reform(maxf,1,ntot),nf,ntot)
cc  = rebin(reform(cone,1,ntot),nf,ntot)
ddt = rebin(reform(dt,1,ntot),nf,ntot)

th  = fltarr(nf,ntot)
b2  = fltarr(nf,ntot)

; ------------------------------------------------------------------------------------
; profil de l'ouverture du cone d'emission
; ------------------------------------------------------------------------------------

wp = where(vv gt 0,cntp, compl=wm, ncompl=cntm)
if cntp ne 0 then begin
  b2(wp) = vv(wp)/sqrt(1.-ff(wp)/mff(wp)) ; prendre max(f_read) et non max(frequence) !!!
  th(wp) = th(wp)+10000.
  w = where(b2(wp) lt 1.,cnt)
  if cnt ne 0 then $
      th(wp(w))=cc/acos(vv(wp(w)))*acos(b2(wp(w)))
endif
if cntm ne 0 then begin
    th(wm)=cc(wm)
endif

delta_theta = abs(th-theta2)

; ------------------------------------------------------------------------------------
; CALCUL DE L'INTENSITE
; ------------------------------------------------------------------------------------

; variation expo de l'intensite / epaisseur du cone, avec dt = epaisseur a 3 dB
; intensite = exp(-delta_theta/dt*2.*alog(2.))	

; variation discrete de l'intensite / epaisseur du cone
  if verbose then message,/info,'Grad(B) ['+strtrim(string(ntot),2)+'] = '+strcompress(strjoin(string(gb)))
  gb = gb * (*(p.src.data)).gradb_test
  w=where(delta_theta le ddt/2 and rebin(reform(gb,1,ntot),nf,ntot) ge 0 )
  intensite=fltarr(nf,ntot)
  if w[0] ne -1 then intensite(w)=1.
;  if (~(intens)) then intensite=intensite*frequence	; ~ = not
  w=where(theta2 gt 90.)

; les ondes ne se propagent pas vers des gradients positifs
  if w[0] ne -1 then intensite(w)=0.
;  intensite(where(frequence lt 1.))=intensite(where(frequence lt 1.))*10.	; variation du pas de L_SHELL_TEST
  position=x		; si on veut tester la goniopolarimetrie

;stop
if keyword_set(stop_flag) then stop
return
end

; ------------------------------------------------------------------------------------
