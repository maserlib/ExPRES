PRO SHOW_PARAMETERS,p

print,'========================================================================='
print,'(p.local_time)                     Local Time:'
print,string(p.local_time)
print,'========================================================================='
print,'(p.simul)               Simulation Parameters:'
help,p.simul,/str
print,'========================================================================='
print,'(p.obs)                   Observer Parameters:'
help,p.obs,/str
print,'(p.obs.param)    Observer position parameters:'
help,*(p.obs.param),/str
if p.obs.motion then begin 
  print,'(p.obs.param.rpd)  Obs. orbit (r,phi,dphi/dt): (*,0)'
  print,(*((*(p.obs.param)).rpd))(*,0)
endif
print,'(p.obs.pos_xyz)   Obs. position (current xyz):'
print,p.obs.pos_xyz
print,'========================================================================='
print,'(p.src)                     Source Parameters:'
help,p.src,/str
for isrc=0,p.src.nsrc-1L do begin
print,'-------------------------------------------------------------------------'
print,'(p.src.names)                     Source Name:'
print,(*(p.src.names))(isrc)
print,'(p.src.dirs)                   Data directory:'
print,(*(p.src.dirs))(isrc)
print,'(p.src.is_sat)          source is satellite ?:'
print,((*(p.src.is_sat))(isrc)?'yes':'no')
for irange=((*(p.src.nrange))(0,isrc)),((*(p.src.nrange))(1,isrc)) do begin
print,'(p.src.data)               source data param.:'
help,(*(p.src.data))(irange),/str
endfor
endfor
print,'========================================================================='
print,'(p.freqs)                   analysis spectrum:'
help,p.freqs,/str
print,'========================================================================='


end