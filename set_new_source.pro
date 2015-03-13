; ***********************************
; *                                 *
; *   Routines de simulation JUNO   *
; *                                 *
; ***********************************
; S. Hess (9/2006), P. Zarka (10/2006), B. Cecconi (10/2006)


; ------------------------------------------------------------------------------------
  pro SET_NEW_SOURCE, name, camino, sat=sat, intensity=intensity, $
	intensity_random=intensity_random, intensity_n_random=intensity_n_random, $
	intensity_local_time=intensity_local_time, cone_emission=ce, lag=lag, shape=v, intensite_norm=int_n
; ------------------------------------------------------------------------------------

COMMON GLOBAL, n_pas, n_sources, nsat, longitude_sat, obs_mov, local_time, sim_time, $
	is_sat, pos_sat, xyz_obs, chemin, freq_scl, theta, dtheta, orbite_param, $
	obs_name, rtp_obs, source_intensite, src_nom, src_data, rpd, intensite_opt

  if n_elements(is_sat) eq 0 then begin
    help,ce
    n_sources=1
    is_sat=n_elements(sat) ne 0
    if is_sat then begin
      nsat=1
      pos_sat=sat(0)
      longitude_sat=sat(1)
      src_data=fltarr(3,2)
      if n_elements(ce) ne 0 then src_data(0,*)=ce else src_data(0,*)=[-1.,-1]
      if n_elements(lag) ne 0 then src_data(1,*)=lag else src_data(1,*)=[0.,0.]
      if n_elements(v) ne 0 then src_data(2,*)=v else src_data(2,*)=[-1.,-1.]
    endif else begin
      nsat=0	
      pos_sat=0.
      longitude_sat=0.
      src_data=fltarr(3,2)
      if n_elements(ce) ne 0 then src_data(0,*)=[ce,-1] else src_data(0,*)=[-1.,-1]
      if n_elements(v) ne 0 then src_data(2,*)=[v,-1.] else src_data(2,*)=[-1.,-1.]
    endelse		; endelse si sat (premier)
    intensite_opt=(n_elements(int_n) ne 0)
    chemin=camino
    src_nom=name
    source_intensite=1
  endif else begin	; else si pas premier
    help,ce
    n_sources=n_sources+1
    is_sat=[is_sat,(n_elements(sat) ne 0)]
    if is_sat(n_sources-1) then begin
      nsat=nsat+1
      pos_sat=[pos_sat,sat(0)]
      longitude_sat=[longitude_sat,sat(1)]
;if n_elements(ce) eq 0 then ce=[-1.,-1]
;if n_elements(lag) eq 0 then lag=[0.,0.]
;if n_elements(v) eq 0 then v=[-1.,-1.]
      src_data=[[src_data(0,*),ce],[src_data(1,*),lag],[src_data(2,*),v]]
    endif else begin
      pos_sat=[pos_sat,0.]
      longitude_sat=[longitude_sat,0.]
      help,ce
      if n_elements(ce) ne 0 then ce=[ce,-1.] else ce=[-1.,-1]
      if n_elements(v) ne 0 then v=[v,-1.] else v=[-1.,-1.]
      help,ce,v
      src_data20=transpose(src_data(0,*))
      src_data20=[src_data20,ce]
      src_data21=transpose(src_data(1,*))
      src_data21=[src_data21,fltarr(2)]
      src_data22=transpose(src_data(2,*))
      src_data22=[src_data22,v]
      src_data=[[src_data20],[src_data21],[src_data22]]
    endelse
    intensite_opt=[intensite_opt,(n_elements(int_n) ne 0)]
    chemin=[chemin,camino]
    src_nom=[src_nom,name]
    if (n_elements(intensity)) eq 0 then x=2^(n_sources-1) else x=intensity
    source_intensite=[source_intensite,x]
  endelse

return
end

