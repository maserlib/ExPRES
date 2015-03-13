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
;                       setenv ROOT_JUNO	'/Groups/JUNO/Simu-JUNO'
;                       alias idl_juno      '$ROOT_JUNO/idl_juno'
;                   then the juno simulation routines can be launched in any
;                   directory. If a local juno_init.pro routine is present, it
;                   will be used instead of the general one. 
;                   - added SET_OUTPUT_PATH in JUNO_INIT.
;                   - added framp keyword in SET_FREQUENCY 
; ------------------------------------------------------------------------------

; ------------------------------------------------------------------------------
  pro JUNO, spdyn,verbose=verbose
; ------------------------------------------------------------------------------

if keyword_set(verbose) then verbose = 1b else verbose = 0b

if verbose then message,/info,""
if verbose then message,/info,"********************************"
if verbose then message,/info,'          Initialisation'
if verbose then message,/info,"********************************"
if verbose then message,/info,""

parameters = {JUNO_PARAMETERS}

JUNO_init,parameters,verbose=verbose


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
    parameters,intensite, position,verbose=verbose;, /b_interp
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


  ECRIRE_SPECTRE, spdyn, parameters.local_time(0), parameters.simul.length(0), *(parameters.freqs.ramp), parameters.output_path

return
end
