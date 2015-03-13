; *******************************************
; *                                         *
; *        Routines de simulation SERPE     *
; *                                         *
; *******************************************
; *                                         *
; *          ROTATION_PLANETE_SAT           *
; *                                         *
; *******************************************
; S. Hess (9/2006), P. Zarka (10/2006), B. Cecconi (10/2006), S. Hess(12/2006),
; L. Lamy (10/2007)


; ------------------------------------------------------------------------------------
  pro ROTATION_PLANETE_SAT,istep,parameters=p,verbose=verbose
; ------------------------------------------------------------------------------------

; ------ rtp_obs = spherical coordinates for observer (from p.obs.pos_xyz)
; ====== updating observer position


  if p.obs.motion eq 2b then begin

; ------ mobile observer  on a real trajectory
    if verbose then message,/info,'++ MOVING OBSERVER ++'

    obs_pos=*((*(p.obs.real_pos)).xyz) 
    xyz_obs = obs_pos(*,istep)
    rtp = XYZ_TO_RTP(xyz_obs)
    rtp(2) += -2.*!pi/p.planet_param[1]*p.simul.step*(istep+1l)
    
    ; Obs position in rotating frame xyz
    xyz_obs = [sin(rtp(1))*cos(rtp(2)),sin(rtp(1))*sin(rtp(2)),cos(rtp(1))]
    xyz_obs = rtp(0)*xyz_obs
    
    p.obs.pos_xyz = xyz_obs

  endif else if p.obs.motion eq 1b then begin

; ------ mobile observer on a pre-defined orbite
    if verbose then message,/info,'++ ORBITING OBSERVER ++'

    rpd = *((*(p.obs.param)).rpd)
    tmpe = (*(p.obs.param)).phase
    xyz_obs = p.obs.pos_xyz
    
    ORBITE, p.obs.param, rpd, xyz_obs, tmpe, p.simul.step
    (*(p.obs.param)).phase = tmpe

    rtp = XYZ_TO_RTP(xyz_obs)
    rtp(2) += -2.*!pi/p.planet_param[1]*p.simul.step*(istep+1l)
    
    ; Obs position in rotating frame xyz
    xyz_obs = [sin(rtp(1))*cos(rtp(2)),sin(rtp(1))*sin(rtp(2)),cos(rtp(1))]
    xyz_obs = rtp(0)*xyz_obs

    p.obs.pos_xyz = xyz_obs
    if verbose then message,/info,'XYZ    : '+strjoin(string(p.obs.pos_xyz))
    if verbose then message,/info,'RTP    : '+strjoin(string(rtp))
    if verbose then message,/info,'phases : '+strjoin(string([0,tmpe,-2.*!pi/p.planet_param[1]*p.simul.step*(istep+1l)]))
  
  endif else begin

; ------ fix observer 
    if verbose then message,/info,'++ FIX OBSERVER ++'

; + RCL_OBS : Radius,Colatitude,Longitude (Longitude=-Azimuth)
    rcl_obs = xyz_to_rtp(p.obs.pos_xyz)*[1,1,-1]
    if verbose then message,/info,'R,Colat,Lon (before) : '+strjoin(string(rcl_obs))
    
    rcl_obs = rcl_obs+[0.,0.,2.*!pi/p.planet_param[1]*p.simul.step]
    if rcl_obs[2] ge (2.*!pi) then rcl_obs[2] -= (2.*!pi)
    if rcl_obs[2] lt 0        then rcl_obs[2] += (2.*!pi)
    if verbose then message,/info,'R,Colat,Lon (after)  : '+strjoin(string(rcl_obs))
    if verbose then message,/info,'XYZ (before) : '+strjoin(string(p.obs.pos_xyz))
    p.obs.pos_xyz[0:1] = [ sin(rcl_obs(1))*cos(rcl_obs(2)), $
	                       -sin(rcl_obs(1))*sin(rcl_obs(2))  ]
    p.obs.pos_xyz[0:1]=rcl_obs(0)*p.obs.pos_xyz[0:1]
    if verbose then message,/info,'XYZ (after)  : '+strjoin(string(p.obs.pos_xyz))
  endelse
  
; ====== updating sources position (satellites)
  wsat = where((*p.src.is_sat))
  if wsat(0) ne -1 then $
  for boucle_sat=0,total((*p.src.is_sat))-1L do begin
      isat = wsat(boucle_sat)
      for boucle_sources=(*p.src.nrange)(0,isat),(*p.src.nrange)(1,isat) do begin
        (*(p.src.data))(boucle_sources).longitude = $
             (*(p.src.data))(boucle_sources).longitude $
             - p.simul.step*360.*(1./((*(p.src.data))(boucle_sources).distance^1.5*p.planet_param[0])-1./p.planet_param[1])
        if (*(p.src.data))(boucle_sources).longitude ge 360. then (*(p.src.data))(boucle_sources).longitude=(*(p.src.data))(boucle_sources).longitude-360.
       endfor
  endfor

; ====== updating sources position (oval local time)
  for boucle_fix=0,n_elements((*p.src.nrange)(0,*))-1L do begin
    for boucle_sources=(*p.src.nrange)(0,boucle_fix),(*p.src.nrange)(1,boucle_fix) do if (*p.src.data)(boucle_sources).fixe_lt then begin
     (*(p.src.data))(boucle_sources).longitude = (*(p.src.data))(boucle_sources).longitude+360./p.planet_param[1]*p.simul.step 
	  ;une source fixe en temps local se comporte comme un observateur fixe
      if (*(p.src.data))(boucle_sources).longitude ge 360. then (*(p.src.data))(boucle_sources).longitude=(*(p.src.data))(boucle_sources).longitude-360.
    endif;endfor
  endfor

return
end
