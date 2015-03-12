;***********************************************************
;***                                                     ***
;***         SERPE V6.0                                  ***
;***                                                     ***
;***********************************************************
;***                                                     ***
;***       MODULE: SPDYN                                 ***
;***                                                     ***
;***     INIT                                            ***
;***     CALLBACK                                        ***
;***     FINALIZE                                        ***
;***                                                     ***
;***********************************************************



;************************************************************** INIT_SPDYN
pro init_spdyn,obj,parameters
n1=(((*obj).f_t+(*obj).f_r+(*obj).f_lg+(*obj).f_lt)<1)+$
(((*obj).lg_t+(*obj).lg_r+(*obj).lg_lg+(*obj).lg_lt)<1)+$
(((*obj).lat_t+(*obj).lat_r+(*obj).lat_lg+(*obj).lat_lt)<1);+$
;(((*obj).lt_t+(*obj).lt_r+(*obj).lt_lg+(*obj).lt_lt)<1)
nobj=n_elements(parameters.objects)
n2=0
for i=0,nobj-1 do begin
if TAG_NAMES(*(parameters.objects[i]),/str) eq 'SOURCE' then n2=n2+1
endfor
if ~(*obj).src_each then (*obj).src_all=1b
if n2 ge 8 then (*obj).dif_each=0b
if (*obj).src_all then n2=1
if (*obj).src_pole or (*obj).pol then n2=2*n2
n=n2*n1
(*obj).nspd=n
*((*obj).out)=PTRarr(n,/ALLOCATE_HEAP)
n=1
if (*obj).f_t then begin
    (*obj).f=n
    for i=n,n+n2-1 do (*((*((*obj).out))[i-1]))=bytarr(parameters.freq.n_freq,parameters.time.n_step)
    n=n+n2
endif
if (*obj).lg_t then begin
    (*obj).lg=n
    for i=n,n+n2-1 do (*((*((*obj).out))[i-1]))=bytarr((*obj).nlg,parameters.time.n_step)
    n=n+n2
endif
if (*obj).lat_t then begin
    (*obj).lat=n
    for i=n,n+n2-1 do (*((*((*obj).out))[i-1]))=bytarr((*obj).nlat,parameters.time.n_step)
    n=n+n2
endif
;if (*obj).lt_t then begin
;    (*obj).lct=n
;    for i=n,n+n2-1 do (*((*((*obj).out))[i-1]))=bytarr((*obj).nlat,parameters.time.n_step)
;    n=n+n2
;endif
return
end


;************************************************************** CB_SPDYN
pro cb_spdyn,obj,parameters
nobj=n_elements(parameters.objects)
n2=0
t=parameters.time.istep

for i=0,nobj-1 do if TAG_NAMES(*(parameters.objects[i]),/str) eq 'SOURCE' then begin
src=(*(parameters.objects[i]))
lg0=fix(*src.lg+(*src.parent).lg); & lg1=(fix(*src.lg+(*src.parent).lg+1) mod 360) & c=(*src.lg)+(*src.parent).lg-lg0
;lg=(1.-c)*(*src.parent).longitude[lg0]+c*(*src.parent).longitude[lg1]
;lg0=fix(lg) & lg1=(fix(lg+1) mod 360) & c=lg-lg0
c=0. & lg1=0
lat=(1.-c)*(*src.parent).latitude[lg0]+c*(*src.parent).latitude[lg1]
lg=(*src.lg+(*src.parent).lg) mod 360
lg=(FIX((lg-(*obj).lgmin)/(*obj).lgstp)>0)<((*obj).nlg-1)
lat=(FIX((lg-(*obj).lgmin)/(*obj).latstp)>0)<((*obj).nlat-1)

if (*obj).src_each then n2=n2+1
if (*obj).src_each and ((*obj).src_pole or (*obj).pol) then n2=n2+1
;stop
if ((*obj).f_t+(*obj).f_r+(*obj).f_lg+(*obj).f_lt) ne 0 then begin
(*((*((*obj).out))[(*obj).f+n2-1]))[*,t]=(*((*((*obj).out))[(*obj).f+n2-1]))[*,t]+$
totale(totale((*((*(parameters.objects[i])).spdyn))[*,*,0:1-((*obj).src_pole+(*obj).pol)],3),2)
if ((*obj).src_pole or (*obj).pol) then (*((*((*obj).out))[(*obj).f+n2]))[*,t]=(*((*((*obj).out))[(*obj).f+n2]))[*,t]+$
totale((*((*(parameters.objects[i])).spdyn))[*,*,1],2)
endif
if ((*obj).lg_t+(*obj).lg_r+(*obj).lg_lg+(*obj).lg_lt) ne 0 then begin
for j=0,n_elements(lg)-1 do (*((*((*obj).out))[(*obj).lg+n2-1]))[lg[j],t]=(*((*((*obj).out))[(*obj).lg+n2-1]))[lg[j],t]+$
totale(totale((*((*(parameters.objects[i])).spdyn))[*,j,0:1-((*obj).src_pole+(*obj).pol)],3),1)
if ((*obj).src_pole or (*obj).pol) then for j=0,n_elements(lg)-1 do $
(*((*((*obj).out))[(*obj).lg+n2]))[lg[j],t]=(*((*((*obj).out))[(*obj).lg+n2]))[lg[j],t]+$
totale((*((*(parameters.objects[i])).spdyn))[*,j,1],1)
endif
if ((*obj).lat_t+(*obj).lat_r+(*obj).lat_lg+(*obj).lat_lt) ne 0 then begin
for j=0,n_elements(lat)-1 do (*((*((*obj).out))[(*obj).lat+n2-1]))[lat[j],t]=(*((*((*obj).out))[(*obj).lat+n2-1]))[lat[j],t]+$
totale(totale((*((*(parameters.objects[i])).spdyn))[*,j,0:1-((*obj).src_pole+(*obj).pol)],3),1)
if ((*obj).src_pole or (*obj).pol) then for j=0,n_elements(lat)-1 do $
(*((*((*obj).out))[(*obj).lat+n2]))[lat[j],t]=(*((*((*obj).out))[(*obj).lat+n2]))[lat[j],t]+$
totale((*((*(parameters.objects[i])).spdyn))[*,j,1],1)
endif

endif;boucle
return
end

;************************************************************** FZ_SPDYN
pro fz_spdyn,obj,parameters
nom=parameters.out & if nom eq '' then nom='out'
t=parameters.time.istep
nobj=n_elements(parameters.objects)
for i=0,nobj-1 do if TAG_NAMES(*(parameters.objects[i]),/str) eq 'OBSERVER' then begin
r=(fix(((*((*(parameters.objects[i])).trajectory_rtp))[0,*]-(*obj).rmin)/(*obj).rstp)>0)<((*obj).nr-1)
olg=(fix(((*((*(parameters.objects[i])).lg))-(*obj).lgmin)/(*obj).lgstp)>0)<((*obj).nlg-1)
olat=(fix((90.-((*((*(parameters.objects[i])).trajectory_rtp))[1,*]*!radeg)-(*obj).latmin)/(*obj).latstp)>0)<((*obj).nlat-1)
olt=(fix((((*((*(parameters.objects[i])).lg))/15.)-(*obj).ltmin)/(*obj).ltstp)>0)<((*obj).nlt-1)
endif
set_plot,'ps'
!p.font=1
!p.multi=[0,1,1]
n2=0
for i=0,nobj-1 do if TAG_NAMES(*(parameters.objects[i]),/str) eq 'SOURCE' then n2=n2+1
w=intarr(n2)
if (*obj).src_all then n2=1
if (*obj).src_pole then n2=2*n2
n=0
for i=0,nobj-1 do if TAG_NAMES(*(parameters.objects[i]),/str) eq 'SOURCE' then begin
w[n]=i & n=n+1
endif

stp=1+(*obj).pol
if (*obj).f ne 0 then for i=(*obj).f,(*obj).f+n2-1,stp do begin
nom1=nom
nsrc=i-1 & if (*obj).src_pole or (*obj).pol then nsrc=fix(nsrc/2)
ntab=i-1 ;& if (*obj).pol then ntab=fix(ntab/2)
title=parameters.name
if (*obj).pol then nom1=nom1+'_pol'
if (*obj).src_each then begin

 title=title+' source: '+(*parameters.objects[w[nsrc+1]]).name
 nom1=nom1+'_'+(*parameters.objects[w[nsrc+1]]).name
endif
if (*obj).src_pole and ((nsrc mod 2) eq 0) then begin
title=title+' North'
 nom1=nom1+'_North'
endif
if (*obj).src_pole and ((nsrc mod 2) eq 1) then begin
title=title+' South'
 nom1=nom1+'_South'
endif
ytit='Frequency ' & if (*obj).kHz then ytit=ytit+'(kHz)' else ytit=ytit+'(MHz)'
f=*parameters.freq.freq_tab
;if (*obj).khz then f=f*1000.
if (*obj).log eq 0 then $
U=((parameters.freq.fmin)+(findgen(parameters.freq.n_freq)/float(parameters.freq.n_freq-1L)*$
((parameters.freq.fmax)-(parameters.freq.fmin)))) $
else $
U=10^(alog10(parameters.freq.fmin)+(findgen(parameters.freq.n_freq)/(parameters.freq.n_freq-1L)*$
(alog10(parameters.freq.fmax)-alog10(parameters.freq.fmin))))
image=fix(transpose(*((*((*obj).out))[ntab]))) & if (*obj).pol then image=image-fix(transpose(*((*((*obj).out))[ntab+1])))
for j=0l,parameters.time.n_step-1l do image(j,*)=interpol(float(image(j,*)),f,u)

if (*obj).khz then U=U*1000.
if (*obj).f_t then begin
device,filename=nom1+'_f_t.ps',/landscape,bits=8
xtit='Time (min)'
if (*obj).log eq 1 then spdynps,image,parameters.time.debut,parameters.time.fin,min(U),max(U),xtit,ytit,title,1,0,0,0,1.,/log else $
spdynps,image,parameters.time.debut,parameters.time.fin,min(U),max(U),xtit,ytit,title,0,0,0,0,1.
device,/close
if (*obj).pdf then begin
print,'PDF'
cmd='/opt/local/bin/ps2pdf '+nom1+'_f_t.ps '+nom1+'_f_t.pdf'
print,cmd
  spawn,cmd
  spawn,'rm -f '+nom1+'_f_t.ps'
endif
endif

if (*obj).f_r then begin
device,filename=nom1+'_f_r.ps',/landscape,bits=8
r0=((*obj).nr-1)*(*obj).rstp+(*obj).rmin
s=sort(r)
im=intarr((*obj).nr,parameters.freq.n_freq)
for j=0l,parameters.freq.n_freq-1l do for k=0,parameters.time.n_step-1 do im(r[k],j)+=float(image(k,j))
xtit='Observer Distance (Parent body radii)'
if (*obj).log eq 1 then spdynps,im,(*obj).rmin,r0,min(U),max(U),xtit,ytit,title,1,0,0,0,1.,/log else $
spdynps,im,(*obj).rmin,max(r0),min(U),max(U),xtit,ytit,title,0,0,0,0,1.
device,/close
if (*obj).pdf then begin
print,'PDF'
cmd='/opt/local/bin/ps2pdf '+nom1+'_f_r.ps '+nom1+'_f_r.pdf'
print,cmd
  spawn,cmd
  spawn,'rm -f '+nom1+'_f_r.ps'
endif
endif

if (*obj).f_lg then begin
device,filename=nom1+'_f_lg.ps',/landscape,bits=8
r0=((*obj).nlg-1.)*(*obj).lgstp+(*obj).lgmin
im=fltarr((*obj).nlg,parameters.freq.n_freq)
for j=0l,parameters.freq.n_freq-1l do for k=0,parameters.time.n_step-1 do im(olg[k],j)+=float(image(k,j))
xtit='Observer Longitude (Degrees)'
if (*obj).log eq 1 then spdynps,im,(*obj).lgmin,r0,min(U),max(U),xtit,ytit,title,1,0,0,0,1.,/log else $
spdynps,im,(*obj).rmin,max(r0),min(U),max(U),xtit,ytit,title,0,0,0,0,1.
device,/close
if (*obj).pdf then begin
print,'PDF'
cmd='/opt/local/bin/ps2pdf '+nom1+'_f_lg.ps '+nom1+'_f_lg.pdf'
print,cmd
  spawn,cmd
  spawn,'rm -f '+nom1+'_f_lg.ps'
endif
endif

if (*obj).f_lat then begin
device,filename=nom1+'_f_lat.ps',/landscape,bits=8
r0=((*obj).nlat-1.)*(*obj).latstp+(*obj).latmin
im=intarr((*obj).nlat,parameters.freq.n_freq)
for j=0l,parameters.freq.n_freq-1l do for k=0,parameters.time.n_step-1 do im(olat[k],j)+=float(image(k,j))
xtit='Observer Latitude (Degrees)'
if (*obj).log eq 1 then spdynps,im,(*obj).latmin,max(r0),min(U),max(U),xtit,ytit,title,1,0,0,0,1.,/log else $
spdynps,im,(*obj).rmin,max(r0),min(U),max(U),xtit,ytit,title,0,0,0,0,1.
device,/close
if (*obj).pdf then begin
print,'PDF'
cmd='/opt/local/bin/ps2pdf '+nom1+'_f_lat.ps '+nom1+'_f_lat.pdf'
print,cmd
  spawn,cmd
  spawn,'rm -f '+nom1+'_f_lat.ps'
endif
endif

if (*obj).f_lt then begin
device,filename=nom1+'_f_lt.ps',/landscape,bits=8
r0=findgen((*obj).nlt)*(*obj).ltstp+(*obj).ltmin
im=intarr((*obj).nlt,parameters.freq.n_freq)
for j=0l,parameters.freq.n_freq-1l do for k=0,parameters.time.n_step-1 do im(olt[k],j)+=float(image(k,j))
xtit='Observer Local Time (Hours)'
if (*obj).log eq 1 then spdynps,image,(*obj).ltmin,max(r0),min(U),max(U),xtit,ytit,title,1,0,0,0,1.,/log else $
spdynps,image,(*obj).rmin,max(r0),min(U),max(U),xtit,ytit,title,0,0,0,0,1.
device,/close
if (*obj).pdf then begin
print,'PDF'
cmd='/opt/local/bin/ps2pdf '+nom1+'_f_lt.ps '+nom1+'_f_lt.pdf'
print,cmd
  spawn,cmd
  spawn,'rm -f '+nom1+'_f_lt.ps'
endif
endif

endfor

if (*obj).lg ne 0 then for i=(*obj).lg,(*obj).lg+n2-1,stp do begin
nom1=nom
nsrc=i-1 & if (*obj).src_pole or (*obj).pol then nsrc=fix(nsrc/2)
ntab=i-1 ;& if (*obj).pol then ntab=fix(ntab/2)
title=parameters.name
if (*obj).pol then nom1=nom1+'_pol'
if (*obj).src_each then begin
 title=title+' source: '+(*parameters.objects[w[nsrc+1]]).name
 nom1=nom1+'_'+(*parameters.objects[w[nsrc+1]]).name
endif
if (*obj).src_pole and ((nsrc mod 2) eq 0) then begin
title=title+' North'
 nom1=nom1+'_North'
endif
if (*obj).src_pole and ((nsrc mod 2) eq 1) then begin
title=title+' South'
 nom1=nom1+'_South'
endif
ytit='Source Longitude (Degrees)
image=fix(transpose(*((*((*obj).out))[ntab]))) & if (*obj).pol then image=image-fix(transpose(*((*((*obj).out))[ntab+1])))

if (*obj).lg_t then begin
device,filename=nom1+'_lg_t.ps',/landscape,bits=8
xtit='Time (min)'
spdynps,image,parameters.time.debut,parameters.time.fin,(*obj).lgmin,(*obj).lgmin+(*obj).nlg*(*obj).lgstp,xtit,ytit,title,0,0,0,0,1.
device,/close
if (*obj).pdf then begin
print,'PDF'
cmd='/opt/local/bin/ps2pdf '+nom1+'_lg_t.ps '+nom1+'_lg_t.pdf'
print,cmd
  spawn,cmd
  spawn,'rm -f '+nom1+'_lg_t.ps'
endif
endif

if (*obj).lg_r then begin
device,filename=nom1+'_lg_r.ps',/landscape,bits=8
r0=((*obj).nr-1)*(*obj).rstp+(*obj).rmin
im=intarr((*obj).nr,(*obj).nlg)
for j=0l,(*obj).nlg-1l do for k=0,parameters.time.n_step-1 do im(r[k],j)+=float(image(k,j))
xtit='Observer Distance (Parent body radii)'
spdynps,im,(*obj).rmin,r0,min(U),max(U),xtit,ytit,title,0,0,0,0,1.
device,/close
if (*obj).pdf then begin
print,'PDF'
cmd='/opt/local/bin/ps2pdf '+nom1+'_lg_r.ps '+nom1+'_lg_r.pdf'
print,cmd
  spawn,cmd
  spawn,'rm -f '+nom1+'_lg_r.ps'
endif
endif

if (*obj).lg_lg then begin
device,filename=nom1+'_lg_lg.ps',/landscape,bits=8
r0=((*obj).nlg-1)*(*obj).lgstp+(*obj).lgmin
im=intarr((*obj).nlg,(*obj).nlg)
for j=0l,(*obj).nlg-1l do for k=0,(*obj).nlg-1 do im(olg[k],j)+=float(image(k,j))
xtit='Observer Longitude (Degrees)'
if (*obj).log eq 1 then spdynps,im,(*obj).rmin,max(r0),min(U),max(U),xtit,ytit,title,1,0,0,0,1.,/log else $
spdynps,im,(*obj).rmin,max(r0),min(U),max(U),xtit,ytit,title,0,0,0,0,1.
device,/close
if (*obj).pdf then begin
print,'PDF'
cmd='/opt/local/bin/ps2pdf '+nom1+'_lg_lg.ps '+nom1+'_lg_lg.pdf'
print,cmd
  spawn,cmd
  spawn,'rm -f '+nom1+'_lg_lg.ps'
endif
endif

if (*obj).lg_lat then begin
device,filename=nom1+'_lg_lat.ps',/landscape,bits=8
r0=((*obj).lat-1)*(*obj).latstp+(*obj).latmin
im=intarr((*obj).nlat,(*obj).nlg)
for j=0l,(*obj).nlg-1l do for k=0,(*obj).nlat-1 do im(olat[k],j)+=float(image(k,j))
xtit='Observer Latitude (Degrees)'
if (*obj).log eq 1 then spdynps,im,(*obj).latmin,max(r0),min(U),max(U),xtit,ytit,title,1,0,0,0,1.,/log else $
spdynps,im,(*obj).rmin,max(r0),min(U),max(U),xtit,ytit,title,0,0,0,0,1.
device,/close
if (*obj).pdf then begin
print,'PDF'
cmd='/opt/local/bin/ps2pdf '+nom1+'_lg_lat.ps '+nom1+'_lg_lat.pdf'
print,cmd
  spawn,cmd
  spawn,'rm -f '+nom1+'_lg_lat.ps'
endif
endif

if (*obj).lg_lt then begin
device,filename=nom1+'_lg_lt.ps',/landscape,bits=8
r0=findgen((*obj).nr)*(*obj).rstp+(*obj).rmin
im=intarr((*obj).nr,(*obj).nlg)
for j=0l,(*obj).nlg-1l do for k=0,(*obj).nlt-1 do im(olg[k],j)+=float(image(k,j))
xtit='Observer Local Time (Hours)'
if (*obj).log eq 1 then spdynps,im,(*obj).rmin,max(r0),min(U),max(U),xtit,ytit,title,1,0,0,0,1.,/log else $
spdynps,im,(*obj).rmin,max(r0),min(U),max(U),xtit,ytit,title,0,0,0,0,1.
device,/close
print,'PDF'
cmd='/opt/local/bin/ps2pdf '+nom1+'_lg_lt.ps '+nom1+'_lg_lt.pdf'
if (*obj).pdf then begin
  spawn,cmd
  spawn,'rm -f '+nom1+'_lg_lt.ps'
endif
endif

endfor


return
end

