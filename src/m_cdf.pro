;***********************************************************
;***                                                     ***
;***         SERPE V6.1                                  ***
;***                                                     ***
;***********************************************************
;***                                                     ***
;***       MODULE: M_CDF                                 ***
;***                                                     ***
;***     function: INIT_cdf				 ***
;***     INIT   [INIT_CDF]    	                         ***
;***     CALLBACK [CB_CDF]		                 ***
;***     FINALIZE [FZ_CDF]		                 ***
;***                                                     ***
;***     Version history                                 ***
;***     [CL] V6.1: First release                        ***
;***                                                     ***
;***********************************************************


; =============================================================================
pro INIT_cdf,obj,parameters

nsrc = 0
for i=0,n_elements(parameters.objects) -1 do if TAG_NAMES(*(parameters.objects[i]),/str) eq 'SOURCE' then begin
	nsrc=nsrc+(*parameters.objects[i]).lgnbr
endif
nbrlg=strarr(nsrc)
k=0
ndat = parameters.time.n_step
nfreq = parameters.freq.n_freq


; =============================================================================
; To be executed once, so it goes into the `_INIT`
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
	for ilg=0,(*parameters.objects[i]).lgnbr-1 do begin
		if (*(parameters.objects[i])).north then hemisphere(h)='NORTH' $
			else hemisphere(h)='SOUTH'
		if (*(*parameters.objects[i]).parent).north then var=0 else var=1 
		
		if (*(*parameters.objects(i)).parent).sat then sourcedescr(h)=(*(*(*parameters.objects(i)).parent).parent).name $
			else begin
				lon=long((*(*parameters.objects[i]).lg)[ilg])
				lat=long((*(*parameters.objects[i]).lat)[ilg])
	;# *********************************
	;# issue with the length of the sentence ?
	;# *********************************
				sourcedescr(h)='main oval at longitude='+strtrim(lon,2)+' degrees (with L_equateur='+strtrim(lat,2)+' R_'+(*(*(*parameters.objects(i)).parent).parent).name+')'

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
	endfor
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
	CML=360.-((*(*parameters.objects(i)).trajectory_rtp)[2,*]/!pi*180.)
	obslatitude=90.-((*(*parameters.objects(i)).trajectory_rtp)[1,*]/!pi*180.)
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
	for i=0,parameters.time.n_step-1 do time(i)=t0+i*parameters.time.fin/60./24./(parameters.time.n_step-1)

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
version="v11"
skt_file = filename+'expres_obs_planet_origin_beam-wid_e_refraction_YYYYMMDD_'+version+'.skt'
master_file = filename+'expres_obs_planet_origin_beam-wid_e_refraction_YYYYMMDD_'+version+'.cdf'


for j=0,n_elements(parameters.objects)-1 do if TAG_NAMES(*(parameters.objects[j]),/str) eq 'CDF' then opt=*parameters.objects[j]
build_serpe_skt,*parameters.freq.freq_tab,Freq_Label,parameters.freq.log,Src_ID_Label,originsrc,hemisphere,b_model,sourcetype,observer,planet,wid,ener,refr,sourcedescr,dt,dated,datef,skt_file,opt,version
spawn,'rm -rf '+master_file
adresse_cdf=loadpath('adresse_cdf',parameters)
spawn,adresse_cdf+'bin/skeletoncdf '+skt_file+' -cdf '+master_file

filename=filename+'expres_'+strlowcase(observer)+'_'+strlowcase(planet)+'_'+strlowcase(originsrc[0])+'_'+b_model+'_'+strlowcase(sourcetype[0])+'-'+strlowcase(wid[0])+'_'+strlowcase(ener[0])+strlowcase(refr[0])+'_'+strlowcase(datefilename)+'_'+version


data = {Epoch:epoch}

		
make_cdf,master_file,filename+'.cdf',data
id = cdf_open(filename+'.cdf')
basename=strsplit(filename,'/',/extract)
cdf_attput,id,'Logical_file_id',0,basename[n_elements(basename)-1]

if opt.obsdistance then CDF_ATTPUT, id, 'SCALEMAX', 'ObsDistance', max(ObsDistance)
if opt.CML then	cdf_varput,id,'CML',reform(CML)
if opt.ObsLatitude then	cdf_varput,id,'ObsLatitude',reform(obslatitude)
if opt.ObsDistance then	cdf_varput,id,'ObsDistance',reform(obsdistance)

(*obj).id=id
end


; =============================================================================
pro cb_cdf,obj,parameters
; =============================================================================
; To be executed at each temporal step
; =============================================================================
h=0
i=parameters.time.istep
ndat=parameters.time.n_step
nfreq = parameters.freq.n_freq
nsrc=0
for j=0,n_elements(parameters.objects)-1 do if TAG_NAMES(*(parameters.objects[j]),/str) eq 'SOURCE' then begin
	nsrc=nsrc+(*parameters.objects[j]).lgnbr
endif

for j=0,n_elements(parameters.objects)-1 do if TAG_NAMES(*(parameters.objects[j]),/str) eq 'CDF' then opt=*parameters.objects[j]

polarization = intarr(ndat,nfreq)
polarization(*,*)=32767

if opt.CML then CML=fltarr(ndat)
if opt.theta then theta = fltarr(nsrc,ndat,nfreq)
if opt.srcvis then begin
	polarizationSUM = intarr(2,ndat,nfreq)
	polarizationSUM(*,*,*)=32767
endif
if opt.azimuth then begin
	azimuth = fltarr(nsrc,ndat,nfreq)
	azimuth(*,*,*)=-1.0e+31
endif
if opt.SrcLongitude then longitude = fltarr(nsrc,ndat)
if opt.fp then begin
	fp2 = fltarr(nsrc,ndat,nfreq)
	fp2(*,*,*)=-1.0e+31
endif
if opt.fc then begin
	fx = fltarr(nsrc,ndat,nfreq)
	fx(*,*,*)=-1.0e+31
endif
if opt.SrcFreqMax then fmax=fltarr(nsrc,ndat)
if opt.SrcFreqMaxCMI then fmaxCMI=fltarr(nsrc,ndat)
if opt.SrcPos then begin
	srcpos=fltarr(nsrc,ndat,3,nfreq)
	srcpos(*,*,*,*)=-1.0e+31
endif
var=0

for j=0,n_elements(parameters.objects)-1 do if TAG_NAMES(*(parameters.objects[j]),/str) eq 'SOURCE' then begin
	if (*(*parameters.objects[j]).parent).north then var=0 else var=1
	for ilg=0,(*parameters.objects[j]).lgnbr-1 do begin
		if opt.theta then theta(h,i,*)=(*(*parameters.objects[j]).th)(*,ilg,var)	
		wn0=where((*(*parameters.objects[j]).th)(*,ilg,var) ne -1.0e+31)
		if wn0(0) ne -1 then begin
			if (*parameters.objects[j]).north eq 1 then polarization(i,wn0)=-1 $
				else polarization(i,wn0)=+1
			if opt.azimuth then azimuth(h,i,wn0)=(*(*parameters.objects[j]).azimuth)(wn0,ilg,var)*!radeg
			if opt.fp then fp2(h,i,wn0)=(*(*parameters.objects[j]).fp)(wn0,ilg,var)
			if opt.fc then fx(h,i,wn0)=(*(*parameters.objects[j]).f)(wn0,ilg,var)
			
			if opt.srcvis then $
			for ipolar=0,n_elements(wn0)-1 do begin
				if var eq 0 then begin
					if polarizationSUM[0,i,wn0[ipolar]] eq 32767 then polarizationSUM[0,i,wn0[ipolar]]=polarizationSUM[0,i,wn0[ipolar]]-32767-1 $
						else polarizationSUM[0,i,wn0[ipolar]]=polarizationSUM[0,i,wn0[ipolar]]-1 
				endif else begin
					if polarizationSUM[1,i,wn0[ipolar]] eq 32767 then polarizationSUM[1,i,wn0[ipolar]]=polarizationSUM[1,i,wn0[ipolar]]-32767+1 $
						else polarizationSUM[1,i,wn0[ipolar]]=polarizationSUM[1,i,wn0[ipolar]]+1 
				endelse
			endfor
			if opt.SrcPos then $
				for ipos=0,2 do srcpos(h,i,ipos,wn0)=((*(*parameters.objects(j)).x)(ipos,wn0,ilg,var))
		endif

		if opt.SrcLongitude then longitude(h,i)=(*(*parameters.objects[j]).parent).lg+(*(*parameters.objects[j]).lg)[*,ilg,*]
		if opt.SrcFreqMax then fmax(h,i)=(*(*parameters.objects[j]).fmax)(ilg,var)
		if opt.SrcFreqMaxCMI then fmaxCMI(h,i)=(*(*parameters.objects[j]).fmaxCMI)(ilg,var)

		h=h+1
	endfor
endif



	
for j=0,n_elements(parameters.objects)-1 do if TAG_NAMES(*(parameters.objects[j]),/str) eq 'OBSERVER' then obs=*(parameters.objects[j])			






id=(*obj).id

cdf_varput,id,'Polarization',reform(polarization[i,*],nfreq),REC_START=i
if (obs.motion+obs.predef) eq 0 then begin
	CML[i]=(*obs.lg)[i]
	if opt.CML then cdf_varput,id,'CML',reform(CML[i]),REC_START=i
endif
if opt.srcvis then cdf_varput,id,'VisibleSources',reform(polarizationSUM[*,i,*],2,nfreq),REC_START=i
if opt.theta then	cdf_varput,id,'Theta',reform(theta[*,i,*],nsrc,nfreq),REC_START=i
if opt.azimuth then	cdf_varput,id,'Azimuth',reform(azimuth[*,i,*],nsrc,nfreq),REC_START=i


if opt.SrcLongitude then	cdf_varput,id,'SrcLongitude',reform(longitude[*,i],nsrc),REC_START=i
if opt.SrcFreqMax then	cdf_varput,id,'SrcFreqMax',reform(fmax[*,i],nsrc),REC_START=i
if opt.SrcFreqMaxCMI then	cdf_varput,id,'SrcFreqMaxCMI',reform(fmaxCMI[*,i],nsrc),REC_START=i
if opt.SrcPos then	cdf_varput,id,'SrcPosition',transpose(reform(srcpos(*,i,*,*),nsrc,3,nfreq),[1,0,2]),REC_START=i
;if opt.SrcPos then cdf_varput,id,'SrcPosition',reform(srcpos[*,i,*,*],nsrc,3,nfreq),REC_START=i
if opt.fp then	cdf_varput,id,'FP',reform(fp2[*,i,*],nsrc,nfreq),REC_START=i
;# here if loss cone f=fx=fce*sqrt(1-v_r^2/c^2); if Shell f=fx=fce*(1-v_r^2/c^2)^(-1/2)
if opt.fc then	cdf_varput,id,'FC',reform(fx[*,i,*],nsrc,nfreq),REC_START=i	

end


pro fz_cdf,obj,parameters
; =============================================================================
; Closing CDF file
; =============================================================================
cdf_close,(*obj).id

adresse_save_tmp=loadpath('adresse_save',parameters)
version="v11"
cmdskt='rm '+adresse_save_tmp+'expres_obs_planet_origin_beam-wid_e_refraction_YYYYMMDD_'+version+'.skt'
cmdcdf='rm '+adresse_save_tmp+'expres_obs_planet_origin_beam-wid_e_refraction_YYYYMMDD_'+version+'.cdf'
spawn,cmdskt
spawn,cmdcdf

end
; =============================================================================


