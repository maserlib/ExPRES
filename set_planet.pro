; ************************************
; *                                  *
; *   Routines de simulation SERPE   *
; *                                  *
; ************************************
; S. Hess (9/2006), P. Zarka (10/2006), B. Cecconi (10/2006), L.Lamy (2/2007)


; ------------------------------------------------------------------------------------
  pro SET_PLANET, planet=planet, parameters=p
; ------------------------------------------------------------------------------------
; p.planet_param=[t_orb_1Rp,t_sid]
; with t_orb_1Rp = 2*!pi*sqrt(Rp^3./G*M) (minutes)
;      t_sid = sidereal period of the planet (minutes)
; ------------------------------------------------------------------------------------

if ~keyword_set(planet) then planet = ''

print,planet

  case strmid(strlowcase(planet),0,3) of
    'jup' : p.planet_param=[177.83,595.5]
    'sat' : p.planet_param=[251.54,647.5/0.7]
    else  : message,'You must choose a planet (Jupiter or Saturn). Aborting...'
  endcase
  
return
end
