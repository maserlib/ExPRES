; ***********************************
; *                                 *
; *   Routines de simulation JUNO   *
; *                                 *
; ***********************************
; S. Hess (9/2006), P. Zarka (10/2006), B. Cecconi (10/2006), S. Hess (12/2006)


; ==============================================================================
  pro ADD_SOURCE, parameters=p, name=name, directory=directory, satellite=satellite, $
    pos_t0=pos_t0, cone_app=cone_app, cone_wid=cone_width, lag=lag, shape=shape, $
    active_lo=active_lo, pole=pole, gradb_test=gradb_test,active_lt=active_lt, $
	verbose=verbose
; ==============================================================================
; INPUTS : 
; name 		: keyword [STR] Name of the source
; directory : keyword [STR] Directory containing the precomputed field line
; satellite : keyword [BYT] satellite if set, auroral oval if not
; pos_t0	: keyword [FLT,FLT] Position of satellite at t=0 [radius (Rj), longitude (deg)]
; cone_app	: keyword [FLT,FLT] Emission Cone apperture (deg) [N,S]
; active_lt : keyword [FLT,FLT,FLT] Active Local-Time sector [min,max,step] (hours)
; active_lo : keyword [FLT,FLT,FLT] Active Longitude sector [min,max,step] (deg)
; ==============================================================================
; pour active_lt=[min,max,step] :
; - utiliser le qualifieur "fixe_lt" prevu dans p.src (voir juno_parameters__define.pro)
; - remplir les donnees pour les sources, comme dans le cas fixe en longitude
; - modifier la routine rotation_planete_sat.pro et faire que la longitude de la 
;   source recule comme dans le cas d'un observateur fixe. 
; ==============================================================================

if keyword_set(satellite) then satellite = 1b else satellite = 0b
; ------------------------------------------------------------------------------  
; Determining the number of sources for the new source
; ------------------------------------------------------------------------------  
  
  if satellite then n_source = 2L else begin
;  if satellite then n_source = 1L else begin
    if ~keyword_set(active_lt) and ~keyword_set(active_lo) then begin
      message,'In case of an auroral oval source, the ACTIVE_LT or ACTIVE_LO keywords must be set.'
    endif else if keyword_set(active_lt) and keyword_set(active_lo) then begin
      message,'ACTIVE_LT and ACTIVE_LO are set, only ACTIVE_LO is taken into account.',/info
      endif else begin 
        case 1b of
          keyword_set(ACTIVE_LO) : active_sector = active_lo
          keyword_set(ACTIVE_LT) : active_sector = active_lt
        endcase
        n_source = long((active_sector(1)-active_sector(0)) / active_sector(2))
        longitudes = active_sector(0)+findgen(n_source)*active_sector(2)+p.local_time[0]
wl=where(longitudes lt 0)
        if wl[0] ne -1 then longitudes(wl)=longitudes(where(longitudes lt 0))+360.
wl=where(longitudes ge 360)
        if wl[0] ne -1 then longitudes(wl)=longitudes(where(longitudes lt 0))-360.
      endelse
  endelse

if ~keyword_set(pole) then pole=intarr(n_source)+1
  
; ------------------------------------------------------------------------------  
; Creating the new source and updating sources parameters
; ------------------------------------------------------------------------------  

  p.src.nsrc += 1L

  if p.src.ntot gt 0L then begin
    tmp_sources_names  = *(p.src.names)
    tmp_sources_dirs   = *(p.src.dirs)
    tmp_sources_is_sat = *(p.src.is_sat)
    tmp_sources_nrange = *(p.src.nrange)
    tmp_sources_data   = *(p.src.data)
    ;stop
  endif else begin
    n_names=0L
    p.src.names     = ptr_new(0b,/allocate)
    p.src.dirs      = ptr_new(0b,/allocate)
    p.src.is_sat    = ptr_new(0b,/allocate)
    p.src.nrange    = ptr_new(0b,/allocate)
    p.src.data      = ptr_new(0b,/allocate)
  endelse
  *(p.src.names)     = strarr(p.src.nsrc)
  *(p.src.dirs)      = strarr(p.src.nsrc)
  *(p.src.is_sat)    = bytarr(p.src.nsrc)
  *(p.src.nrange)    = lonarr(2,p.src.nsrc)
  *(p.src.data)      = replicate({source},p.src.ntot+n_source)
  if p.src.ntot gt 0L then begin
    (*(p.src.names))(0:p.src.nsrc-2L)       = tmp_sources_names
    (*(p.src.dirs))(0:p.src.nsrc-2L)        = tmp_sources_dirs
    (*(p.src.is_sat))(0:p.src.nsrc-2L)      = tmp_sources_is_sat
    (*(p.src.nrange))(*,0:p.src.nsrc-2L)    = tmp_sources_nrange
    (*(p.src.data))(0:p.src.ntot-1L)        = tmp_sources_data
  endif
  (*(p.src.names))(p.src.nsrc-1L)    = name
  (*(p.src.dirs))(p.src.nsrc-1L)     = directory
  (*(p.src.is_sat))(p.src.nsrc-1L)   = satellite
  (*(p.src.nrange))(*,p.src.nsrc-1L) = [p.src.ntot,p.src.ntot+n_source-1L]
  (*(p.src.data))(p.src.ntot:p.src.ntot+n_source-1L)                         $
                                     = replicate({source},n_source)
  ;stop
  p.src.ntot = p.src.ntot+n_source

;  if satellite then pole=[1,-1]

; ------------------------------------------------------------------------------  
; Filling source structure data
; ------------------------------------------------------------------------------  

;stop
ff = *p.freqs.ramp
nf = n_elements(ff)

iname = n_elements(*p.src.names)-1
  
if ~keyword_set(gradb_test) then gradb_test = 0

isrc0 = (*p.src.nrange)(0,iname) & isrc1 = (*p.src.nrange)(1,iname)
if satellite then begin
  (*p.src.data)(isrc0:isrc1).pole           = pole
  (*p.src.data)(isrc0:isrc1).distance       = pos_t0(0)
  (*p.src.data)(isrc0:isrc1).longitude      = pos_t0(1)
  (*p.src.data)(isrc0:isrc1).cone_apperture = cone_app
  (*p.src.data)(isrc0:isrc1).cone_thickness = cone_width
  (*p.src.data)(isrc0:isrc1).lag_active     = lag
  (*p.src.data)(isrc0:isrc1).shape_cone     = shape
  (*p.src.data)(isrc0:isrc1).gradb_test     = gradb_test
  (*p.src.data)(isrc0:isrc1).fixe_lt        = keyword_set(ACTIVE_LT)
  for isrc = isrc0,isrc1 do begin
		for ilon=0,359 do begin
    b  = dblarr(3,nf)
    x  = dblarr(3,nf)
    n = 0L
    file = "$ROOT_JUNO/"+(*(p.src.dirs))(iname)+"/"+strtrim(ilon*pole(isrc-p.src.ntot+n_source),2)+".lsr"
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

; -- INTERPOLATION DES DONNES LUES SUR L'ECHELLE DE FREQUENCE FOURNIES

    for j=0,2 do begin 
      b(j,*) = interpol(b_read(j,*),f_read,ff)
      x(j,*) = interpol(x_read(j,*),f_read,ff)
    endfor
      
    (*p.src.data)(isrc).mag_field_line(ilon).b    = ptr_new(b,/allocate)
    (*p.src.data)(isrc).mag_field_line(ilon).x    = ptr_new(x,/allocate)
    (*p.src.data)(isrc).mag_field_line(ilon).fmax = max(f_read)
    (*p.src.data)(isrc).mag_field_line(ilon).fIo  = f_read[0]
  endfor
tab_tmp=(*p.src.data)(isrc).mag_field_line(*).fmax
tab_tmp=smooth(tab_tmp,6,/EDGE_TRUNCATE)
(*p.src.data)(isrc).mag_field_line(*).fmax=tab_tmp
  endfor
endif else begin
  (*p.src.data)(isrc0:isrc1).pole           = pole
  (*p.src.data)(isrc0:isrc1).distance       = 0
  (*p.src.data)(isrc0:isrc1).longitude      = longitudes
  (*p.src.data)(isrc0:isrc1).cone_apperture = cone_app
  (*p.src.data)(isrc0:isrc1).cone_thickness = cone_width
  (*p.src.data)(isrc0:isrc1).lag_active     = 0
  (*p.src.data)(isrc0:isrc1).shape_cone     = shape
  (*p.src.data)(isrc0:isrc1).gradb_test     = gradb_test
  b  = dblarr(3,nf)
  x  = dblarr(3,nf)
  n = 0L
  isrc = isrc0
  for ilon=0,359 do begin
    file = "$ROOT_JUNO/"+(*(p.src.dirs))(iname)+"/"+strtrim(ilon*pole(isrc-p.src.ntot+n_source),2)+".lsr"
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

; -- INTERPOLATION DES DONNES LUES SUR L'ECHELLE DE FREQUENCE FOURNIES

    for j=0,2 do begin 
      b(j,*) = interpol(b_read(j,*),f_read,ff)
      x(j,*) = interpol(x_read(j,*),f_read,ff)
    endfor
      
    (*p.src.data)(isrc).mag_field_line(ilon).b    = ptr_new(b,/allocate)
    (*p.src.data)(isrc).mag_field_line(ilon).x    = ptr_new(x,/allocate)
    (*p.src.data)(isrc).mag_field_line(ilon).fmax = max(f_read)
  endfor
  
  ; NB: We have loaded the data for source isrc0. We won't load the same data 
  ;     again nor duplicate it. We just have to put the pointer address of the
  ;     data already loaded into the isrc pointers. 
  
  if isrc1 gt isrc0 then for isrc=isrc0+1,isrc1 do begin
    (*p.src.data)(isrc).mag_field_line.b    = (*p.src.data)(isrc0).mag_field_line.b
    (*p.src.data)(isrc).mag_field_line.x    = (*p.src.data)(isrc0).mag_field_line.x
    (*p.src.data)(isrc).mag_field_line.fmax = (*p.src.data)(isrc0).mag_field_line.fmax    
  endfor
endelse
    
  message,/info,"Source "+name+" successfully added."
  
return
end
