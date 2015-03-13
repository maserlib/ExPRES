; ***********************************
; *                                 *
; *   Routines de simulation JUNO   *
; *                                 *
; ***********************************
; S. Hess (9/2006), P. Zarka (10/2006), B. Cecconi (10/2006)


;PRO satellite_source__define
;tmp = {satellite_source,			$
;       name:		''$;,	$
;      }
;end

;PRO auroral_oval_source__define
;tmp = {auroral_oval_source,			$
;       name:		''$;,	$
;      }
;end

; ==============================================================================
  pro ADD_SOURCE, parameters=p, name=name, directory=directory, satellite=satellite, $
    pos_t0=pos_t0, cone_app=cone_app, cone_wid=cone_width, $
  	intensity=intensity, $
	intensite_random=intensite_random, intensite_n_random=intensite_n_random, $
	intensite_local_time=intensite_local_time,  lag=lag, shape=shape, $
	intensite_norm=int_n, active_lt=active_lt, active_lo=active_lo, $
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

;COMMON GLOBAL, n_pas, n_sources, nsat, longitude_sat, obs_mov, local_time, sim_time, $
;	is_sat, pos_sat, xyz_obs, chemin, freq_scl, theta, dtheta, orbite_param, $
;	obs_name, rtp_obs, source_intensite, src_nom, src_data, rpd, intensite_opt


if keyword_set(satellite) then satellite = 1b else satellite = 0b

; ------------------------------------------------------------------------------  
; Determining the number of sources for the new source
; ------------------------------------------------------------------------------  
  
;  if satellite then n_source = 2L else begin
  if satellite then n_source = 1L else begin
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
        longitudes = active_sector(0)+findgen(n_source)*active_sector(2)
      endelse
  endelse
  
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

  iname = n_elements(*p.src.names)-1

  for isrc=(*p.src.nrange)(0,iname),(*p.src.nrange)(1,iname) do begin
 ;   (*p.src.data)(isrc).pole           = pole(isrc-p.src.ntot+n_source)
    (*p.src.data)(isrc).distance       = (satellite ? pos_t0(0) : 0.)
    (*p.src.data)(isrc).longitude      = (satellite ? pos_t0(1) : longitudes(isrc-(*p.src.nrange)(0,iname)))
    (*p.src.data)(isrc).cone_apperture = cone_app
    (*p.src.data)(isrc).cone_thickness = cone_width
    (*p.src.data)(isrc).lag_active     = (keyword_set(lag) ? lag : [0.,0.])
    (*p.src.data)(isrc).shape_cone     = (keyword_set(shape) ? shape : [-1.,-1.])
    (*p.src.data)(isrc).intensite_opt  = keyword_set(int_n)
    (*p.src.data)(isrc).intensity      = (keyword_set(intensity) ? keyword_set(intensity):2UL^ULONG(isrc))
  endfor
  
  if verbose then message,/info,"Source "+name+" successfully added."
  
return
end
