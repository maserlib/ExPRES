; ***********************************
; *                                 *
; *   Routines de simulation JUNO   *
; *                                 *
; ***********************************
; S. Hess (9/2006), P. Zarka (10/2006), B. Cecconi (10/2006)


; ------------------------------------------------------------------------------------
  pro SET_OUTPUT, path=path,local_time=local_time,latitude=latitude,radius=radius,pdf=pdf,log=log,$
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

return
end

