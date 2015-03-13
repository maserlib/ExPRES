; ************************************
; *                                  *
; *   Routines de simulation SERPE   *
; *                                  *
; ************************************
; S. Hess (9/2006), P. Zarka (10/2006), B. Cecconi (10/2006)


; ------------------------------------------------------------------------------------
  pro SET_DENSITY,dat, parameters=p
; ------------------------------------------------------------------------------------

if n_elements(dat) eq 3 then begin
  p.dense.n = p.dense.n+1L
  if p.dense.n gt 1L then begin
    tmpdata     = *(p.dense.data)
  endif else begin
    p.dense.data     = ptr_new(0b,/allocate)
  endelse
  
  *(p.dense.data)=fltarr(3,p.dense.n)
  if p.dense.n gt 1L then (*(p.dense.data))(*,0:p.dense.n-2L) =tmpdata
  (*(p.dense.data))(*,p.dense.n-1L)=dat
  print,"Nouveaux profil de densite ajoute"

endif else  print,"Densite: bad argument"
return
end