;+
; Contains the aj_t70 function
;
; :Author:
;    Baptiste Cecconi / modified by Corentin LOUIS
;
; :History:
;    2004/12/03: Created
;
;    2004/12/03: Last Edit
;	2015/03/09
;-
;
;+
; date conversion AAAAJJJ -> T1970.0 or AAJJJ -> T1970.0
; YYYYDDD -> T1970.0 or YYDDD -> T1970.
;
; :Returns:
;    T1970.0
;
; :Params:
;    aj: in, required, type=long/lonarr/double/dblarr
;       AAAAJJJ, AAJJJ, YYYYDDD or YYDDD
;-
Function AJ_T70, aj
; call : t70 = AJ_T70(aj)
;        t70 = AJ_T70(yd)

  deb= double([0,reform(rebin(reform([365,365,366,365],4,1),4,15),60)])
  for i=1,60 do deb(i)=deb(i)+deb(i-1)

  aj=double(aj)
  a=long(aj/1000.)
  test=where(a lt 60) & if test(0) ne -1 then a(test)=a(test)+2000
  test=where(a lt 100) & if test(0) ne -1 then a(test)=a(test)+1900
  t70=deb(a-1970)+(aj mod 1000.)

return, t70
end
