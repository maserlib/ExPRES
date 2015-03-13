;***********************************************
;******** simulation JUNO fichier init *********
;***********************************************

pro JUNO_INIT,params,verbose=verbose,diag_theta=diag_theta


; ==============================================================================
; si diag_theta = 1 alors on sauvegarde dans angle.dat les angles
; obs/planete/sources dans angle.dat
; ==============================================================================
diag_theta=0

; Unites : latitudes, longitudes en degres, distances en Rj, temps en minutes, frequences en MHz

; ==============================================================================
; Definition des parametres de la planetes: (periode de revolution, periode 
; keplereienne a un rayon planetaire le tout en minutes)
; ==============================================================================

  SET_PLANET, planet='Jupiter', parameters=params

; ==============================================================================
; Definition de la longitude (+inclinaison) planetocentrique du Soleil (a t=0?):
; ==============================================================================

  SET_LOCAL_TIME, longitude=0., inclination=0., parameters=params

; ==============================================================================
; Duree totale et pas de la simulation:
; ==============================================================================

  SET_SIMULATION_TIME, simul_length=480., simul_step=.25, parameters=params
;  SET_SIMULATION_TIME, simul_length=3000., simul_step=.25, parameters=params
;  SET_SIMULATION_TIME, simul_length=1200., simul_step=0.5, parameters=params
;  SET_SIMULATION_TIME, simul_length=1200., simul_step=1., parameters=params
;  SET_SIMULATION_TIME, simul_length=800., simul_step=1., parameters=params

; ==============================================================================
; Observateur fixe ou mobile:
; ==============================================================================

  SET_OBSERVER, name="fixe", motion=0b, obs_params=[3000.,0.,351.], parameters=params,verbose=verbose
;  SET_OBSERVER, name="fixe", motion=0b, obs_params=[3000.,0.,119.], parameters=params
  ; obs_params : position fixe de l'observateur 
  ;            = [distance, latitude, longitude] (a t=0?) 
;  SET_OBSERVER, name="orbiter", motion=1b, obs_params=[20.31,6.5,119.,90.,90.], parameters=params
;  SET_OBSERVER, name="orbiter", motion=1b, obs_params=[20.31,6.5,351.,90.,90.], parameters=params,verbose=verbose
 
  ;            = [semi_major_axis, semi_minor_axis, apoapsis longitude, apoapsis declination, orbit inclinaison, initial phase]
  ; NB initial phase = angle de phase sur l'orbite a t=0 par rapport au centre de l'ellipse avec phase=0 a l'apojove

; ==============================================================================
; Definition des frequences d'observation:
; fmin, fmax, step_f pour le spectre dynamique produit
; ==============================================================================

 SET_FREQUENCY, fmin=.1, fmax=40., fstep=0.2, parameters=params				
;  SET_FREQUENCY, fmin=1., fmax=40., fstep=0.2,  parameters=params


; ==============================================================================
; Label du nom de la source, nom du repertoire de stockage des parametres 
; precalcules pour cette source
; ==============================================================================

;ADD_SOURCE, name="Ovale Nord", directory="OvaleN", active_LT=[0,3,3],verbose=verbose,parameters=params,cone_app=70., cone_wid=.2, shape=0.2;,/gradb_test;,/intensity
;ADD_SOURCE, name="Ovale Sud",  directory="OvaleS", active_LT=[0,60,3],verbose=verbose,parameters=params,cone_app=70., cone_wid=.2, shape=0.2;,/gradb_test;,/intensity

;ADD_SOURCE, name="Io Flux Tube", directory="IFT", /satellite, pos_t0=[5.95, 105.], lag=[30.,-30.], shape=[0.1,0.1], cone_app=[70.,70.], cone_wid=[1.,1.], parameters=params,verbose=verbose,pole=[1,-1];,/intensity
;ADD_SOURCE, name="Io Flux Tube", directory="IFT", /satellite, pos_t0=[5.95, 105.], lag=[25.,-10.], shape=[0.1,0.1], cone_app=[70.,70.], cone_wid=[1.,1.], parameters=params,verbose=verbose,pole=[1,-1];,/intensity
ADD_SOURCE, name="Io Flux Tube", directory="IFT", /satellite, pos_t0=[5.95, 105.], lag=[30.,-30.], shape=[0.1,0.1], cone_app=[70.,70.], cone_wid=[1.,1.], parameters=params,verbose=verbose,pole=[1,-1],gradb_test=1;,/intensity

end