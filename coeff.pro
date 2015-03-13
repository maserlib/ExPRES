pro COEFF, g,h,n,dip,crt,tdip,mfl_model=mfl_model


if ~ keyword_set(mfl_model) then stop,'You must choose a magnetic field model. Aborting...'


case mfl_model of
  ; Exoplanete

  'TDS'   : coeff_tds, g,h,n,dip,crt,tdip
  ; Jupiter:
  
  'D'     : COEFF_D, g,h,n,dip,crt,tdip
  
  'O6'    : COEFF_O6, g,h,n,dip,crt,tdip
  
  'VIP4'  : COEFF_VIP4, g,h,n,dip,crt,tdip  
  
  'VIT4'  : COEFF_VIT4, g,h,n,dip,crt,tdip   
  
  
  
  ; Saturne:
  'Z3'    : COEFF_Z3, g,h,n,dip,crt,tdip  
  'SPV'   : COEFF_SPV, g,h,n,dip,crt,tdip
  'SPVR'  : COEFF_SPVR, g,h,n,dip,crt,tdip
endcase

return
end