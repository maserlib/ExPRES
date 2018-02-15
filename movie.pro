;***********************************************************
;***                                                     ***
;***         SERPE V6.0                                  ***
;***                                                     ***
;***********************************************************
;***                                                     ***
;***       MODULE: MOVIE                                 ***
;***                                                     ***
;***     INIT    [INIT_MOVIE]                            ***
;***     CALLBACK  [CB_MOVIE]                            ***
;***     FINALIZE  [FZ_MOVIE]                            ***
;***                                                     ***
;***********************************************************
;/opt/local/bin/ffmpeg -f image2 -an -i Test_Io_movie%03d.png -vcodec h264 -vpre slow -crf 22 video-test-ffmpeg-x264.mp4

;************************************************************** INIT_MOVIE
pro init_movie
rad=0.1
oOrb = OBJ_NEW('orb', COLOR=[255, 0, 0])
oOrb->Scale, rad, rad, rad
oSymbol = OBJ_NEW('IDLgrSymbol', oOrb)
plot_3d,[0,0,0],[1,0,1],[0,0,1],COLOR=[0,255,0],THICK=2,img=img
img->GetProperty, DATA=imag
write_png,'test.png',imag
end

;************************************************************** FZ_MOVIE
pro fz_movie,obj,parameters
comd="rm -f "+parameters.out+"_movie.mp4"
spawn,comd
adr=loadpath('ffmpeg')
comd=adr+"ffmpeg -f image2 -an -i "+parameters.out
comd=comd+"_movie%03d.png -vcodec h264 -pix_fmt yuv420p -crf 22 "+parameters.out+"_movie.mp4"
spawn,comd
comd="rm "+parameters.out+"_movie*.png"
spawn,comd
comd="chmod 777 "+parameters.out+"_movie.mp4"
spawn,comd
end


;************************************************************** CB_MOVIE
pro cb_movie,obj,parameters
set_plot,'Z'
if parameters.time.istep mod (*obj).sub ne 0 then return
frame=fix(parameters.time.istep/(*obj).sub)
t=parameters.time.istep
sx=(*obj).xr[1]-(*obj).xr[0] & sy=(*obj).yr[1]-(*obj).zr[0] & sz=(*obj).zr[1]-(*obj).zr[0]
m=max([sx,sy,sz])
sx=sx/m & sy=sy/m & sz=sz/m
nobj=n_elements(parameters.objects)
n0=1b
for i=0,nobj-1 do if TAG_NAMES(*(parameters.objects[i]),/str) eq 'BODY' then begin
ob2=(parameters.objects[i])
rad=(*ob2).radius
oOrb = OBJ_NEW('orb', COLOR=[0, 0, 255])
oOrb->Scale, rad*sx, rad*sy, rad*sz
oSymbol = OBJ_NEW('IDLgrSymbol', oOrb)
;on dessine la trajectoire
if (*ob2).motion and (*obj).traj then if n0 then begin
plot_3d,(*((*ob2).trajectory_xyz))[0,*],(*((*ob2).trajectory_xyz))[1,*],(*((*ob2).trajectory_xyz))[2,*],$
 COLOR=[0,255,0],THICK=2,img=img,xr=(*obj).xr,yr=(*obj).yr,zr=(*obj).zr
n0=0
endif else plot_3d,(*((*ob2).trajectory_xyz))[0,*],(*((*ob2).trajectory_xyz))[1,*],(*((*ob2).trajectory_xyz))[2,*],$
 COLOR=[0,255,0],THICK=2, /OVERPLOT,img=img,xr=(*obj).xr,yr=(*obj).yr,zr=(*obj).zr

if n0 then begin
plot_3d,[(*((*ob2).trajectory_xyz))[0,t]],[(*((*ob2).trajectory_xyz))[1,t]],[(*((*ob2).trajectory_xyz))[2,t]],$
 COLOR=[0,255,0], SYMBOL=oSymbol,THICK=2,img=img,xr=(*obj).xr,yr=(*obj).yr,zr=(*obj).zr
n0=0
endif else plot_3d,[(*((*ob2).trajectory_xyz))[0,t]],[(*((*ob2).trajectory_xyz))[1,t]],[(*((*ob2).trajectory_xyz))[2,t]],$
 COLOR=[0,255,0], SYMBOL=oSymbol,THICK=2, /OVERPLOT,img=img,xr=(*obj).xr,yr=(*obj).yr,zr=(*obj).zr
endif;BODY

rad=0.1
oOrb = OBJ_NEW('orb', COLOR=[255, 0, 0])
oOrb->Scale, rad*sx, rad*sy, rad*sz
oSymbol = OBJ_NEW('IDLgrSymbol', oOrb)

for i=0,nobj-1 do if TAG_NAMES(*(parameters.objects[i]),/str) eq 'SOURCE' then begin
ob2=(parameters.objects[i])
;on dessine la trajectoire
if (*obj).mfl then begin
w=where((*((*ob2).spdyn)) ne 0)
if w[0] ne -1 then begin
x=reform((*((*ob2).x)),3,parameters.freq.n_freq*((*ob2).nsrc)*2)
xyz=x[*,w] & nx=n_elements(w)
for j=0, nx-1 do xyz[*,j]=(transpose((*((*ob2).parent)).rot)#(xyz[*,j])+(*((*ob2).parent)).pos_xyz)

if n0 then begin
for j=0, nx-1 do plot_3d,[xyz[0,j],xyz[0,j]],[xyz[1,j],xyz[1,j]],[xyz[2,j],xyz[2,j]],$
 COLOR=[0,255,0],THICK=2,xr=(*obj).xr,yr=(*obj).yr,zr=(*obj).zr, SYMBOL=oSymbol,img=img
n0=0
endif else for j=0, nx-1 do plot_3d,[xyz[0,j],xyz[0,j]],[xyz[1,j],xyz[1,j]],[xyz[2,j],xyz[2,j]],$
 COLOR=[0,255,0],THICK=2, /OVERPLOT,xr=(*obj).xr,yr=(*obj).yr,zr=(*obj).zr, SYMBOL=oSymbol,img=img
endif
endif
endif;SOURCE


rad=0.3
oOrb = OBJ_NEW('orb', COLOR=[255, 127, 0])
oOrb->Scale, rad*sx, rad*sy, rad*sz
oSymbol = OBJ_NEW('IDLgrSymbol', oOrb)

for i=0,nobj-1 do if TAG_NAMES(*(parameters.objects[i]),/str) eq 'OBSERVER' then begin
ob2=(parameters.objects[i])
;on dessine la trajectoire
if (*ob2).motion and (*obj).traj then if n0 then begin
plot_3d,(*((*ob2).trajectory_xyz))[0,*],(*((*ob2).trajectory_xyz))[1,*],(*((*ob2).trajectory_xyz))[2,*],$
 COLOR=[0,255,0],THICK=2,img=img,xr=(*obj).xr,yr=(*obj).yr,zr=(*obj).zr
n0=0
endif else plot_3d,(*((*ob2).trajectory_xyz))[0,*],(*((*ob2).trajectory_xyz))[1,*],(*((*ob2).trajectory_xyz))[2,*],$
 COLOR=[0,255,0],THICK=2, /OVERPLOT,img=img,xr=(*obj).xr,yr=(*obj).yr,zr=(*obj).zr

if n0 then begin
plot_3d,[(*((*ob2).trajectory_xyz))[0,t]],[(*((*ob2).trajectory_xyz))[1,t]],[(*((*ob2).trajectory_xyz))[2,t]],$
 COLOR=[0,255,0], SYMBOL=oSymbol,THICK=2,img=img,xr=(*obj).xr,yr=(*obj).yr,zr=(*obj).zr
n0=0
endif else plot_3d,[(*((*ob2).trajectory_xyz))[0,t]],[(*((*ob2).trajectory_xyz))[1,t]],[(*((*ob2).trajectory_xyz))[2,t]],$
 COLOR=[0,255,0], SYMBOL=oSymbol,THICK=2, /OVERPLOT,img=img,xr=(*obj).xr,yr=(*obj).yr,zr=(*obj).zr
endif;OBSERVER


img->GetProperty, DATA=imag
; Display the image data using Direct Graphics:
nom=parameters.out+'_movie'
if frame lt 100 then nom=nom+'0'
if frame lt 10 then nom=nom+'0'
nom=nom+strtrim(string(frame),2)+'.png'
write_png,nom,imag
CATCH, Error_status
IF Error_status EQ 0 THEN HEAP_GC,/obj
CATCH, /CANCEL
return
end

;VV    3D plot function issued from the xplot3d function of IDL    VV
;--------------------------------------------------------------------
pro xplot3d__draw, oWindow, oPicture, vector=vector
compile_opt hidden
;
;Purpose: On some platforms, when IDLgrWindow::Draw is invoked, math
;errors (e.g. "% Program caused arithmetic error: Floating illegal
;operand") are ;printed.  xplot3d__draw suppresses the
;;printing of these errors.
;
;Flush and ;print any accumulated math errors
;
void = check_math(/print)
;
;Silently accumulate any subsequent math errors.
;
orig_except = !except
!except = 0
;
;Draw.
;
if n_elements(vector) gt 0 then begin
    oWindow->Draw, oPicture, vector=vector
    endif $
else begin
    oWindow->Draw, oPicture
    endelse
;
;Silently flush any accumulated math errors.
;
void = check_math()
;
;Restore original math error behavior.
;
!except = orig_except
end
;--------------------------------------------------------------------
pro xplot3d__set_axes_prop, state, _extra=extra

for i=0,n_elements(state.oAxes)-1 do $
    state.oAxes[i]->SetProperty, _extra=extra

end
;--------------------------------------------------------------------
pro plot_3d, x, y, z, $
    _extra=extra, $
    xtitle=xtitle, $
    ytitle=ytitle, $
    ztitle=ztitle, $
    title=title, $
    xrange=xrng, $
    yrange=yrng, $
    zrange=zrng, $
    overplot=overplot, $
    double_view=double_view, $
    block=block, $          ; IN: (opt) block command line.
    just_reg=just_reg, $
    modal=modal,$
    img=img

compile_opt idl2

on_error, 2 ; Return to caller on error.

common xplot3d, oView2, xs, ys, zs, xaxrange, yaxrange, zaxrange, $
    oShadowXYModel, oShadowXZModel, oShadowYZModel, oWindow, oScene, $
    oPolylineModel, tlb


if n_elements(x) eq 0 or n_elements(y) eq 0 or n_elements(z) eq 0 then $
    message, 'Requires 3 non-keyword arguments (x, y and z).'

if n_elements(x) ne n_elements(y) $
or n_elements(x) ne n_elements(z) then $
    message, $
        'Invalid Input: X, Y, and Z should have the same number ' + $
        'of elements.'

oPolyline = obj_new('IDLgrPolyline',  $
    x, $
    y, $
    z, $
    _extra=extra, $
    name=name, $
    color=[255, 0, 0] $
    )

if (obj_valid(oView2) eq 0) or (keyword_set(overplot) eq 0) then begin
    doing_initial_plot = 1b

    oHelvetica14pt = obj_new('IDLgrFont', 'Helvetica', size=14)
    oHelvetica10pt = obj_new('IDLgrFont', 'Helvetica', size=10)

    if n_elements(xtitle) eq 0 then xtitle='X Axis'
    if n_elements(ytitle) eq 0 then ytitle='Y Axis'
    if n_elements(ztitle) eq 0 then ztitle=' '

    oScene = obj_new('IDLgrScene')

    if n_elements(title) gt 0 then begin
        oView1 = obj_new('IDLexInscribingView', $
            location=[0, .9], $
            dimensions=[1, .1], $
            units=3 $
            )
        oTitle = obj_new('IDLgrText', $
            title , $
            alignment=0.5, $
            font=oHelvetica14pt, $
            recompute=2 $
            )

        oModel = obj_new('IDLgrModel')
        oModel->Add, oTitle

        oView1->Add, oModel

        oView2 = obj_new('IDLexObjview', $
            location=[0, 0], $
            dimensions=[1, .9], $
            double=double_view, $
            units=3 $
            )
        oScene->Add, [oView1, oView2]
        end $
    else begin
        oView2 = obj_new('IDLexObjview', double=double_view)
        oScene->Add, oView2
        end

    oXtitle = obj_new('IDLgrText', xtitle, recompute=0)
    oYtitle = obj_new('IDLgrText', ytitle, recompute=0)
    oZtitle = obj_new('IDLgrText', ztitle, recompute=0)

    oXaxis = obj_new('IDLgrAxis', $
        0, $
        ticklen=0.1, $
        minor=0, $
        title=oXtitle, $
        /exact $
        )
    oXaxis->GetProperty, ticktext=oXaxisText
    oXaxisText->SetProperty, font=oHelvetica10pt

    oXaxis2 = obj_new('IDLgrAxis', 0, minor=0, notext=1, /exact, ticklen=0)
    oXaxis3 = obj_new('IDLgrAxis', 0, minor=0, notext=1, /exact, ticklen=0)

    oYaxis = obj_new('IDLgrAxis', $
        1, $
        ticklen=0.1, $
        minor=0, $
        title=oYtitle, $
        /exact $
        )
    oYaxis->GetProperty, ticktext=oYaxisText
    oYaxisText->SetProperty, font=oHelvetica10pt

    oYaxis2 = obj_new('IDLgrAxis', 1, minor=0, notext=1, /exact, ticklen=0)
    oYaxis3 = obj_new('IDLgrAxis', 1, minor=0, notext=1, /exact, ticklen=0)

    oZaxis = obj_new('IDLgrAxis', $
        2, $
        ticklen=0.1, $
        minor=0, $
        title=oZtitle, $
        /exact $
        )
    oZaxis->GetProperty, ticktext=oZaxisText
    oZaxisText->SetProperty, font=oHelvetica10pt

    oZaxis2 = obj_new('IDLgrAxis', 2, minor=0, notext=1, /exact, ticklen=0)
    oZaxis3 = obj_new('IDLgrAxis', 2, minor=0, notext=1, /exact, ticklen=0)

    dummy = -1
    if n_elements(xrng) eq 0 then $
        xrange = float([min(x), max(x)]) $
    else $
        xrange = float(xrng)

    if n_elements(yrng) eq 0 then $
        yrange = float([min(y), max(y)]) $
    else $
        yrange = float(yrng)

    if n_elements(zrng) eq 0 then $
        zrange = float([min(z), max(z)]) $
    else $
        zrange = float(zrng)

    if xrange[0] ge xrange[1] then begin
        xrange[1] = xrange[0] + 1
        end
    xs = norm_coord(xrange)
    oXaxis->SetProperty, range=xrange,  location=[dummy, 0, 0], $
        xcoord_conv=xs
    oXaxis2->SetProperty, range=xrange, location=[dummy, 1, 0], $
        xcoord_conv=xs
    oXaxis3->SetProperty, range=xrange, location=[dummy, 1, 1], $
        xcoord_conv=xs

    if yrange[0] ge yrange[1] then begin
        yrange[1] = yrange[0] + 1
        end
    ys=norm_coord(yrange)
    oYaxis->SetProperty, range=yrange,  location=[0, dummy, 0], $
        ycoord_conv=ys
    oYaxis2->SetProperty, range=yrange, location=[1, dummy, 0], $
        ycoord_conv=ys
    oYaxis3->SetProperty, range=yrange, location=[1, dummy, 1], $
        ycoord_conv=ys

    if zrange[0] ge zrange[1] then begin
        zrange[1] = zrange[0] + 1
        end
    zs=norm_coord(zrange)
    oZaxis->SetProperty, range=zrange,  location=[0, 1, dummy], $
        zcoord_conv=zs
    oZaxis2->SetProperty, range=zrange, location=[1, 0, dummy], $
        zcoord_conv=zs
    oZaxis3->SetProperty, range=zrange, location=[1, 1, dummy], $
        zcoord_conv=zs

    oXaxis->GetProperty, xrange=xaxrange, tickvalues=xtickvalues
    oYaxis->GetProperty, yrange=yaxrange, tickvalues=ytickvalues
    oZaxis->GetProperty, zrange=zaxrange, tickvalues=ztickvalues
;
;   Create gridlines.
;
    zNumlines = n_elements(ztickvalues)
    oGridz = objarr(zNumlines)
    for i=0,zNumlines-1 do begin
        oGridz[i]=obj_new('IDLgrPolyline', $
            [xaxrange[1], xaxrange[1]], $
            [yaxrange[1], yaxrange[0]],$
            [ztickvalues[i], ztickvalues[i]], $
            xcoord_conv=xs, $
            ycoord_conv=ys, $
            zcoord_conv=zs, $
            linestyle=([6, 1])[ $
                ztickvalues[i] ne zaxrange[0] and $
                ztickvalues[i] ne zaxrange[1] $
                ] $
            )
        endfor

    xNumlines = n_elements(xtickvalues)
    oGridx = objarr(xNumlines)
    for i=0,xNumlines-1 do begin
        oGridx[i]=obj_new('IDLgrPolyline', $
            [xtickvalues[i], xtickvalues[i]], $
            [yaxrange[1], yaxrange[1]],$
            [zaxrange[0], zaxrange[1]], $
            xcoord_conv=xs, $
            ycoord_conv=ys, $
            zcoord_conv=zs, $
            linestyle=([6, 1])[ $
                xtickvalues[i] ne xaxrange[0] and $
                xtickvalues[i] ne xaxrange[1] $
                ] $
            )
        endfor

    yNumlines = n_elements(ytickvalues)
    oGridy = objarr(yNumlines)
    for i=0,yNumlines-1 do begin
        oGridy[i]=obj_new('IDLgrPolyline', $
            [xaxrange[1], xaxrange[1]], $
            [ytickvalues[i], ytickvalues[i]],$
            [zaxrange[1], zaxrange[0]], $
            xcoord_conv=xs, $
            ycoord_conv=ys, $
            zcoord_conv=zs, $
            linestyle=([6, 1])[ $
                ytickvalues[i] ne yaxrange[0] and $
                ytickvalues[i] ne yaxrange[1] $
                ] $
            )
        endfor
;
    oAxes = [ $
        oXaxis, $
        oXaxis2, $
        oXaxis3, $

        oYaxis, $
        oYaxis2, $
        oYaxis3, $

        oZaxis, $
        oZaxis2, $
        oZaxis3, $

        oGridx, $
        oGridy, $
        oGridz $
        ]

    oPolylineModel = obj_new('IDLgrModel')
    oShadowXYModel = obj_new('IDLgrModel', /hide)
    oShadowXZModel = obj_new('IDLgrModel', /hide)
    oShadowYZModel = obj_new('IDLgrModel', /hide)
    end

shadow_color = [150, 150, 150]
shadow=intarr(n_elements(z))
oShadowXY = obj_new('IDLgrPolyline',  $
    x, $
    y, $
    shadow+zaxrange[0], $
    _extra=extra $
    )
oShadowXY->SetProperty, color=shadow_color

shadow=intarr(n_elements(y))
oShadowXZ = obj_new('IDLgrPolyline',  $
    x, $
    shadow+yaxrange[1], $
    z, $
    _extra=extra $
    )
oShadowXZ->SetProperty, color=shadow_color

shadow=intarr(n_elements(x))
oShadowYZ = obj_new('IDLgrPolyline',  $
    shadow+xaxrange[1], $
    y, $
    z, $
    _extra=extra $
    )
oShadowYZ->SetProperty, color=shadow_color

oPolylineModel->Add, oPolyline
oShadowXYModel->Add, oShadowXY
oShadowXZModel->Add, oShadowXZ
oShadowYZModel->Add, oShadowYZ

if keyword_set(doing_initial_plot) then begin
    oView2->Add, [ $
        oPolylineModel, $
        oShadowXYModel, $
        oShadowYZModel, $
        oShadowXZModel, $
        oAxes $
        ]
    end

oPolyline->SetProperty,xcoord_conv=xs, ycoord_conv=ys, zcoord_conv=zs
oShadowXY->SetProperty,xcoord_conv=xs, ycoord_conv=ys, zcoord_conv=zs
oShadowYZ->SetProperty,xcoord_conv=xs, ycoord_conv=ys, zcoord_conv=zs
oShadowXZ->SetProperty,xcoord_conv=xs, ycoord_conv=ys, zcoord_conv=zs

if keyword_set(doing_initial_plot) then begin
    oXaxis -> SetProperty, ticklen=1, gridstyle=1
    oYaxis -> SetProperty, ticklen=1, gridstyle=1
    oZaxis -> SetProperty, ticklen=1, gridstyle=1

windowSize = [512, 384]
oWindow = OBJ_NEW('IDLgrBuffer', $
   DIMENSIONS = windowSize)
 ;, RETAIN = 2,TITLE = 'Damped Sine Wave with Noise'
oWindow->SetProperty, GRAPHICS_TREE = oSene

    if n_elements(oView1) eq 1 then begin
        oView1->SetViewVolume, oWindow, /quiet, /isotropic
        end

    oView2->Reset, /full, oWindow
    oView2->Rotate, [0,0,1], 30
    oView2->Rotate, [1,0,0], -60
;
    oWindow->Draw, oScene
    oXaxis->GetProperty, ticktext=oTicktext
    oTickText->SetProperty, recompute_dimensions=0
    oYaxis->GetProperty, ticktext=oTicktext
    oTickText->SetProperty, recompute_dimensions=0
    oZaxis->GetProperty, ticktext=oTicktext
    oTickText->SetProperty, recompute_dimensions=0

    end $
else begin
    xplot3d__draw, oWindow, oScene
    end

 img=oWindow->read()
end

function find_min,x1,x2,dist
z1=where((x1 lt 0.) or (x1 gt dist))
z2=where((x2 lt 0.) or (x2 gt dist))
z=fltarr(n_elements(x1))
if z1[0] ne -1 then z[z1]=1
if z2[0] ne -1 then z[z2]=z[z2]+2
w=where((z eq 0) or (z eq 3))
if w[0] ne -1 then for h=0,n_elements(w)-1 do z[w[h]]=min([(x1[w[h]]>0.)<dist[w[h]],(x2[w[h]]>0.)<dist[w[h]]])
w=where(z eq 1)
if w[0] ne -1 then z[w]=x1[w]
w=where(z eq 2)
if w[0] ne -1 then z[w]=x2[w]
return,z

end

