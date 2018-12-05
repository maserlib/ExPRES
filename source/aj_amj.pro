;+
; Contains the aj_amj function
;
; :Author:
;    Baptiste Cecconi
;
; :History:
;    2004/12/03: Created
;
;    2013/10/09: Last Edit
;-
;
;+
; date conversion AAAAJJJ -> AAAAMMJJ or AAJJJ -> AAMMJJ
; YYYYDDD -> YYYYMMDD or YYDDD -> YYMMDD
;
; :Returns:
;    AAAAMMJJ, AAMMJJ, YYYYMMDD or YYMMDD
;
; :Params:
;    aj: in, required, type=long/lonarr/double/dblarr
;       AAAAJJJ/AAJJJ/YYYYDDD/YYDDD
;-
Function AJ_AMJ, aj
; call : amj = AJ_AMJ(aj)
; ymd = AJ_AMJ(yd)

  amj=aj
  for i=0l, n_elements(aj)-1 do begin
    j=aj(i) mod 1000 & a=long(aj(i)/1000)
    m=1 & k=1 & ms=31
    while j gt ms do begin
      m=m+1 & j=j-ms & k=-k
      case m of
	2: if (a mod 4) eq 0 then ms=29 else ms=28
	3: ms=31
	8: begin
	     k=1 & ms=31
	   end
	else: ms=ms+k
      endcase
    endwhile
    amj(i)=a*10000L+m*100+j
  endfor

return, amj
end
