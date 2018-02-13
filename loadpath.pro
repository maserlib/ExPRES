
;***********************************************************
;***                                                     ***
;***         SERPE V6.1                                  ***
;***                                                     ***
;***********************************************************
;***                                                     ***
;***       MODULE: LOADPATH                              ***
;***                                                     ***
;***     function: loadpath 							 ***
;***                                                     ***
;***     Version history                                 ***
;***     [CL] V6.1: First release					     ***
;***                                                     ***
;***********************************************************


; =============================================================================
function loadpath,adresse

; ------ adresse des fichiers d ephemerides ------
if adresse eq 'adresse_ephem' then adresse_out='/Groups/SERPE/SERPE_6.1/ephemerides/'
; ------ adresse des fichiers de lignes de champ magnetique ------
if adresse eq 'adresse_lib' then adresse_out='/Groups/SERPE/data'
; ------ adresse ou ecrire les resultats ------
if adresse eq 'adresse_save' then adresse_out='/Groups/SERPE/SERPE_6.1/result/'
	;#  ------ pour ecrire directement sur kronos ------
	;if adresse eq 'adresse_save' then adresse_out='/Users/serpe/Volumes/kronos/serpe/data/'+observer+'/'+year+'/'+month+'/'


return,adresse_out
END