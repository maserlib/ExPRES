; ***********************************
; *                                 *
; *   Routines de simulation JUNO   *
; *                                 *
; ***********************************
; S. Hess (9/2006), P. Zarka (10/2006), B. Cecconi (10/2006), L. Lamy (02/2007)


; ------------------------------------------------------------------------------------
  pro ECRIRE_SPECTRE, spdyn, debt, dureet, y, path
; ------------------------------------------------------------------------------------
 stop
 sz = size(spdyn)
  if sz(3) eq 1 then ds=transpose(reform(-spdyn)) else ds=transpose(total(-spdyn, 3))
  x=findgen(n_elements(ds(*,0)))/float(n_elements(ds(*,0)))*dureet+debt
  fmin=min(y)
  fmax=max(y)
  set_plot,'PS'
  DEVICE, file=path+'spectre.ps', /ENCAP,/COLOR,bits=8,/PORTRAIT,YOFFSET=2.,YSIZE=25.7                                                            
  CONTOUR, ds, x, y, title='spectre dynamique', xtitle='temp en minutes', $
	ytitle='f (MHz)', /NODATA, xra=[debt,debt+dureet], yra=[fmin,fmax*2.], $
	xsty=1, ysty=1, /ylog
  TVSCL, ds, !X.WINDOW(0), !Y.WINDOW(0), XSIZE = !X.WINDOW(1) - !X.WINDOW(0), $
	YSIZE = !Y.WINDOW(1) - !Y.WINDOW(0), /NORM
;  CONTOUR, ds, x, y, title='spectre dynamique', xtitle='temps en minutes', $
;	ytitle='f (MHz)', /NOERASE, /NODATA, xra=[debt,debt+dureet], $
;	yra=[fmin,fmax], xsty=1, ysty=1
  device,/close  
  set_plot,'X'

return
end

