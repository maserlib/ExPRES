; ***********************************
; *                                 *
; *   Routines de simulation JUNO   *
; *                                 *
; ***********************************
; S. Hess (9/2006), P. Zarka (10/2006), B. Cecconi (10/2006)


; ------------------------------------------------------------------------------------
  pro ROTATION_PLANETE_SAT,istep,parameters=p,verbose=verbose
; ------------------------------------------------------------------------------------

;COMMON GLOBAL, n_pas, n_sources, nsat, longitude_sat, obs_mov, local_time, sim_time, $
;	is_sat, pos_sat, pos_xyz, chemin, freq_scl, theta, dtheta, orbite_param, $
;	obs_name, rtp_obs, source_intensite, src_nom, src_data, rpd, intensite_opt


; ------ rtp_obs = spherical coordinates for observer (from p.obs.pos_xyz)


; ====== updating observer position

  if p.obs.motion then begin

; ------ mobile observer 

    if verbose then message,/info,'++ ORBITING OBSERVER ++'

    rpd = *((*(p.obs.param)).rpd)
    tmpe = (*(p.obs.param)).phase
    xyz_obs = p.obs.pos_xyz
    
    ORBITE, p.obs.param, rpd, xyz_obs, tmpe, p.simul.step
    (*(p.obs.param)).phase = tmpe

    rtp = XYZ_TO_RTP(xyz_obs)
    rtp(2) += -2.*!pi/595.5*p.simul.step*(istep+1l)

    xyz_obs = [sin(rtp(1))*cos(rtp(2)),sin(rtp(1))*sin(rtp(2)),cos(rtp(1))]
    xyz_obs = rtp(0)*xyz_obs

    p.obs.pos_xyz = xyz_obs
    
    if verbose then message,/info,'XYZ    : '+strjoin(string(p.obs.pos_xyz))
    if verbose then message,/info,'RTP    : '+strjoin(string(rtp))
    if verbose then message,/info,'phases : '+strjoin(string([0,tmpe,-2.*!pi/595.5*p.simul.step*(istep+1l)]))
  endif else begin

; ------ fix observer 

    if verbose then message,/info,'++ FIX OBSERVER ++'

; + RCL_OBS : Radius,Colatitude,Longitude (Longitude=-Azimuth)
    rcl_obs = xyz_to_rtp(p.obs.pos_xyz)*[1,1,-1]
    if verbose then message,/info,'R,Colat,Lon (before) : '+strjoin(string(rcl_obs))
    
    rcl_obs = rcl_obs+[0.,0.,2.*!pi/595.5*p.simul.step]
    if rcl_obs[2] ge (2.*!pi) then rcl_obs[2] -= (2.*!pi)
    if rcl_obs[2] lt 0        then rcl_obs[2] += (2.*!pi)
    if verbose then message,/info,'R,Colat,Lon (after)  : '+strjoin(string(rcl_obs))
    if verbose then message,/info,'XYZ (before) : '+strjoin(string(p.obs.pos_xyz))
    p.obs.pos_xyz[0:1] = [ sin(rcl_obs(1))*cos(rcl_obs(2)), $
	                       -sin(rcl_obs(1))*sin(rcl_obs(2))  ]
    p.obs.pos_xyz[0:1]=rcl_obs(0)*p.obs.pos_xyz[0:1]
    if verbose then message,/info,'XYZ (after)  : '+strjoin(string(p.obs.pos_xyz))
;stop
  endelse
  
; ====== updating sources position
  wsat = where((*p.src.is_sat))
  if wsat(0) ne -1 then $
  for boucle_sat=0,total((*p.src.is_sat))-1L do begin
      isat = wsat(boucle_sat)
      for boucle_sources=(*p.src.nrange)(0,isat),(*p.src.nrange)(1,isat) do begin
        (*(p.src.data))(boucle_sources).longitude = $
             (*(p.src.data))(boucle_sources).longitude $
             - p.simul.step*360.*(1./((*(p.src.data))(boucle_sources).distance^1.5*175.53)-1./595.5)
        if (*(p.src.data))(boucle_sources).longitude ge 360. then (*(p.src.data))(boucle_sources).longitude=(*(p.src.data))(boucle_sources).longitude-360.
       ;print,(*(p.src.data))(boucle_sources).longitude
       endfor
  endfor
;  for boucle_sources=0,p.src.ntot-1 do begin
;    if (p.src.is_sat(boucle_sources)) then begin
;      (*(p.src.data))(boucle_sources).longitude = $
;	(*(p.src.data))(boucle_sources).longitude-p.simul.step*360.*(1./((*(p.src.data))(boucle_sources).distance^1.5*175.53)-1./595.5)
;      if (*(p.src.data))(boucle_sources).longitude ge 360. then (*(p.src.data))(boucle_sources).longitude=(*(p.src.data))(boucle_sources).longitude-360.
;       ;print,(*(p.src.data))(boucle_sources).longitude
;    endif
;  endfor
; inclure la variation en temps local
;stop
return
end
