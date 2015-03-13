; ***********************************
; *                                 *
; *   Routines de simulation JUNO   *
; *                                 *
; ***********************************
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
;                       setenv ROOT_JUNO	'/Groups/JUNO/Simu-JUNO'
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
;
; LL [2007/02/14] : - spdyn array definition corrected in time
;                   - local time calculation added
;                 
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

JUNO_init,parameters,verbose=verbose,diag_theta=diag_theta
;

if diag_theta eq 1 then diag_angle=fltarr(n_elements(*p.freqs.ramp),parameters.src.ntot,parameters.simul.nsteps)


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
nstep = parameters.simul.nsteps
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

phi_source0 = 360.-(*(parameters.src.data))(0).longitude ; initial source azimuth
tl_obs = fltarr(parameters.simul.nsteps)
phi = tl_obs
phi_source = tl_obs
phi_obs = tl_obs

for boucle_temps=0L,parameters.simul.nsteps-1l do begin
    print, boucle_temps

;  if verbose  then message,/info,"Simulation Step # "+string(boucle_temps)
  ;if boucle_temps eq 300 then stop_flag=1b else stop_flag=0b

;for boucle_temps=0L,parameters.simul.nsteps-1l do begin
  ;print, boucle_tempso
  if verbose  then message,/info,"Simulation Step # "+string(boucle_temps)
if diag_theta eq 1 then begin
FIELD_LINE_EMISSION, stop_flag=stop_flag,parameters,intensite, position,verbose=verbose,theta=diagtheta
diag_angle(*,*, boucle_temps)=diagtheta
endif else begin
 FIELD_LINE_EMISSION, stop_flag=stop_flag,parameters,intensite, position,verbose=verbose;,/b_interp
  spdyn(*,boucle_temps,*) = spdyn(*,boucle_temps,*)+reform(intensite,nfreq,1,nsrcs)
  ;*(*(parameters.src.data))(boucle2_sources).intensity
endelse
  ;w = where(intensite gt 0, count) & if count gt 0 then stop
  ;if boucle_temps eq 300 then stop;_flag=1b else stop_flag=0b
  spdyn(*,boucle_temps,*) = spdyn(*,boucle_temps,*) $
    + reform(intensite,nfreq,1,nsrcs);*(*(parameters.src.data))(boucle2_sources).intensity

  ;spdyn(*,0)=1.
  xtmp=[xtmp,parameters.obs.pos_xyz(0)]
  ytmp=[ytmp,parameters.obs.pos_xyz(1)]
  ztmp=[ztmp,parameters.obs.pos_xyz(2)]
  if boucle_temps mod 20 eq 0 then begin
    if boucle_temps le 1000 then tvscl,1-transpose(total(spdyn,3) ge 1)
    if boucle_temps gt 1000 then tvscl,1-transpose((total(spdyn,3) ge 1)(*,boucle_temps-1000:boucle_temps))
  endif

  ; Local time calculation:
  phi(boucle_temps) = (xyz_to_rtp(parameters.obs.pos_xyz))(2)*!radeg ; obs azimuth 
  phi_source(boucle_temps) = 360.-(*(parameters.src.data))(0).longitude ; source azimuth

  phi_obs(boucle_temps) = phi(boucle_temps)*1.d0-phi_source(boucle_temps)*1.d0+phi_source0*1.d0
  if phi_obs(boucle_temps) lt 0 then phi_obs(boucle_temps) = phi_obs(boucle_temps)+360.
  if phi_obs(boucle_temps) ge 360 then phi_obs(boucle_temps) = phi_obs(boucle_temps)-360.

  tl_obs(boucle_temps) = phi_obs(boucle_temps)*24./360.+12.
  if tl_obs(boucle_temps) lt 0. then tl_obs(boucle_temps) = tl_obs(boucle_temps)+24.
  if tl_obs(boucle_temps) ge 24. then tl_obs(boucle_temps) = tl_obs(boucle_temps)-24.
  
  ROTATION_PLANETE_SAT,boucle_temps,parameters=parameters,verbose=verbose

  ; WARNING: Erreur persistante = changement de la période par modification du
  ; demi petit axe.
  
endfor ; boucle sur le temps


if verbose then message,/info,""
if verbose then message,/info,"********************************"
if verbose then message,/info,'          Output results'
if verbose then message,/info,"********************************"
if verbose then message,/info,""


;titreim='Simu_LT'
;sz = size(spdyn)
;if sz(4) eq 1 then spdyn=transpose(reform(spdyn)) else spdyn=transpose(total(spdyn, 3))
;
;restore,'f.sav'
;spdyn2 = fltarr(sz(2),n_elements(f))
;w1 = where(f le min(*(parameters.freqs.ramp)),count1)
;w2 = where(f le max(*(parameters.freqs.ramp)),count2)
;spdyn2(*,count1-1l:count2-1l) = spdyn

;  ECRIRE_SPECTRE_TL, spdyn2, tl_obs,f,titreim, parameters.output_path
;  ECRIRE_SPECTRE, spdyn, parameters.local_time(0), parameters.simul.length(0), *(parameters.freqs.ramp), parameters.output_path

;spawn,'ps2pdf spectre.ps '+titreim+'.pdf'
;spawn,'rm -f spectre.ps '
;stop
if diag_theta eq 1 then save,filename="angle.dat",diag_angle

return
end
