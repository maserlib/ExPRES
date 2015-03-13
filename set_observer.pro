; ************************************
; *                                  *
; *   Routines de simulation SERPE   *
; *                                  *
; ************************************
; S. Hess (9/2006), P. Zarka (10/2006), B. Cecconi (10/2006), L. Lamy (10/2007)

PRO orb_obs_param__define

; Hyp = apojove et perijove dans le plan equatorial

tmp = {orb_obs_param,                 $
       semi_major_axis:      0.,      $
       semi_minor_axis:      0.,      $
       apoapsis_longitude:   0.,      $
       orbit_inclination:    0.,      $
       apoapsis_declination: 0.,      $
       initial_phase:        0.,      $
       phase:                0.,      $
       rpd:                  ptr_new()$
       }
end

PRO fix_obs_param__define

tmp = {fix_obs_param,    $
       radius:        0.,$
       colatitude:    0.,$
       longitude:     0. $
       }
end

PRO real_obs_param__define

tmp = {real_obs_param,           $
       xyz:            ptr_new(),$
       time:           ptr_new() $
       }
end


; ------------------------------------------------------------------------------------
  pro SET_OBSERVER, name=name, motion=motion, obs_params=obs_params, $
      parameters=p,verbose=verbose, ephem=ephem,tb=tb,te=te,resampl=resampl
; ------------------------------------------------------------------------------------

; inclure la variation en temps local
  if keyword_set(motion) then p.obs.motion = motion else p.obs.motion = 0b
  p.obs.name   = name

  if p.obs.motion eq 2b then begin
  
; ----- Initialization of the Observer real position 
    restore,ephem,/verb
    wt=where(t ge tb and t lt te,count)
    real_xyz=xyz(*,wt) & t=t(wt)
    if resampl ne 1 then RESAMPLING,real_xyz,t,resampl    

    p.obs.real_pos=ptr_new({real_obs_param},/allocate)
    (*(p.obs.real_pos)).xyz  = ptr_new(real_xyz,/allocate)
    (*(p.obs.real_pos)).time = ptr_new(t*1440.,/allocate)

    !p.multi=[0,1,2]
    maxy=max([abs(real_xyz(0,*)),abs(real_xyz(1,*))]) 
    plot,[0,0],[0,0],xran=[-1.1*maxy,1.1*maxy],yran=[-1.1*maxy,1.1*maxy],$
    xtit='X (Rp) -> sun',ytit='Y (Rp)',tit='Equatorial observer motion',/iso
    for k=0,23 do oplot,findgen(10)*20*cos(15*k*!dtor),findgen(10)*20*sin(15*k*!dtor),col=100,linestyle=2
    oplot,real_xyz(0,*),real_xyz(1,*),col=150
    oplot,cos(findgen(360)*!dtor),sin(findgen(360)*!dtor)
   
  endif else if p.obs.motion eq 1b then begin

; ----- Initialization of the Observer orbital parameters
    p.obs.param=ptr_new({orb_obs_param},/allocate)
    (*(p.obs.param)).semi_major_axis      = obs_params(0)
    (*(p.obs.param)).semi_minor_axis      = obs_params(1)
    (*(p.obs.param)).apoapsis_longitude   = obs_params(2)/!radeg
    (*(p.obs.param)).apoapsis_declination = obs_params(3)/!radeg
    (*(p.obs.param)).orbit_inclination    = obs_params(4)/!radeg
    (*(p.obs.param)).initial_phase        = obs_params(5)/!radeg

    CALC_ORBITE, p.obs.param, rpd,p
    (*(p.obs.param)).rpd = ptr_new(rpd,/allocate)
    (*(p.obs.param)).phase = rpd(1,0)

    !p.multi=[0,1,2]
    maxy=max([2*obs_params(0),2*obs_params(1)]) 
    plot,[0,0],[0,0],xran=[-1.1*maxy,1.1*maxy],yran=[-1.1*maxy,1.1*maxy],$
    xtit='X (Rp) -> sun',ytit='Y (Rp)',tit='Equatorial observer motion',/iso
    for k=0,23 do oplot,findgen(10)*20*cos(15*k*!dtor),findgen(10)*20*sin(15*k*!dtor),col=100,linestyle=2
    oplot,cos(findgen(360)*!dtor),sin(findgen(360)*!dtor)
    
    ORBITE, p.obs.param, *((*(p.obs.param)).rpd), xyz_obs, (*(p.obs.param)).phase, p.simul.step
    p.obs.pos_xyz = xyz_obs
    
  endif else begin

; ----- Initialization of the Observer fixed position
    p.obs.param=ptr_new({fix_obs_param},/allocate)
    (*(p.obs.param)).radius     = obs_params(0)
    (*(p.obs.param)).colatitude = (90. - obs_params(1))/!radeg
    (*(p.obs.param)).longitude  = obs_params(2)/!radeg

    p.obs.pos_xyz = (*(p.obs.param)).radius * $
         [ sin( (*(p.obs.param)).colatitude )*cos( (*(p.obs.param)).longitude ), $
          -sin( (*(p.obs.param)).colatitude )*sin( (*(p.obs.param)).longitude ), $
           cos( (*(p.obs.param)).colatitude ) ]
  endelse

  if verbose then message,/info,'XYZ position: '+strcompress(strjoin(string(p.obs.pos_xyz)))

return
end
