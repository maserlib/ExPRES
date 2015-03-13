PRO SERPE_PTR_FREE,parameters

message,/info,'Freeing SERPE pointers...'

if ptr_valid(parameters.obs.param) then begin
  ptr_free,(*parameters.obs.param).rpd
  ptr_free, parameters.obs.param
endif

if ptr_valid(parameters.obs.real_pos) then begin
  ptr_free,(*(parameters.obs.real_pos)).xyz
  ptr_free,(*(parameters.obs.real_pos)).time
  ptr_free,parameters.obs.real_pos
endif

ptr_free,parameters.freqs.ramp

ptr_free,parameters.src.names
ptr_free,parameters.src.dirs
ptr_free,parameters.src.is_sat
ptr_free,parameters.src.nrange
for j=0,parameters.src.ntot-1l do begin 
  ptr_free,((*parameters.src.data)(j)).mag_field_line.b
  ptr_free,((*parameters.src.data)(j)).mag_field_line.x
  ptr_free,((*parameters.src.data)(j)).mag_field_line.wp
endfor
ptr_free,parameters.src.data

if ptr_valid(parameters.dense.data) then begin 
  ptr_free,parameters.dense.data
endif

end