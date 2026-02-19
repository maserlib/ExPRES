;***********************************************************
;***                                                     ***
;***         SERPE V6.1                                  ***
;***                                                     ***
;***********************************************************
;***                                                     ***
;***       MODULE: MAIN_LESIA                            ***
;***                                                     ***
;***     STRREPLACE                                      ***
;***     XYZ_TO_RTP                                      ***
;***     TOTALE                                          ***
;***     FIND_MIN                                        ***
;***     MAIN                                            ***
;***     INIT                                            ***
;***     CALLBACK                                        ***
;***     FINALIZE                                        ***
;***                                                     ***
;***     Version history                                 ***
;***     [CL] V6.1: creation of a out.sav file			 ***
;***                                                     ***
;***********************************************************

;************************************************************** STRREPLACE
pro STRREPLACE, Strings, Find1, Replacement1

;   Check integrity of input parameter

         NP        = N_PARAMS()
         if (NP ne 3) then message,'Must be called with 3 parameters, '+$
                   'Strings, Find, Replacement'

         sz        = SIZE(Strings)
         ns        = n_elements(sz)
         if (sz(ns-2) ne 7) then message,'Parameter must be of string type.'

         Find      = STRING(Find1)
         pos       = STRPOS(Strings,Find)
         here      = WHERE(pos ne -1, nreplace)

         if (nreplace eq 0) then return

         Replacement=STRING(Replacement1)
         Flen      = strlen(Find)
         for i=0,nreplace-1 do begin

              j         = here(i)
              prefix    = STRMID(Strings(j),0,pos(j))
              suffix    = STRMID(Strings(j),pos(j)+Flen,$
                                       strlen(Strings(j))-(pos(j)+Flen))
              Strings(j) = prefix + replacement + suffix
         endfor
end


;************************************************************** XYZ_TO_RTP
FUNCTION XYZ_TO_RTP, xyz
; x,y,z & r en Rp
; theta, phi en rad
  x=reform(xyz(0,*)*1.) & y=reform(xyz(1,*)*1.) & z=reform(xyz(2,*)*1.)
  i=where(x eq 0.) & if i(0) ne -1 then x(i)=0.000001
  i=where(y eq 0.) & if i(0) ne -1 then y(i)=0.000001
  r=sqrt(x^2+y^2+z^2)
  theta=!pi/2.-atan(z/sqrt(x^2+y^2))
  phi=atan(y/x)
  i=where(x lt 0 and y gt 0) & if i(0) ne -1 then phi(i)=phi(i)+!pi
  i=where(x lt 0 and y lt 0) & if i(0) ne -1 then phi(i)=phi(i)+!pi
  i=where(x gt 0 and y lt 0) & if i(0) ne -1 then phi(i)=phi(i)+2*!pi
return,transpose([[r],[theta],[phi]])
end

;************************************************************** TOTALE
function totale,a,b
;IDL considere qu un tableau dont la derniere dimension a une taille 1
;n a pas cette dimension. Donc cette fonction  corrige un bug IDL
if size(a,/n_dim) lt b then return,a
return,total(a,b)
end

;************************************************************** FIND_MIN
function find_min,x1,x2,dist
z1=where((x1 lt 0.) or (x1 gt dist))
z2=where((x2 lt 0.) or (x2 gt dist))
z=fltarr(n_elements(x1))
if z1[0] ne -1 then z[z1]=1
if z2[0] ne -1 then z[z2]=z[z2]+2
w=where((z eq 0) or (z eq 3))
if w[0] ne -1 then for h=0,n_elements(w)-1 do z[w[h]]=min([(x1[w[h]]>0.)<dist[w[h]],(x2[w[h]]>0.)<dist[w[h]]])
w=where(z eq 1)
if w[0] ne -1 then z[w]=x1[w]
w=where(z eq 2)
if w[0] ne -1 then z[w]=x2[w]
return,z
end


;************************************************************** NAMING_FILES
pro naming_files,parameters

	nsrc = 0
	for i=0,n_elements(parameters.objects) -1 do if TAG_NAMES(*(parameters.objects[i]),/str) eq 'SOURCE' then begin
		nsrc=nsrc+(*parameters.objects[i]).lgnbr
	endif

	
	originsrc = strarr(nsrc)
	sourcetype = strarr(nsrc)
	ener = strarr(nsrc)
	refr = strarr(nsrc)
	mode = strarr(nsrc)
	wid = strarr(nsrc)


	h=0
	for i=0,n_elements(parameters.objects) -1 do if TAG_NAMES(*(parameters.objects[i]),/str) eq 'SOURCE' then begin
		for ilg=0,(*parameters.objects[i]).lgnbr-1 do begin
			ener(h)=strtrim(long(string(((*(parameters.objects[i])).vmin)^2*255.5)),2)+'keV'
			wid(h) ='wid'+strtrim(long((*parameters.objects[i]).width),2)+'deg'
			
			
			if (*(parameters.objects[i])).refract then refr(h)='_refr' $
			else refr(h)=''


			mode(h) = '_'+(*(parameters.objects[i])).mode

			if (*(*parameters.objects(i)).parent).sat then originsrc(h)=(*(*(*parameters.objects(i)).parent).parent).name $
				else originsrc(h)=strtrim(lon,2)+'d-'+strtrim(lat,2)+'R'
			
			if (*(parameters.objects[i])).loss then sourcetype(h)='lossc' else $
			if (*(parameters.objects[i])).constant then sourcetype(h)='cst'+strmid(strtrim((*(parameters.objects[i])).constant,1),0,6) else $
			if (*(parameters.objects[i])).cavity then sourcetype(h)='cavity'
			if (*(parameters.objects[i])).ring then sourcetype(h)='shell'
			
			h=h+1
		endfor
	endif
	test=0
	for i=0,n_elements(parameters.objects) -1 do if TAG_NAMES(*(parameters.objects[i]),/str) eq 'FEATURE' then begin
		if test eq 0 then $
			b_model=strlowcase((strsplit((*(parameters.objects[i])).name,'_',/extract))[0])
			b_model=strlowcase((strsplit(b_model,'+',/extract))[0])
		test=test+1
	endif


	for i=0,n_elements(parameters.objects)-1 do if TAG_NAMES(*(parameters.objects[i]),/str) eq 'OBSERVER' then begin
		planet=(*(*parameters.objects(i)).parent).name
		if (*parameters.objects(i)).name then $
			observer=(*parameters.objects(i)).name else $
			observer='Earth'		
	endif	

	


	for i=0,n_elements(parameters.objects)-1 do if TAG_NAMES(*(parameters.objects[i]),/str) eq 'SACRED' then $
		t0=julday((*parameters.objects[i]).date[1],(*parameters.objects[i]).date[2],(*parameters.objects[i]).date[0],$
		(*parameters.objects[i]).date[3],(*parameters.objects[i]).date[4],(*parameters.objects[i]).date[5])
		time=dblarr(parameters.time.n_step)
		for i=0,parameters.time.n_step-1 do time(i)=t0+i*parameters.time.fin/60./24./(parameters.time.n_step-1)

	for i=0,n_elements(parameters.objects)-1 do if TAG_NAMES(*(parameters.objects[i]),/str) eq 'SACRED' then begin
		dated=string(format='(I04,"-",I02,"-",I02,"T",I02,":",I02,":",I02)',(*parameters.objects(i)).date(0:5))
		datefilename=string(format='(I04,I02,I02)',(*parameters.objects(i)).date(0:2))
	endif


	filename = parameters.out
	version=parameters.version


	if parameters.doi ne ''  then begin
		filename=filename+'expres_'+strlowcase(observer)+'_'+strlowcase(planet)+'_'+strlowcase(originsrc[0])+'_'+parameters.doi+'_'+strlowcase(datefilename)+'_'+version
	endif else begin
		filename=filename+'expres_'+strlowcase(observer)+'_'+strlowcase(planet)+'_'+strlowcase(originsrc[0])+'_'+b_model+'_'+strlowcase(sourcetype[0])+'-'+strlowcase(wid[0])+'_'+strlowcase(ener[0])+strlowcase(mode[0])+strlowcase(refr[0])+'_'+strlowcase(datefilename)+'_'+version
	endelse
	parameters.out = filename

end

;**************************************************************
;************************************************************** MAIN
pro main,buf
;**************************************************************
; Main routine, starting serpe 
;**************************************************************
t=systime(/seconds)
tmp=(STRSPLIT(buf,'/',/EXTRACT))

tmp=strtrim(tmp[n_elements(tmp)-1],2)
buf2=strtrim(buf,2)
name_r=FILE_SEARCH(buf2)
name_r=name_r[0]
if name_r eq '' then message,'Simulation File not found'

name_rold=name_r
STRREPLACE,name_r,'queue', 'on-going'
comd='mv '+name_rold+' '+name_r
spawn,comd


version='v14'

adresse_mfl=loadpath('adresse_mfl',parameters)



case strlowcase(strmid(name_r,strlen(name_r)-3)) of
  'son' : read_save_json,version,adresse_mfl,name_r,parameters
  else: message,'Illegal input file name.'
endcase 
nobj=n_elements(parameters.objects)
for i=0,nobj-1 do if TAG_NAMES(*(parameters.objects[i]),/str) eq 'SACRED' then begin
	year=strtrim((*parameters.objects[i]).date[0],1)
	month=string(format='(I02)',(*parameters.objects[i]).date[1])
endif
for i=0,nobj-1 do if TAG_NAMES(*(parameters.objects[i]),/str) eq 'OBSERVER' then $
	observer=STRLOWCASE((*parameters.objects[i]).name)

if observer eq '' then observer='earth'

;adresse_save_tmp='/Groups/SERPE/SERPE_6.1/Corentin/result/Juno/'
adresse_save_tmp=loadpath('adresse_save',parameters)







adresse_save=adresse_save_tmp
parameters.out=adresse_save
print,'Simulation file ok'
print,'Results will be saved in the '+parameters.out+' directory'
NAMING_FILES,parameters
print,'Results will be saved as '+parameters.out

print,'Initialization'
INIT,parameters

print,'Looping...'
for i=0,parameters.time.n_step-1 do begin
	;print,parameters.time.debut+i*parameters.time.step
	
	if i eq long(parameters.time.n_step*.10) then print,"## 10 % ##################"
	if i eq long(parameters.time.n_step*.25) then print,"##### 25 % ###############"
	if i eq long(parameters.time.n_step*.50) then print,"########## 50 % ##########"
	if i eq long(parameters.time.n_step*.75) then print,"############### 75 % #####"
	if i eq long(parameters.time.n_step*.90) then print,"################## 90 % ##"

	parameters.time.time=float(i)*parameters.time.step+parameters.time.t0
	parameters.time.istep=i
	CALLBACK,parameters
endfor

print,'Finalization'
FINALIZE,parameters

nobj=n_elements(parameters.objects)
for i=0,nobj-1 do if TAG_NAMES(*(parameters.objects[i]),/str) eq 'SPDYN' then spdyn=*(parameters.objects[i])
;*********************************
;section for out.sav file
;*********************************
if spdyn.save_out then begin
;*********************************
; Time

	for i=0,nobj-1 do if TAG_NAMES(*(parameters.objects[i]),/str) eq 'SACRED' then $
	t0=julday((*parameters.objects[i]).date[1],(*parameters.objects[i]).date[2],(*parameters.objects[i]).date[0],$
	(*parameters.objects[i]).date[3],(*parameters.objects[i]).date[4],(*parameters.objects[i]).date[5])
	time=dblarr(parameters.time.n_step)
	for i=0,parameters.time.n_step-1 do time(i)=t0+i*(parameters.time.fin-parameters.time.debut)/60./24./parameters.time.n_step

;*********************************
; Freq

	frequency=*parameters.freq.freq_tab


;*********************************
; Longitude of the observer (CML)
	for i=0,nobj-1 do if TAG_NAMES(*(parameters.objects[i]),/str) eq 'OBSERVER' then $
	CML=*(*parameters.objects[i]).lg	
	
	
;*********************************
; number of sources
	nsrclg=[]
	nsrc=0
	
	for i=0,nobj-1 do if TAG_NAMES(*(parameters.objects[i]),/str) eq 'SOURCE' then begin
		nsrc=nsrc+1
		nsrclg=[nsrclg,(*(parameters.objects[i])).lgnbr]
		if (*(parameters.objects)[i]).lossbornes then nsrcarc=nsrcarc+2
	endif
	nsrcarc=total(nsrclg)


;*********************************
; hemispher of origin
; beam (LOSS / RING / CAVITY / RAMP / CONSTANT)
; theta at each time/freq step
; azimuth at each time/freq step (azimuth = portion of the emission angle that the observer see)
; longitude of the emitting magnetic field line (at each time step)
	
	hemisphere=strarr(nsrcarc)
	beam=strarr(nsrcarc)
	theta=fltarr(nsrcarc,parameters.time.n_step,parameters.freq.n_freq)
	azimuth=fltarr(nsrcarc,parameters.time.n_step,parameters.freq.n_freq)
	longitude=fltarr(nsrcarc,parameters.time.n_step)
	intensity=intarr(nsrcarc,parameters.time.n_step,parameters.freq.n_freq)
	k=0
	h=0
	for i=0,nobj-1 do if TAG_NAMES(*(parameters.objects[i]),/str) eq 'SPDYN' then w=i
	
	for i=0,nobj-1 do if TAG_NAMES(*(parameters.objects[i]),/str) eq 'SOURCE' then begin
		if (*(parameters.objects[i])).lossbornes then bornes=2. else bornes=0.
		for j=0,(*(parameters.objects[i])).lgnbr+bornes-1 do begin
			if (*(parameters.objects[i])).north then hemisphere(h)='NORTH' $
				else hemisphere(h)='SOUTH'
			
			if (*(parameters.objects[i])).loss then beam(h)='LC' $
				else if (*(parameters.objects[i])).ring then beam(h)='RING' $
				else if (*(parameters.objects[i])).cavity then beam(h)='CAVITY' $
				else if (*(parameters.objects[i])).rampe then beam(h)='RAMPE' $
				else if ((*(parameters.objects[i])).constant gt 0) then beam(h)='CONSTANT = '+strtrim(string((*(parameters.objects[i])).constant),1)
			
			theta(h,*,*)=(*(*(*parameters.objects[w]).out)[k])[*,*,j]
			azimuth(h,*,*)=(*(*(*parameters.objects[w]).out)[k+nsrc])[*,*,j]
			longitude(h,*)=(*(*(*parameters.objects[w]).out)[k+2*nsrc])[*,j]
			;intensity(h,*,*)=transpose((*(*(*parameters.objects[w]).out)[k+2+2*nsrc])[*,*])
			h=h+1
		endfor
		k=k+1
	endif

	for i=0,n_elements(parameters.objects)-1 do if TAG_NAMES(*(parameters.objects[i]),/str) eq 'OBSERVER' then begin
		planet=(*(*parameters.objects(i)).parent).name
		if (*parameters.objects(i)).name then $
			observer=(*parameters.objects(i)).name else $
			observer='Earth'		
	endif
	h=0
	for i=0,n_elements(parameters.objects) -1 do if TAG_NAMES(*(parameters.objects[i]),/str) eq 'SOURCE' then begin
		if h eq 0 then begin
			if (*(*parameters.objects(i)).parent).sat then originsrc=(*(*(*parameters.objects(i)).parent).parent).name $
				else originsrc=strtrim(lon,2)+'d-'+strtrim(lat,2)+'R'
		
		
			if (*(parameters.objects[i])).loss then sourcetype='lossc' else $
				if (*(parameters.objects[i])).constant then sourcetype='cst'+strmid(strtrim((*(parameters.objects[i])).constant,1),0,6) else $
				if (*(parameters.objects[i])).cavity then sourcetype='cavity'
				if (*(parameters.objects[i])).ring then sourcetype='shell'
			
			ener=strtrim(long(((*(parameters.objects[i])).vmin)^2*255.5),2)+'keV'
			wid='wid'+strtrim(long((*parameters.objects[i]).width),2)+'deg'	
			
			if (*(parameters.objects[i])).refract then refr='_refr' $
				else refr=''
			
			if (*(parameters.objects[i])).LAGAUTO eq 'on' then lag='_lag' $
			else lag=''
		endif
		h=h+1
	endif
	for i=0,n_elements(parameters.objects)-1 do if TAG_NAMES(*(parameters.objects[i]),/str) eq 'SACRED' then begin
		dated=string(format='(I04,"-",I02,"-",I02,"T",I02,":",I02,":",I02)',(*parameters.objects(i)).date(0:5))
		datefilename=string(format='(I04,I02,I02)',(*parameters.objects(i)).date(0:2))
	endif

	
	;outsplit=strsplit(parameters.out,'/',/EXTRACT)
	;filename=strmid(parameters.out,0,strlen(parameters.out)-strlen(outsplit(n_elements(outsplit)-1)))
	;file=filename+'expres_'+strlowcase(observer)+'_'+strlowcase(planet)+'_'+strlowcase(originsrc)+lag+'_'+strlowcase(sourcetype)+'-'+strlowcase(wid)+'_'+strlowcase(ener)+strlowcase(refr)+'_'+strlowcase(datefilename)+'_'+version+'.sav'
	file = parameters.out+'.sav' ; at first parameters.out contains only the output directory. But after INIT, it contains the full name used for the cdf file.

	
	
	nsources=nsrcarc
	save,time,frequency,CML,nsources,hemisphere,beam,theta,azimuth,longitude,FILE=file,$
	DESCRIPTION= "time (Julien Day) ; frequency (MHz) ; CML : position of the observer ; nsrcarc : number of sources ; hemisphere : hemisphere of the emission ; beam : type (LossCone, Constant, Shell) ;theta : value of the beam opening for emission ; azimuth : azimuth of the beam ; longitude : longitude of the active field line"

	for i=0,nobj-1 do if TAG_NAMES(*(parameters.objects[i]),/str) eq 'OBSERVER' then ind=i
	latitude=fltarr(n_elements(time))
	distance=fltarr(n_elements(time))
	latitude=(*parameters.objects(ind)).APOAPSIS_DECLINATION
	distance=(*parameters.objects(ind)).semi_major_axis
	
	
	;intensitefinal=intarr(n_elements(time),n_elements(frequency))
	;for i=0,nsources-1 do intensitefinal=intensitefinal(*,*)+intensity(i,*,*)
	;stop
	
	
endif
;*********************************
;*********** Deleting of ephemeris files ***********

adresse_ephem=loadpath('adresse_ephem',parameters)
cmdobs='rm '+adresse_ephem+'ephemobs'+strtrim(parameters.ticket,1)+'.txt'
cmdbody='rm '+adresse_ephem+'ephembody'+strtrim(parameters.ticket,1)+'.txt'
spawn,cmdobs
spawn,cmdbody

; removing votable files, as there are not usefull any more. Will be fully deleted from the code in a future version
cmdvot = 'rm '+parameters.out+'_source*.vot'
spawn, cmdvot


parameters=''
HEAP_GC
end


;**************************************************************
;************************************************************** INIT
pro init,parameters
;**************************************************************
; Calls all INIT procedures for selected objects 
;**************************************************************
nobj=n_elements(parameters.objects)
for i=0,nobj-1 do begin
it=(*(parameters.objects[i])).it
if it[0] ne '' then for j=0,n_elements(it)-1 do CALL_PROCEDURE,it[j],parameters.objects[i],parameters
endfor
end

;**************************************************************
;************************************************************** CALLBACK
pro callback,parameters
;**************************************************************
; Calls all CALLBACK procedures for the selected objects
;**************************************************************
nobj=n_elements(parameters.objects)

for i=0,nobj-1 do begin
cb=(*(parameters.objects[i])).cb
if cb[0] ne '' then for j=0,n_elements(cb)-1 do CALL_PROCEDURE,cb[j],parameters.objects[i],parameters
endfor
end

;**************************************************************
;************************************************************** FINALIZE
pro finalize,parameters
;**************************************************************
; Calls all FINALIZE procedures for the selected objects
;**************************************************************
nobj=n_elements(parameters.objects)

for i=0,nobj-1 do begin
fz=(*(parameters.objects[i])).fz
if fz[0] ne '' then for j=0,n_elements(fz)-1 do CALL_PROCEDURE,fz[j],parameters.objects[i],parameters
endfor
end

;**************************************************************




