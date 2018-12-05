;***********************************************************
;***                                                     ***
;***         SERPE V6.1                                  ***
;***                                                     ***
;***********************************************************
;***                                                     ***
;***       MODULE: read_ephem	                         ***
;*** 		Version history  							 ***
;***        [CL] : First release                         ***
;***     function: read_ephem_obs						 ***
;***         lecture des ephemerides de l observateur	 ***
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

if (file_lines(filename) lt 10) then goto, erreur
openr,u,filename,/get_lun
buf=''
Rayon=0.
body=''
buf2=''
for i=0,13l do begin
	readf,u,buf
	if strmatch(buf,"Flag: -1") then goto,erreur
	if strmatch(buf,"*Planet*") then begin
		tmp=(STRSPLIT(buf,' * ',/EXTRACT))
		planet=tmp[n_elements(tmp)-1]
	endif
	if strmatch(buf,"*Satellite*") then begin
		tmp=(STRSPLIT(buf,' * ',/EXTRACT))
		planet=tmp[n_elements(tmp)-1]
	endif

	nbr_lines_suppr=nbr_lines_suppr+1
endfor

if planet eq 'Io' then Rayon=71492.00
if planet eq 'Europa' then Rayon=71492.00
if planet eq 'Ganymede' then Rayon=71492.00
if planet eq 'Callisto' then Rayon=71492.00
if planet eq 'Amalthea' then Rayon=71492.00
if planet eq 'Jupiter' then Rayon=71492.00
if planet eq 'Uranus' then Rayon=25559.00
if planet eq 'Saturn' then Rayon=60268.00

if planet eq 'Mercure' or planet eq 'Venus' or planet eq 'Earth' or planet eq 'Mars' then stop,'ajouter rayon planete dans read_ephemph.pro'

tmp=(STRSPLIT(buf,' ',/EXTRACT))
if tmp(n_elements(tmp)-1) eq 'spacecraft' then j=5 else j=4

for i=0,j-1 do begin
  readf,u,buf 
  nbr_lines_suppr=nbr_lines_suppr+1
endfor


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
	Q			:0d}

n = file_lines(filename)-nbr_lines_suppr-8
data_new = replicate({result},n)  

datefin=strarr(n)
longitude=fltarr(n)
lat=fltarr(n)
distance=fltarr(n)
Date=''
LONGSEP=0. & L1SEP=0. & L2SEP=0. & LATSEP=0.
LONGSSP=0. & L1SSP=0. & L2SSP=0. & LATSSP=0.
NP= 0. & dPole=0. & Mv=0. & Phase=0. & RApp=0. & Dg=0. & Dh=0. & PAQ=0. & Q=0.
for i=0l,n-1l do begin
if planet eq 'Jupiter' then begin
	readf,u,buf
	Date=strmid(buf,0,24)
	L1SEP=strmid(buf,26,6) & if L1SEP ne '******' then L1SEP=float(L1SEP) else L1SEP = -1.0e+31
	L2SEP=strmid(buf,33,6) & if L2SEP ne '******' then L2SEP=float(L2SEP) else L2SEP=-1.0e+31
	LONGSEP=strmid(buf,40,6) & if LONGSEP ne '******' then LONGSEP=float(LONGSEP) else  goto, erreur & print,'error on the sub-observer longitude (CML)'
	LATSEP=strmid(buf,47,6) & if LATSEP ne '******' then LATSEP=float(LATSEP) else  goto, erreur & print,'error on the sub-observer latitude'
	L1SSP=strmid(buf,54,6) & if L1SSP ne '******' then L1SSP=float(L1SSP) else L1SSP = -1.0e+31
	L2SSP=strmid(buf,61,6) & if L2SSP ne '******' then L2SSP=float(L2SSP) else L2SSP = -1.0e+31
	LONGSSP=strmid(buf,68,6) & if LONGSSP ne '******' then LONGSSP=float(LONGSSP) else LONGSSP = -1.0e+31
	LATSSP=strmid(buf,75,6) & if LATSSP ne '******' then LATSSP=float(LATSSP) else LATSSP = -1.0e+31
	NP=strmid(buf,82,6) &  if NP ne '******' then NP=float(NP) else NP = -1.0e+31
	dPole=strmid(buf,89,10) & if dPole ne '*********' then dPole=float(dPole) else dPole = -1.0e+31
	Mv=strmid(buf,100,6) & if Mv ne '******' then Mv=float(Mv) else Mv = -1.0e+31
	Phase=strmid(buf,107,7) & if Phase ne '*******' then Phase=float(Phase) else Phase = -1.0e+31
	RApp=strmid(buf,115,12) & if RApp ne '************' then RApp=float(RApp) else RApp = -1.0e+31
	Dg=strmid(buf,128,12) & if Dg ne '************' then Dg=float(Dg) else  goto, erreur & print,'error on the sub-observer distance'
	Dh=strmid(buf,141,12) & if Dh ne '************' then Dh=float(Dh) else Dh = -1.0e+31
	PAQ=strmid(buf,155,7) & if PAQ ne '******' then PAQ=float(PAQ) else PAQ = -1.0e+31
	Q=strmid(buf,168,10) & if Q ne '*********' then Q=float(Q) else Q = -1.0e+31
 
endif else begin
;	readf,u,format='(A25,1x,F6.2,1x,F6.2,1x,F6.2,1x,F6.2,1x,F6.2,1x,F6.2,1x,F6.2,1x,F7.3,1x,F9.6,1x,E12.6,1x,E12.6,2x,F6.2,1x,F7.3)',Date,LONGSEP,LATSEP,LONGSSP,LATSSP,NP,dPole,Mv,Phase,RApp,Dg,Dh,PAQ,Q
	readf,u,buf
	Date=strmid(buf,0,24)
	LONGSEP=strmid(buf,26,6) & if LONGSEP ne '******' then LONGSEP=float(LONGSEP) else  goto, erreur & print,'error on the sub-observer longitude (CML)'
	LATSEP=strmid(buf,33,6) & if LATSEP ne '******' then LATSEP=float(LATSEP) else  goto, erreur & print,'error on the sub-observer latitude'
	LONGSSP=strmid(buf,40,6) & if LONGSSP ne '******' then LONGSSP=float(LONGSSP) else LONGSSP = -1.0e+31
	LATSSP=strmid(buf,47,6) & if LATSSP ne '******' then LATSSP=float(LATSSP) else LATSSP = -1.0e+31
	NP=strmid(buf,54,6) & if NP ne '******' then NP=float(NP) else NP = -1.0e+31
	dPole=strmid(buf,61,10) & if dPole ne '******' then dPole=float(dPole) else dPole = -1.0e+31
	Mv=strmid(buf,72,6) & if Mv ne '******' then Mv=float(Mv) else Mv = -1.0e+31
	Phase=strmid(buf,79,7) & if Phase ne '*******' then Phase=float(Phase) else Phase = -1.0e+31
	RApp=strmid(buf,87,12) & if RApp ne '*********' then RApp=float(RApp) else RApp = -1.0e+31
	Dg=strmid(buf,100,12) & if Dg ne '************' then Dg=float(Dg) else  goto, erreur & print,'error on the sub-observer distance'
	Dh=strmid(buf,113,12) & if Dh ne '************' then Dh=float(Dh) else Dh = -1.0e+31
	PAQ=strmid(buf,126,7) & if PAQ ne '******' then PAQ=float(PAQ) else PAQ = -1.0e+31
	Q=strmid(buf,134,10) & if Q ne '*******' then Q=float(Q) else Q = -1.0e+31
endelse

	data_new(i).Date=Date & datefin(i)=Date
	data_new(i).LONGSEP=LONGSEP & if planet eq 'Uranus' then longitude(i)=LONGSEP else longitude(i)=360.-LONGSEP ; longitude comptée WEST (360.-EAST)
	data_new(i).LATSEP=LATSEP & lat(i)=LATSEP
	data_new(i).LONGSSP=LONGSSP
	data_new(i).LATSSP=LATSSP
	data_new(i).NP=NP
	data_new(i).dPole=dPole
	data_new(i).Mv=Mv
	data_new(i).Phase=Phase
	data_new(i).RApp=RApp
	data_new(i).Dg=Dg
	distance(i)=Dg*149597870.700/Rayon
	data_new(i).Dh=Dh
	data_new(i).PAQ=PAQ
	data_new(i).Q=Q
endfor
close, u
free_lun, u

error=0
return

erreur :
	error=1
	return

end