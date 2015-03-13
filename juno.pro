; ***********************************
; *                                 *
; *   Routines de simulation JUNO   *
; *                                 *
; ***********************************
; S. Hess (9/2006), P. Zarka (10/2006), B. Cecconi (10/2006)
; ------------------------------------------------------------------------------
; MAIN PROGRAM
; Version:
; 3.1
; History:
; BC [2006/10/30] : no more common blocks.
; BC [2006/11/03] : frequency interpolation before computation.
; BC [2006/11/07] : 1 spdyn/source (PZ idea)
; ------------------------------------------------------------------------------

; ------------------------------------------------------------------------------
  pro JUNO, spdyn,verbose=verbose
; ------------------------------------------------------------------------------

;COMMON GLOBAL, n_pas, n_sources, nsat, longitude_sat, obs_mov, local_time, sim_time, $
;	is_sat, pos_sat, xyz_obs, chemin, freq_scl, theta, dtheta, orbite_param, $
;	obs_name, rtp_obs, source_intensite, src_nom, src_data, rpd, intensite_opt
;
; COMMON BLOCK variables replaced with : 
; n_pas				->         parameters. simul. nsteps
; n_sources			->         parameters. src.   ntot
; nsat				-> total(*(parameters. src.   is_sat))
; longitude_sat		->      (*(parameters. src.   data)). longitude
; obs_mov			->         parameters. obs.   motion
; local_time		->         parameters. local_time
; sim_time(0)		->         parameters. simul. length
; sim_time(1)		->         parameters. simul. step
; is_sat			->       *(parameters. src.   is_sat)
; pos_sat			->      (*(parameters. src.   data)). distance
; xyz_obs			->         parameters. obs.   pos_xyz
; chemin			->       *(parameters. src.   dirs)
; freq_scl			->       *(parameters. freqs. ramp)
; theta				->      (*(parameters. src.   data)). cone_apperture
; dtheta			->      (*(parameters. src.   data)). cone_thickness
; orbite_param		->       *(parameters. abs.   param)
; obs_name			-> suppressed
; rtp_obs			-> suppressed
; source_intensite	->      (*(parameters. src.   data)). intensity
; src_nom			->       *(parameters. src.   names)
; src_data(0,*)		->      (*(parameters. src.   data)). cone_apperture
; src_data(1,*)		->      (*(parameters. src.   data)). lag_active
; src_data(2,*)		->      (*(parameters. src.   data)). shape_cone
; rpd				->       *(parameters. obs.   param.  rpd)
; intensite_opt		->      (*(parameters. src.   data)). intensite_opt

message,/info,""
message,/info,"********************************"
message,/info,'          Initialisation'
message,/info,"********************************"
message,/info,""

parameters = {JUNO_PARAMETERS}

if keyword_set(verbose) then verbose = 1b else verbose = 0b

JUNO_INIT,parameters,verbose=verbose


  print,'Simulation des emissions radio de Jupiter vue par un observateur '
  if parameters.obs.motion then begin
    print,"decrivant l'ORBITE:"
    ; a completer ...
  endif else begin 
    ;stop
    rtp_obs = xyz_to_rtp(parameters.obs.pos_xyz)
    print,"fixe situe a r="+STRTRIM(rtp_obs(0),2)+$
	"colatitude="+STRTRIM(rtp_obs(1),2)+" longitude="+ STRTRIM(-rtp_obs(2),2)
  endelse
  
  print,""
  print,"La simulation demarre a "+STRTRIM(parameters.local_time(0)/15.,2)+" heure (meridien 0) et dure "+ $
	STRTRIM(parameters.simul.length,2)+" minutes"
  print,"par pas de "+STRTRIM(parameters.simul.step,2)+" minute(s)"
  print,""
  print,"Cette simulation contient "+STRTRIM(parameters.src.ntot,2)+" sources d'emissions ";+ $
;  "dont "+STRTRIM(parameters.src.nsat,2)+" satellites:"
;  for i=0,n_sources-1 do if is_sat(i) then print,src_nom(i),"   satellite" else print,src_nom(i)

  xtmp=0. & ytmp=0. & ztmp=0.
  nfreq = parameters.freqs.n
  nstep = parameters.simul.nsteps+1
  nspec = parameters.src.ntot
  spdyn=fltarr(nfreq,nstep,nspec)
  if nspec eq 1 then spdyn = reform(spdyn,nfreq,nstep,1)
  
  set_plot,'X'

  if verbose then show_parameters,parameters
;stop
  for boucle_temps=0L,parameters.simul.nsteps do begin

    if verbose then message,/info,"Simulation Step # "+string(boucle_temps)
if boucle_temps eq 300 then stop;_flag=1b else stop_flag=0b
    ROTATION_PLANETE_SAT,boucle_temps,parameters=parameters,verbose=verbose

    for boucle_sources=0,parameters.src.nsrc-1L do begin

      if (*parameters.src.is_sat)(boucle_sources) then begin
;stop
if boucle_temps eq 300 then stop;_flag=1b else stop_flag=0b

        FIELD_LINE_EMISSION, stop_flag=stop_flag, $
            parameters.obs.pos_xyz, $
            (*(parameters.src.data))(boucle_sources).longitude, $
            (*parameters.src.dirs)(boucle_sources), $
            intensite, *(parameters.freqs.ramp), position, $
            (*(parameters.src.data))(boucle_sources).cone_apperture(0), $
            (*(parameters.src.data))(boucle_sources).cone_thickness(0), $
            (*(parameters.src.data))(boucle_sources).cone_apperture(0), $
            (*(parameters.src.data))(boucle_sources).lag_active(0), $
            (*(parameters.src.data))(boucle_sources).shape_cone(0), $
            (*(parameters.src.data))(boucle_sources).intensite_opt

;        SCALE_FREQUENCY, intensite, frequence, intensite_scl, $
;            *(parameters.freqs.ramp), $
;            (*(parameters.src.data))(boucle_sources).intensite_opt

        spdyn(*,boucle_temps,(*parameters.src.nrange)(0,boucle_sources)) = spdyn(*,boucle_temps) $
                              + intensite*(*(parameters.src.data))(boucle_sources).intensity

        FIELD_LINE_EMISSION, $
            parameters.obs.pos_xyz, $
            -(*(parameters.src.data))(boucle_sources).longitude, $
            (*parameters.src.dirs)(boucle_sources), $
            intensite,  *(parameters.freqs.ramp), position, $
            (*(parameters.src.data))(boucle_sources).cone_apperture(1), $
            (*(parameters.src.data))(boucle_sources).cone_thickness(1), $
            (*(parameters.src.data))(boucle_sources).cone_apperture(1), $
            (*(parameters.src.data))(boucle_sources).lag_active(1), $
            (*(parameters.src.data))(boucle_sources).shape_cone(1), $
            (*(parameters.src.data))(boucle_sources).intensite_opt

;        SCALE_FREQUENCY, intensite, frequence, intensite_scl, $
;            *(parameters.freqs.ramp), $
;            (*(parameters.src.data))(boucle_sources).intensite_opt

        spdyn(*,boucle_temps,(*parameters.src.nrange)(1,boucle_sources)) = spdyn(*,boucle_temps) $
                              + intensite*(*(parameters.src.data))(boucle_sources).intensity

      endif else begin
        
        for boucle2_sources=(*parameters.src.nrange)(0,boucle_sources),(*parameters.src.nrange)(1,boucle_sources) do begin

          FIELD_LINE_EMISSION, $
            parameters.obs.pos_xyz, $
            (*(parameters.src.data))(boucle2_sources).longitude, $
            (*parameters.src.dirs)(boucle_sources), $
            intensite,  *(parameters.freqs.ramp), position, $
            (*(parameters.src.data))(boucle2_sources).cone_apperture(0), $
            (*(parameters.src.data))(boucle2_sources).cone_thickness(0), $
            (*(parameters.src.data))(boucle2_sources).cone_apperture(0), $
            (*(parameters.src.data))(boucle2_sources).lag_active(0), $
            (*(parameters.src.data))(boucle2_sources).shape_cone(0), $
            (*(parameters.src.data))(boucle2_sources).intensite_opt

	      spdyn(*,boucle_temps,boucle2_sources) = spdyn(*,boucle_temps) $
                                + intensite*(*(parameters.src.data))(boucle2_sources).intensity
        endfor	; boucle sur la longitude
      endelse
    endfor	; boucle sur les sources
    ; if obs_mov eq "orb" then ORBITE
    spdyn(*,0)=1.
    xtmp=[xtmp,parameters.obs.pos_xyz(0)]
    ytmp=[ytmp,parameters.obs.pos_xyz(1)]
    ztmp=[ztmp,parameters.obs.pos_xyz(2)]
    if boucle_temps mod 20 eq 0 then begin
      if boucle_temps le 1000 then tvscl,1-transpose(total(spdyn,3) ge 1)
      if boucle_temps gt 1000 then tvscl,1-transpose((total(spdyn,3) ge 1)(*,boucle_temps-1000:boucle_temps))
      ; if boucle_temps ne 0 then plot,xtmp(1:n_elements(xtmp)-1),ytmp(1:n_elements(xtmp)-1)
    endif
  endfor		; boucle sur le temps
stop
  

  ECRIRE_SPECTRE, -spdyn, parameters.local_time(0), parameters.simul.length(0), *(parameters.freqs.ramp)

return
end
