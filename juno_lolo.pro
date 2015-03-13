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
;                   - local time calculation added (tl_obs)
;                   - ecrire_spectre_tl = dynamic spectrum vs Obs Local Time
;                   - ecrire_spectre_tl2 = 2 dynamic spectra vs Obs Local Time
; +++++++++++++++++
; LL [2007/03/08] : - latitude calculation added (lat_obs)
;                   - ecrire_spectre_lat = dynamic spectrum vs Obs Latitude
;                 
; ------------------------------------------------------------------------------

; ------------------------------------------------------------------------------
  pro JUNO, spdyn,verbose=verbose
; ------------------------------------------------------------------------------

;restore,'params_orb.sav',/verb


for i=0,n_elements(worb)-2l do begin
orbitexyz=pos(*,worb(i):worb(i+1))
torbite=time(worb(i):worb(i+1))

;*******************************************************************************
for v=20,20,1 do begin         ; Boucle Colatitude magnetique
print,'Latitude =',90-v
  for w=70,70,5 do begin      ; Boucle Beaming angle
  print,'Beaming angle =',w
	for x=10,10,1 do begin    ; Boucle Largeur de cone
	print,'Cone Width =',x
;*******************************************************************************

if keyword_set(verbose) then verbose = 1b else verbose = 0b

if verbose then message,/info,""
if verbose then message,/info,"********************************"
if verbose then message,/info,'          Initialisation'
if verbose then message,/info,"********************************"
if verbose then message,/info,""

parameters = {JUNO_PARAMETERS}

JUNO_init,parameters,v,w,float(x),orbitexyz,verbose=verbose,diag_theta=diag_theta
;
if diag_theta eq 1 then diag_angle=fltarr(n_elements(*p.freqs.ramp),parameters.src.ntot,parameters.simul.nsteps)

if verbose then message,/info,'Simulation des emissions radio vue par un observateur '
if verbose then if parameters.obs.motion then begin
  message,/info,"en ORBITE"
endif else begin 
  rtp_obs = xyz_to_rtp(parameters.obs.pos_xyz)
  message,/info,"fixe situe a r="+STRTRIM(rtp_obs(0),2)+$
  "colatitude="+STRTRIM(rtp_obs(1),2)+" longitude="+ STRTRIM(-rtp_obs(2),2)
endelse
  
if verbose then message,/info,""
if verbose then message,/info,"La simulation demarre a "+STRTRIM(parameters.local_time(0)/15.,2)+$
" heure (meridien 0) et dure "+STRTRIM(parameters.simul.length,2)+" minutes"
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

phi_source0 = 360.-(*(parameters.src.data))(0).longitude ; source azimuth
tl_obs     = fltarr(parameters.simul.nsteps)             ; observer local time
phi        = fltarr(parameters.simul.nsteps)                                             
phi_source = fltarr(parameters.simul.nsteps)                                   
phi_obs    = fltarr(parameters.simul.nsteps)                                        
lat_obs    = fltarr(parameters.simul.nsteps) 
dxy_obs    = fltarr(parameters.simul.nsteps) 
dxz_obs    = fltarr(parameters.simul.nsteps) 
x_obs = fltarr(parameters.simul.nsteps)
y_obs = fltarr(parameters.simul.nsteps)
z_obs = fltarr(parameters.simul.nsteps)

for boucle_temps=0L,parameters.simul.nsteps-1l do begin
  ;print, boucle_tempso
  if verbose  then message,/info,"Simulation Step # "+string(boucle_temps)
if diag_theta eq 1 then begin
FIELD_LINE_EMISSION, stop_flag=stop_flag,parameters,intensite, position,verbose=verbose,theta=diagtheta
diag_angle(*,*, boucle_temps)=diagtheta
endif else FIELD_LINE_EMISSION, stop_flag=stop_flag,parameters,intensite, position,verbose=verbose;,/b_interp
  spdyn(*,boucle_temps,*) = spdyn(*,boucle_temps,*)+reform(intensite,nfreq,1,nsrcs)
  ;*(*(parameters.src.data))(boucle2_sources).intensity

  ;spdyn(*,0)=1.
  xtmp=[xtmp,parameters.obs.pos_xyz(0)]
  ytmp=[ytmp,parameters.obs.pos_xyz(1)]
  ztmp=[ztmp,parameters.obs.pos_xyz(2)]
  
  if boucle_temps mod 20 eq 0 then begin
    if boucle_temps le 1000 then tvscl,1-transpose(total(spdyn,3) ge 1)
    if boucle_temps gt 1000 then tvscl,1-transpose((total(spdyn,3) ge 1)(*,boucle_temps-1000:boucle_temps))
  endif

  ; Local time calculation:
  phi(boucle_temps) = (xyz_to_rtp(parameters.obs.pos_xyz))(2)*!radeg    ; obs azimuth 
  phi_source(boucle_temps) = 360.-(*(parameters.src.data))(0).longitude ; source azimuth

  phi_obs(boucle_temps) = phi(boucle_temps)*1.d0-phi_source(boucle_temps)*1.d0+phi_source0*1.d0
  stop
  if phi_obs(boucle_temps) lt 0 then phi_obs(boucle_temps) = phi_obs(boucle_temps)+360.
  if phi_obs(boucle_temps) ge 360 then phi_obs(boucle_temps) = phi_obs(boucle_temps)-360.

  tl_obs(boucle_temps) = phi_obs(boucle_temps)*24./360.+12.
  if tl_obs(boucle_temps) lt 0. then tl_obs(boucle_temps) = tl_obs(boucle_temps)+24.
  if tl_obs(boucle_temps) ge 24. then tl_obs(boucle_temps) = tl_obs(boucle_temps)-24.

  ; S/C position:
  x_obs(boucle_temps) = parameters.obs.pos_xyz(0)
  y_obs(boucle_temps) = parameters.obs.pos_xyz(1)
  z_obs(boucle_temps) = parameters.obs.pos_xyz(2)

  ; Latitude calculation (¡):
  dxy_obs(boucle_temps) = sqrt(parameters.obs.pos_xyz(1)^2+parameters.obs.pos_xyz(0)^2)
  dxz_obs(boucle_temps) = sqrt(parameters.obs.pos_xyz(2)^2+parameters.obs.pos_xyz(0)^2)
  lat_obs(boucle_temps) = atan(parameters.obs.pos_xyz(2)/dxy_obs(boucle_temps))/!dtor

  teta=phi_obs(boucle_temps)*!dtor
  oplot,[dxy_obs(boucle_temps)*cos(teta),dxy_obs(boucle_temps)*cos(teta)],$
  [dxy_obs(boucle_temps)*sin(teta),dxy_obs(boucle_temps)*sin(teta)],psym=1

  ;teta=lat_obs(boucle_temps)
  ;oplot,[dxz_obs(boucle_temps)*cos(teta),dxz_obs(boucle_temps)*cos(teta)],$
  ;[dxz_obs(boucle_temps)*sin(teta),dxz_obs(boucle_temps)*sin(teta)],psym=3


  ROTATION_PLANETE_SAT,boucle_temps,parameters=parameters,verbose=verbose  
endfor

  stop

if verbose then message,/info,""
if verbose then message,/info,"********************************"
if verbose then message,/info,'          Output results'
if verbose then message,/info,"********************************"
if verbose then message,/info,""

titreim='Simu_LT_0_24_colat_'+strtrim(string(v),1)+'_beaming_'+strtrim(string(w),1)+$
'_wid_'+strtrim(string(x),1)+'_Rs_30_Orbite_'+strtrim(string(i),1)
path = parameters.output_path 
sz = size(spdyn)
if sz(4) eq 1 then spdyn=transpose(reform(spdyn)) else spdyn=transpose(total(spdyn, 3))
restore,'f.sav'
  
  ; Latitude array OR circular orbite:
  w1 = where(f le min(*(parameters.freqs.ramp)),count1)
  w2 = where(f le max(*(parameters.freqs.ramp)),count2)
  spdyn2=fltarr(sz(2),n_elements(f))
  spdyn2(*,count1-1l:count2-1l) = spdyn

  ; Local time array resampling:
  ;dmin=3.
  ;tl=findgen(24*60/dmin)*dmin/60. & ntl = n_elements(tl)
  ;spdyn2 = fltarr(ntl,n_elements(f))
  ;w1 = where(f le min(*(parameters.freqs.ramp)),count1)
  ;w2 = where(f le max(*(parameters.freqs.ramp)),count2)
  ;for i=0,ntl-2l do begin
  ;  wi = where(tl_obs ge tl(i) and tl_obs lt tl(i+1),count)
  ;  if count gt 0 then spdyn2(i,count1-1l:count2-1l) = rebin(spdyn(wi,*),1,n_elements(*(parameters.freqs.ramp)))
  ;endfor


;ECRIRE_SPECTRE_TL, spdyn2, tl,f, titreim, parameters.output_path
;ECRIRE_SPECTRE_LAT, spdyn2, lat_obs,f, titreim, parameters.output_path
;ECRIRE_SPECTRE, spdyn, parameters.local_time(0), parameters.simul.length(0), *(parameters.freqs.ramp), parameters.output_path

spdyn=spdyn2
save,file='Simu_orbites_reelles/'+titreim+'.sav',spdyn,f,tl_obs
spawn,'ps2pdf spectre.ps spectre.pdf'
spawn,'rm -f spectre.ps'


;*******************************************************************************
      endfor       ; Fin de boucle Largeur de cone
    endfor         ; Fin de boucle Beaming Angle
  endfor           ; Fin de boucle Colatitude magnetique
;*******************************************************************************

endfor

if diag_theta eq 1 then save,filename="angle.dat",diag_angle

return
end
