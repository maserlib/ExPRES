; ************************************
; *                                  *
; *   Routines de simulation SERPE   *
; *                                  *
; ************************************
; S. Hess (9/2006), P. Zarka (10/2006), B. Cecconi (10/2006), S. Hess (12/2006),
; L. Lamy (2/2007-10/2007-02/2008)


; ==============================================================================
  pro ADD_SOURCE, parameters=p, name=name, directory=directory, satellite=satellite, $
    pos_t0=pos_t0, cone_app=cone_app, cone_wid=cone_width, lag=lag, shape=shape, $
    active_lo=active_lo, pole=pole, gradb_test=gradb_test,active_lt=active_lt, $
    axisym_latitude=axisym_latitude,cone_shape=cone_shape,rep_lag=rep_lag,$
    rep_shape=rep_shape,verbose=verbose,fmax_alt=fmax_alt
; ==============================================================================
; INPUTS :
; name      : keyword [STR] Name of the source
; directory : keyword [STR] Directory containing the precomputed field line
; satellite : keyword [BYT] satellite if set, auroral oval if not
; pos_t0    : keyword [FLT,FLT] Position of satellite at t=0 [radius (Rj), longitude (deg)]
; cone_app  : keyword [FLT,FLT] Emission Cone apperture (deg) [N,S]
; active_lt : keyword [FLT,FLT,FLT] Active Local-Time sector [min,max,step] (hours)
; active_lo : keyword [FLT,FLT,FLT] Active Longitude sector [min,max,step] (deg)
; axisym_latitude : keyword [FLT,FLT,FLT] For axisymmetric field, active latitudes [min,max,step] (deg)
; fmax_alt  : keyword [STR] to set the ionospheric limit (that defines fmax) 
;             to the aurora altitude (expressed in Rp)
; ==============================================================================
; pour active_lt=[min,max,step] :
; - utiliser le qualifieur "fixe_lt" prevu dans p.src (voir serpe_parameters__define.pro)
; - remplir les donnees pour les sources, comme dans le cas fixe en longitude
; - modifier la routine rotation_planete_sat.pro et faire que la longitude de la
;   source recule comme dans le cas d'un observateur fixe.
; ==============================================================================


; **************************************************************************************
; work on keywords
; **************************************************************************************

; keyword cone_shape: type of beaming variation: if not set = no variation
if ~keyword_set(cone_shape) then cone_shape = ""

; key word active_lt : convert the active local time into longitude
if keyword_set(active_lt) then begin
for h=0,1 do begin
  if active_lt(h) le 12. then active_lt(h) = -active_lt(h)+12. else $
                              active_lt(h) = -active_lt(h)+36.
endfor
active_lt(0:1) = active_lt([1,0])
active_lt = active_lt*360./24.
endif

if keyword_set(satellite) then satellite = 1b else satellite = 0b



; ------------------------------------------------------------------------------
; Determining the number of sources for the new source
; ------------------------------------------------------------------------------
if ~keyword_set(rep_lag) then rep_lag=[1,1]
if ~keyword_set(rep_shape) then rep_shape=[1,1]

if satellite then n_source = 2L*rep_lag[0]*rep_shape[0] else begin
 ;      if emissions for active sectors -> many new sources (active field lines) at the same time
        if ~keyword_set(active_lt) and ~keyword_set(active_lo) then begin
      message,'In case of an auroral oval source, the ACTIVE_LT or ACTIVE_LO keywords must be set.'
    endif else if keyword_set(active_lt) and keyword_set(active_lo) then begin
      message,'ACTIVE_LT and ACTIVE_LO are set, only ACTIVE_LO is taken into account.',/info
    endif else begin
        case 1b of
          keyword_set(ACTIVE_LO) : active_sector = active_lo
          keyword_set(ACTIVE_LT) : active_sector = active_lt
        endcase

        if active_sector(0) le active_sector(1) then $
          n_source = long((active_sector(1)-active_sector(0)) / active_sector(2)) +1. else $
          n_source = long((active_sector(1)+360.-active_sector(0)) / active_sector(2)) +1.

		dlong=0.
		if keyword_set(active_lt) then  dlong=p.local_time[0]
        longitudes = active_sector(0)+findgen(n_source)*active_sector(2)+dlong
        wl=where(longitudes lt 0,countl)
          if countl gt 0 then longitudes(wl)=longitudes(wl)+360.
        wl=where(longitudes ge 360,countl)
          if countl gt 0 then longitudes(wl)=longitudes(wl)-360.
      endelse
  endelse
;_______

if ~keyword_set(pole) then pole=intarr(n_source)+1

; si plusieurs latitude actives definie en une seule source (axisym_latitude seulement)
; alors on fait une boucle sur les latitudes: comme ca on enregistre chaque latitude
; comme une sources differente
repa=0 & repb=0 & repc=1
if keyword_set(axisym_latitude) then begin
repa=axisym_latitude[0] & repb=axisym_latitude[1] & repc=axisym_latitude[2]
endif

if keyword_set(axisym_latitude) then begin
  if (repa lt 90. and repb lt 90.) and strmid(directory,11) eq 'conjugate_mfl' then pole(*)=-1
  if (repa gt 90. and repb gt 90.) and strmid(directory,11) ne 'conjugate_mfl' then pole(*)=-1
  if (repa gt 90. and repb le 90.) or (repb gt 90. and repa le 90.) then stop,$
  'Warning: error in adding simultaneously northern/southern sources'
endif

for rep=repa,repb,repc do begin

; ------------------------------------------------------------------------------
; Creating the new source and updating sources parameters
; ------------------------------------------------------------------------------

  p.src.nsrc += 1L

  if p.src.ntot gt 0L then begin
if keyword_set(axisym_latitude) then tmp_sources_names=*(p.src.names)+strtrim(repa,2) else tmp_sources_names=*(p.src.names)
    tmp_sources_dirs   = *(p.src.dirs)
    tmp_sources_is_sat = *(p.src.is_sat)
    tmp_sources_is_orbiting = *(p.src.is_orbiting)
    tmp_sources_nrange = *(p.src.nrange)
    tmp_sources_data   = *(p.src.data)
    ;stop
  endif else begin
    n_names=0L
    p.src.names     = ptr_new(0b,/allocate)
    p.src.dirs      = ptr_new(0b,/allocate)
    p.src.is_sat    = ptr_new(0b,/allocate)
    p.src.is_orbiting    = ptr_new(0b,/allocate)
    p.src.nrange    = ptr_new(0b,/allocate)
    p.src.data      = ptr_new(0b,/allocate)
  endelse
  *(p.src.names)     = strarr(p.src.nsrc)
  *(p.src.dirs)      = strarr(p.src.nsrc)
  *(p.src.is_sat)    = bytarr(p.src.nsrc)
  *(p.src.is_orbiting)    = bytarr(p.src.nsrc)
  *(p.src.nrange)    = lonarr(2,p.src.nsrc)
  *(p.src.data)      = replicate({source},p.src.ntot+n_source)
  if p.src.ntot gt 0L then begin
    (*(p.src.names))(0:p.src.nsrc-2L)       = tmp_sources_names
    (*(p.src.dirs))(0:p.src.nsrc-2L)        = tmp_sources_dirs
    (*(p.src.is_sat))(0:p.src.nsrc-2L)      = tmp_sources_is_sat
    (*(p.src.is_orbiting))(0:p.src.nsrc-2L)      = tmp_sources_is_orbiting
    (*(p.src.nrange))(*,0:p.src.nsrc-2L)    = tmp_sources_nrange
    (*(p.src.data))(0:p.src.ntot-1L)        = tmp_sources_data
  endif
  (*(p.src.names))(p.src.nsrc-1L)    = name
  (*(p.src.dirs))(p.src.nsrc-1L)     = directory
  (*(p.src.is_sat))(p.src.nsrc-1L)   = satellite
  (*(p.src.is_orbiting))(p.src.nsrc-1L)   = 0
  (*(p.src.nrange))(*,p.src.nsrc-1L) = [p.src.ntot,p.src.ntot+n_source-1L]
  (*(p.src.data))(p.src.ntot:p.src.ntot+n_source-1L) = replicate({source},n_source)
  p.src.ntot = p.src.ntot+n_source

;  if satellite then pole=[1,-1]

; ------------------------------------------------------------------------------
; Filling source structure data
; ------------------------------------------------------------------------------

ff = *p.freqs.ramp
nf = n_elements(ff)

iname = n_elements(*p.src.names)-1

if ~keyword_set(gradb_test) then gradb_test = 0

isrc0 = (*p.src.nrange)(0,iname) & isrc1 = (*p.src.nrange)(1,iname)


;   CAS SATELLITE !!!!
if satellite then begin
; 1) on enregistre les options
for i0=0,rep_lag[0]-1 do for j0=0,rep_shape[0]-1 do begin
  (*p.src.data)(isrc0+2*j0+2*i0*rep_shape[0]:isrc0+1+2*j0+2*i0*rep_shape[0]).pole           = pole
  (*p.src.data)(isrc0+2*j0+2*i0*rep_shape[0]:isrc0+1+2*j0+2*i0*rep_shape[0]).distance       = pos_t0(0)
  (*p.src.data)(isrc0+2*j0+2*i0*rep_shape[0]:isrc0+1+2*j0+2*i0*rep_shape[0]).longitude      = pos_t0(1)
  (*p.src.data)(isrc0+2*j0+2*i0*rep_shape[0]:isrc0+1+2*j0+2*i0*rep_shape[0]).cone_apperture = cone_app
  (*p.src.data)(isrc0+2*j0+2*i0*rep_shape[0]:isrc0+1+2*j0+2*i0*rep_shape[0]).cone_thickness = cone_width
  (*p.src.data)(isrc0+2*j0+2*i0*rep_shape[0]:isrc0+1+2*j0+2*i0*rep_shape[0]).beam_shape     = cone_shape
  (*p.src.data)(isrc0+2*j0+2*i0*rep_shape[0]:isrc0+1+2*j0+2*i0*rep_shape[0]).gradb_test     = gradb_test
  (*p.src.data)(isrc0+2*j0+2*i0*rep_shape[0]:isrc0+1+2*j0+2*i0*rep_shape[0]).lag_active     = lag+pole*rep_lag[1]*i0
  (*p.src.data)(isrc0+2*j0+2*i0*rep_shape[0]:isrc0+1+2*j0+2*i0*rep_shape[0]).shape_cone     = shape+rep_shape[1]*j0
endfor

; boucle sur les sources (nord/sud)
for isrc = isrc0,isrc0+1 do begin
       for ilon=0,359 do begin
    b  = dblarr(3,nf)
    x  = dblarr(3,nf)
    n = 0L
; tmp_longi: correction du bug a 0∞ longitude au sud (longitude sud de 1∞ a 360∞)
tmp_longi=fix(ilon+0.5*(1-pole(isrc-p.src.ntot+n_source)))*pole(isrc-p.src.ntot+n_source)
; on lit les fichiers du champ magnetique (+correction / \ pour windows!!)
if p.display_mgr eq 'WIN' then file = p.working_dir+"\"+(*(p.src.dirs))(iname)+"\"+strtrim(tmp_longi,2)+".lsr"
if p.display_mgr ne 'WIN' then file = p.working_dir+"/"+(*(p.src.dirs))(iname)+"/"+strtrim(tmp_longi,2)+".lsr"


    if verbose then message,/info,'Loading '+file
    openr,unit, file,/get_lun,/swap_if_little_endian
      readu,unit,n
      b_read      = dblarr(3,n)
      f_read      = dblarr(n)
      x_read      = dblarr(3,n)
      xt          = dblarr(n)
      readu,unit, xt
      x_read(0,*) = xt
      readu,unit, xt
      x_read(1,*) = xt
      readu,unit, xt
      x_read(2,*) = xt
      xt          = 0
      readu,unit, b_read
      readu,unit, f_read
    close, unit & free_lun, unit


; on calcule si besoin est wp le long de la ligne de champ
if p.dense.n ne 0L then begin
  jov_alt=dblarr(n)
  Io_alt=dblarr(n)
  Io_pos=x_read(*,0)
  jov_pos=x_read(*,n-1)
  for i_dens=0L,n-1L do begin
    jov_alt(i_dens)=sqrt((x_read(0,i_dens)-jov_pos(0))^2 $
                   +(x_read(1,i_dens)-jov_pos(1))^2+(x_read(2,i_dens)-jov_pos(2))^2)
    Io_alt(i_dens) =sqrt((x_read(0,i_dens)-Io_pos(0))^2 $
                   +(x_read(1,i_dens)-Io_pos(1))^2+(x_read(2,i_dens)-Io_pos(2))^2)
  endfor
  dens=dblarr(n)
  tmpdens=*(p.dense.data)
  for i_dens=0L,p.dense.n-1L do begin
    if tmpdens(1,i_dens) ne 0 then begin
      if tmpdens(2,i_dens) eq 0 then dens=dens+tmpdens(0,i_dens)*exp(-jov_alt/tmpdens(1,i_dens))
      if tmpdens(2,i_dens) eq 1 then dens=dens+tmpdens(0,i_dens)*exp(-Io_alt/tmpdens(1,i_dens))
      if tmpdens(2,i_dens) eq 2 then dens=dens+tmpdens(0,i_dens)*exp(-(eq_alt/tmpdens(1,i_dens))^2)/(abs(x_read(0,0))^3)
    endif else dens=dens+tmpdens(0,i_dens)
  endfor
  wp0=2.*!pi*9.*sqrt(dens)*1E-3
endif


;  (RAPPEL CAS SATELLITE)

; -- INTERPOLATION DES DONNEES LUES SUR L'ECHELLE DE FREQUENCE FOURNIES
    for j=0,2 do begin
      b(j,*) = interpol(b_read(j,*),f_read,ff)
      x(j,*) = interpol(x_read(j,*),f_read,ff)
      if p.dense.n ne 0L then wp1=interpol(wp0,f_read,ff)
    endfor

; on energistre les donnee ligne de champ
    (*p.src.data)(isrc).mag_field_line(ilon).b    = ptr_new(b,/allocate)
    (*p.src.data)(isrc).mag_field_line(ilon).x    = ptr_new(x,/allocate)
    if p.dense.n ne 0L then (*p.src.data)(isrc).mag_field_line(ilon).wp   = ptr_new(wp1,/allocate)
    (*p.src.data)(isrc).mag_field_line(ilon).fmax = max(f_read)
    (*p.src.data)(isrc).mag_field_line(ilon).fIo  = f_read[0]
  endfor
; on smooth les donnees fmax, pour eviter que le bruit sur fmax ne perturbe
; le calcul du gradient
tab_tmp=(*p.src.data)(isrc).mag_field_line(*).fmax
tab_tmp=smooth(tab_tmp,6,/EDGE_TRUNCATE)
(*p.src.data)(isrc).mag_field_line(*).fmax=tab_tmp

tab_tmp=(*p.src.data)(isrc).mag_field_line(*).fIo
tab_tmp=smooth(tab_tmp,6,/EDGE_TRUNCATE)
(*p.src.data)(isrc).mag_field_line(*).fIo=tab_tmp


  endfor

    if (isrc1 gt isrc0+1) then for isrc=isrc0+2,isrc1-1,2 do begin
    (*p.src.data)(isrc+1).mag_field_line.b    = (*p.src.data)(isrc0+1).mag_field_line.b
    (*p.src.data)(isrc+1).mag_field_line.x    = (*p.src.data)(isrc0+1).mag_field_line.x
    
     if p.dense.n ne 0L then (*p.src.data)(isrc+1).mag_field_line.wp   = (*p.src.data)(isrc0+1).mag_field_line.wp
     
    (*p.src.data)(isrc+1).mag_field_line.fmax = (*p.src.data)(isrc0+1).mag_field_line.fmax
    (*p.src.data)(isrc+1).mag_field_line.fIo = (*p.src.data)(isrc0+1).mag_field_line.fIo
    (*p.src.data)(isrc).mag_field_line.b    = (*p.src.data)(isrc0).mag_field_line.b
    (*p.src.data)(isrc).mag_field_line.x    = (*p.src.data)(isrc0).mag_field_line.x
    
    if p.dense.n ne 0L then (*p.src.data)(isrc).mag_field_line.wp   = (*p.src.data)(isrc0).mag_field_line.wp
    
    (*p.src.data)(isrc).mag_field_line.fmax = (*p.src.data)(isrc0).mag_field_line.fmax
    (*p.src.data)(isrc).mag_field_line.fIo = (*p.src.data)(isrc0).mag_field_line.fIo
    

endfor


; FIN CAS SATELLITE: CAS OVAL
endif else begin
  (*p.src.data)(isrc0:isrc1).pole           = pole
  (*p.src.data)(isrc0:isrc1).distance       = 0
  (*p.src.data)(isrc0:isrc1).longitude      = longitudes
  (*p.src.data)(isrc0:isrc1).cone_apperture = cone_app
  (*p.src.data)(isrc0:isrc1).cone_thickness = cone_width
  (*p.src.data)(isrc0:isrc1).lag_active     = 0
  (*p.src.data)(isrc0:isrc1).shape_cone     = shape
  (*p.src.data)(isrc0:isrc1).beam_shape     = cone_shape
  (*p.src.data)(isrc0:isrc1).gradb_test     = gradb_test
  (*p.src.data)(isrc0:isrc1).fixe_lt        = keyword_set(ACTIVE_LT)

  b  = dblarr(3,nf)
  x  = dblarr(3,nf)
  n = 0L
  isrc = isrc0

; CAS NON-AXISYM_LATITUDE
if ~keyword_set(axisym_latitude) then begin
  for ilon=0,359 do begin
; tmp_longi: correction du bug a 0∞ longitude au sud (longitude sud de 1∞ a 360∞)
tmp_longi=fix((ilon+0.5*(1-pole(isrc-p.src.ntot+n_source)))*pole(isrc-p.src.ntot+n_source))
print,tmp_longi
; on lit les fichiers du champ magnetique (+correction / \ pour windows!!)
if p.display_mgr eq 'WIN' then file = p.working_dir+"\"+(*(p.src.dirs))(iname)+"\"+strtrim(tmp_longi,2)+".lsr"
if p.display_mgr ne 'WIN' then file = p.working_dir+"/"+(*(p.src.dirs))(iname)+"/"+strtrim(tmp_longi,2)+".lsr"

    if verbose then message,/info,'Loading '+file
    openr,unit, file,/get_lun,/swap_if_little_endian
      readu,unit,n
      b_read      = dblarr(3,n)
      f_read      = dblarr(n)
      x_read      = dblarr(3,n)
      xt          = dblarr(n)
      readu,unit, xt
      x_read(0,*) = xt
      readu,unit, xt
      x_read(1,*) = xt
      readu,unit, xt
      x_read(2,*) = xt
      xt          = 0
      readu,unit, b_read
      readu,unit, f_read
    close, unit & free_lun, unit

; on calcule si besoin est wp le long de la ligne de champ
if p.dense.n ne 0L then begin
  jov_alt=dblarr(n)
  Io_alt=dblarr(n)
  Io_pos=x_read(*,0)
  jov_pos=x_read(*,n-1)

  for i_dens=0L,n-1L do begin
    jov_alt(i_dens)=sqrt((x_read(0,i_dens)-jov_pos(0))^2 $
                   +(x_read(1,i_dens)-jov_pos(1))^2+(x_read(2,i_dens)-jov_pos(2))^2)
    Io_alt(i_dens) =sqrt((x_read(0,i_dens)-Io_pos(0))^2 $
                   +(x_read(1,i_dens)-Io_pos(1))^2+(x_read(2,i_dens)-Io_pos(2))^2)
  endfor
  dens=dblarr(n)
  tmpdens=*(p.dense.data)

  for i_dens=0L,p.dense.n-1L do begin
    if tmpdens(1,i_dens) ne 0 then begin
      if tmpdens(2,i_dens) eq 0 then dens=dens+tmpdens(0,i_dens)*exp(-jov_alt/tmpdens(1,i_dens))
      if tmpdens(2,i_dens) eq 1 then dens=dens+tmpdens(0,i_dens)*exp(-Io_alt/tmpdens(1,i_dens))
      if tmpdens(2,i_dens) eq 2 then dens=dens+tmpdens(0,i_dens)*exp(-(eq_alt/tmpdens(1,i_dens))^2)/(abs(x_read(0,0))^3)
    endif else dens=dens+tmpdens(0,i_dens)
  endfor
  wp0=2.*!pi*9.*sqrt(dens)*1E-3
endif


; (RAPPEL CAS OVAL NON AXISYM)
; -- INTERPOLATION DES DONNES LUES SUR L'ECHELLE DE FREQUENCE FOURNIES
   for j=0,2 do begin
      b(j,*) = interpol(b_read(j,*),f_read,ff)
      x(j,*) = interpol(x_read(j,*),f_read,ff)
      if p.dense.n ne 0L then wp1=interpol(wp0,f_read,ff)
    endfor
; on energistre les donnee ligne de champ
    (*p.src.data)(isrc).mag_field_line(ilon).b    = ptr_new(b,/allocate)
    (*p.src.data)(isrc).mag_field_line(ilon).x    = ptr_new(x,/allocate)
    if p.dense.n ne 0L then (*p.src.data)(isrc).mag_field_line(ilon).wp   = ptr_new(wp1,/allocate)
    (*p.src.data)(isrc).mag_field_line(ilon).fmax = max(f_read)
  endfor
; on smooth les donnees fmax, pour eviter que le bruit sur fmax ne perturbe
; le calcul du gradient
tab_tmp=(*p.src.data)(isrc).mag_field_line(*).fmax
tab_tmp=smooth(tab_tmp,6,/EDGE_TRUNCATE)
(*p.src.data)(isrc).mag_field_line(*).fmax=tab_tmp

; FIN CAS NORMAL: CAS AXISYM_LONGITUDE
endif else begin

;  file = "$ROOT_SERPE/"+(*(p.src.dirs))(iname)+"/"+strtrim(repa,2)+".lsr"
if p.display_mgr eq 'WIN' then file = p.working_dir+"\"+(*(p.src.dirs))(iname)+"\"+strtrim(rep,2)+".lsr"
if p.display_mgr ne 'WIN' then file = p.working_dir+"/"+(*(p.src.dirs))(iname)+"/"+strtrim(rep,2)+".lsr"

    if verbose then message,/info,'Loading '+file
    openr,unit, file,/get_lun,/swap_if_little_endian
      readu,unit,n
      b_read      = dblarr(3,n)
      f_read      = dblarr(n)
      x_read      = dblarr(3,n)
      xt          = dblarr(n)
      readu,unit, xt
      x_read(0,*) = xt
      readu,unit, xt
      x_read(1,*) = xt
      readu,unit, xt
      x_read(2,*) = xt
      xt          = 0
      readu,unit, b_read
      readu,unit, f_read
    close, unit & free_lun, unit

; on calcule si besoin est wp le long de la ligne de champ
if p.dense.n ne 0L then begin
  jov_alt=dblarr(n)
  Io_alt=dblarr(n)
  Io_pos=x_read(*,0)
  jov_pos=x_read(*,n-1)
  eq_alt=reform(x_read(2,*))
  for i_dens=0L,n-1L do begin
    jov_alt(i_dens)=sqrt((x_read(0,i_dens)-jov_pos(0))^2 $
                   +(x_read(1,i_dens)-jov_pos(1))^2+(x_read(2,i_dens)-jov_pos(2))^2)
    Io_alt(i_dens) =sqrt((x_read(0,i_dens)-Io_pos(0))^2 $
                   +(x_read(1,i_dens)-Io_pos(1))^2+(x_read(2,i_dens)-Io_pos(2))^2)
  endfor
  dens=dblarr(n)
  tmpdens=*(p.dense.data)
  for i_dens=0L,p.dense.n-1L do begin
    if tmpdens(1,i_dens) ne 0 then begin
      if tmpdens(2,i_dens) eq 0 then dens=dens+tmpdens(0,i_dens)*exp(-jov_alt/tmpdens(1,i_dens))
      if tmpdens(2,i_dens) eq 1 then dens=dens+tmpdens(0,i_dens)*exp(-Io_alt/tmpdens(1,i_dens))
      if tmpdens(2,i_dens) eq 2 then dens=dens+tmpdens(0,i_dens)*exp(-(eq_alt/tmpdens(1,i_dens))^2)/(abs(x_read(0,0))^3)
    endif else dens=dens+tmpdens(0,i_dens)
  endfor
  wp0=2.*!pi*9.*sqrt(dens)*1E-3
endif

    for j=0,2 do begin
      b(j,*) = interpol(b_read(j,*),f_read,ff)
      x(j,*) = interpol(x_read(j,*),f_read,ff)
    if p.dense.n ne 0L then  wp1=interpol(wp0,f_read,ff)
    endfor
b2=b
x2=x

  for ilon=0,359 do begin

; -- INTERPOLATION DES DONNES LUES SUR L'ECHELLE DE FREQUENCE FOURNIES

    b[0,*]=b2[0,*]*cos((ilon-180)*!dtor)+b2[1,*]*sin((ilon-180)*!dtor)
    b[1,*]=b2[1,*]*cos((ilon-180)*!dtor)-b2[0,*]*sin((ilon-180)*!dtor)
    x[0,*]=x2[0,*]*cos((ilon-180)*!dtor)+x2[1,*]*sin((ilon-180)*!dtor)
    x[1,*]=x2[1,*]*cos((ilon-180)*!dtor)-x2[0,*]*sin((ilon-180)*!dtor)

    (*p.src.data)(isrc).mag_field_line(ilon).b    = ptr_new(b,/allocate)
    (*p.src.data)(isrc).mag_field_line(ilon).x    = ptr_new(x,/allocate)
     if p.dense.n ne 0L then (*p.src.data)(isrc).mag_field_line(ilon).wp   = ptr_new(wp1,/allocate)
    
    (*p.src.data)(isrc).mag_field_line(ilon).fmax = max(f_read)
  endfor
endelse

; N.B: Si on prend fmax à l'altitude des aurores (ex 1000km sur saturne) = variation de 6% => A implémenter avec un mot-clef
if keyword_set(fmax_alt) then begin
  hh=sqrt(x_read(0,*)^2+x_read(2,*)^2)
  test=where(hh le (min(hh)+fmax_alt))
  if test(0) ne -1 then (*p.src.data)(isrc).mag_field_line(*).fmax=f_read(test(0)) else stop,'Wrong altitude of aurora'
endif

  ; NB: We have loaded the data for source isrc0. We won't load the same data
  ;     again nor duplicate it. We just have to put the pointer address of the
  ;     data already loaded into the isrc pointers.

  if isrc1 gt isrc0 then for isrc=isrc0+1,isrc1 do begin
    (*p.src.data)(isrc).mag_field_line.b    = (*p.src.data)(isrc0).mag_field_line.b
    (*p.src.data)(isrc).mag_field_line.x    = (*p.src.data)(isrc0).mag_field_line.x
     if p.dense.n ne 0L then (*p.src.data)(isrc).mag_field_line.wp   = (*p.src.data)(isrc0).mag_field_line.wp
    (*p.src.data)(isrc).mag_field_line.fmax = (*p.src.data)(isrc0).mag_field_line.fmax
  endfor
endelse
; FIN CAS AXISYM

endfor ;boucle latitude
  message,/info,"Source "+name+" successfully added."

return
end
