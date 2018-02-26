
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
function loadpath,adresse,parameters
; ------ adresse des fichiers d ephemerides ------
if adresse eq 'adresse_ephem' then adresse_out='/Groups/SERPE/SERPE_6.1/ephemerides/'
; ------ adresse des fichiers de lignes de champ magnetique ------
if adresse eq 'adresse_lib' then adresse_out='/Groups/SERPE/data'
; ------ adresse ou ecrire les resultats ------
	;if adresse eq 'adresse_save' then adresse_out='/Groups/SERPE/SERPE_6.1/result/'
	;#  ------ pour ecrire directement sur kronos ------
if adresse eq 'adresse_save' then begin
	nobj=n_elements(parameters.objects)
	for i=0,nobj-1 do begin
		if TAG_NAMES(*(parameters.objects[i]),/str) eq 'SACRED' then begin
			year=string(format='(I04)',(*parameters.objects[i]).date[0])
			month=string(format='(I02)',(*parameters.objects[i]).date[1])
		endif
		if TAG_NAMES(*(parameters.objects[i]),/str) eq 'OBSERVER' then $
			observer=strlowcase((*parameters.objects[i]).name)
	endfor
	adresse_out='/Users/serpe/Volumes/kronos/serpe/data/'+observer+'/'+year+'/'+month+'/'
endif
; ------ adresse des fonctions ------
if adresse eq 'ps2pdf' then adresse_out='/opt/ghostscript/lib/'
if adresse eq 'ffmpeg' then adresse_out='/opt/local/bin/'
return,adresse_out
END