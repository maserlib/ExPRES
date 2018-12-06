;+
; Contains the amj_aj function
;
; :Author:
;    Baptiste Cecconi
;
; :History:
;    2004/12/03: Created
;
;    2004/12/03: Last Edit
;-
;
;+
; date conversion AAAAMMJJ -> AAAAJJJ or AAMMJJ -> AAJJJ
; YYYYMMDD -> YYYYDDD or YYMMDD -> YYDDD
;
; :Returns:
;    AAAAJJJ, AAJJJ, YYYYDDD or YYDDD
;
; :Params:
;    amj: in, required, type=long/lonarr/double/dblarr
;       AAAAMMJJ/AAMMJJ/YYYYMMDD/YYMMDD
;-
Function AMJ_AJ, amj
; call : aj = AMJ_AJ(amj)
;	 yd = AMJ_AJ(ymd)

  mois=[0L,31,59,90,120,151,181,212,243,273,304,334,365]
  a=long(amj/10000)
  m=long((amj-a*10000L)/100)
  j=mois(m-1)
  test=float(a)/4.
  for i=0, n_elements(a)-1 do $
    if test(i) eq float(fix(test(i))) and m(i) ge 3 then j(i)=j(i)+1
  aj=a*1000+j+(amj-a*10000-m*100)

return, aj
end
