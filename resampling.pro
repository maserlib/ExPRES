; ************************************
; *                                  *
; *   Routines de simulation SERPE   *
; *                                  *
; ************************************

; ------------------------------------------------------------------------------
PRO RESAMPLING,xyz,t,h
; ------------------------------------------------------------------------------

; h=N   = oversampling
; h=1/N = undersampling

h=float(h)
dt=1.d0/1440.d0
nt=(max(t)-min(t))/dt
t2=findgen(round(nt*h))*dt/h+t(0)

tmp=fltarr(3,round(nt*h))
for i=0,2l do tmp(i,*)=interpol(xyz(i,*),t,t2)
xyz = tmp
t=t2

end

