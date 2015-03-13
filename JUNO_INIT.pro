;***********************************************
;******** simulation JUNO fichier init *********
;***********************************************

pro JUNO_INIT

; Unites : latitudes, longitudes en degres, distances en Rj, temps en minutes, frequences en MHz

;  SET_LOCAL_TIME, 0., 0. ; definition de la longitude (+ inclinaison) jovicentrique du Soleil (a t=0?)

;  SET_SIMULATION_TIME, 1200., 1. ; duree totale et pas de la simulation
;  SET_SIMULATION_TIME, 480., .25 ; duree totale et pas de la simulation




; SET_OBSERVER, "fixe", pos=[3000.,0.,351.]		; pos = position fixe de l'observateur (distance, latitude, longitude (a t=0?) )
;  SET_OBSERVER, "mobile", orb=[20.31,6.5,119.,90.,90.]	; orb = orbite elliptique de grand axe dans le plan de l'equateur
							; parametres = a, b, longitude jovienne de l'apojove de l'orbite, inclinaison,
							; 	angle de phase sur l'orbite a t=0 par rapport au centre de l'ellipse avec phase=0 a l'apojove

; SET_FREQUENCY, 5., 45., 0.05				; fmin, fmax, step_f pour le spectre dynamique produit
;  SET_FREQUENCY, 1., 40., 0.2
; SET_EMISSION_CONE, 60., 2.				; demi-ouverture du cone par defaut, epaisseur du cone (constante ou profil gaussien)
							; (si non redefini specifiquement pour une source donnee)
;  SET_EMISSION_CONE, 70., 1.


; label du nom de la source, nom du repertoire de stockage des parametres precalcules pour cette source
; SET_NEW_SOURCE, "Ovale Nord", "OvaleN", shape=[0.1]
; SET_NEW_SOURCE, "Ovale Sud",  "OvaleS"
;SET_NEW_SOURCE, "Io Flux Tube", "IFT", sat=[5.95, 15.], lag=[30.,-30.], shape=[0.1,0.1], cone_emission=[70.,70.],/intensite_norm
;SET_NEW_SOURCE, "Io Flux Tube", "IFT", sat=[5.95, 105.], lag=[30.,-30.], shape=[0.1,0.1], cone_emission=[70.,70.],/intensite_norm
 
; SET_NEW_SOURCE, "Europa Flux Tube","EFT", sat=[9.5,0.]
; SET_NEW_SOURCE, "Ganymede Flux Tube","GFT", sat=[15.1,0.]

; OPTIONS:	sat = [r, long] = distance orbitale du satellite et longitude jovicentrique a t=0
;		cone_emission = [ouvN, ouvS] = ouverture du cone d'emission dans l'hemisphere Nord et Sud
;			l'epaisseur du cone reste celle definie par defaut dans SET_EMISSION_CONE
;		lag = [lagN, lagS] = decalage de la ligne de champ active par rapport au satellite [>0 au Nord --> aval, inverse au sud]
;		shape =[profilN, profilS] = profil du cone d'emission en fonction de la frequence, au Nord et au Sud (cf. ModeEmploi.txt)
;		/intensite_norm = normalisation de l'intensite detectee de sorte que chaque point source soit compte 1 fois au plus 
;					dans chaque case dtxdf du spectre dynamique produit
;		intensity = X (defaut = 2^numero d'ordre de la source definie par SET_NEW_SOURCE)
; RESTE A FAIRE:
;		/intensity_local_time = intensite en fonction du temps local
;		/intensity_random = intensite aleatoire
;		/intensity_n_random = intensite normale + aleatoire

;  SET_LOCAL_TIME, 0., 0.
;  SET_SIMULATION_TIME, 1200., 0.5
;  SET_OBSERVER, "mobile", orb=[20.31,6.5,351.,90.,90.]
;  SET_OBSERVER, "fixe", pos=[3000.,0.,351.]
;  SET_FREQUENCY, 1., 40., 0.2
;  SET_EMISSION_CONE, 70., 1.

;  SET_LOCAL_TIME, 0., 0.
;  SET_SIMULATION_TIME, 800., 1.
;  SET_OBSERVER, "fixe", pos=[3000.,0.,119.]
;  SET_FREQUENCY, 1., 40., 0.2
;  SET_EMISSION_CONE, 70., 1.
;  SET_NEW_SOURCE, "Io Flux Tube", "IFT", sat=[5.95, 105.], cone_emission=[70.,70.], lag=[25.,-10.], shape=[0.1,0.1], /intensite_norm
;  SET_NEW_SOURCE, "Ovale Nord", "OvaleN", shape=[0.1]
;  SET_NEW_SOURCE, "Ovale Sud", "OvaleS", shape=[0.1]

  SET_LOCAL_TIME, 0., 0.
  SET_SIMULATION_TIME, 480.,0.25
  SET_OBSERVER, "fixe", pos=[3000.,0.,351.]
  SET_FREQUENCY, 1., 40., 0.2
  SET_EMISSION_CONE, 70., 1.
  SET_NEW_SOURCE, "Io Flux Tube", "IFT", sat=[5.95, 105.], cone_emission=[70.,70.], lag=[30.,-30.], shape=[0.1,0.1], /intensite_norm

end