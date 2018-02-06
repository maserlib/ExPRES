;+
; Contains the spdynps procedure 
; and supporting procedures
;
; :Author:
;    Philippe Zarka
;
; :History:
;    2009/04/30: Created
;
;    2015/10/30: Last Edit LL
;-
;

;+
; Background and sigma of a 1-D distribution of intensities.
;-
  pro FOND, tab, fon,sigma
; tab =  (INPUT)  1-D array of intensities
; fon,sigma =  (OUTPUT)  background and fluctuations (1 sigma level)

  if n_elements(tab) gt 1 then sigma=10.*stdev(tab,fon) else begin $
        fon=tab(0) & sigma=0
  endelse
encore:
  test=where(abs(tab-fon) lt 2.5*sigma)
  if n_elements(test) eq 1 then return
  sigma=stdev(tab(test),moy)
  if moy eq fon then return
  fon=moy
  goto,encore
end

;+
; Calculation of Background and Sigma arrays of a 2-D distribution of 
; intensities, frequency by frequency. ONLY values >min(tab) are used.
; A save set can be put in 'fichier'.
;-
  pro FAIT_FOND, tab,fichier, f,s
; tab =  (INPUT)  2-D array of intensities, function of (time,freq)
; fichier =  (INPUT)  name of save_set containing f & s
; f,s =  (OUTPUT)  arrays of background and fluctuations (1 sigma level)

  nf=n_elements(tab(0,*))
  f=fltarr(nf) & s=fltarr(nf)
  mintab=min(tab)
  for i=0,nf-1 do begin
;   if (i mod 50) eq 0 then print,i
    test=where(tab(*,i) gt mintab)
    if test(0) ne -1 then begin
	FOND,tab(test,i),ff,ss
	f(i)=ff & s(i)=ss
    endif
  endfor
  if fichier ne '' then save,f,s,filename=fichier
  return
end

;+
; Substraction of (background + seuil * sigmas) from a 2-D array of raw 
; data, and setting of resulting negative values to 0.
;-
pro RETIRE_FOND, f,s,seuil, tab
; f,s =  (INPUT)  arrays of background and fluctuations (1 sigma level)
; seuil =  (INPUT)  threshold value for the number of sigmas above background
; tab =  (INPUT/OUTPUT)  2-D array of raw data (time,freq) -> tab-(f+seuil*s)

  for i=0,n_elements(tab(*,0))-1 do tab(i,*)=(tab(i,*)-f-seuil*s) >0
return
end

;+
; PostScript plot of dynamic spectrum.
;
; :Uses:
;    dyn, fond
;
; :Params:
;    image:     in, required, type=sometype
;       dynamic spectrum
;    xmin:      in, optional, type=sometype
;       range x coordinate
;    xmax:      in, optional, type=sometype
;       range x coordinate
;    ymin:      in, optional, type=sometype
;       range y coordinate
;    ymax:      in, optional, type=sometype
;       range y coordinate
;    legende_x: in, optional, type=sometype
;       x axis caption
;    legende_y: in, optional, type=sometype
;       y axis caption
;    titre:     in, optional, type=sometype
;       title of plot
;    grid:      in, optional, type=sometype
;       =1 to superimpose a grid to the plot, =0 otherwise
;    fond:      in, optional, type=sometype
;       =1 to substract a background to the data before plotting, =0 otherwise
;    seuil:     in, optional, type=sometype
;       number of sigmas -in addition to fond- to substract from data
;    fracmin:   in, optional, type=sometype
;       min threshold for optimization of the dynamic range of the plot
;    fracmax:   in, optional, type=sometype
;       max threshold for optimization of the dynamic range of the plot
;    color:     in, optional, type=sometype
;       grey scale of plot: =0 -> black=intense, =1 -> white=intense
;    bar_titre: in, optional, type=sometype
;       title of dynamic bar (unit = dB, except if '.')
;
; :Keywords:
;    log:       in, optional, type=sometype
;       A keyword named log
;    posxmin:   in, optional, type=sometype
;       A keyword named posxmin
;    posymin:   in, optional, type=float
;       A keyword named posymin
;    posxmax:   in, optional, type=float
;       A keyword named posxmax
;    posymax:   in, optional, type=float
;       A keyword named posymax
;    xy:  in, optional, type=array of dimension 2xn
;       A keyword named oplot_xy
;    xz:  in, optional, type=array of dimension 2xm
;       A keyword named oplot_xz
;-
pro SPDYNPS, image,xmin,xmax,ymin,ymax,legende_x,legende_y,titre, $
	     grid,fond,seuil,fracmin,fracmax,color,bar_titre,log=log, $
	     posxmin=posxmin,posymin=posymin,posxmax=posxmax,posymax=posymax, $
	     col_scale=col_scale,xy=xy,xz=xz,no_abscissa=no_abscissa

; Default values = 0,n_spectra,0,n_frequencies,' ',' ',' ',0,0,0,.05,.95,0,' '
  if n_elements(xmin) eq 0 or n_elements(xmax) eq 0 then begin
	xmin=0 & xmax=n_elements(image(*,0))
  endif
  if n_elements(ymin) eq 0 or n_elements(ymax) eq 0 then begin
	ymin=0 & ymax=n_elements(image(0,*))
  endif
  if n_elements(legende_x) eq 0 then legende_x=' '
  if n_elements(legende_y) eq 0 then legende_y=' '
  if n_elements(titre) eq 0 then titre=' '
  if n_elements(grid) eq 0 then grid=0
  if n_elements(fond) eq 0 then fond=0
  if n_elements(seuil) eq 0 then seuil=0
  if n_elements(fracmin) eq 0 or n_elements(fracmax) eq 0 then begin
	fracmin=0.05 & fracmax=0.95
  endif
  if n_elements(color) eq 0 then color=0
  if n_elements(bar_titre) eq 0 then bar_titre=' '

  tab=image

; Fond

  if fond eq 1 then begin
    FAIT_FOND, tab,'', f,s
    RETIRE_FOND, f,s,seuil, tab
  endif

; Dynamic range

  if (fracmin ne 0. and fracmin ne -1) or (fracmax ne 1.) then begin
    DYN, tab,fracmin,fracmax, tabmin,tabmax
    if tabmax eq -1 then RETURN
  endif else begin
    if fracmin eq -1 then test=where(tab ge min(tab)) else test=where(tab gt min(tab))
    tabmin=min(tab(test)) & tabmax=max(tab(test))
  endelse
  tab=bytscl(tab,min=tabmin,max=tabmax)

  if color eq 0 then tab=255-tab	; 0->noir=intense, 1->blanc=intense

  print,'Writing in Postscript file ...'

  tl=-0.015
  if grid eq 1 then tl=1.0

  nx=!p.multi(1) & ny=!p.multi(2)
  if nx eq 0 then nx=1
  if ny eq 0 then ny=1
  x=!p.multi(0)
  if x ne 0 then x=nx*ny-x
  i=x mod nx
  j=ny-(x-i)/nx-1
  dx=(0.9-0.1*nx)/nx		& dy=(0.9-0.1*ny)/ny
  
  if ~keyword_set(posxmin) then posxmin=0.08+i*(0.12+dx)	
  if ~keyword_set(posymin) then posymin=0.14+j*(0.1+dy)
  if ~keyword_set(posxmax) then posxmax=posxmin+dx		
  if ~keyword_set(posymax) then posymax=posymin+dy

  cm=1. & if nx ge 3 or ny ge 3 then cm=1.5
  if keyword_set(log) then $
  plot_io, [xmin,xmax], [ymin,ymax], /nodata, xra=[xmin,xmax], xstyle=13, $
      yra=[ymin,ymax], ystyle=13, title=titre, ticklen=tl, charsize=1.1*cm, $
      pos = [posxmin,posymin,posxmax,posymax] else $
  plot, [xmin,xmax], [ymin,ymax], /nodata, xra=[xmin,xmax], xstyle=13, $
      yra=[ymin,ymax], ystyle=13, title=titre, ticklen=tl, charsize=1.1*cm, $
      pos = [posxmin,posymin,posxmax,posymax]
  if keyword_set(col_scale) then loadct,col_scale
  tv, tab, !x.window(0), !y.window(0), xsize=!x.window(1)-!x.window(0), $
    ysize=!y.window(1)-!y.window(0),/normal
  if keyword_set(col_scale) then loadct,0
  if keyword_set(no_abscissa) then begin
    axis, xaxis=0, xra=[xmin,xmax], xstyle=1, xticklen=tl, $
    xtickname=replicate(' ',9)
  endif else $
  axis, xaxis=0, xra=[xmin,xmax], xstyle=1, xticklen=tl, $
    xtitle=legende_x, charsize = 1.*cm
  axis, xaxis=1, xra=[xmin,xmax], xstyle=1, xticklen=tl, $
    xtickname=replicate(' ',9)
  axis, yaxis=0, yra=[ymin,ymax], ystyle=1, yticklen=tl, $
    ytitle=legende_y, charsize = 1.*cm
  axis, yaxis=1, yra=[ymin,ymax], ystyle=1, yticklen=tl, $
    ytickname=replicate(' ',9)
  if keyword_set(xy) then oplot,xy(0,*),xy(1,*),thick=3,col=255
  if keyword_set(xz) then oplot,xz(0,*),xz(1,*),thick=3,col=0
  
  posxmin2=posxmax+0.03*dx/0.8	& posymin2=posymin+0.05*dy/0.8
  posxmax2=posxmin2+0.03*dx/0.8	& posymax2=posymax-0.05*dy/0.8

  bar_tick = [' ','dB',' ']
  if bar_titre eq '.' then begin
    bar_titre=' ' & bar_tick = [' ',' ',' ']
  endif
  if bar_titre ne '.' and bar_titre ne ' ' then begin
    bar_tick = [' ',bar_titre,' '] & bar_titre=' '
  endif

  plot, [0,1], [0,1], /nodata, /noerase, xst=1, yst=12, $
    pos = [posxmin2,posymin2,posxmax2,posymax2], $
    /norm, xticklen=0, xticks=2, xtickv=[0,0.5,1], $
    xtickname=bar_tick, xtitle=bar_titre, charsize=1.1*cm
  axis, /yaxis, yra=[tabmin,tabmax], ticklen=-0.2, /ysty, charsize=1.*cm

;  dynamique=alog10(tabmax-tabmin)
;  if dynamique ge 0. then dynamique=fix(dynamique)
;  if dynamique lt 0. then dynamique=fix(dynamique)-1
;  dynamique=10.^dynamique
;  ndyn = fix((tabmax-tabmin)/dynamique)
;  axis, /yaxis, yra=[tabmin,tabmax], ticklen=-0.02, /ysty, yticks=ndyn-1, $
;	ytickv=tabmin+dynamique-(tabmin mod dynamique)+indgen(ndyn)*dynamique, $
;	yminor=-1

  bcb = bytscl(replicate(1,10)#bindgen(256))
  if color eq 0 then bcb=255-bcb
  if keyword_set(col_scale) then loadct,col_scale
  tv, bcb, !x.window(0), !y.window(0), xsize = !x.window(1) - !x.window(0), $
    ysize = !y.window(1) - !y.window(0), /normal
  if keyword_set(col_scale) then loadct,0
  oplot, [1,0,0,1], [1,1,0,0]

RETURN
END


;--------------------------------------------------------------------
  pro HELP_SPDYNPS
;--------------------------------------------------------------------
  print,'SPDYNPS, image, xmin,xmax,ymin,ymax, legende_x,legende_y,titre, $'
  print,'          grid,fond,seuil,fracmin,fracmax,color,bar_titre, [/log], $'
  print,'          [/no_abscissa], [posxmin=float],[posxmax=float], $'
  print,'          [posymin=float],[posymax=float] $'
  print,'          [xy=array(2,n)],[xz=array(2,m)]'
return
end
