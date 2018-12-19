;***********************************************************
;***                                                     ***
;***         SERPE V6.1                                  ***
;***                                                     ***
;***********************************************************
;***                                                     ***
;***       MODULE: M_CDF                                 ***
;***                                                     ***
;***     function: INIT_cdf						 		 ***
;***     INIT   [INIT_CDF]    	                         ***
;***     CALLBACK [CB_CDF]		                         ***
;***     FINALIZE [FZ_CDF]		                         ***
;***                                                     ***
;***     Version history                                 ***
;***     [CL] V6.1: First release                        ***
;***                                                     ***
;***********************************************************


; =============================================================================
pro INIT_cdf,obj,parameters

nsrc = 0
for i=0,n_elements(parameters.objects) -1 do if TAG_NAMES(*(parameters.objects[i]),/str) eq 'SOURCE' then $
	nsrc=nsrc+1
nbrlg=strarr(nsrc)
k=0
ndat = parameters.time.n_step
nfreq = parameters.freq.n_freq


; =============================================================================
; A faire une fois au debut, donc dans la partie _INIT
; =============================================================================

; Defining ID and Labels
Freq_Label = string(format='(F5.2)',*parameters.freq.freq_tab)+" MHz"

hemisphere = strarr(nsrc)
originsrc = strarr(nsrc)
sourcetype = strarr(nsrc)
sourcedescr = strarr(nsrc)
ener = strarr(nsrc)
refr = strarr(nsrc)
wid = strarr(nsrc)
cml = fltarr(ndat)


obslatitude=fltarr(ndat)
obsdistance=fltarr(ndat)
obslocaltime=fltarr(ndat)
h=0
for i=0,n_elements(parameters.objects) -1 do if TAG_NAMES(*(parameters.objects[i]),/str) eq 'SOURCE' then begin
	if (*(parameters.objects[i])).north then hemisphere(h)='NORTH' $
		else hemisphere(h)='SOUTH'
	if (*(*parameters.objects[i]).parent).north then var=0 else var=1 
	
	if (*(*parameters.objects(i)).parent).sat then sourcedescr(h)=(*(*(*parameters.objects(i)).parent).parent).name $
		else begin
			lon=long((*parameters.objects(i)).LGMIN)
			lat=long((*parameters.objects(i)).LATMIN)
; *********************************
; probleme de longueur de phrase !!!!! ?????
; *********************************
	print,'There may be a sentence length problem for the description of the sources - see m_cdf.pro file - line 53 if error'
			sourcedescr(h)='main oval at longitude='+strtrim(lon,2)+' degrees (with L_equateur='+strtrim(lat,2)+' R_'+(*(*(*parameters.objects(i)).parent).parent).name+')'
; *********************************
;			sourcedescr(h)=''
; *********************************
		endelse
;# here we do a string(long(string(ener))) to avoid rounding problems
	ener(h)=strtrim(long(string(((*(parameters.objects[i])).vmin)^2*255.5)),2)+'keV'
	wid(h) ='wid'+strtrim(long((*parameters.objects[i]).width),2)+'deg'
	
	
	if (*(parameters.objects[i])).refract then refr(h)='_refr' $
	else refr(h)=''
	

	
	if (*(*parameters.objects(i)).parent).sat then originsrc(h)=(*(*(*parameters.objects(i)).parent).parent).name $
		else originsrc(h)=strtrim(lon,2)+'d-'+strtrim(lat,2)+'R'
	
	if (*(parameters.objects[i])).loss then sourcetype(h)='lossc' else $
	if (*(parameters.objects[i])).constant then sourcetype(h)='cst'+strmid(strtrim((*(parameters.objects[i])).constant,1),0,6) else $
	if (*(parameters.objects[i])).cavity then sourcetype(h)='cavity'
	if (*(parameters.objects[i])).ring then sourcetype(h)='shell'
	h=h+1
endif

test=0
for i=0,n_elements(parameters.objects) -1 do if TAG_NAMES(*(parameters.objects[i]),/str) eq 'FEATURE' then begin
	if test eq 0 then $
		b_model=strlowcase((strsplit((*(parameters.objects[i])).name,'_',/extract))[0])
		b_model=strlowcase((strsplit(b_model,'+',/extract))[0])
	test=test+1
endif

Src_ID_Label = originsrc+' '+hemisphere



for i=0,n_elements(parameters.objects)-1 do if TAG_NAMES(*(parameters.objects[i]),/str) eq 'OBSERVER' then begin
	CML=*(*parameters.objects[i]).lg
	obslatitude(*)=(*parameters.objects(i)).apoapsis_declination
	obsdistance=sqrt(total(((*(*parameters.objects(i)).trajectory_xyz)(*,*))^2,1))
	planet=(*(*parameters.objects(i)).parent).name
	if (*parameters.objects(i)).name then $
		observer=(*parameters.objects(i)).name else $
		observer='Earth'		
endif	

dt=strtrim(parameters.time.step*60.,1)



; Computing Time TT2000

for i=0,n_elements(parameters.objects)-1 do if TAG_NAMES(*(parameters.objects[i]),/str) eq 'SACRED' then $
	t0=julday((*parameters.objects[i]).date[1],(*parameters.objects[i]).date[2],(*parameters.objects[i]).date[0],$
	(*parameters.objects[i]).date[3],(*parameters.objects[i]).date[4],(*parameters.objects[i]).date[5])
	time=dblarr(parameters.time.n_step)
	for i=0,parameters.time.n_step-1 do time(i)=t0+i*parameters.time.fin/60./24./parameters.time.n_step

caldat,time,mo,dd,yr,hh,mn,second
ss = fix(second)
ms = fix((second-ss)*1000.)
us = fix((second-ss-ms/1000.)*1000.)
ns = fix((second-ss-ms/1000.-us/1.e6)*1000.)
CDF_TT2000, epoch, yr, mo, dd, hh, mn, ss, ms, us, ns, /COMPUTE_EPOCH



for i=0,n_elements(parameters.objects)-1 do if TAG_NAMES(*(parameters.objects[i]),/str) eq 'SACRED' then begin
	dated=string(format='(I04,"-",I02,"-",I02,"T",I02,":",I02,":",I02)',(*parameters.objects(i)).date(0:5))
	datefilename=string(format='(I04,I02,I02)',(*parameters.objects(i)).date(0:2))
	
	caldat,julday((*parameters.objects(i)).date(1),(*parameters.objects(i)).date(2),(*parameters.objects(i)).date(0),(*parameters.objects(i)).date(3),(*parameters.objects(i)).date(4),(*parameters.objects(i)).date(5))+parameters.time.fin/60./24.,month,day,year,h,m,s
	datef=string(format='(I04,"-",I02,"-",I02,"T",I02,":",I02,":",I02)',year,month,day,h,m,s)
endif



outsplit=strsplit(parameters.out,'/',/EXTRACT)
filename=strmid(parameters.out,0,strlen(parameters.out)-strlen(outsplit(n_elements(outsplit)-1)))
skt_file = filename+'expres_obs_planet_origin_beam-wid_e_refraction_YYYYMMDD_v01.skt'
master_file = filename+'expres_obs_planet_origin_beam-wid_e_refraction_YYYYMMDD_v01.cdf'


for j=0,n_elements(parameters.objects)-1 do if TAG_NAMES(*(parameters.objects[j]),/str) eq 'CDF' then opt=*parameters.objects[j]
build_serpe_skt,*parameters.freq.freq_tab,Freq_Label,parameters.freq.log,Src_ID_Label,originsrc,hemisphere,b_model,sourcetype,observer,planet,wid,ener,refr,sourcedescr,dt,dated,datef,skt_file,opt
spawn,'rm -rf '+master_file
adresse_cdf=loadpath('adresse_cdf',parameters)
spawn,adresse_cdf+'bin/skeletoncdf '+skt_file+' -cdf '+master_file

filename=filename+'expres_'+strlowcase(observer)+'_'+strlowcase(planet)+'_'+strlowcase(originsrc[0])+'_'+b_model+'_'+strlowcase(sourcetype[0])+'-'+strlowcase(wid[0])+'_'+strlowcase(ener[0])+strlowcase(refr[0])+'_'+strlowcase(datefilename)+'_v01'



data = {Epoch:epoch,$
		CML:reform(cml),$
		ObsLatitude:reform(obslatitude),$
		;ObsLocalTime:reform(obslocaltime),$
		ObsDistance:reform(ObsDistance)$
		}

		
make_cdf,master_file,filename+'.cdf',data
id = cdf_open(filename+'.cdf')
basename=strsplit(filename,'/',/extract)
cdf_attput,id,'Logical_file_id',0,basename[n_elements(basename)-1]
if opt.obsdistance then CDF_ATTPUT, id, 'SCALEMAX', 'ObsDistance', max(ObsDistance)

(*obj).id=id
end


; =============================================================================
pro cb_cdf,obj,parameters
; =============================================================================
; A faire a chaque pas de la boucle temporelle
; =============================================================================
; a chaque boucle il faudra calculer intensity comme suit :
; intensity = total(theta gt 0.,1)      
h=0
i=parameters.time.istep
ndat=parameters.time.n_step
nfreq = parameters.freq.n_freq
nsrc=0
for j=0,n_elements(parameters.objects)-1 do if TAG_NAMES(*(parameters.objects[j]),/str) eq 'SOURCE' then nsrc=nsrc+1

theta = fltarr(nsrc,ndat,nfreq)
polarization = intarr(ndat,nfreq)
azimuth = fltarr(nsrc,ndat,nfreq)
azimuth(*,*,*)=-1.0e+31
longitude = fltarr(nsrc,ndat)
fp2 = fltarr(nsrc,ndat,nfreq)
fp2(*,*,*)=-1.0e+31
fx = fltarr(nsrc,ndat,nfreq)
fx(*,*,*)=-1.0e+31
fmax=fltarr(nsrc,ndat)
fmaxCMI=fltarr(nsrc,ndat)
srcpos=fltarr(nsrc,ndat,3,nfreq)
srcpos(*,*,*,*)=-1.0e+31
var=0

for j=0,n_elements(parameters.objects)-1 do if TAG_NAMES(*(parameters.objects[j]),/str) eq 'SOURCE' then begin
	if (*(*parameters.objects[j]).parent).north then var=0 else var=1 
	theta(h,i,*)=(*(*parameters.objects[j]).th)(*,*,var)	
	wthet=where(theta(h,i,*) ne -1.0e+31)
	if wthet(0) ne -1 then begin
		azimuth(h,i,wthet)=(*(*parameters.objects[j]).azimuth)(wthet,*,var)*!radeg
		fp2(h,i,wthet)=(*(*parameters.objects[j]).fp)(wthet,*,var)
		fx(h,i,wthet)=(*(*parameters.objects[j]).f)(wthet,*,var)
	endif
	longitude(h,i)=(*(*parameters.objects[j]).parent).lg+(*(*parameters.objects[j]).lg)

	fmax(h,i)=(*(*parameters.objects[j]).fmax)(*,var)
	fmaxCMI(h,i)=(*(*parameters.objects[j]).fmaxCMI)(*,var)
	wn0=where(theta(h,i,*) gt 0.)
	if wn0(0) ne -1 then $
		if (*parameters.objects[j]).north eq 1 then polarization(i,wn0)=-1 $
			else polarization(i,wn0)=+1
	for ipos=0,2 do begin
		if wthet[0] ne -1 then srcpos(h,i,ipos,wthet)=((*(*parameters.objects(j)).x)(ipos,wthet,0,var))
	endfor
	h=h+1
endif

w0=where(polarization(i,*) eq 0)
polarization(i,w0)=32767

id=(*obj).id
for j=0,n_elements(parameters.objects)-1 do if TAG_NAMES(*(parameters.objects[j]),/str) eq 'CDF' then opt=*parameters.objects[j]

	cdf_varput,id,'Polarization',reform(polarization[i,*],nfreq),REC_START=i
	if opt.theta then	cdf_varput,id,'Theta',reform(theta[*,i,*],nsrc,nfreq),REC_START=i
	if opt.azimuth then	cdf_varput,id,'Azimuth',reform(azimuth[*,i,*],nsrc,nfreq),REC_START=i


	if opt.SrcLongitude then	cdf_varput,id,'SrcLongitude',reform(longitude[*,i],nsrc),REC_START=i
	if opt.SrcFreqMax then	cdf_varput,id,'SrcFreqMax',reform(fmax[*,i],nsrc),REC_START=i
	if opt.SrcFreqMaxCMI then	cdf_varput,id,'SrcFreqMaxCMI',reform(fmaxCMI[*,i],nsrc),REC_START=i
	if opt.SrcPos then	cdf_varput,id,'SrcPosition',transpose(reform(srcpos(*,i,*,*),nsrc,3,nfreq),[1,0,2]),REC_START=i
	;if opt.SrcPos then cdf_varput,id,'SrcPosition',reform(srcpos[*,i,*,*],nsrc,3,nfreq),REC_START=i
	if opt.fp then	cdf_varput,id,'FP',reform(fp2[*,i,*],nsrc,nfreq),REC_START=i
; ici f=fx=fce*sqrt(1-v_r^2/c^2)
	if opt.fc then	cdf_varput,id,'FC',reform(fx[*,i,*],nsrc,nfreq),REC_START=i	

end


pro fz_cdf,obj,parameters
; =============================================================================
; Fermeture fichier cdf
; =============================================================================



cdf_close,(*obj).id
end
; =============================================================================


