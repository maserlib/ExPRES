;***********************************************
;******** simulation JUNO fichier init *********
;***********************************************

pro JUNO_INIT,params,verbose=verbose

; Unites : latitudes, longitudes en degres, distances en Rj, temps en minutes, frequences en MHz

; ==============================================================================
; ====== definition de la longitude (+ inclinaison) jovicentrique du Soleil (a t=0?)

  SET_LOCAL_TIME, longitude=0., inclination=0., parameters=params

; ==============================================================================
; ====== duree totale et pas de la simulation

  SET_SIMULATION_TIME, simul_length=480., simul_step=.25, parameters=params
;  SET_SIMULATION_TIME, simul_length=1200., simul_step=0.5, parameters=params
;  SET_SIMULATION_TIME, simul_length=1200., simul_step=1., parameters=params
;  SET_SIMULATION_TIME, simul_length=800., simul_step=1., parameters=params

; ==============================================================================
; ====== Observateur fixe ou mobile 

  SET_OBSERVER, name="fixe", motion=0b, obs_params=[3000.,0.,351.], parameters=params,verbose=verbose
;  SET_OBSERVER, name="fixe", motion=0b, obs_params=[3000.,0.,119.], parameters=params
  ; obs_params : position fixe de l'observateur 
  ;            = [distance, latitude, longitude] (a t=0?) 
;  SET_OBSERVER, name="orbiter", motion=1b, obs_params=[20.31,6.5,119.,90.,90.], parameters=params
;  SET_OBSERVER, name="orbiter", motion=1b, obs_params=[20.31,6.5,351.,90.,90.], parameters=params
 
  ;            = [semi_major_axis, semi_minor_axis, apoapsis longitude, orbit inclinaison, initial phase]
  ; NB initial phase = angle de phase sur l'orbite a t=0 par rapport au centre de l'ellipse avec phase=0 a l'apojove

; ==============================================================================
; ====== Definition des frequences d'observation
; fmin, fmax, step_f pour le spectre dynamique produit

; SET_FREQUENCY, fmin=5., fmax=45., fstep=0.05, parameters=params				
  SET_FREQUENCY, fmin=1., fmax=40., fstep=0.2,  parameters=params

;;;; ************************************************************ 
;;;; DEPRECATED : EMISSION CONE MUST BE DEFINED IN ADD_NEW_SOURCE ! 
;;;; SET_EMISSION_CONE, 60., 2.				; demi-ouverture du cone par defaut, epaisseur du cone (constante ou profil gaussien)
;;;;							; (si non redefini specifiquement pour une source donnee)
;;;; SET_EMISSION_CONE, 70., 1.
;;;; ************************************************************ 


; ==============================================================================
; label du nom de la source, nom du repertoire de stockage des parametres precalcules pour cette source

ADD_SOURCE, name="Ovale Nord", directory="OvaleN", active_LO=[0,360,10],verbose=verbose,parameters=params,cone_app=70., cone_wid=.5, shape=0.1;,/intensity
;ADD_SOURCE, name="Ovale Sud",  directory="OvaleS", active_LO=[0,360,10],verbose=verbose,parameters=params,cone_app=70., cone_wid=.5, shape=0.1;,/intensity

ADD_SOURCE, name="Io Flux Tube", directory="IFT", /satellite, pos_t0=[5.95, 105.], lag=[30.,-30.], shape=[0.1,0.1], cone_app=[70.,70.], cone_wid=[1.,1.], parameters=params,verbose=verbose,pole=[1,-1];,/gradb_test;,/intensity
;ADD_SOURCE, name="Io Flux Tube", directory="IFT", /satellite, pos_t0=[5.95, 105.], lag=[25.,-10.], shape=[0.1,0.1], cone_app=[70.,70.], cone_wid=[1.,1.], parameters=params,verbose=verbose,pole=[1,-1],/gradb_test;,/intensity

;;;; OPTIONS:	pos_T0 = [r, long] = distance orbitale du satellite et longitude jovicentrique a t=0
;;;;		cone_app = [ouvN, ouvS] = ouverture du cone d'emission dans l'hemisphere Nord et Sud
;;;;			l'epaisseur du cone reste celle definie par defaut dans SET_EMISSION_CONE
;;;;		cone_wid = [widN, owidS] = epaisseur du cone d'emission dans l'hemisphere Nord et Sud
;;;;		lag = [lagN, lagS] = decalage de la ligne de champ active par rapport au satellite [>0 au Nord --> aval, inverse au sud]
;;;;		shape_cone =[profilN, profilS] = profil du cone d'emission en fonction de la frequence, au Nord et au Sud (cf. ModeEmploi.txt)
;;;;		/intensite_norm = normalisation de l'intensite detectee de sorte que chaque point source soit compte 1 fois au plus 
;;;;					dans chaque case dtxdf du spectre dynamique produit
;;;;		intensity = X (defaut = 2^numero d'ordre de la source definie par SET_NEW_SOURCE)
;;;; RESTE A FAIRE:
;;;;		/intensity_local_time = intensite en fonction du temps local
;;;;		/intensity_random = intensite aleatoire
;;;;		/intensity_n_random = intensite normale + aleatoire

end