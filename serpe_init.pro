;***********************************************
;    SERPE Modeling / Initialization file    *
;***********************************************

pro SERPE_INIT,params,verbose=verbose

; Unites : latitudes, longitudes en degres, distances en Rp, 
; temps en minutes, frequences en MHz

; ==============================================================================
; Definition des parametres de la planetes: (periode de revolution, periode
; keplereienne a un rayon planetaire le tout en minutes)
; ==============================================================================

  SET_PLANET, planet='Saturn', parameters=params

; ==============================================================================
; Definition de la longitude (+inclinaison) planetocentrique du Soleil (a t=0?):
; ==============================================================================

  SET_LOCAL_TIME, longitude=0., inclination=0., parameters=params

; ==============================================================================
; Observateur fixe ou mobile:
; ==============================================================================

;SET_OBSERVER, name="orbiter", motion=2b, parameters=params,verbose=verbose,$
;ephem='Ephem/Ephem_xyz_2003181_2007180.sav',tb=aj_t97(2006180),te=aj_t97(2006203),resampl=1./50.

 SET_OBSERVER, name="orbiter", motion=1b, obs_params=[25.1,12.3,-183,0.,0.,0.], parameters=params,verbose=verbose
;   obs_params = [semi_major_axis, semi_minor_axis, apoapsis longitude, apoapsis declination, orbit inclinaison, initial phase]
;   NB initial phase = angle de phase sur l'orbite a t=0 par rapport au centre de l'ellipse avec phase=0 a l'apojove

; SET_OBSERVER, name="fixe", motion=0b, obs_params=[3000.,3.,351.], parameters=params,verbose=verbose
;   obs_params : position fixe de l'observateur = [distance, latitude, longitude] 

; ==============================================================================
; Duree totale et pas de la simulation:
; ==============================================================================

;SET_SIMULATION_TIME, parameters=params,/real_xyz
 SET_SIMULATION_TIME, simul_length=480., simul_step=.25, parameters=params


; ==============================================================================
; Definition des frequences d'observation:
; fmin, fmax, step_f pour le spectre dynamique produit
; ==============================================================================

SET_OUTPUT,path='temp/',/pdf,/local_time,step_tl=3,step_lati=1,step_dist=1,$
/kHz,/log,parameters=params

;  SET_FREQUENCY,framp='f.sav', parameters=params	
 SET_FREQUENCY, fmin=.1, fmax=40., fstep=0.1, parameters=params

; SET_DENSITY,[24000,0.02,0],parameters=params   ; Ionosphere
; SET_DENSITY,[1250.,0.9,1],parameters=params    ; Io torus
; SET_DENSITY,[2400,1.,2],parameters=params      ; Plasma disc

; ==============================================================================
; Label du nom de la source, nom du repertoire de stockage des parametres
; precalcules pour cette source
; ==============================================================================

ADD_SOURCE, name="Ovale Nord", directory="OvaleN_SPV", active_LT=[21.,13.,0.1],axisym_latitude=[15,15,1],$
verbose=verbose,parameters=params,cone_app=70, cone_wid=5, cone_shape='loss cone asymp',shape=0.1
;ADD_SOURCE, name="Ovale Nord", directory="OvaleN", active_LT=[6,9,1],verbose=verbose,parameters=params,cone_app=70., cone_wid=.2, shape=0.2;,/gradb_test;,/intensity
;ADD_SOURCE, name="Ovale Sud",  directory="OvaleS", active_LT=[0,60,3],verbose=verbose,parameters=params,cone_app=70., cone_wid=.2, shape=0.2;,/gradb_test;,/intensity

;ADD_SOURCE, name="Io Flux Tube", directory="IFT", /satellite, pos_t0=[5.95, 105.], lag=[30.,-30.], shape=[0.1,0.1], cone_app=[70.,70.], cone_wid=[1.,1.], parameters=params,verbose=verbose,pole=[1,-1];,/intensity
;ADD_SOURCE, name="Io Flux Tube", directory="IFT", /satellite, pos_t0=[5.95, 105.], lag=[25.,-10.], shape=[0.1,0.1], cone_app=[70.,70.], cone_wid=[1.,1.], parameters=params,verbose=verbose,pole=[1,-1];,/intensity
;ADD_SOURCE, name="Io Flux Tube", directory="IFT", /satellite,cone_shape="loss dens", pos_t0=[5.95, 105.], lag=[30.,-30.], shape=[0.2,0.2], cone_app=[70.,70.], cone_wid=[1.,1.], parameters=params,verbose=verbose,pole=[1,-1];,gradb_test=1;,/intensity
;ADD_SOURCE, name="Io Flux Tube", directory="IFT", /satellite,cone_shape="loss dens", pos_t0=[5.95, 105.], lag=[30.,-30.], shape=[0.2,0.2], cone_app=[70.,70.], cone_wid=[1.,1.], parameters=params,verbose=verbose,pole=[1,-1];,gradb_test=1;,/intensity

end