;***********************************************************
;***                                                     ***
;***         SERPE V6.1                                  ***
;***                                                     ***
;***********************************************************
;***                                                     ***
;***       MODULE: read_ephem	                         ***
;*** 		Version history  							 ***
;***        [CL] : First release                         ***
;***     routine: read_ephemph							 ***
;***         lecture des ephemerides de l objet			 ***
;***         venant de l OV Miriade				   		 ***
;***         /!\ attention au changement MIRIADE /!\	 ***
;***         /!\ verifier régulièrement MIRIADE	 /!\	 ***
;***********************************************************

; ==================================================================================================
PRO read_ephemph,filename,datefin=datefin,distance=distance,longitude=longitude,lat=lat,error=error
; ==================================================================================================
; ASCII data from OV MIRIADE (IMCCE)
; DATE : en YYYY-MM-DDTHH:MM:SS.SSS
; LONGSEP : Longitude planétocentrique du point subterrestre
; LATSEP : Latitude planétocentrique du point subterrestre
; LONGSSP : Longitude planétocentrique du point subsolaire
; LATSSP : Latitude planétocentrique du point subsolaire
;  NP	Angle de position du pôle nord de la planète par rapport à la direction du pôle nord céleste 
;       (en degré)
;  dPole	Distance entre le centre de la planète et son pôle nord ou sud 
;           (en seconde de degré ou minute de degré pour la Lune)
;  Mv	Magnitude visuelle
;  Phase	Angle de phase (en degré)
;  RApp	Rayon apparent du corps (en seconde de degré ou minute de degré pour la Lune)
;  Dg	Distance Observateur-corps (en Unité astronomique ou unité de rayon terrestre pour la Lune)
;  Dh	Distance Soleil-corps (en Unité astronomique)
;  PAQ	Angle de position de l équateur d intensité (en degré)
;  Q	Longueur du segment de droite sur l equateur d intensité qui n est pas illuminée 
;       (à la surface du disque apparent de la planète, en seconde de degré ou minute de degré pour la Lune)

; --------------------------------------------------------------------------------------------------
; OUTPUT&KEYWORD 
; filename : chemin d acces du fichier d ephemerides lu
;  dist : distance entre l observateur et l objet (en Rayon de l objet)
; long : Longitude planétocentrique du point subterrestre
; lat : Latitude planétocentrique du point subterrestre
; --------------------------------------------------------------------------------------------------

nbr_lines_suppr=0l

nlines=file_lines(filename)
if nlines lt 10 then goto, erreur
openr,u,filename,/get_lun
buf=''
Rayon=0.
body=''
buf2=''
readf,u,buf
if strmatch(buf,"Flag: -1") then goto,erreur
nbr_lines_suppr=nbr_lines_suppr+1

while strmid(buf,0,1) eq '#' do begin
		readf,u,buf
		if strmatch(buf,"*Planet:*") or strmatch(buf,"*Planet :*") then begin
			tmp=(STRSPLIT(buf,' * ',/EXTRACT))
			planet=tmp[n_elements(tmp)-1]
		endif
		if strmatch(buf,"*Satellite*") then begin
			tmp=(STRSPLIT(buf,' * ',/EXTRACT))
			planet=tmp[n_elements(tmp)-1]
		endif

		nbr_lines_suppr=nbr_lines_suppr+1
endwhile
if planet eq 'Io' then Rayon=71492.00
if planet eq 'Europa' then Rayon=71492.00
if planet eq 'Ganymede' then Rayon=71492.00
if planet eq 'Callisto' then Rayon=71492.00
if planet eq 'Amalthea' then Rayon=71492.00
if planet eq 'Jupiter' then Rayon=71492.00
if planet eq 'Uranus' then Rayon=25559.00
if planet eq 'Saturn' then Rayon=60268.00

if planet eq 'Mercure' or planet eq 'Venus' or planet eq 'Earth' or planet eq 'Mars' then stop,'add '+planet+"'s radius in read_ephemph.pro"

tmp = {result,$
	Date		:'',$
	LONGSEP		:0.,$
	LATSEP		:0.,$
	LONGSSP		:0.,$
	LATSSP		:0.,$
	NP			:0.,$
	dPole		:0.,$
	Mv			:0.,$
	Phase		:0.,$
	RApp		:0.,$
	Dg			:0.,$
	Dh			:0.,$
	PAQ			:0.,$
	Q			:0d,$
	RV			:0.}


n = nlines-nbr_lines_suppr
data_new = replicate({result},n)  

datefin=strarr(n)
longitude=fltarr(n)
lat=fltarr(n)
distance=fltarr(n)
Date=''
LONGSEP=0. & LATSEP=0.
LONGSSP=0. & LATSSP=0.
NP= 0. & dPole=0. & Mv=0. & Phase=0. & RApp=0. & Dg=0. & Dh=0. & PAQ=0. & Q=0. & RV=0.


for i=0l,n-1l do begin
	if i ne 0 then readf,u,buf
	
	Date=strtrim(strmid(buf,0,26),2)
	LONGSEP=strmid(buf,27,12) & if LONGSEP ne '******' then LONGSEP=float(LONGSEP) else begin goto, erreur & print,'error on the sub-observer longitude (CML)' & endelse
	LATSEP=strmid(buf,40,11) & if LATSEP ne '******' then LATSEP=float(LATSEP) else begin & goto, erreur & print,'error on the sub-observer latitude' & endelse
	LONGSSP=strmid(buf,52,12) & if LONGSSP ne '******' then LONGSSP=float(LONGSSP) else LONGSSP = -1.0e+31
	LATSSP=strmid(buf,65,11) & if LATSSP ne '******' then LATSSP=float(LATSSP) else LATSSP = -1.0e+31
	NP=strmid(buf,77,8) & if NP ne '******' then NP=float(NP) else NP = -1.0e+31
	dPole=strmid(buf,86,11) & if dPole ne '******' then dPole=float(dPole) else dPole = -1.0e+31
	Mv=strmid(buf,98,8) & if Mv ne '******' then Mv=float(Mv) else Mv = -1.0e+31
	Phase=strmid(buf,107,9) & if Phase ne '*******' then Phase=float(Phase) else Phase = -1.0e+31
	RApp=strmid(buf,117,15) & if RApp ne '*********' then RApp=float(RApp) else RApp = -1.0e+31
	Dg=strmid(buf,133,20) & if Dg ne '************' then Dg=float(Dg) else begin & goto, erreur & print,'error on the sub-observer distance' & endelse
	Dh=strmid(buf,154,20) & if Dh ne '************' then Dh=float(Dh) else Dh = -1.0e+31
	PAQ=strmid(buf,175,8) & if PAQ ne '******' then PAQ=float(PAQ) else PAQ = -1.0e+31
	Q=strmid(buf,184,10) & if Q ne '*******' then Q=float(Q) else Q = -1.0e+31
	Rv=strmid(buf,196,11) & if Rv ne '*******' then Rv=float(Rv) else Rv = -1.0e+31
	
	data_new(i).Date=strtrim(Date,2) & datefin(i)=Date
	data_new(i).LONGSEP=LONGSEP & if planet eq 'Uranus' then longitude(i)=LONGSEP else longitude(i)=360.-LONGSEP ; longitude comptée WEST (360.-EAST)
	data_new(i).LATSEP=LATSEP & lat(i)=LATSEP
	data_new(i).LONGSSP=LONGSSP
	data_new(i).LATSSP=LATSSP
	data_new(i).NP=NP
	data_new(i).dPole=dPole
	data_new(i).Mv=Mv
	data_new(i).Phase=Phase
	data_new(i).RApp=RApp
	data_new(i).Dg=Dg & distance(i)=Dg*149597870.700/Rayon
	data_new(i).Dh=Dh
	data_new(i).PAQ=PAQ
	data_new(i).Q=Q
	data_new(i).Rv=Rv
endfor
close, u
free_lun, u

error=0
return

erreur :
	error=1
	return
end