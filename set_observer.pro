; ***********************************
; *                                 *
; *   Routines de simulation JUNO   *
; *                                 *
; ***********************************
; S. Hess (9/2006), P. Zarka (10/2006), B. Cecconi (10/2006)

PRO orb_obs_param__define

; on suppose apojove et perijove dans le plan equatorial

tmp = {orb_obs_param, 			$
       semi_major_axis:		0.,	$
       semi_minor_axis:		0.,	$
       apoapsis_longitude: 	0.,	$
       orbit_inclination:	0.,	$ 
       initial_phase:		0.,	$
       phase:				0., $
       rpd:					ptr_new() }
end

PRO fix_obs_param__define
tmp = {fix_obs_param, 	$
       radius:		0., $
       colatitude:	0.,	$
       longitude:	0.	 }
end

; ------------------------------------------------------------------------------------
  pro SET_OBSERVER, name=name, motion=motion, obs_params=obs_params, parameters=p
; ------------------------------------------------------------------------------------

;COMMON GLOBAL, n_pas, n_sources, nsat, longitude_sat, obs_mov, local_time, sim_time, $
;	is_sat, pos_sat, xyz_obs, chemin, freq_scl, theta, dtheta, orbite_param, $
;	obs_name, rtp_obs, source_intensite, src_nom, src_data, rpd, intensite_opt

; inclure la variation en temps local
  p.obs.motion = motion
  p.obs.name   = name
  
  if p.obs.motion then begin

; ----- Initialization of the Observer orbital parameters 
    p.obs.param=ptr_new({orb_obs_param},/allocate)
    (*(p.obs.param)).semi_major_axis    = obs_params(0)
    (*(p.obs.param)).semi_minor_axis    = obs_params(1)
    (*(p.obs.param)).apoapsis_longitude = obs_params(2)/!radeg
    (*(p.obs.param)).orbit_inclination  = obs_params(3)/!radeg
    (*(p.obs.param)).initial_phase       = obs_params(4)/!radeg
    
    CALC_ORBITE, p.obs.param, rpd
    (*(p.obs.param)).rpd = ptr_new(rpd,/allocate)
    (*(p.obs.param)).phase = rpd(1,0)
    ORBITE, p.obs.param, *((*(p.obs.param)).rpd), xyz_obs, (*(p.obs.param)).phase, p.simul.step

    p.obs.pos_xyz = xyz_obs
    
  endif else begin

; ----- Initialization of the Observer fixed position 
    p.obs.param=ptr_new({fix_obs_param},/allocate)
    (*(p.obs.param)).radius     = obs_params(0)
    (*(p.obs.param)).colatitude = (90. - obs_params(1))/!radeg
    (*(p.obs.param)).longitude  = obs_params(2)/!radeg
    
    p.obs.pos_xyz = (*(p.obs.param)).radius * $
         [ sin( (*(p.obs.param)).colatitude )*cos( (*(p.obs.param)).longitude ), $
           -sin( (*(p.obs.param)).colatitude )*sin( (*(p.obs.param)).longitude ), $
           cos( (*(p.obs.param)).colatitude ) ]
    ;stop
  endelse

;    obs_mov="orb" => voir p.obs.obs.motion
;    orbite_param = orb		; param=[a,b,phia,i,angle] => voir p.obs.obs.param

;  obs_name=name => voir p.obs.obs.name

;  if obs_mov eq "fixe" then begin
;    rtp_obs=pos
;    xyz_obs = [ cos(rtp_obs(1)*!pi/180.)*cos(rtp_obs(2)*!pi/180.), $
;	-cos(rtp_obs(1)*!pi/180.)*sin(rtp_obs(2)*!pi/180.-!pi/2.), sin(rtp_obs(1)*!pi/180.) ]
;    xyz_obs=rtp_obs(0)*xyz_obs
;  endif

;  if obs_mov eq "orb" then begin
;    CALC_ORBITE, orb, rpd
;    rtp_obs=[0.,rpd(1,0),0.]
;    ORBITE, orb, rpd, xyz_obs, rtp_obs(1), p.obs.simul_time(1)
;  endif

  print,p.obs.pos_xyz

return
end
