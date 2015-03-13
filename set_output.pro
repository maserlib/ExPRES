; ************************************
; *                                  *
; *   Routines de simulation SERPE   *
; *                                  *
; ************************************
; S. Hess (9/2006), P. Zarka (10/2006), B. Cecconi (10/2006), L. Lamy (10/2007)


; ------------------------------------------------------------------------------------
  pro SET_OUTPUT, path=path,local_time=local_time,latitude=latitude,radius=radius,pdf=pdf,$
  step_tl=step_tl,step_lati=step_lati,step_dist=step_dist,log=log,$
  diag_theta=diag_theta,nom=nom,titre=titre,kHz=kHz,parameters=p
; ------------------------------------------------------------------------------------

p.output_path = path
if keyword_set(titre) then p.output_type.titre=tr
if ~keyword_set(nom) then p.output_type.nom='spectre' else p.output_type.nom=nm
p.output_type.local_time=keyword_set(local_time)
p.output_type.radius=keyword_set(radius)
p.output_type.latitude=keyword_set(latitude)
p.output_type.log=keyword_set(log)
p.output_type.pdf=keyword_set(pdf)
p.output_type.kHz=keyword_set(kHz)
p.output_type.diag_theta=keyword_set(diag_theta)
if keyword_set(step_tl) then p.output_type.step_tl=step_tl else p.output_type.step_tl=1.
if keyword_set(step_lati) then p.output_type.step_lati=step_lati else p.output_type.step_lati=1. 
if keyword_set(step_dist) then p.output_type.step_dist=step_dist else p.output_type.step_dist=1.

return
end

