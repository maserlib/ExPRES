; ***********************************
; *                                 *
; *   Routines de simulation JUNO   *
; *                                 *
; ***********************************
; S. Hess (9/2006), P. Zarka (10/2006), B. Cecconi (10/2006)
; ------------------------------------------------------------------------------
; MAIN PROGRAM
; Version:
; 3.2
; History:
; +++++++++++++++++ v3.0
; BC [2006/10/30] : no more common blocks.
; +++++++++++++++++ v3.1
; BC [2006/11/03] : frequency interpolation before computation.
; BC [2006/11/07] : 1 spdyn/source (PZ idea)
; +++++++++++++++++ v3.2
; BC [2006/11/08] : satellite = 2 sources (N and S) 
;                   => no source distinction in main loop
; +++++++++++++++++ v3.3
; BC [2006/11/08] : loop on sources has been suppressed 
; BC [2006/11/09] : loading 2 successive field lines data for (BC/SH idea) :
;                   (i)  real longitude interpolation 
;                   (ii) dFmax/dLon (= dB/dLon @ ionosphere)
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
; source_intensite	-> suppressed [was (*(parameters.src.data)).intensity]
; src_nom			->       *(parameters. src.   names)
; src_data(0,*)		->      (*(parameters. src.   data)). cone_apperture
; src_data(1,*)		->      (*(parameters. src.   data)). lag_active
; src_data(2,*)		->      (*(parameters. src.   data)). shape_cone
; rpd				->       *(parameters. obs.   param.  rpd)
; intensite_opt		-> suppressed [was (*(parameters.src.data)).intensite_opt]

if keyword_set(verbose) then verbose = 1b else verbose = 0b

if verbose then message,/info,""
if verbose then message,/info,"********************************"
if verbose then message,/info,'          Initialisation'
if verbose then message,/info,"********************************"
if verbose then message,/info,""

parameters = {JUNO_PARAMETERS}

JUNO_INIT,parameters,verbose=verbose


if verbose then message,/info,'Simulation des emissions radio de Jupiter vue par un observateur '
if verbose then if parameters.obs.motion then begin
  message,/info,"decrivant l'ORBITE:"
  ; a completer ...
endif else begin 
  ;stop
  rtp_obs = xyz_to_rtp(parameters.obs.pos_xyz)
  message,/info,"fixe situe a r="+STRTRIM(rtp_obs(0),2)+$
  "colatitude="+STRTRIM(rtp_obs(1),2)+" longitude="+ STRTRIM(-rtp_obs(2),2)
endelse
  
if verbose then message,/info,""
if verbose then message,/info,"La simulation demarre a "+STRTRIM(parameters.local_time(0)/15.,2)+" heure (meridien 0) et dure "+ $
  STRTRIM(parameters.simul.length,2)+" minutes"
if verbose then message,/info,"par pas de "+STRTRIM(parameters.simul.step,2)+" minute(s)"
if verbose then message,/info,""
if verbose then message,/info,"Cette simulation contient "+STRTRIM(parameters.src.ntot,2)+" sources d'emissions ";+ $
;  "dont "+STRTRIM(parameters.src.nsat,2)+" satellites:"
;  for i=0,n_sources-1 do if is_sat(i) then print,src_nom(i),"   satellite" else print,src_nom(i)

xtmp=0. & ytmp=0. & ztmp=0.
nfreq = parameters.freqs.n
nstep = parameters.simul.nsteps+1
nsrcs = parameters.src.ntot
spdyn=fltarr(nfreq,nstep,nsrcs)
if nsrcs eq 1 then spdyn = reform(spdyn,nfreq,nstep,1)
  
set_plot,'X'

if verbose then show_parameters,parameters

if verbose then message,/info,""
if verbose then message,/info,"********************************"
if verbose then message,/info,'          Main Loop'
if verbose then message,/info,"********************************"
if verbose then message,/info,""


for boucle_temps=0L,parameters.simul.nsteps do begin
    print, boucle_temps

  if verbose then message,/info,"Simulation Step # "+string(boucle_temps)
;if boucle_temps eq 300 then stop_flag=1b else stop_flag=0b
  ROTATION_PLANETE_SAT,boucle_temps,parameters=parameters,verbose=verbose

  FIELD_LINE_EMISSION, stop_flag=stop_flag, $
    parameters,intensite, position, /b_interp,verbose=verbose
;if boucle_temps eq 300 then stop;_flag=1b else stop_flag=0b
  spdyn(*,boucle_temps,*) = spdyn(*,boucle_temps,*) $
                          + reform(intensite,nfreq,1,nsrcs);*(*(parameters.src.data))(boucle2_sources).intensity

  spdyn(*,0)=1.
  xtmp=[xtmp,parameters.obs.pos_xyz(0)]
  ytmp=[ytmp,parameters.obs.pos_xyz(1)]
  ztmp=[ztmp,parameters.obs.pos_xyz(2)]
  if boucle_temps mod 20 eq 0 then begin
    if boucle_temps le 1000 then tvscl,1-transpose(total(spdyn,3) ge 1)
    if boucle_temps gt 1000 then tvscl,1-transpose((total(spdyn,3) ge 1)(*,boucle_temps-1000:boucle_temps))
  endif
endfor		; boucle sur le temps

;stop
  
if verbose then message,/info,""
if verbose then message,/info,"********************************"
if verbose then message,/info,'          Output results'
if verbose then message,/info,"********************************"
if verbose then message,/info,""


;  ECRIRE_SPECTRE, -spdyn, parameters.local_time(0), parameters.simul.length(0), *(parameters.freqs.ramp)

return
end
