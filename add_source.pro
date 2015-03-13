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
	intensity_random=intensity_random, intensity_n_random=intensity_n_random, $
	intensity_local_time=intensity_local_time,  lag=lag, shape=v, $
	intensite_norm=int_n, active_lt=active_lt, active_lo=active_lo
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
      endelse
  endelse
  
; ------------------------------------------------------------------------------  
; Creating the new source and updating sources parameters
; ------------------------------------------------------------------------------  

  if p.src.ntot gt 0L then begin
    tmp_sources_names  = *(p.src.names)
    tmp_sources_dirs   = *(p.src.dirs)
    tmp_sources_is_sat = *(p.src.is_sat)
    tmp_sources_nrange = *(p.src.nrange)
    tmp_sources_data   = *(p.src.data)
    n_names = n_elements(tmp_source_names)
  endif else begin
    n_names=0L
    p.src.names     = ptr_new(0b,/allocate)
    p.src.dirs      = ptr_new(0b,/allocate)
    p.src.is_sat    = ptr_new(0b,/allocate)
    p.src.nrange    = ptr_new(0b,/allocate)
    p.src.data      = ptr_new(0b,/allocate)
  endelse
  *(p.src.names)     = strarr(n_names+1L)
  *(p.src.dirs)      = strarr(n_names+1L)
  *(p.src.is_sat)    = lonarr(2,n_names+1L)
  *(p.src.nrange)    = lonarr(2,n_names+1L)
  *(p.src.data)      = replicate({source},p.src.ntot+n_source)
  if p.src.ntot gt 0L then begin
    (*(p.src.names))(0:n_names-1L)       = tmp_sources_names
    (*(p.src.dirs))(0:n_names-1L)        = tmp_sources_dirs
    (*(p.src.is_sat))(*,0:n_names-1L)    = tmp_sources_is_sat
    (*(p.src.nrange))(*,0:n_names-1L)    = tmp_sources_nrange
    (*(p.src.data))(0:p.src.ntot-1L)     = tmp_sources_data
  endif
  (*(p.src.names))(n_names) = name
  (*(p.src.dirs))(n_names) = directory
  (*(p.src.is_sat))(*,n_names) = bytarr(n_source)+satellite
  (*(p.src.nrange))(*,n_names) = [p.src.ntot,p.src.ntot+n_source-1L]
  (*(p.src.data))(0:p.src.ntot,p.src.ntot+n_source-1L) = replicate({source},n_source)
  
  p.src.ntot = p.src.ntot+n_source



; ------------------------------------------------------------------------------  
; Filling source structure data
; ------------------------------------------------------------------------------  

  iname = n_elements(*p.src.names)-1

  for isrc=(*p.src.nrange)(0,iname),(*p.src.nrange)(1,iname) do begin
    (*p.src.data)(isrc).distance       = pos_t0(0)
    (*p.src.data)(isrc).longitude      = pos_t0(1)
    (*p.src.data)(isrc).cone_apperture = cone_app
    (*p.src.data)(isrc).cone_thickness = cone_width
    (*p.src.data)(isrc).lag_active     = lag
    (*p.src.data)(isrc).shape_cone     = v
    (*p.src.data)(isrc).intensite_opt  = keyword_set(int_n)
    (*p.src.data)(isrc).intensity      = (keyword_set(intensity) ? keyword_set(intensity):2UL^ULONG(isrc))
  endfor
  
return
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
    intensite_opt=keyword_set(int_n)
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
    intensite_opt=[intensite_opt,keyword_set(int_n)]
    chemin=[chemin,camino]
    src_nom=[src_nom,name]
    if ~keyword_set(intensity) then x=2^(n_sources-1) else x=intensity
    source_intensite=[source_intensite,x]
  endelse

return
end
