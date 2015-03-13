; ***********************************
; *                                 *
; *   Routines de simulation JUNO   *
; *                                 *
; ***********************************
; S. Hess (9/2006), P. Zarka (10/2006), B. Cecconi (10/2006)


; ------------------------------------------------------------------------------------
  pro SET_SIMULATION_TIME, simul_length=t1, simul_step=t2, parameters=p
; ------------------------------------------------------------------------------------

;COMMON GLOBAL, n_pas, n_sources, nsat, longitude_sat, obs_mov, local_time, sim_time, $;
;	is_sat, pos_sat, xyz_obs, chemin, freq_scl, theta, dtheta, orbite_param, $
;	obs_name, rtp_obs, source_intensite, src_nom, src_data, rpd, intensite_opt

  p.simul.length = t1
  p.simul.step   = t2
  p.simul.nsteps = LONG(t1/t2)

return
end
