;+
; Contains the dyn procedure
;
; :Author:
;    Philippe Zarka
;    Baptiste Cecconi
;
; :History:
;    2006/03/08: Last Edit
;-
;
;+
; Adjustment of dynamic range
; (Part of the Cassini-Kronos IDL library)
;-
pro DYN, tab,fracmin,fracmax, tabmin,tabmax
; Adjustment of dynamic range

  tabmax=-1     & tabmin=-1
  test=where(tab gt min(tab))
  if test(0) eq -1 then begin
    message,'Null dynamic range',/info
    ;stop
    return
  endif
  test=float(tab(test))
  dh=max(test)-min(test)
  if dh eq 0 then begin
    message,'Null dynamic range > min(tab)',/info
    tabmin=min(tab) & tabmax=max(tab)
    return
  endif
  dh=dh/1000.
  h=histogram(float(test),min=min(test),max=max(test),binsize=dh)
  xh=findgen(n_elements(h))*dh+min(test)
  th=total(h)   & nh=0
  for i=0,n_elements(h)-1 do begin
    nh=nh+h(i)
    if nh le fracmin*th then tabmin=i
    if nh le fracmax*th then tabmax=i
  endfor
  if tabmin eq -1 then tabmin=0
  tabmin=xh(tabmin)
  if tabmax eq -1 then tabmax=0
  tabmax=xh(tabmax)
return
end

