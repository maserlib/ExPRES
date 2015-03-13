; -------------------------------------------------
  Function AJ_T97, aj
; -------------------------------------------------
; date conversion AAAAJJJ -> T1997.0 or AAJJJ -> T1997.0
;		  YYYYDDD -> T1997.0 or YYDDD -> T1997.0
; data type = long integer or double precision, scalar or 1D array
; call : t97 = AJ_T97(aj)
;        t97 = AJ_T97(yd)

  deb= double([0,reform(rebin(reform([365,365,365,366],4,1),4,15),60)])
  for i=1,60 do deb(i)=deb(i)+deb(i-1)

  aj=double(aj)
  a=long(aj/1000.)
  test=where(a lt 60) & if test(0) ne -1 then a(test)=a(test)+2000
  test=where(a lt 100) & if test(0) ne -1 then a(test)=a(test)+1900
  t97=deb(a-1997)+(aj mod 1000.)

return, t97
end
