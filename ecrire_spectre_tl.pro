; ***********************************
; *                                 *
; *   Routines de simulation JUNO   *
; *                                 *
; ***********************************
; L. Lamy (02/2007)

; ------------------------------------------------------------------------------------
  pro ECRIRE_SPECTRE_TL, s, t, f, titre, path
; ------------------------------------------------------------------------------------

fm=f*1e3
f1=min(fm) & f2=max(fm) 
t1=min(t) & t2=max(t)
sm=s(sort(t),*)
nf=n_elements(f)
nt=n_elements(t)

; Si echelle lineaire en frequence:
;U=findgen(nf)/(nf-1.)*1200. 

; Si echelle log en frequence:
U=10^(alog10(f1)+(findgen(nf)/(nf-1L)*(alog10(f2)-alog10(f1))))
image=fltarr(nt,nf)
for i=0,nt-1 do image(i,*)=interpol(sm(i,*),fm,U)

set_plot,'ps'
device,filename=path+'spectre.ps',/landscape,bits=8;,/ENCAP,/COLOR
!p.font=1
!p.multi=[0,1,1]
spdynps,image,t1,t2,min(U),max(U),'Local Time (H)','f (kHz)',titre,1,0,0,0,1,/log
device,/close
set_plot,'x' 

return
end

; ------------------------------------------------------------------------------------
  pro ECRIRE_SPECTRE_TL2, s1,s2, t, f, titre1,titre2, path
; ------------------------------------------------------------------------------------

fm=f*1e3
f1=min(fm) & f2=max(fm) 
t1=min(t) & t2=max(t)
sm1=s1(sort(t),*)
sm2=s2(sort(t),*)
nf=n_elements(f)
nt=n_elements(t)

; Si echelle lineaire en frequence:
;U=findgen(nf)/(nf-1.)*1200. 

; Si echelle log en frequence:
U=10^(alog10(f1)+(findgen(nf)/(nf-1L)*(alog10(f2)-alog10(f1))))

image1=fltarr(nt,nf)
for i=0,nt-1 do image1(i,*)=interpol(sm1(i,*),fm,U)
image2=fltarr(nt,nf)
for i=0,nt-1 do image2(i,*)=interpol(sm2(i,*),fm,U)

set_plot,'ps'
device,filename=path+'spectre.ps',/landscape,bits=8,/ENCAP,/COLOR
!p.font=1
!p.multi=[0,1,2]
spdynps,image1,t1,t2,min(U),max(U),'Local Time (H)','f (kHz)',titre1,1,0,0,0,0.98,/log
spdynps,image2,t1,t2,min(U),max(U),'Local Time (H)','f (kHz)',titre2,1,0,0,0,0.98,/log
device,/close
set_plot,'x' 

return
end

; ------------------------------------------------------------------------------------
  pro ECRIRE_SPECTRE_TL4, s1,s2,s3,s4, t, f, titre1,titre2,titre3,titre4, path
; ------------------------------------------------------------------------------------

fm=f*1e3
f1=min(fm) & f2=max(fm) 
t1=min(t) & t2=max(t)
sm1=s1(sort(t),*)
sm2=s2(sort(t),*)
sm3=s3(sort(t),*)
sm4=s4(sort(t),*)
nf=n_elements(f)
nt=n_elements(t)

; Si echelle lineaire en frequence:
;U=findgen(nf)/(nf-1.)*1200. 

; Si echelle log en frequence:
U=10^(alog10(f1)+(findgen(nf)/(nf-1L)*(alog10(f2)-alog10(f1))))

image1=fltarr(nt,nf)
for i=0,nt-1 do image1(i,*)=interpol(sm1(i,*),fm,U)
image2=fltarr(nt,nf)
for i=0,nt-1 do image2(i,*)=interpol(sm2(i,*),fm,U)
image3=fltarr(nt,nf)
for i=0,nt-1 do image3(i,*)=interpol(sm3(i,*),fm,U)
image4=fltarr(nt,nf)
for i=0,nt-1 do image4(i,*)=interpol(sm4(i,*),fm,U)

set_plot,'ps'
device,filename=path+'spectre.ps',/landscape,bits=8,/ENCAP,/COLOR
!p.font=1
!p.multi=[0,1,4]
spdynps,image1,t1,t2,min(U),max(U),'Local Time (H)','f (kHz)',titre1,1,0,0,0,0.98,/log
spdynps,image2,t1,t2,min(U),max(U),'Local Time (H)','f (kHz)',titre2,1,0,0,0,0.98,/log
spdynps,image3,t1,t2,min(U),max(U),'Local Time (H)','f (kHz)',titre3,1,0,0,0,0.98,/log
spdynps,image4,t1,t2,min(U),max(U),'Local Time (H)','f (kHz)',titre4,1,0,0,0,0.98,/log
device,/close
set_plot,'x' 

return
end