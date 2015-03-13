; ************************************
; *                                  *
; *   Routines de simulation SERPE   *
; *                                  *
; ************************************
; S. Hess (9/2006), P. Zarka (10/2006), B. Cecconi (10/2006), L. Lamy (02/2007)
; ------------------------------------------------------------------------------
; MAIN PROGRAM
; Version:
; 3.2
; History:
; +++++++++++++++++ v3.0
; BC [2006/10/30] : - no more common blocks.
; +++++++++++++++++ v3.1
; BC [2006/11/03] : - frequency interpolation before computation.
; BC [2006/11/07] : - 1 spdyn/source (PZ idea)
; +++++++++++++++++ v3.2
; BC [2006/11/08] : - satellite = 2 sources (N and S)
;                   => no source distinction in main loop
; +++++++++++++++++ v3.3
; BC [2006/11/08] : - loop on sources has been suppressed
; BC [2006/11/09] : - loading 2 successive field lines data for (BC/SH idea) :
;                   (i)  real longitude interpolation
;                   (ii) dFmax/dLon (= dB/dLon @ ionosphere)
; +++++++++++++++++ v3.4
; BC [2006/11/09] : - loading all field lines and interpolate them on frequency
;                   ramp at init time (save time in case for long simul. and
;                   numerous auroral sources)
; +++++++++++++++++ v3.5
; SH [2006/12/03] : - active_LT implemented
;                   - Bmag gradient test implemented
;                   - added Set_planet procedure in JUNO_init.pro call
;                   - modified shape keyword to include linear variation of
;                   beaming
; BC [2007/01/15] : - added remote run capability for charybde users in juno
;                   group. They must add the following lines in their .cshrc :
;                       setenv ROOT_JUNO    '/Groups/JUNO/Simu-JUNO'
;                       alias idl_juno      '$ROOT_JUNO/idl_juno'
;                   then the juno simulation routines can be launched in any
;                   directory. If a local juno_init.pro routine is present, it
;                   will be used instead of the general one.
;                   - added SET_OUTPUT_PATH in JUNO_INIT.
;                   - added framp keyword in SET_FREQUENCY
; +++++++++++++++++ v3.6
; SH [2007/02/01] : - axisym_latitude added
;                   - angle between major axis and equatorial plane added
;                   - possibility of planet parameters modification added
;                   - few other things so important that I can't remember them
; LL [2007/02/14] : - spdyn array definition corrected in time
;                   - local time/latitude calculation added
; +++++++++++++++++ v4.0
; SH [2007/06/29] : _ lot of bug corrections
;               - pb with fmax
;               - all hard coded specific instructions removed:must be coded as options
;               - 0° longitude problem for south field line of the satellites
;               - some minor corrections
;
;             _ added parameters.working_dir : may be getenv('$ROOT_JUNO') if it exists
;               or a different path
;             _ added parameters.display_mgr : 'X' or 'WIN' for the poor windows users
;             _ added density effet on beaming (SET_DENSITY) and Parameters.dense.(n|data)
; +++++++++++++++++ v4.1
; LL [2007/10/10] : - JUNO is now SERPE
;                   - some minor corrections (serpe, set_observer & ecrire_spectre)
;                   - added real tracjectory of the S/C (set_observer, serpe_parameters__define etc...)
;                   - added plasma disc in density profile (add_source)
;                   - added resampling.pro & rebin_spdyn.pro
; LL [2007/02/19] : - added the aurora's altitude (keyword fmax_alt) in add_source for a better 
;                     determination of fmax (only for axisym case)
; ------------------------------------------------------------------------------

; ------------------------------------------------------------------------------
  pro SERPE, spdyn,verbose=verbose,parameters=parameters


; ------------------------------------------------------------------------------

if keyword_set(verbose) then verbose = 1b else verbose = 0b

if verbose then message,/info,""
if verbose then message,/info,"********************************"
if verbose then message,/info,'          Initialization'
if verbose then message,/info,"********************************"
if verbose then message,/info,""

if ~keyword_set(parameters) then parameters = {SERPE_PARAMETERS}

SERPE_init,parameters,verbose=verbose
diag_theta=parameters.output_type.diag_theta

if diag_theta eq 1 then diag_angle=fltarr(n_elements(*parameters.freqs.ramp), parameters.src.ntot,parameters.simul.nsteps)


if verbose then message,/info,'Simulation des emissions radio planetaires vue par un observateur '
if verbose then if parameters.obs.motion then message,/info,"mobile" else begin
  rtp_obs = xyz_to_rtp(parameters.obs.pos_xyz)
  message,/info,"fixe situe a r="+STRTRIM(rtp_obs(0),2)+$
  "colatitude="+STRTRIM(rtp_obs(1),2)+" longitude="+ STRTRIM(-rtp_obs(2),2)
endelse

if verbose then message,/info,""
if verbose then message,/info,"La simulation demarre a "+STRTRIM(parameters.local_time(0)/15.,2)+" heure (meridien 0) et dure "+ $
  STRTRIM(parameters.simul.length,2)+" minutes"
if verbose then message,/info,"par pas de "+STRTRIM(parameters.simul.step,2)+" minute(s)"
if verbose then message,/info,""
if verbose then message,/info,"Cette simulation contient "+STRTRIM(parameters.src.ntot,2)+" sources d'emissions "

nfreq = parameters.freqs.n
nstep = parameters.simul.nsteps
nsrcs = parameters.src.ntot
spdyn=fltarr(nfreq,nstep,nsrcs)
if nsrcs eq 1 then spdyn = reform(spdyn,nfreq,nstep,1)

set_plot,parameters.display_mgr

if verbose then show_parameters,parameters

if verbose then message,/info,""
if verbose then message,/info,"********************************"
if verbose then message,/info,'          Main Loop'
if verbose then message,/info,"********************************"
if verbose then message,/info,""

phi_source0 = 360.-(*(parameters.src.data))(0).longitude ; initial source azimuth
tl_obs = fltarr(parameters.simul.nsteps)
phi        = tl_obs
phi_source = tl_obs
phi_obs    = tl_obs
dist_obs   = tl_obs
lati_obs   = tl_obs

for boucle_temps=0L,parameters.simul.nsteps-1l do begin
  print, boucle_temps, ' / ', parameters.simul.nsteps

  ;if verbose  then message,/info,"Simulation Step # "+string(boucle_temps)
  ;if boucle_temps eq 300 then stop_flag=1b else stop_flag=0b
  
  if verbose  then message,/info,"Simulation Step # "+string(boucle_temps)
  if diag_theta eq 1 then begin
    FIELD_LINE_EMISSION, stop_flag=stop_flag,parameters,intensite, position,verbose=verbose,theta=diagtheta
    diag_angle(*,*, boucle_temps)=diagtheta
  endif else begin
    FIELD_LINE_EMISSION, stop_flag=stop_flag,parameters,intensite, position,verbose=verbose
 endelse
  spdyn(*,boucle_temps,*) = spdyn(*,boucle_temps,*) + reform(intensite,nfreq,1,nsrcs)
  ;*(*(parameters.src.data))(boucle2_sources).intensity

  if boucle_temps mod 20 eq 0 then begin
    if boucle_temps le 1000 then tvscl,1-transpose(total(spdyn,3) ge 1)
    if boucle_temps gt 1000 then tvscl,1-transpose((total(spdyn,3) ge 1)(*,boucle_temps-1000:boucle_temps))
  endif

  if parameters.obs.motion eq 2b then begin
    pos_obs=*((*(parameters.obs.real_pos)).xyz)
    pos_obs=pos_obs(*,boucle_temps)
   
    dist_obs(boucle_temps)=(xyz_to_rtp(pos_obs))(0)
    lati_obs(boucle_temps)=90.-(xyz_to_rtp(pos_obs))(1)*180./!pi 
    tl_obs(boucle_temps) = (atan(pos_obs(1),pos_obs(0))+!pi)/!pi*12.
   
    oplot,[pos_obs(0),pos_obs(0)],[pos_obs(1),pos_obs(1)],psym=3  
    
  endif else if parameters.obs.motion eq 1b then begin
    phi(boucle_temps) = (xyz_to_rtp(parameters.obs.pos_xyz))(2)*!radeg    ; obs azimuth
    phi_source(boucle_temps) = 360.-(*(parameters.src.data))(0).longitude ; source azimuth

    phi_obs(boucle_temps) = phi(boucle_temps)*1.d0-phi_source(boucle_temps)*1.d0+phi_source0*1.d0
    if phi_obs(boucle_temps) lt 0 then phi_obs(boucle_temps) = phi_obs(boucle_temps)+360.
    if phi_obs(boucle_temps) ge 360 then phi_obs(boucle_temps) = phi_obs(boucle_temps)-360.

    ; Latitude calculation (¡):
    dist_obs(boucle_temps)=(xyz_to_rtp(parameters.obs.pos_xyz))(0)
    lati_obs(boucle_temps)=90.-(xyz_to_rtp(parameters.obs.pos_xyz))(1)*180./!pi
    ;test=atan(parameters.obs.pos_xyz(2)/dxy)/!dtor
  
    ; Local time calculation:
    tl_obs(boucle_temps) = phi_obs(boucle_temps)*24./360.+12.
    if tl_obs(boucle_temps) lt 0. then tl_obs(boucle_temps) = tl_obs(boucle_temps)+24.
    if tl_obs(boucle_temps) ge 24. then tl_obs(boucle_temps) = tl_obs(boucle_temps)-24.
  
    teta=phi_obs(boucle_temps)*!dtor
    dxy=(xyz_to_rtp(parameters.obs.pos_xyz))(0)*sin((xyz_to_rtp(parameters.obs.pos_xyz))(1))
    oplot,[dxy*cos(teta),dxy*cos(teta)],[dxy*sin(teta),dxy*sin(teta)],psym=3  
  endif
  
  ROTATION_PLANETE_SAT,boucle_temps,parameters=parameters,verbose=verbose


endfor 


if verbose then message,/info,""
if verbose then message,/info,"********************************"
if verbose then message,/info,'          Output results'
if verbose then message,/info,"********************************"
if verbose then message,/info,""

;sz = size(spdyn) & if sz(4) eq 1 then spdyn=transpose(reform(spdyn)) else spdyn=transpose(total(spdyn, 3))
goto,fin
if parameters.obs.motion eq 2b then ECRIRE_SPECTRE, spdyn,*((*(parameters.obs.real_pos)).time)/1440.-3652.,'DOY',$
'',p=parameters,/oversampling else $
  ECRIRE_SPECTRE, spdyn,findgen(parameters.simul.nsteps)/float(parameters.simul.nsteps)*parameters.simul.length(0),$
  'Time (min)','',p=parameters

if parameters.output_type.radius then begin
  REBIN_SPDYN,parameters,spdyn,dist_obs,spdyn_dist,dist_obs2,/rs
  ECRIRE_SPECTRE,spdyn_dist, dist_obs2,'Distance to the planet (Rp)','_rs',p=parameters
endif
if parameters.output_type.latitude then begin
  REBIN_SPDYN,parameters,spdyn,lati_obs,spdyn_lati,lati_obs2,/lat
  ECRIRE_SPECTRE,spdyn_lati,lati_obs2,'S/C Magnetic Latitude (deg)','_lat',p=parameters
endif
if parameters.output_type.local_time then begin
  REBIN_SPDYN,parameters,spdyn,tl_obs,spdyn_tl,tl_obs2,/tl
  ECRIRE_SPECTRE,spdyn_tl,tl_obs2,'Local Time (h)','_tl',p=parameters
endif
fin:
if parameters.output_type.diag_theta eq 1 then save,filename="angle.dat",diag_angle
return
end
