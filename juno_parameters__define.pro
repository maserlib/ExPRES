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

tmp1 = {simul,					$
        length:			0.,		$
        step:			0.,		$
        nsteps:			0L$;,	$
       }
end

PRO FREQS__DEFINE

tmp1 = {freqs,					$
        n:			0L,			$
        ramp:		ptr_new()$;,$
       }
end

PRO SOURCES__DEFINE

tmp1 = {sources,				$
        nsrc:       0L,         $
        ntot:		0L,		    $
        names:		ptr_new(),	$
        dirs:		ptr_new(),	$
        is_sat:		ptr_new(),	$
        nrange:		ptr_new(),	$
        data:		ptr_new()$;,	$
       }
end

PRO OBSERVER__DEFINE

tmp1 = {observer,					$
        motion:		0b,				$
        name:		'',				$
        param:		ptr_new(),		$
        pos_xyz:	fltarr(3)		$
       }
end

; ------------------------------------------------------------------------------
  PRO JUNO_PARAMETERS__DEFINE
; ------------------------------------------------------------------------------

tmp = {juno_parameters,				$
       local_time: 	fltarr(2),		$
       simul: 		{simul},		$
       obs:			{observer},		$
       freqs:		{freqs},		$
       src:			{sources}$;,	$
      }

return
end