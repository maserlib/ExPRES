; ***********************************
; *                                 *
; *   Routines de simulation JUNO   *
; *                                 *
; ***********************************
; S. Hess (9/2006), P. Zarka (10/2006), B. Cecconi (10/2006)


; ------------------------------------------------------------------------------------
  pro SET_FREQUENCY, fmin=f1, fmax=f2, fstep=f3, parameters=p
; ------------------------------------------------------------------------------------

;COMMON GLOBAL, n_pas, n_sources, nsat, longitude_sat, obs_mov, local_time, sim_time, $
;	is_sat, pos_sat, xyz_obs, chemin, freq_scl, theta, dtheta, orbite_param, $
;	obs_name, rtp_obs, source_intensite, src_nom, src_data, rpd, intensite_opt

  p.freqs.n = fix((f2-f1)/f3)
  p.freqs.ramp = ptr_new(findgen(p.freqs.n)*f3+f1)
  
return
end

