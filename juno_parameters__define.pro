; ***********************************
; *                                 *
; *   Routines de simulation JUNO   *
; *                                 *
; ***********************************
; B. Cecconi (10/2006)
; ------------------------------------------------------------------------------
; INPUT PARAMETERS STRUCTURE DEFINITION
; ------------------------------------------------------------------------------

PRO SIMUL__DEFINE

tmp1 = {simul,            $
        length:        0.,     $
        step:      0.,     $
        nsteps:        0L$;, $
       }
end

PRO FREQS__DEFINE

tmp1 = {freqs,            $
        n:       0L,         $
        ramp:     ptr_new()$;,$
       }
end

PRO DENSE__DEFINE

tmp1 = {dense,            $
        n:       0L,         $
        data:     ptr_new()$;,$
       }
end

PRO SOURCES__DEFINE

tmp1 = {sources,          $
        nsrc:       0L,         $
        ntot:     0L,       $
        names:   ptr_new(),  $
        dirs:     ptr_new(),   $
        is_sat:     ptr_new(), $
        nrange:     ptr_new(), $
        data:     ptr_new()$;, $
       }
end

PRO OBSERVER__DEFINE

tmp1 = {observer,             $
        fixe_lt:    0b,          $
        motion:     0b,          $
        name:     '',          $
        param:   ptr_new(),   $
        pos_xyz:    fltarr(3)   $
       }
end

PRO OUTTYPE__DEFINE

tmp1 = {outtype,             $
        log:    0b,          $
        radius:     0b,          $
        pdf:    0b,          $
        diag_theta:    0b,          $
        local_time:    0b,          $
        latitude:  0b,   $
        kHz:  0b,  $
        titre: '', $
        nom: 'spectre'$
       }
end


; ------------------------------------------------------------------------------
  PRO JUNO_PARAMETERS__DEFINE
; ------------------------------------------------------------------------------

tmp = {juno_parameters,          $
       local_time:  fltarr(2),   $
       simul:    {simul},       $
       obs:        {observer},     $
       freqs:     {freqs},     $
       src:        {sources},        $
       dense: {dense},   $
       planet_param:    fltarr(3),  $
       working_dir:''            ,  $
       display_mgr:''            ,  $
       output_path: ''           ,  $
       output_type: {outtype}  }

return
end