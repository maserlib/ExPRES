;***********************************************************
;***                                                     ***
;***         SERPE V6.1                                  ***
;***                                                     ***
;***********************************************************
;***                                                     ***
;***       MODULE: calc_lag                              ***
;***        CL : 29/06/2015                              ***
;***     function: calc_lag ; calcul du lead angle 		 ***
;***                                                     ***
;***********************************************************

;calc_lag : calcul automatique de la valeur du lead angle pour Io
function calc_lag,north,phase,satellite = satellite

if satellite eq 'Io' then begin
	if north eq 1 then begin
		A=2.8
		B=-3.5
	endif else begin
		A=4.3
		B=3.5
	endelse

	lag =-(A+B*cos((phase-202)*!dtor)) ; Io ref : Hess-JGR 2011
	
endif else if satellite eq 'Ganymede' then begin
	if north eq 1 then begin
		A=6.8
		B=-6.2
	endif else begin
		A=6.8
		B=6.2
	endelse
	lag =-(A+B*cos((phase-202)*!dtor))
endif else if satellite eq 'Europa' then begin
	if north eq 1 then begin
		A=5.2
		B=-4.8
	endif else begin
		A=5.2
		B=4.8
	endelse
	lag =-(A+B*cos((phase-202)*!dtor))
endif else if satellite eq 'Callisto' then begin
	lag=0.
endif else lag=0.

return, lag
end