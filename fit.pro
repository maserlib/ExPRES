;***********************************************************
;***                                                     ***
;***         SERPE V6.0                                  ***
;***                                                     ***
;***********************************************************
;***                                                     ***
;***       MODULE: FIT                                   ***
;***                                                     ***
;***     INIT   [INIT_FIT]                               ***
;***     CALLBACK [CB_FIT]                               ***
;***     FINALIZE [FZ_FIT]                               ***
;***                                                     ***
;***********************************************************


;************************************************************** INIT_FIT
pro init_fit,obj,parameters
;************************************************************** 
;  init_fit se substitue a SERPE_MAIN
;************************************************************** 
restore,(*obj).file_img
sortie=dilate(sortie,fltarr(7,7)+1)
(*((*obj).img))=sortie
nobj=n_elements(parameters.objects)
iobj=0
for i=0,nobj-1 do if parameters.objects[i] eq obj then iobj=i
for i=0,nobj-1 do if TAG_NAMES(*(parameters.objects[i]),/str) eq 'SOURCE' then src=parameters.objects[i]
(*obj).found=0b

for rerun=0,(*obj).max_rerun do begin
if rerun eq (*obj).max_rerun and (*obj).found ne 3b then (*obj).found=4b

if rerun eq 0 then begin
;pour deux v donnes on cherche la meilleure longitude ou latitude
; ca permet de definir vtolg ou vtolat
(*src).vmin=(*obj).vmin
(*src).vmax=(*obj).vmax
(*src).vstep=(*obj).vmax-(*obj).vmin
(*src).lgmin=(*obj).lgmin
(*src).lgmax=(*obj).lgmax
(*src).lgstep=((*obj).lgmax-(*obj).lgmin)/79.
endif else if (*obj).found eq 2b then begin
;si on converge en basse resolution on passe en haute resolution
(*src).vmin=(*obj).vmin-0.015-0.5*(*src).lgtov
(*src).vmax=(*obj).vmin+0.015-0.5*(*src).lgtov
(*src).vstep=0.001
(*src).lgmin=(*obj).lgmin-0.5
(*src).lgmax=(*obj).lgmin+0.5
(*src).lgstep=0.05

endif else if (*obj).found ge 3b then begin
;Quand on a trouve le resultat (ou quand on a atteint max_rerun)
(*src).vmin=(*obj).vmin
(*src).vmax=(*obj).vmin
(*src).vstep=0.003
(*src).lgmin=(*obj).lgmin
(*src).lgmax=(*obj).lgmin
(*src).lgstep=0.4
endif else begin
;on recherche le meilleur fit en basse resolution
;la meilleure solution est stokee dans lgmin et vmin
(*src).vmin=(*obj).vmin-0.03-5.*(*src).lgtov
(*src).vmax=(*obj).vmin+0.03-5.*(*src).lgtov
(*src).vstep=0.003
(*src).lgmin=(*obj).lgmin-5.
(*src).lgmax=(*obj).lgmin+5.
(*src).lgstep=0.4

endelse
;stop
for i=0,iobj-1 do  begin
    it=(*(parameters.objects[i])).it
    if it[0] ne '' then for j=0,n_elements(it)-1 do CALL_PROCEDURE,it[j],parameters.objects[i],parameters
endfor
if (*obj).found ge 3b then return

for t=0,parameters.time.n_step-1 do begin
parameters.time.time=float(t)*parameters.time.step+parameters.time.t0
parameters.time.istep=t
print,'time',parameters.time.time
    for i=0,iobj do begin
       cb=(*(parameters.objects[i])).cb
       if cb[0] ne '' then for j=0,n_elements(cb)-1 do CALL_PROCEDURE,cb[j],parameters.objects[i],parameters
    endfor
endfor

fz_fit,obj,parameters

endfor

return
end

;************************************************************** CB_FIT
pro cb_fit,obj,parameters
nobj=n_elements(parameters.objects)
for i=0,nobj-1 do if TAG_NAMES(*(parameters.objects[i]),/str) eq 'SOURCE' then src=parameters.objects[i]
t=parameters.time.istep
nf=parameters.freq.n_freq
nv=FIX(((*src).vmax-(*src).vmin)/(*src).vstep)+1
nlg=FIX(((*src).lgmax-(*src).lgmin)/(*src).lgstep)+1
nlat=FIX(((*src).latmax-(*src).latmin)/(*src).latstep)+1
if parameters.time.istep eq 0 then (*((*obj).tab))=fltarr(3,nv,nlg)
img=rebin(reform((*((*obj).img))[t,*],nf),nf,nv,nlg,nlat)
(*((*obj).tab))[0,*,*]=(*((*obj).tab))[0,*,*]+totale(totale(img,4),1)
(*((*obj).tab))[1,*,*]=(*((*obj).tab))[1,*,*]+totale(totale(totale(reform((*((*src).spdyn)),nf,nv,nlg,nlat,2),5),4),1)*FIX(totale(totale(img,4),1)<1)
(*((*obj).tab))[2,*,*]=(*((*obj).tab))[2,*,*]+totale(totale(totale(reform((*((*src).spdyn)),nf,nv,nlg,nlat,2),5)*img,4),1)
w=where( totale(totale(totale(reform((*((*src).spdyn)),nf,nv,nlg,nlat,2),5),4),1) gt nf)
if w[0] ne -1 then stop
if (*obj).found ge 3b then begin
(*((*src).spdyn))[*,0,0]=(*((*src).spdyn))[*,0,0]+img
endif
return
end

;************************************************************** FZ_FIT
pro fz_fit,obj,parameters
nobj=n_elements(parameters.objects)
for i=0,nobj-1 do if TAG_NAMES(*(parameters.objects[i]),/str) eq 'SOURCE' then src=parameters.objects[i]
nf=parameters.freq.n_freq
nv=FIX(((*src).vmax-(*src).vmin)/(*src).vstep)+1
nlg=FIX(((*src).lgmax-(*src).lgmin)/(*src).lgstep)+1
nlat=FIX(((*src).latmax-(*src).latmin)/(*src).latstep)+1

n=float(nf)*float(parameters.time.n_step)
n0=(*((*obj).tab))[0,*,*]/n
n1=(*((*obj).tab))[1,*,*]/n
w=where(n1 gt 1)
if w[0] ne -1 then stop
sigxy=(*((*obj).tab))[2,*,*]-(*((*obj).tab))[1,*,*]*n0-(*((*obj).tab))[0,*,*]*n1+n0*n1*n
sigx=sqrt((*((*obj).tab))[0,*,*]*(1.-2.*n0)+n0^2*n)
sigy=sqrt((*((*obj).tab))[1,*,*]*(1.-2.*n1)+n1^2*n)
coef_cor=sigxy/(sigx*sigy)
w=where(n1 eq 0.)
if w[0] ne -1 then coef_cor[w]=0.
coef_cor=reform(coef_cor,nv,nlg)

w=(where(Coef_cor eq max(coef_cor)))[0]
(*src).width=(*src).width*n0[w]/n1[w]
lg=fix(w/nv)
v=fix(w-lg*nv)
xlg=fix(4.*lg/nlg)
xv=fix(4.*v/nv)
(*obj).lgmin=lg*(*src).lgstep+(*src).lgmin
(*obj).vmin=v*(*src).vstep+(*src).vmin+(*src).lgtov*((*obj).lgmin-(*src).lgmin);vitesse reellement fittee

if (*obj).found eq 0b then begin
w0=(where(coef_cor[0,*] eq max(coef_cor[0,*])))[0]
w1=(where(coef_cor[1,*] eq max(coef_cor[1,*])))[0]
(*src).lgtov=((*src).vmax-(*src).vmin)/((w1*(*src).lgstep+(*src).lgmin)-(w0*(*src).lgstep+(*src).lgmin))
endif

if ( ((xv eq 1) or (xv eq 2)) and ((xlg eq 1) or (xlg eq 2)) ) then (*obj).found=(*obj).found+1b
if ( (xv eq 0) and ((xlg eq 1) or (xlg eq 2)) and (*src).vmin eq 0) then (*obj).found=(*obj).found+1b
if (*obj).found eq 0b then (*obj).found=1b

if (*obj).found ge 3b then begin
openw,unit,(*obj).file_res,/get_lun
printf,unit,'Simulation name'
printf,unit,parameters.name
if (*obj).found eq 3b then printf,unit,'Good fit' else printf,unit,'Bad fit'
printf,unit,'Correlation coefficient'
printf,unit,coef_cor[w]
printf,unit,'Velocity'
printf,unit,(*obj).vmin
printf,unit,'Longitude'
printf,unit,(*obj).lgmin
printf,unit,'Width"
printf,unit,(*src).width
close,unit & free_lun,unit
endif
return
end
