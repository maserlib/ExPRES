;***********************************************************
;***                                                     ***
;***         SERPE V6.0                                  ***
;***                                                     ***
;***********************************************************
;***                                                     ***
;***       MODULE: SACRED                                ***
;***                                                     ***
;***     function: code64;     base64 encoding           ***
;***     function: code6;                                ***
;***     INIT    [INIT_SACRED]                           ***
;***     CALLBACK  [CB_SACRED]                           ***
;***     FINALIZE  [FZ_SACRED]                           ***
;***                                                     ***
;***********************************************************

;************************************************************** CODE6
function code6,in

list=     ['A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z']
list=[list,'a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z']
list=[list,'0','1','2','3','4','5','6','7','8','9','+','/']
n=in[0]*32+in[1]*16+in[2]*8+in[3]*4+in[4]*2+in[5]
out=list[n]
return,out
end

;************************************************************** CODE64
function code64,in

n_in=n_elements(in)
n_24=fix((n_in-1)/24)
left=n_in-24*n_24
cas=-1
if left eq 24 then n_24=n_24+1 else if left gt 16 then cas=0 else if left gt 8 then cas=1 else cas=2
out=''
for i=0,n_24-1 do out=out+code6(in[i*24:i*24+5])+code6(in[i*24+6:i*24+11])+code6(in[i*24+12:i*24+17])+code6(in[i*24+18:i*24+23])
if cas ne -1 then begin
	tab=intarr(24) & tab[0:left-1]=in[n_24*24:n_in-1]
	out=out+code6(tab[0:5])+code6(tab[6:11])
	if cas eq 0 then  out=out+code6(tab[12:17])+code6(tab[18:23])
	if cas eq 1 then  out=out+code6(tab[12:17])+'='
	if cas eq 2 then  out=out+'=='
endif

return,out
end


;************************************************************** INIT_SACRED
pro init_sacred,obj,parameters

nom_f=parameters.out & if nom_f eq '' then nom_f='out'
nom=parameters.name
sz=parameters.freq.n_freq
nobj=n_elements(parameters.objects)
for i=0,nobj-1 do if TAG_NAMES(*(parameters.objects[i]),/str) eq 'SOURCE' then begin
	obj2=(*(parameters.objects[i]))
	nom_f2=nom_f+'_'+obj2.name
	nv=FIX((obj2.vmax-obj2.vmin)/obj2.vstep)+1
	nlg=FIX((obj2.lgmax-obj2.lgmin)/obj2.lgstep)+1
	nlat=FIX((obj2.latmax-obj2.latmin)/obj2.latstep)+1
	n_src=nv*nlg*nlat

	for iv=0,nv-1 do for ilg=0,nlg-1 do for ilat=0,nlat-1 do begin
		v=obj2.vmin+iv*obj2.vstep
		lg=obj2.lgmin+ilg*obj2.lgstep
		lat=obj2.latmin+ilat*obj2.latstep
		nom_fichier=nom_f2+'_'+strtrim(string(iv),2)+'_'+strtrim(string(ilg),2)+'_'+strtrim(string(ilat),2)+'.vot' 

		openw, unit, nom_fichier, /get_lun
		if (iv+ilg+ilat) eq 0 then begin
			printf,unit,'<?xml version="1.0"?>'
			printf,unit,'<VOTABLE version="1.2" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"'
			printf,unit,' xmlns="http://www.ivoa.net/xml/VOTable/v1.2">'
			printf,unit,'<GROUP ID="freq_tab">'
			printf,unit,'<PARAM datatype="int" name="Number of Frequencies" ucd="meta.number" value="'+strtrim(string(sz),2)+'"/>' 
			txt='<PARAM datatype="float" name="Frequencies" unit="MHz" ucd="em.freq" arraysize="'+strtrim(string(sz),2)+'" value="'
			for j=0,sz-2 do txt=txt+strtrim(string((*parameters.freq.freq_tab)[j]),2)+' '
			txt=txt+strtrim(string((*parameters.freq.freq_tab)[sz-1]),2)+'"/>'
			printf,unit,txt
			printf,unit,'</GROUP>'
			txt='<RESOURCE name="ExPRES Simu:'+obj2.name+'">'
			printf,unit,txt
		endif
		txt= '<TABLE name="Source '+strtrim(string(ilat+ilg*nlat+iv*nlg*nlat),2)+'">'
		printf,unit,txt
		printf,unit,'<DESCRIPTION>Dynamic spectrum</DESCRIPTION>'
		txt= '<INFO name="Energy" ucd="phys.energy;phys.electron" value="'+strtrim(string(v^2*255.5),2)+'" unit="keV" />'
		printf,unit,txt
		txt= '<INFO name="Longitude" ucd="pos.bodyrc.long;src" value="'+strtrim(string(obj2.lgstep*ilg+obj2.lgmin),2)+'" unit="degrees" />'
		printf,unit,txt
		txt= '<INFO name="Latitude" ucd="pos.bodyrc.lat;src" value="'+strtrim(string(obj2.latstep*ilat+obj2.latmin),2)+'" unit="degrees" />'
		printf,unit,txt
		printf,unit,'<FIELD name="Time (ISO)" ID="col_time" ucd="time.epoch" xtype="datetime" datatype="char" arraysize="24"/>'
		printf,unit,'<FIELD name="Northern_Visibility" ID="col_RR" ucd="phot.flux.density;phys.polarization.circular.RR;meta.modeled;"'
		printf,unit,' datatype="bit" arraysize="'+strtrim(string(sz),2)+'" unit="" ref="freq_tab"/>'
		printf,unit,'<FIELD name="Southern_Visibility" ID="col_LL" ucd="phot.flux.density;phys.polarization.circular.LL;meta.modeled;"'
		printf,unit,' datatype="bit" arraysize="'+strtrim(string(sz),2)+'" unit="" ref="freq_tab"/>'
		printf,unit,'<DATA>'
		printf,unit,'<TABLEDATA>'
		close,unit & free_lun,unit
	endfor
endif
return
end

;************************************************************** CB_SACRED
pro cb_sacred,obj,parameters
nom_f=parameters.out & if nom_f eq '' then nom_f='out'
nom=parameters.name
date=(*obj).date
date_glb=julday(date[1],date[2],date[0],date[3],date[4],date[5])
nobj=n_elements(parameters.objects)
for i=0,nobj-1 do if TAG_NAMES(*(parameters.objects[i]),/str) eq 'SOURCE' then begin
	obj2=(*(parameters.objects[i]))
	nom_f2=nom_f+'_'+obj2.name
	nv=FIX((obj2.vmax-obj2.vmin)/obj2.vstep)+1
	nlg=FIX((obj2.lgmax-obj2.lgmin)/obj2.lgstep)+1
	nlat=FIX((obj2.latmax-obj2.latmin)/obj2.latstep)+1
	n_src=nv*nlg*nlat
	n2=0
	sp=(*(obj2.spdyn))[*,*,*]
	n2=n_elements(sp[0,*,0])
	nf=n_elements(sp[*,0,0])
	for iv=0,nv-1 do for ilg=0,nlg-1 do for ilat=0,nlat-1 do begin
		v=obj2.vmin+iv*obj2.vstep
		lg=obj2.lgmin+ilg*obj2.lgstep
		lat=obj2.latmin+ilat*obj2.latstep
		j=ilg+ilat*nlg+iv*nlg*nlat
		sm=total(sp[*,j,*])
		if sm ne 0 then begin
			nom_fichier=nom_f2+'_'+strtrim(string(iv),2)+'_'+strtrim(string(ilg),2)+'_'+strtrim(string(ilat),2)+'.vot'

;***** Appending data file *****
			openu,unit, nom_fichier, /get_lun, /APPEND
			
;***** Computing ISO-Time for current line *****
			date=double(date_glb)+double(parameters.time.time/1440.)
			caldat,date,mt,d,y,h,m,s
			if mt ge 10 then mt=strtrim(string(mt),2) else mt='0'+strtrim(string(mt),2)
			if d ge 10 then d=strtrim(string(d),2) else d='0'+strtrim(string(d),2)
			if h ge 10 then h=strtrim(string(h),2) else h='0'+strtrim(string(h),2)
			if m ge 10 then m=strtrim(string(m),2) else m='0'+strtrim(string(m),2)
			sec=s & s=fix(s) & msec=fix((sec-s)*1000)
			if s ge 10 then s=strtrim(string(s),2) else s='0'+strtrim(string(s),2)
			if msec ge 100 then msec=strtrim(string(msec),2) else msec='0'+strtrim(string(msec),2)
			if msec ge 10 then msec=strtrim(string(msec),2) else msec='0'+strtrim(string(msec),2)
			date=strtrim(string(y),2)+'-'+mt+'-'+d+'T'+h+':'+m+':'+s+'.'+msec+'Z'

;***** Writing ISO-Time for current line *****
			printf,unit,'<TR>'
			txt='<TD>'+date+'</TD>'
			printf,unit,txt

;***** Writing data for current line *****
			txt='<TD encoding="base64">'
			txt=txt+code64(sp[*,j,0])+'</TD>'
			printf,unit,txt
			txt='<TD encoding="base64">'
			txt=txt+code64(sp[*,j,1])+'</TD>'
			printf,unit,txt
			printf,unit,'</TR>'
			
			close,unit & free_lun,unit
;***** file closed *****

		endif
	endfor
endif
return
end

;************************************************************** FZ_SACRED
pro fz_sacred,obj,parameters

nom_f=parameters.out & if nom_f eq '' then nom_f='out'
nom=parameters.name
sz=parameters.freq.n_freq
nobj=n_elements(parameters.objects)
for i=0,nobj-1 do if TAG_NAMES(*(parameters.objects[i]),/str) eq 'SOURCE' then begin
	obj2=(*(parameters.objects[i]))
	nom_f2=nom_f+'_'+obj2.name
	nv=FIX((obj2.vmax-obj2.vmin)/obj2.vstep)+1
	nlg=FIX((obj2.lgmax-obj2.lgmin)/obj2.lgstep)+1
	nlat=FIX((obj2.latmax-obj2.latmin)/obj2.latstep)+1
	n_src=nv*nlg*nlat
	nom_fichier0=nom_f2+'.vot'
	cmd="cat "
	for iv=0,nv-1 do for ilg=0,nlg-1 do for ilat=0,nlat-1 do begin
		v=obj2.vmin+iv*obj2.vstep
		lg=obj2.lgmin+ilg*obj2.lgstep
		lat=obj2.latmin+ilat*obj2.latstep
		nom_fichier=nom_f2+'_'+strtrim(string(iv),2)+'_'+strtrim(string(ilg),2)+'_'+strtrim(string(ilat),2)+'.vot' 
		cmd=cmd+" "+nom_fichier
		openu, unit, nom_fichier, /get_lun,/APPEND
		printf,unit,'</TABLEDATA>'
		printf,unit,'</DATA>'
		printf,unit,'</TABLE>'
		close,unit & free_lun,unit
	endfor
	cmd=cmd+" > "+nom_fichier0
	spawn,cmd

	for iv=0,nv-1 do for ilg=0,nlg-1 do for ilat=0,nlat-1 do begin
		v=obj2.vmin+iv*obj2.vstep
		lg=obj2.lgmin+ilg*obj2.lgstep
		lat=obj2.latmin+ilat*obj2.latstep
		nom_fichier=nom_f2+'_'+strtrim(string(iv),2)+'_'+strtrim(string(ilg),2)+'_'+strtrim(string(ilat),2)+'.vot' 
		cmd="rm -f "+nom_fichier
		spawn,cmd
	endfor

	openu, unit, nom_fichier0, /get_lun,/APPEND
	printf,unit,'</RESOURCE>'
	printf,unit,'</VOTABLE>'
	close,unit & free_lun,unit

endif
return
end



