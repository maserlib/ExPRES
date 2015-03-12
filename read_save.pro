pro rank_bodies,bd
ntot=n_elements(bd)
bd2=bd
n=0
for i=0,ntot-1 do begin
	if bd[i].parent eq '' then begin
		bd2[n]=bd[i]
		n=n+1
	endif
endfor
for k=0,ntot-1 do begin
	w=where(bd2[0:n-1].name eq bd[k].name)
	if w[0] eq -1 then begin
        	w=where(bd2[0:n-1].name eq bd[k].parent)
		if w[0] ne -1 then begin
			bd2[n]=bd[k]
			bd2[n].ipar=w[0]
			n=n+1
		endif
	endif
endfor
bd=bd2
return
end	


pro read_save,adresse_lib,file_name,parameters


time={TI,mini:0.,maxi:0.,nbr:0,dt:0.}
freq={FR,mini:0.,maxi:0.,nbr:0,df:0.,name:'',log:0b,predef:0b}
observer={OB,motion:0b,smaj:0.,smin:0.,decl:0.,alg:0.,incl:0.,phs:0.,predef:0b,name:'',parent:'',start:''}
body={BO,on:0b,name:'',rad:0.,per:0.,orb1:0.,lg0:0.,sat:0b,smaj:0.,smin:0.,decl:0.,alg:0.,incl:0.,phs:0.,parent:'', mfl:'',dens:intarr(4),ipar:0}
dens={DE,on:0b,name:'',type:'',rho0:0.,height:0.,perp:0.}
src={SO,on:0b,name:'',parent:'',sat:'',type:'',loss:0b,width:0.,temp:0.,cold:0.,v:0.,lgmin:0.,lgmax:0.,lgstep:1.,latmin:0.,latmax:0.,latstep:1.,north:0b,south:0b,subcor:0.}
spdyn={SP,intensity:0b,polar:0b,f_t:0b,lg_t:0b,lat_t:0b,f_r:0b,lg_r:0b,lat_r:0b,f_lg:0b,lg_lg:0b,lat_lg:0b,f_lat:0b,lg_lat:0b,lat_lat:0b,f_lt:0b,lg_lt:0b,lat_lt:0b,$
khz:0b,pdf:0b,log:0b,xrange:[0.,0.],lgrange:[0.,0.],larange:[0.,0.],ltrange:[0.,0.],nr:0,dr:0.,nlg:0,dlg:0.,nlat:0,dlat:0.,nlt:0,dlt:0.}
mov2d={M2D,on:0b,sub:0,range:0.}
mov3d={M3D,on:0b,sub:0,xrange:[0.,0.],yrange:[0.,0.],zrange:[0.,0.],obs:0b,traj:0b}

lecture=''
openr,unit,file_name,/get_lun
readf,unit,lecture;<SIMU>
if lecture ne '<SIMU>' then begin
	print,'File is not a valid SERPE save file (<SIMU>)'
	return
endif
readf,unit,lecture;<NAME=...>
if strmid(lecture,0,6) ne '<NAME=' then begin
	print,strmid(lecture,0,5)
	print,'File is not a valid SERPE save file (<NAME>)'
	return
endif
lecture=(STRSPLIT(((STRSPLIT(lecture,'=',/EXTRACT))[1]),'>',/EXTRACT))[0]
simulation_name=lecture
readf,unit,lecture;<OUT=...>
if strmid(lecture,0,5) ne '<OUT=' then begin
	print,'File is not a valid SERPE save file (<OUT>)'
	return
endif
lecture=(STRSPLIT(((STRSPLIT(lecture,'=',/EXTRACT))[1]),'>',/EXTRACT))[0]
simulation_out=lecture
readf,unit,lecture;</SIMU>
if lecture ne '</SIMU>' then begin
	print,'File is not a valid SERPE save file (</SIMU>)'
	return
endif
readf,unit,lecture;<NUMBER>
if lecture ne '<NUMBER>' then begin
	print,'File is not a valid SERPE save file (<NUMBER>)'
	return
endif
readf,unit,lecture;<BODY=...>
if strmid(lecture,0,6) ne '<BODY=' then begin
	print,'File is not a valid SERPE save file (<BODY>)'
	return
endif
lecture=(STRSPLIT(((STRSPLIT(lecture,'=',/EXTRACT))[1]),'>',/EXTRACT))[0]
nbody=fix(lecture)
readf,unit,lecture;<DENS=...>
if strmid(lecture,0,9) ne '<DENSITY=' then begin
	print,'File is not a valid SERPE save file (<DENSITY>)'
	return
endif
lecture=(STRSPLIT(((STRSPLIT(lecture,'=',/EXTRACT))[1]),'>',/EXTRACT))[0]
ndens=fix(lecture)
readf,unit,lecture;<SOURCE=...>
if strmid(lecture,0,8) ne '<SOURCE=' then begin
	print,'File is not a valid SERPE save file (<SOURCE>)'
	return
endif
lecture=(STRSPLIT(((STRSPLIT(lecture,'=',/EXTRACT))[1]),'>',/EXTRACT))[0]
nsrc=fix(lecture)
readf,unit,lecture;</NUMBER>
if lecture ne '</NUMBER>' then begin
	print,'File is not a valid SERPE save file (</NUMBER>)'
	return
endif
readf,unit,lecture;<TIME>
if lecture ne '<TIME>' then begin
	print,'File is not a valid SERPE save file (<TIME>)'
	return
endif
readf,unit,lecture;<MIN=...>
lecture=(STRSPLIT(((STRSPLIT(lecture,'=',/EXTRACT))[1]),'>',/EXTRACT))[0]
time.mini=float(lecture)
readf,unit,lecture;<MAX=...>
lecture=(STRSPLIT(((STRSPLIT(lecture,'=',/EXTRACT))[1]),'>',/EXTRACT))[0]
time.maxi=float(lecture)
readf,unit,lecture;<NBR=...>
lecture=(STRSPLIT(((STRSPLIT(lecture,'=',/EXTRACT))[1]),'>',/EXTRACT))[0]
time.nbr=fix(lecture)
time.dt=(time.maxi-time.mini)/float(time.nbr)
readf,unit,lecture;</TIME>
if lecture ne '</TIME>' then begin
	print,'File is not a valid SERPE save file (</TIME>)'
	return
endif
readf,unit,lecture;<FREQUENCY>
if lecture ne '<FREQUENCY>' then begin
	print,'File is not a valid SERPE save file (<FREQUENCY>)'
	return
endif
readf,unit,lecture;<TYPE=...>
lecture=(STRSPLIT(((STRSPLIT(lecture,'=',/EXTRACT))[1]),'>',/EXTRACT))[0]
if lecture eq 'Linear' then begin
freq.log=0b & freq.predef=0b
endif
if lecture eq 'Log' then begin
freq.log=1b & freq.predef=0b
endif
if lecture eq 'Pre-Defined' then begin
freq.log=0b & freq.predef=1b
endif
readf,unit,lecture;<MIN=...>
lecture=(STRSPLIT(((STRSPLIT(lecture,'=',/EXTRACT))[1]),'>',/EXTRACT))[0]
freq.mini=float(lecture)
readf,unit,lecture;<MAX=...>
lecture=(STRSPLIT(((STRSPLIT(lecture,'=',/EXTRACT))[1]),'>',/EXTRACT))[0]
freq.maxi=float(lecture)
readf,unit,lecture;<NBR=...>
lecture=(STRSPLIT(((STRSPLIT(lecture,'=',/EXTRACT))[1]),'>',/EXTRACT))[0]
freq.nbr=fix(lecture)
freq.df=(time.maxi-time.mini)/float(time.nbr)
readf,unit,lecture;<SC=...>
lecture=(STRSPLIT(((STRSPLIT(lecture,'=',/EXTRACT))[1]),'>',/EXTRACT))[0]
if freq.predef then freq.name=(adresse_lib+'freq/'+lecture) else freq.name=''
readf,unit,lecture;</FREQUENCY>
if lecture ne '</FREQUENCY>' then begin
	print,'File is not a valid SERPE save file (</FREQUENCY>)'
	return
endif
readf,unit,lecture;<OBSERVER>
if lecture ne '<OBSERVER>' then begin
	print,'File is not a valid SERPE save file (<OBSERVER>)'
	return
endif
readf,unit,lecture;<TYPE=...>
lecture=(STRSPLIT(((STRSPLIT(lecture,'=',/EXTRACT))[1]),'>',/EXTRACT))[0]
if lecture eq 'Fixed' then begin
observer.motion=0b & observer.predef=0b
endif
if lecture eq 'Orbiter' then begin
observer.motion=1b & observer.predef=0b
endif
if lecture eq 'Pre-Defined' then begin
observer.motion=0b & observer.predef=1b
endif
readf,unit,lecture;<FIXE_DIST=...>
lecture=(STRSPLIT(((STRSPLIT(lecture,'=',/EXTRACT))[1]),'>',/EXTRACT))[0]
if ((observer.motion+observer.predef) eq 0b) then begin
observer.smaj=float(lecture)
observer.smin=float(lecture)
endif
readf,unit,lecture;<FIXE_SUBL=...>
lecture=(STRSPLIT(((STRSPLIT(lecture,'=',/EXTRACT))[1]),'>',/EXTRACT))[0]
if ((observer.motion+observer.predef) eq 0b) then observer.phs=-float(lecture)
readf,unit,lecture;<FIXE_DECL=...>
lecture=(STRSPLIT(((STRSPLIT(lecture,'=',/EXTRACT))[1]),'>',/EXTRACT))[0]
if ((observer.motion+observer.predef) eq 0b) then observer.decl=float(lecture)
readf,unit,lecture;<PARENT=...>
lecture=(STRSPLIT(((STRSPLIT(lecture,'=',/EXTRACT))[1]),'>',/EXTRACT))[0]
observer.parent=lecture
readf,unit,lecture;<SC=...>
lecture=(STRSPLIT(((STRSPLIT(lecture,'=',/EXTRACT))[1]),'>',/EXTRACT))[0]
observer.name=lecture
readf,unit,lecture;<SCTIME=...>
lecture=(STRSPLIT(((STRSPLIT(lecture,'=',/EXTRACT))[1]),'>',/EXTRACT))[0]
observer.start=lecture
readf,unit,lecture;<SEMI_MAJ=...>
lecture=(STRSPLIT(((STRSPLIT(lecture,'=',/EXTRACT))[1]),'>',/EXTRACT))[0]
if observer.motion then observer.smaj=float(lecture)
readf,unit,lecture;<SEMI_MIN=...>
lecture=(STRSPLIT(((STRSPLIT(lecture,'=',/EXTRACT))[1]),'>',/EXTRACT))[0]
if observer.motion then observer.smin=float(lecture)
readf,unit,lecture;<SUBL=...>
lecture=(STRSPLIT(((STRSPLIT(lecture,'=',/EXTRACT))[1]),'>',/EXTRACT))[0]
if observer.motion then observer.alg=float(lecture)
readf,unit,lecture;<DECL=...>
lecture=(STRSPLIT(((STRSPLIT(lecture,'=',/EXTRACT))[1]),'>',/EXTRACT))[0]
if observer.motion then observer.decl=float(lecture)
readf,unit,lecture;<PHASE=...>
lecture=(STRSPLIT(((STRSPLIT(lecture,'=',/EXTRACT))[1]),'>',/EXTRACT))[0]
if observer.motion then observer.phs=float(lecture)
readf,unit,lecture;<INCL=...>
lecture=(STRSPLIT(((STRSPLIT(lecture,'=',/EXTRACT))[1]),'>',/EXTRACT))[0]
if observer.motion then observer.incl=float(lecture)
readf,unit,lecture;</OBSERVER>
if lecture ne '</OBSERVER>' then begin
	print,'File is not a valid SERPE save file (</OBSERVER>)'
	return
endif
readf,unit,lecture;<SPDYN>
if lecture ne '<SPDYN>' then begin
	print,'File is not a valid SERPE save file (<SPDYN>)'
	return
endif
readf,unit,lecture;<INTENSITY=...>
lecture=(STRSPLIT(((STRSPLIT(lecture,'=',/EXTRACT))[1]),'>',/EXTRACT))[0]
spdyn.intensity=(lecture eq 'true')
readf,unit,lecture;<POLAR=...>
lecture=(STRSPLIT(((STRSPLIT(lecture,'=',/EXTRACT))[1]),'>',/EXTRACT))[0]
spdyn.polar=(lecture eq 'true')
readf,unit,lecture;<FREQ=...>
lecture=STRSPLIT(((STRSPLIT(((STRSPLIT(lecture,'=',/EXTRACT))[1]),'>',/EXTRACT))[0]),':',/EXTRACT)
spdyn.f_t=(lecture[0] eq 'true')
spdyn.f_r=(lecture[1] eq 'true')
spdyn.f_lg=(lecture[2] eq 'true')
spdyn.f_lat=(lecture[3] eq 'true')
spdyn.f_lt=(lecture[4] eq 'true')
lecture=''
readf,unit,lecture;<LONG=...>
lecture=STRSPLIT(((STRSPLIT(((STRSPLIT(lecture,'=',/EXTRACT))[1]),'>',/EXTRACT))[0]),':',/EXTRACT)
spdyn.lg_t=(lecture[0] eq 'true')
spdyn.lg_r=(lecture[1] eq 'true')
spdyn.lg_lg=(lecture[2] eq 'true')
spdyn.lg_lat=(lecture[3] eq 'true')
spdyn.lg_lt=(lecture[4] eq 'true')
lecture=''
readf,unit,lecture;<LAT=...>
lecture=STRSPLIT(((STRSPLIT(((STRSPLIT(lecture,'=',/EXTRACT))[1]),'>',/EXTRACT))[0]),':',/EXTRACT)
spdyn.lat_t=(lecture[0] eq 'true')
spdyn.lat_r=(lecture[1] eq 'true')
spdyn.lat_lg=(lecture[2] eq 'true')
spdyn.lat_lat=(lecture[3] eq 'true')
spdyn.lat_lt=(lecture[4] eq 'true')
lecture=''
readf,unit,lecture;<DRANGE=...>
lecture=STRSPLIT(((STRSPLIT(((STRSPLIT(lecture,'=',/EXTRACT))[1]),'>',/EXTRACT))[0]),':',/EXTRACT)
spdyn.xrange=float(lecture)
if (spdyn.xrange[0] ne spdyn.xrange[1]) then begin 
spdyn.nr=101
spdyn.dr=(spdyn.xrange[1]-spdyn.xrange[0])*0.01
endif else begin
spdyn.nr=1
spdyn.dr=1.
endelse
lecture=''
readf,unit,lecture;<LGRANGE=...>
lecture=STRSPLIT(((STRSPLIT(((STRSPLIT(lecture,'=',/EXTRACT))[1]),'>',/EXTRACT))[0]),':',/EXTRACT)
spdyn.lgrange=float(lecture)
if (spdyn.lgrange[0] ne spdyn.lgrange[1]) then begin 
spdyn.nlg=101
spdyn.dlg=(spdyn.lgrange[1]-spdyn.lgrange[0])*0.01
endif else begin
spdyn.nlg=1
spdyn.dlg=1.
endelse
lecture=''
readf,unit,lecture;<LARANGE=...>
lecture=STRSPLIT(((STRSPLIT(((STRSPLIT(lecture,'=',/EXTRACT))[1]),'>',/EXTRACT))[0]),':',/EXTRACT)
spdyn.larange=float(lecture)
if (spdyn.larange[0] ne spdyn.larange[1]) then begin 
spdyn.nlat=101
spdyn.dlat=(spdyn.larange[1]-spdyn.larange[0])*0.01
endif else begin
spdyn.nlat=1
spdyn.dlat=1.
endelse
lecture=''
readf,unit,lecture;<LTRANGE=...>
lecture=STRSPLIT(((STRSPLIT(((STRSPLIT(lecture,'=',/EXTRACT))[1]),'>',/EXTRACT))[0]),':',/EXTRACT)
spdyn.ltrange=float(lecture)
if (spdyn.ltrange[0] ne spdyn.ltrange[1]) then begin 
spdyn.nlt=101
spdyn.dlt=(spdyn.ltrange[1]-spdyn.ltrange[0])*0.01
endif else begin
spdyn.nlt=1
spdyn.dlt=1.
endelse
lecture=''
readf,unit,lecture;<KHZ=...>
lecture=(STRSPLIT(((STRSPLIT(lecture,'=',/EXTRACT))[1]),'>',/EXTRACT))[0]
spdyn.khz=(lecture eq 'true')
readf,unit,lecture;<LOG=...>
lecture=(STRSPLIT(((STRSPLIT(lecture,'=',/EXTRACT))[1]),'>',/EXTRACT))[0]
spdyn.log=(lecture eq 'true')
readf,unit,lecture;<PDF=...>
lecture=(STRSPLIT(((STRSPLIT(lecture,'=',/EXTRACT))[1]),'>',/EXTRACT))[0]
spdyn.pdf=(lecture eq 'true')
readf,unit,lecture;</SPDYN>
if lecture ne '</SPDYN>' then begin
	print,'File is not a valid SERPE save file (</SPDYN>)'
	return
endif
readf,unit,lecture;<MOVIE2D>
if lecture ne '<MOVIE2D>' then begin
	print,'File is not a valid SERPE save file (<MOVIE2D>)'
	return
endif
readf,unit,lecture;<ON=...>
lecture=(STRSPLIT(((STRSPLIT(lecture,'=',/EXTRACT))[1]),'>',/EXTRACT))[0]
mov2d.on=(lecture eq 'true')
readf,unit,lecture;<SUBCYCLE=...>
lecture=(STRSPLIT(((STRSPLIT(lecture,'=',/EXTRACT))[1]),'>',/EXTRACT))[0]
mov2d.sub=fix(lecture)>1
readf,unit,lecture;<RANGE=...>
lecture=(STRSPLIT(((STRSPLIT(lecture,'=',/EXTRACT))[1]),'>',/EXTRACT))[0]
mov2d.range=float(lecture)
readf,unit,lecture;</MOVIE2D>
if lecture ne '</MOVIE2D>' then begin
	print,'File is not a valid SERPE save file (</MOVIE2D>)'
	return
endif
readf,unit,lecture;<MOVIE3D>
if lecture ne '<MOVIE3D>' then begin
	print,'File is not a valid SERPE save file (<MOVIE3D>)'
	return
endif
readf,unit,lecture;<ON=...>
lecture=(STRSPLIT(((STRSPLIT(lecture,'=',/EXTRACT))[1]),'>',/EXTRACT))[0]
mov3d.on=(lecture eq 'true')
readf,unit,lecture;<SUBCYCLE=...>
lecture=(STRSPLIT(((STRSPLIT(lecture,'=',/EXTRACT))[1]),'>',/EXTRACT))[0]
mov3d.sub=fix(lecture)>1
readf,unit,lecture;<XRANGE=...>
lecture=STRSPLIT(((STRSPLIT(((STRSPLIT(lecture,'=',/EXTRACT))[1]),'>',/EXTRACT))[0]),':',/EXTRACT)
mov3d.xrange=float(lecture)
lecture=''
readf,unit,lecture;<YRANGE=...>
lecture=STRSPLIT(((STRSPLIT(((STRSPLIT(lecture,'=',/EXTRACT))[1]),'>',/EXTRACT))[0]),':',/EXTRACT)
mov3d.yrange=float(lecture)
lecture=''
readf,unit,lecture;<ZRANGE=...>
lecture=STRSPLIT(((STRSPLIT(((STRSPLIT(lecture,'=',/EXTRACT))[1]),'>',/EXTRACT))[0]),':',/EXTRACT)
mov3d.zrange=float(lecture)
lecture=''
readf,unit,lecture;<OBS=...>
lecture=(STRSPLIT(((STRSPLIT(lecture,'=',/EXTRACT))[1]),'>',/EXTRACT))[0]
mov3d.obs=(lecture eq 'true')
readf,unit,lecture;<TRAJ=...>
lecture=(STRSPLIT(((STRSPLIT(lecture,'=',/EXTRACT))[1]),'>',/EXTRACT))[0]
mov3d.traj=(lecture eq 'true')
readf,unit,lecture;</MOVIE3D>
if lecture ne '</MOVIE3D>' then begin
	print,'File is not a valid SERPE save file (</MOVIE3D>)'
	return
endif
bd=[body]
ds=[dens]
n=0
nd=0
for i=1,nbody do begin
readf,unit,lecture;<BODY>
readf,unit,lecture;<ON=...>
lecture=(STRSPLIT(((STRSPLIT(lecture,'=',/EXTRACT))[1]),'>',/EXTRACT))[0]
on=(lecture eq 'true')
if on then begin
	n=n+1
	bd=[bd,body]
readf,unit,lecture;<NAME=...>
lecture=(STRSPLIT(((STRSPLIT(lecture,'=',/EXTRACT))[1]),'>',/EXTRACT))[0]
bd[n].name=lecture
readf,unit,lecture;<RADIUS=...>
lecture=(STRSPLIT(((STRSPLIT(lecture,'=',/EXTRACT))[1]),'>',/EXTRACT))[0]
bd[n].rad=float(lecture)
readf,unit,lecture;<PERIOD=...>
lecture=(STRSPLIT(((STRSPLIT(lecture,'=',/EXTRACT))[1]),'>',/EXTRACT))[0]
bd[n].per=float(lecture)
readf,unit,lecture;<ORB_PER=...>
lecture=(STRSPLIT(((STRSPLIT(lecture,'=',/EXTRACT))[1]),'>',/EXTRACT))[0]
bd[n].orb1=float(lecture)
readf,unit,lecture;<INIT_AX=...>
lecture=(STRSPLIT(((STRSPLIT(lecture,'=',/EXTRACT))[1]),'>',/EXTRACT))[0]
bd[n].lg0=float(lecture)
readf,unit,lecture;<MAG=...>
lecture=(STRSPLIT(((STRSPLIT(lecture,'=',/EXTRACT))[1]),'>',/EXTRACT))[0]
bd[n].mfl=lecture
readf,unit,lecture;<MOTION=...>
lecture=(STRSPLIT(((STRSPLIT(lecture,'=',/EXTRACT))[1]),'>',/EXTRACT))[0]
bd[n].sat=(lecture eq 'true')
readf,unit,lecture;<PARENT=...>
lecture=(STRSPLIT(((STRSPLIT(lecture,'=',/EXTRACT))[1]),'>',/EXTRACT))[0]
bd[n].parent=strtrim(lecture,2)
readf,unit,lecture;<SEMI_MAJ=...>
lecture=(STRSPLIT(((STRSPLIT(lecture,'=',/EXTRACT))[1]),'>',/EXTRACT))[0]
bd[n].smaj=float(lecture)
readf,unit,lecture;<SEMI_MIN=...>
lecture=(STRSPLIT(((STRSPLIT(lecture,'=',/EXTRACT))[1]),'>',/EXTRACT))[0]
bd[n].smin=float(lecture)
readf,unit,lecture;<DECLINATION=...>
lecture=(STRSPLIT(((STRSPLIT(lecture,'=',/EXTRACT))[1]),'>',/EXTRACT))[0]
bd[n].decl=float(lecture)
readf,unit,lecture;<APO_LONG=...>
lecture=(STRSPLIT(((STRSPLIT(lecture,'=',/EXTRACT))[1]),'>',/EXTRACT))[0]
bd[n].alg=float(lecture)
readf,unit,lecture;<INCLINATION=...>
lecture=(STRSPLIT(((STRSPLIT(lecture,'=',/EXTRACT))[1]),'>',/EXTRACT))[0]
bd[n].incl=float(lecture)
readf,unit,lecture;<PHASE=...>
lecture=(STRSPLIT(((STRSPLIT(lecture,'=',/EXTRACT))[1]),'>',/EXTRACT))[0]
bd[n].phs=float(lecture)
	readf,unit,lecture;</BODY>
for l=1,ndens do begin
readf,unit,lecture;<DENSITY>
readf,unit,lecture;<ON=...>
lecture=(STRSPLIT(((STRSPLIT(lecture,'=',/EXTRACT))[1]),'>',/EXTRACT))[0]
on=(lecture eq 'true')
	if on then begin
		nd=nd+1
		ds=[ds,dens]
		bd[n].dens[i-1]=nd
readf,unit,lecture;<NAME=...>
lecture=(STRSPLIT(((STRSPLIT(lecture,'=',/EXTRACT))[1]),'>',/EXTRACT))[0]
ds[nd].name=lecture
readf,unit,lecture;<TYPE=...>
lecture=(STRSPLIT(((STRSPLIT(lecture,'=',/EXTRACT))[1]),'>',/EXTRACT))[0]
ds[nd].type=lecture
readf,unit,lecture;<RHO0=...>
lecture=(STRSPLIT(((STRSPLIT(lecture,'=',/EXTRACT))[1]),'>',/EXTRACT))[0]
ds[nd].rho0=float(lecture)
readf,unit,lecture;<SCALE=...>
lecture=(STRSPLIT(((STRSPLIT(lecture,'=',/EXTRACT))[1]),'>',/EXTRACT))[0]
ds[nd].height=float(lecture)
readf,unit,lecture;<PERP=...>
lecture=(STRSPLIT(((STRSPLIT(lecture,'=',/EXTRACT))[1]),'>',/EXTRACT))[0]
ds[nd].perp=float(lecture)
readf,unit,lecture;</DENSITY>
	endif else for j=0,5 do readf,unit,lecture
endfor
endif else begin
;skip if body not used
for j=0,14 do readf,unit,lecture
for k=1,ndens do for j=0,7 do readf,unit,lecture
endelse
endfor

sc=[src]
n=0
for i=1,nsrc do begin
readf,unit,lecture;<SOURCE>
readf,unit,lecture;<ON=...>
lecture=(STRSPLIT(((STRSPLIT(lecture,'=',/EXTRACT))[1]),'>',/EXTRACT))[0]
on=(lecture eq 'true')
if on then begin
	n=n+1
	sc=[sc,src]
readf,unit,lecture;<NAME=...>
lecture=(STRSPLIT(((STRSPLIT(lecture,'=',/EXTRACT))[1]),'>',/EXTRACT))[0]
sc[n].name=lecture
readf,unit,lecture;<PARENT=...>
lecture=(STRSPLIT(((STRSPLIT(lecture,'=',/EXTRACT))[1]),'>',/EXTRACT))[0]
sc[n].parent=STRTRIM(lecture,2)
readf,unit,lecture;<TYPE=...>
lecture=(STRSPLIT(((STRSPLIT(lecture,'=',/EXTRACT))[1]),'>',/EXTRACT))[0]
sc[n].type=lecture
readf,unit,lecture;<LG_MIN=...>
lecture=(STRSPLIT(((STRSPLIT(lecture,'=',/EXTRACT))[1]),'>',/EXTRACT))[0]
sc[n].lgmin=float(lecture)
readf,unit,lecture;<LG_MAX=...>
lecture=(STRSPLIT(((STRSPLIT(lecture,'=',/EXTRACT))[1]),'>',/EXTRACT))[0]
sc[n].lgmax=float(lecture)
readf,unit,lecture;<LG_NBR=...>
lecture=(STRSPLIT(((STRSPLIT(lecture,'=',/EXTRACT))[1]),'>',/EXTRACT))[0]
sc[n].lgstep=(sc[n].lgmax-sc[n].lgmin)/float((fix(lecture)-1)>1)
if sc[n].lgstep eq 0 then sc[n].lgstep=1
readf,unit,lecture;<LAT=...>
lecture=(STRSPLIT(((STRSPLIT(lecture,'=',/EXTRACT))[1]),'>',/EXTRACT))[0]
sc[n].latmin=float(lecture)
sc[n].latmax=float(lecture)
readf,unit,lecture;<SUB=...>
lecture=(STRSPLIT(((STRSPLIT(lecture,'=',/EXTRACT))[1]),'>',/EXTRACT))[0]
sc[n].subcor=float(lecture)
readf,unit,lecture;<SAT=...>
lecture=(STRSPLIT(((STRSPLIT(lecture,'=',/EXTRACT))[1]),'>',/EXTRACT))[0]
sc[n].sat=STRTRIM(lecture,2)
readf,unit,lecture;<NORTH=...>
lecture=(STRSPLIT(((STRSPLIT(lecture,'=',/EXTRACT))[1]),'>',/EXTRACT))[0]
sc[n].north=(lecture eq 'true')
readf,unit,lecture;<SOUTH=...>
lecture=(STRSPLIT(((STRSPLIT(lecture,'=',/EXTRACT))[1]),'>',/EXTRACT))[0]
sc[n].south=(lecture eq 'true')
readf,unit,lecture;<WIDTH=...>
lecture=(STRSPLIT(((STRSPLIT(lecture,'=',/EXTRACT))[1]),'>',/EXTRACT))[0]
sc[n].width=float(lecture)
readf,unit,lecture;<CURRENT=...>
lecture=(STRSPLIT(((STRSPLIT(lecture,'=',/EXTRACT))[1]),'>',/EXTRACT))[0]
sc[n].loss=(lecture eq 'Transient (Aflvénic)')
readf,unit,lecture;<ACCEL=...>
lecture=(STRSPLIT(((STRSPLIT(lecture,'=',/EXTRACT))[1]),'>',/EXTRACT))[0]
sc[n].v=sqrt(float(lecture)/255.5)
readf,unit,lecture;<TEMP=...>
lecture=(STRSPLIT(((STRSPLIT(lecture,'=',/EXTRACT))[1]),'>',/EXTRACT))[0]
sc[n].cold=float(lecture)/255.5
readf,unit,lecture;<TEMPH=...>
lecture=(STRSPLIT(((STRSPLIT(lecture,'=',/EXTRACT))[1]),'>',/EXTRACT))[0]
sc[n].temp=float(lecture)/255.5
readf,unit,lecture;</SOURCE>
endif else for j=0,16 do readf,unit,lecture
endfor
nobj=n_elements(bd)-1+n_elements(ds)-1+2*(n_elements(sc)-1)+2+mov2d.on+mov3d.on+1;sacred

TEMPS={TIME,debut:time.mini,fin:time.maxi,step:time.dt,n_step:time.nbr,time:0.,t0:0.,istep:0}
FREQUE={FREQ,fmin:freq.mini,fmax:freq.maxi,n_freq:freq.nbr,step:freq.df,file:freq.name,log:freq.log,freq_tab:PTR_NEW(/ALLOCATE_HEAP)}
parameters={PARAMETERS,time:temps,freq:freque,name:simulation_name,objects:PTRARR(nobj,/ALLOCATE_HEAP),out:simulation_out}


n=0
for i=0,n_elements(ds)-2 do begin
tp=(ds[i+1]).type
case tp of
'Stellar': typ='stellar'
'Ionospheric': typ='ionospheric'
'Torus': typ='torus'
'Disk': typ='disk'
end

(parameters.objects[n])=PTR_NEW({DENSITY,name:(ds[i+1]).name,type:typ,rho0:(ds[i+1]).rho0,height:(ds[i+1]).height,perp:(ds[i+1]).perp,it:[''],cb:[''],fz:['']})
n=n+1
endfor

rank_bodies,bd

start_bodies=n

for i=0,n_elements(bd)-2 do begin
(parameters.objects[n])=PTR_NEW({BODY,name:(bd[i+1]).name,radius:(bd[i+1]).rad,period:(bd[i+1]).per,orb_1r:(bd[i+1]).orb1,lg0:(bd[i+1]).lg0,motion:(bd[i+1]).sat,$
				parent:PTR_NEW(/ALLOCATE_HEAP),initial_phase:(bd[i+1]).phs,semi_major_axis:(bd[i+1]).smaj,semi_minor_axis:(bd[i+1]).smin,apoapsis_declination:(bd[i+1]).decl,$
				apoapsis_longitude:(bd[i+1]).alg,orbit_inclination:(bd[i+1]).incl,traj_file:'',density:PTR_NEW(/ALLOCATE_HEAP),$
				lg:PTR_NEW(/ALLOCATE_HEAP),lct:PTR_NEW(/ALLOCATE_HEAP),trajectory_xyz:PTR_NEW(/ALLOCATE_HEAP),trajectory_rtp:PTR_NEW(/ALLOCATE_HEAP),$
				it:['init_body','init_orb'],cb:['cb_body'],fz:[''],rot:fltarr(3,3),body_rank:0})
if (bd[i+1]).ipar ne 0 then (*((parameters.objects)[n])).parent=(parameters.objects[n-i+(bd[i+1]).ipar-1])
w=where(((bd[i+1]).dens) ne 0)
if w[0] eq -1 then ndd=0 else begin
ndd=n_elements(w)
(*((parameters.objects[n]))).density=PTR_NEW(PTRARR(ndd,/ALLOCATE_HEAP))
n0=0
for j=0,ndens-1 do if ((bd[i+1]).dens)[j] ne 0 then begin
(*((*((parameters.objects[n]))).density))[n0]=(parameters.objects[((bd[i+1]).dens)[j]-1])
n0=n0+1
endif
endelse
n=n+1
endfor

nm1=""
if (observer.name ne "") then begin
nm1=file_name
STRREPLACE,nm1,'on-going','tmp'
nm1=strsplit(nm1,".",/EXTRACT)
nm1=nm1[0]+'.eph'
endif
(parameters.objects[n])=PTR_NEW({OBSERVER,name:observer.name,motion:observer.motion,parent:PTR_NEW(/ALLOCATE_HEAP),initial_phase:observer.phs,semi_major_axis:observer.smaj,$
semi_minor_axis:observer.smin,apoapsis_declination:observer.decl,apoapsis_longitude:observer.alg,orbit_inclination:observer.incl,traj_file:nm1,$
				trajectory_xyz:PTR_NEW(/ALLOCATE_HEAP),trajectory_rtp:PTR_NEW(/ALLOCATE_HEAP),$
				lg:PTR_NEW(/ALLOCATE_HEAP),it:['init_orb'],cb:['cb_orb'],fz:['']})
x=bd[*].name
wpar=where(x eq (observer.parent))
if wpar[0] gt 0 then begin
wpar=wpar[0]-1+start_bodies
(*parameters.objects[n]).parent=(parameters.objects[wpar])
endif
if (wpar[0] eq -1) then begin
	print,'An observer has no parent.'
	return
endif
help,*(parameters.objects[n]),/str
n=n+1



for i=0,n_elements(sc)-2 do begin
if ((sc[i+1]).type eq 'attached to a satellite') then sat=1b else sat=0b
nm=(sc[i+1]).name+'_ft'
(parameters.objects[n])=PTR_NEW({FEATURE,name:nm,parent:PTR_NEW(/ALLOCATE_HEAP),folder:'',north:(sc[i+1]).north,south:(sc[i+1]).south,$
				loffset:0.,l_min:(sc[i+1]).latmin,l_max:(sc[i+1]).latmax,nlat:1,sat:sat,lct:0b,subcor:(sc[i+1]).subcor,oval_lat0:0.,aurora_alt:0.,file_lat:'',file_lg:'',$
				b_n:PTR_NEW(/ALLOCATE_HEAP),x_n:PTR_NEW(/ALLOCATE_HEAP),bz_n:PTR_NEW(/ALLOCATE_HEAP),gb_n:PTR_NEW(/ALLOCATE_HEAP),$
				b_s:PTR_NEW(/ALLOCATE_HEAP),x_s:PTR_NEW(/ALLOCATE_HEAP),bz_s:PTR_NEW(/ALLOCATE_HEAP),gb_s:PTR_NEW(/ALLOCATE_HEAP),$
				fmax:PTR_NEW(/ALLOCATE_HEAP),feq:PTR_NEW(/ALLOCATE_HEAP),grad_b_eq:PTR_NEW(/ALLOCATE_HEAP),grad_b_in:PTR_NEW(/ALLOCATE_HEAP),$
				dens_n:PTR_NEW(/ALLOCATE_HEAP),dens_s:PTR_NEW(/ALLOCATE_HEAP),rot:fltarr(3,3),lg:0.,pos_xyz:fltarr(3),$
				it:['init_field'],cb:['cb_rot_field'],fz:[''],latitude:fltarr(360),longitude:findgen(360)})
x=bd[*].name
wpar=where(x eq (sc[i+1]).parent)
if wpar[0] gt 0 then begin
mfl=bd[wpar[0]].mfl
(*((parameters.objects[n]))).name=mfl+'__'+(*((parameters.objects[n]))).name
wpar=wpar[0]-1+start_bodies
parent=(parameters.objects[wpar])
endif
if sat and (wpar[0] eq -1) then begin
	print,'A source attached to a satellite has no parent.'
	return
endif

x=bd[*].name
wsat=where(x eq (sc[i+1]).sat)
if wsat[0] gt 0 then begin
wsat=wsat[0]-1+start_bodies
satel=(parameters.objects[wsat])
endif
if sat and (wsat[0] eq -1) then begin
	print,'A source attached to a satellite is actually attached to a fixed body.'
	return
endif


if sat then (*((parameters.objects[n]))).parent=satel else (*((parameters.objects[n]))).parent=parent
if sat then begin
a=(*satel).semi_major_axis
b=(*satel).semi_minor_axis
c=sqrt(a^2-b^2)
b=(fix(a-c))>2
a=(fix(a+c+1))<50
(*((parameters.objects[n]))).l_min=b
(*((parameters.objects[n]))).l_max=a
(*((parameters.objects[n]))).nlat=(a-b+1)

endif

case mfl of 
'O6+Connerney CS':fld='O6'
'VIP4+Connerney CS' :fld='VIP4'
'VIPAL+Connerney CS' : fld='VIPAL'
'O6 Connerney CS':fld='O6'
'VIP4 Connerney CS' :fld='VIP4'
'VIPAL Connerney CS' : fld='VIPAL'
'SPV': fld='SPV'
 'Z3': fld='Z3'
 else: fld=''
end

if strmid(mfl,0,6) eq 'Dipole' then fld=mfl else fld=adresse_lib+'/mfl/'+fld
if ((sc[i+1]).type eq 'fixed in latitude') then (*((parameters.objects[n]))).folder=fld+'_lat' else (*((parameters.objects[n]))).folder=fld+'_lsh'


n=n+1
(parameters.objects[n])=PTR_NEW({SOURCE,name:(sc[i+1]).name,parent:PTR_NEW(/ALLOCATE_HEAP),loss:(sc[i+1]).loss,ring:0b,cavity:(1b-(sc[i+1]).loss),rampe:0b,constant:0.,asymp:0.,width:(sc[i+1]).width,$
				temp:(sc[i+1]).temp,cold:(sc[i+1]).cold,vmin:(sc[i+1]).v,vmax:(sc[i+1]).v,vstep:1.,lgmin:(sc[i+1]).lgmin,lgmax:(sc[i+1]).lgmax,$
				lgstep:(sc[i+1]).lgstep,latmin:0.,latmax:0.,latstep:1.,$
				lgtov:0.,north:(sc[i+1]).north,south:(sc[i+1]).south,grad_eq:0,grad_in:0,shield:1b,$
				nsrc:1,spdyn:PTR_NEW(/ALLOCATE_HEAP),v:PTR_NEW(/ALLOCATE_HEAP),$
				lat:PTR_NEW(/ALLOCATE_HEAP),lg:PTR_NEW(/ALLOCATE_HEAP),x:PTR_NEW(/ALLOCATE_HEAP),it:['init_src'],cb:['cb_src'],fz:['']})
(*((parameters.objects[n]))).parent=(parameters.objects[n-1])

n=n+1
endfor

(parameters.objects[n])=PTR_NEW({SPDYN,name:'',src_each:0b,src_pole:0b,dif_each:0b,pol:spdyn.polar,pdf:spdyn.pdf,log:spdyn.log,khz:spdyn.khz,$
				f_t:spdyn.f_t,lg_t:spdyn.lg_t,lat_t:spdyn.lat_t,f_r:spdyn.f_r,lg_r:spdyn.lg_r,lat_r:spdyn.lat_r,f_lg:spdyn.f_lg,lg_lg:spdyn.lg_lg,$
				lat_lg:spdyn.lat_lg,f_lat:spdyn.f_lat,lg_lat:spdyn.lg_lat,lat_lat:spdyn.lat_lat,f_lt:spdyn.f_lt,lg_lt:spdyn.lg_lt,lat_lt:spdyn.lat_lt,$
				lgmin:spdyn.lgrange[0],nlg:spdyn.nlg,lgstp:spdyn.dlg,latmin:spdyn.larange[0],nlat:spdyn.nlat,latstp:spdyn.dlat,$
				ltmin:spdyn.ltrange[0],nlt:spdyn.nlt,ltstp:spdyn.dlt,rmin:spdyn.xrange[0],nr:spdyn.nr,rstp:spdyn.dr,$
				it:['init_spdyn'],cb:['cb_spdyn'],fz:['fz_spdyn'],nspd:0,out:PTR_NEW(/ALLOCATE_HEAP),f:0b,lg:0b,lat:0b,lct:0b,src_all:0b})
n=n+1

if mov2d.on then begin
(parameters.objects[n])=PTR_NEW({MOVIE2D,name:'movie_2d',sub:mov2d.sub,obs:0b,mfl:0b,traj:0b,xr:[-mov2d.range,mov2d.range],yr:[-mov2d.range,mov2d.range],zr:[-mov2d.range,mov2d.range],it:[''],cb:['cb_movie2d'],fz:['fz_movie2d']})
n=n+1
endif
if mov3d.on then begin
(parameters.objects[n])=PTR_NEW({MOVIE3D,name:'movie_3d',sub:mov3d.sub,obs:mov3d.obs,mfl:1b,traj:mov3d.traj,xr:mov3d.xrange,yr:mov3d.yrange,zr:mov3d.zrange,it:[''],cb:['cb_movie'],fz:['fz_movie']})
n=n+1
endif
CALDAT,SYSTIME(/JULIAN), Mo, D, Y, H, Mi, S
if (STRLEN(observer.start) eq 10) then begin
Y=2000+fix(strmid(observer.start,0,2))
Mo=fix(strmid(observer.start,2,2))
D=fix(strmid(observer.start,4,2))
H=fix(strmid(observer.start,6,2))
Mi=fix(strmid(observer.start,8,2))
S=0
endif
(parameters.objects[n])=PTR_NEW({SACRED,date:[Y,Mo,D,H,Mi,S],it:['init_sacred'],cb:['cb_sacred'],fz:['fz_sacred']})
end

