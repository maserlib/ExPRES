;***********************************************************
;***                                                     ***
;***         SERPE V6.0                                  ***
;***                                                     ***
;***********************************************************
;***                                                     ***
;***       MODULE: MOVIE2D                               ***
;***                                                     ***
;***     CALLBACK [CB_MOVIE2D]                           ***
;***     FINALIZE [FZ_MOVIE2D]                           ***
;***                                                     ***
;***********************************************************

;************************************************************** FZ_MOVIE2D
pro fz_movie2d,obj,parameters
comd="rm -f "+parameters.out+"_fov.mp4"
spawn,comd
comd="/opt/local/bin/ffmpeg -f image2 -an -i "+parameters.out
comd=comd+"_fov%03d.png -vcodec h264 -pix_fmt yuv420p -crf 22 "+parameters.out+"_fov.mp4"
spawn,comd
comd="rm "+parameters.out+"_fov*.png"
spawn,comd
comd="chmod 777 "+parameters.out+"_fov.mp4"
spawn,comd
end


;************************************************************** CB_MOVIE2D
pro cb_movie2d,obj,parameters
if parameters.time.istep mod (*obj).sub ne 0 then return
frame=fix(parameters.time.istep/(*obj).sub)
time_cur=parameters.time.istep
nobj=n_elements(parameters.objects)




bkg=fltarr(110,480)
fmax=parameters.freq.fmax
fmin=parameters.freq.fmin
bbkg=fltarr(32,130)+255b
h=rebin(reform(findgen(64),1,64),30,128)

set_plot,'Z'
device,/close
device,set_resol=[10,10]
;tv=fltarr(10,10)
!p.font=0
xyouts,0,0,'N',/DEVICE
N = TVRD(CHANNEL=0)
device,/close

set_plot,'Z'
device,set_resol=[10,10]
tv=fltarr(10,10)
!p.font=0
xyouts,0,0,'S',/DEVICE
S = TVRD(CHANNEL=0)
device,/close

set_plot,'Z'
device,set_resol=[30,10]
tv=fltarr(30,10)
!p.font=0
xyouts,0,0,'MHz',/DEVICE
Mhz = TVRD(CHANNEL=0)
device,/close

set_plot,'Z'
device,set_resol=[30,10]
tv=fltarr(30,10)
!p.font=0
xyouts,0,0,strcompress(string(fmax,format='(I3)'),/remove_all),/DEVICE
tmax = TVRD(CHANNEL=0)
device,/close

set_plot,'Z'
device,set_resol=[30,10]
tv=fltarr(30,10)
!p.font=0
xyouts,0,0,strcompress(string(fmin,format='(I3)'),/remove_all),/DEVICE
tmin = TVRD(CHANNEL=0)
device,/close

nrth=fltarr(40,150)
nrth(15:24,5:14)=N
nrth(4:35,20:149)=bbkg
nrth(5:34,21:148)=h+190b

srth=fltarr(40,150)
srth(15:24,5:14)=S
srth(4:35,20:149)=bbkg
srth(5:34,21:148)=94b-h

bkg(0:39,100:249)=nrth
bkg(40:79,100:249)=srth
bkg(80:109,240:249)=tmax
bkg(80:109,120:129)=tmin
bkg(80:109,180:189)=mhz

;stop

set_plot,'Z'
device,set_resol=[640,480]
!p.font=0
plot,[0,1],[0,1],xr=(*obj).xr,yr=(*obj).yr,ys=1,xs=1,title="Observer's Field of View", xtitle='degrees',ytitle='degrees',/NODATA,/iso



for i=0,nobj-1 do if TAG_NAMES(*(parameters.objects[i]),/str) eq 'OBSERVER' then begin
pos_obs=(*((*(parameters.objects[i])).trajectory_xyz))[*,time_cur]
dist_obs=sqrt(total(pos_obs^2))
th01=atan(pos_obs[1],pos_obs[0])
th02=atan(pos_obs[2],sqrt(pos_obs[0]^2+pos_obs[1]^2))
endif;OBSERVER



for i=0,nobj-1 do if TAG_NAMES(*(parameters.objects[i]),/str) eq 'BODY' then begin
ob2=(parameters.objects[i])
rad=(*ob2).radius
if (*ob2).motion eq 1b then rad=0.1*rad
;stop
pos_body=(*((*ob2).trajectory_xyz))[*,time_cur]
;stop
pos_bod=fltarr(3)
dist=sqrt(total((pos_body-pos_obs)^2))
;dessin de l'astre
th1=atan(pos_body[1],pos_body[0])-th01
r1=sqrt(pos_body[0]^2+pos_body[1]^2)
pos_bod[0]=r1*cos(th1)
pos_bod[1]=r1*sin(th1)
th2=atan(pos_body[2],pos_bod[0])-th02
r2=sqrt(pos_bod[0]^2+pos_body[2]^2)
pos_bod[0]=r2*cos(th2)
pos_bod[2]=r2*sin(th2)

xy_pos=asin(pos_bod[1])*!radeg
z_pos=asin(pos_bod[2]/dist)*!radeg
rad_ang=atan(total(rad/dist))*!radeg
ang=findgen(361)*!dtor
if (*ob2).motion ne 1b then oplot,xy_pos+rad_ang*cos(ang),z_pos+rad_ang*sin(ang)
;stop

for l=-2,2 do begin
p=findgen(3601)*0.1*!dtor
vec=rebin(pos_body,3,3601)+rad*transpose([[sin((l*30.+90)*!dtor)*cos(p)],[sin((l*30.+90)*!dtor)*sin(p)],[cos((l*30.+90)*!dtor)+p*0.]])
dv=sqrt(total((vec-rebin(pos_obs,3,3601))^2,1))

th1=atan(vec[1,*],vec[0,*])-rebin([th01],3601)
r1=sqrt(vec[0,*]^2+vec[1,*]^2)
vec[0,*]=r1*cos(th1)
vec[1,*]=r1*sin(th1)
th2=atan(vec[2,*],vec[0,*])-rebin([th02],3601)
r2=sqrt(vec[0,*]^2+vec[2,*]^2)
vec[0,*]=r2*cos(th2)
vec[2,*]=r2*sin(th2)
w=where(vec[0,*] gt 0.)
;stop
if w[0] ne -1 then begin
vec=vec[*,w]
dv=dv[w]
s=sort(vec[1,*])
xy_pos=asin(vec[1,*]/dv)*!radeg
z_pos=asin(vec[2,*]/dv)*!radeg
if l eq 0 then oplot,xy_pos(s),z_pos(s),color=128 else oplot,xy_pos(s),z_pos(s)
;stop
endif
endfor

lg=(*ob2).lg0+360.*parameters.time.time/(*ob2).period;-th01*!radeg
;if time_cur eq 260 then  stop

for l=0,11 do begin
t=findgen(1800)*0.1*!dtor
vec=rebin(pos_body,3,1800)+rad*transpose([[sin(t)*cos((l*30.+lg)*!dtor)],[sin(t)*sin((l*30.+lg)*!dtor)],[cos(t)]])
dv=sqrt(total((vec-rebin(pos_obs,3,1800))^2,1))

th1=atan(vec[1,*],vec[0,*])-rebin([th01],1800)
r1=sqrt(vec[0,*]^2+vec[1,*]^2)
vec[0,*]=r1*cos(th1)
vec[1,*]=r1*sin(th1)
th2=atan(vec[2,*],vec[0,*])-rebin([th02],1800)
r2=sqrt(vec[0,*]^2+vec[2,*]^2)
vec[0,*]=r2*cos(th2)
vec[2,*]=r2*sin(th2)
w=where(vec[0,*] gt 0.)
;stop
if w[0] ne -1 then begin
vec=vec[*,w]
dv=dv[w]
s=sort(vec[2,*])
xy_pos=asin(vec[1,*]/dv)*!radeg
z_pos=asin(vec[2,*]/dv)*!radeg
if l eq 0 then oplot,xy_pos(s),z_pos(s),color=128 else oplot,xy_pos(s),z_pos(s)
;stop
endif
endfor

;stop
endif;BODY


for i=0,nobj-1 do if TAG_NAMES(*(parameters.objects[i]),/str) eq 'SOURCE' then begin
ob2=(parameters.objects[i])
;stop
;on dessine la trajectoire
w=where((*((*ob2).spdyn)) ne 0)
if w[0] ne -1 then begin
x=reform((*((*ob2).x)),3,1.*parameters.freq.n_freq*((*ob2).nsrc)*2.)
col=rebin(reform(findgen(parameters.freq.n_freq)/float(parameters.freq.n_freq)*64.,parameters.freq.n_freq,1,1),parameters.freq.n_freq,((*ob2).nsrc),2)
col=col*rebin(reform([1,-1],1,1,2),parameters.freq.n_freq,((*ob2).nsrc),2)
col=col+rebin(reform([190,94],1,1,2),parameters.freq.n_freq,((*ob2).nsrc),2)
integ=findgen(parameters.freq.n_freq)/float(parameters.freq.n_freq)*(parameters.freq.fmax-parameters.freq.fmin)+parameters.freq.fmin
integ=fix(integ*0.1) & integ=1-(integ-(shift(integ,1))<1) & integ[0]=1
;col=rebin(integ,parameters.freq.n_freq,((*ob2).nsrc),2)*col
col=reform(col,1.*parameters.freq.n_freq*((*ob2).nsrc)*2.)
;www=where(col eq 0)&if www[0] ne -1 then col[www]=255
xyz=x[*,w] & nx=n_elements(w) & col=col[w]

vec=fltarr(3,nx)
for j=0, nx-1 do vec[*,j]=(transpose((*((*ob2).parent)).rot)#(xyz[*,j])+(*((*ob2).parent)).pos_xyz)
dv=sqrt(total((vec-rebin(pos_obs,3,nx))^2,1))
th1=atan(vec[1,*],vec[0,*])-rebin([th01],nx)
r1=sqrt(vec[0,*]^2+vec[1,*]^2)
vec[0,*]=r1*cos(th1)
vec[1,*]=r1*sin(th1)
th2=atan(vec[2,*],vec[0,*])-rebin([th02],nx)
r2=sqrt(vec[0,*]^2+vec[2,*]^2)
vec[0,*]=r2*cos(th2)
vec[2,*]=r2*sin(th2)
xy_pos=asin(vec[1,*]/dv)*!radeg
z_pos=asin(vec[2,*]/dv)*!radeg
for pi=0, nx-1 do oplot,[xy_pos[pi]],[z_pos[pi]],psym=1,color=col[pi]
;for i=0, nx-1 do if col[i] eq 255 then oplot,[xy_pos[i]],[z_pos[i]],psym=1,color=col[i]
;stop

endif
endif;SOURCE


; Display the image data using Direct Graphics:
im=TVRD(Channel=0)
imag=fltarr(660,480)
imag[0:639,*]=im
imag[550:659,*]=bkg
wn=where(imag eq 0b)
wb=where(imag eq 255b)
if wn[0] ne -1 then imag[wn]=255b
if wb[0] ne -1 then imag[wb]=0b

;stop
device,/close
;stop
set_plot,'ps'
loadct,39
TVLCT, R, G, B, /GET
rgbdata =fltarr(3,660,480)  
for i=0,659 do for j=0,479 do begin
 rgbdata[0,i,j]=r[imag[i,j]]
 rgbdata[1,i,j]=g[imag[i,j]]
 rgbdata[2,i,j]=b[imag[i,j]]
; rgbdata[0,i,j]=255
endfor

nom=parameters.out+'_fov'
if frame lt 100 then nom=nom+'0'
if frame lt 10 then nom=nom+'0'
nom=nom+strtrim(string(frame),2)+'.png'
;nom=parameters.out+'_fov'+strtrim(string(frame),2)+'.png'
;help,rgbdata
write_png,nom,rgbdata
;write_png,nom,imag,r,g,b
;nom=parameters.out+parameters.name+strtrim(string(frame),2)+'.sv'
;save,imag,filename=nom
loadct,0
;stop
return
end



