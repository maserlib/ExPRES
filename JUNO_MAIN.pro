;****************************************************
;***** simulation JUNO fichier principal  ***********
;****************************************************

pro JUNO, dynsp

common global, n_pas, n_sources, nsat, longitude_sat, obs_mov, local_time, sim_time, is_sat, pos_sat, xyz_obs, chemin,freq_scl,theta,dtheta,orbite_param,obs_name,rtp_obs, source_intensite,src_nom,src_data,rpd,intensite_opt


JUNO_INIT
print,""
print,""
print,""
print,"********************************"
print,'          INITIALISATION'
print,"********************************"
print,""

print,'simulation des emissions radio de jupiter vue par un observateur '
if (obs_mov eq "fixe") then print,"fixe situe a r=",STRTRIM(rtp_obs(0),2)," colatitude=", STRTRIM(rtp_obs(1),2)," longitude=", STRTRIM(rtp_obs(2),2)

if (obs_mov eq "orb") then begin
print,"decrivant l'orbite:"
end

print,""
print,"la simulation demarre a ",STRTRIM(local_time(0)/15.,2)," heure (meridien 0) et dure ",STRTRIM(sim_time(0),2)," minutes"
print,"par pas de ",STRTRIM(sim_time(1),2)," minutes."
print,""
print,"cette simulation contient ",STRTRIM(n_sources,2)," sources d'emissions dont ",STRTRIM(nsat,2)," satellites:"
for i=0,n_sources-1 do begin
if (is_sat(i)) then begin
print,src_nom(i),"   satellite"
endif else begin
print,src_nom(i)
endelse
endfor

xtmp=0.
ytmp=0.
ztmp=0.

dynsp=fltarr(n_elements(freq_scl),n_pas+1)

set_plot,'x'
for boucle_temps=0L,n_pas do begin
print, boucle_temps
rotation_planete_sat

for boucle_sources=0,n_sources-1 do begin

if (is_sat(boucle_sources)) then begin
field_line_emission, xyz_obs, longitude_sat(boucle_sources), chemin(boucle_sources), intensite, frequence, position, theta, dtheta, src_data(*,boucle_sources*2), intensite_opt(boucle_sources)
scale_frequency,intensite,frequence,intensite_scl,freq_scl,intensite_opt(boucle_sources)
dynsp(*,boucle_temps)=dynsp(*,boucle_temps)+intensite_scl*source_intensite(boucle_sources)
field_line_emission,xyz_obs,-longitude_sat(boucle_sources),chemin(boucle_sources),intensite,frequence,position,theta,dtheta,src_data(*,boucle_sources*2+1),intensite_opt(boucle_sources)
scale_frequency,intensite,frequence,intensite_scl,freq_scl,intensite_opt(boucle_sources)
dynsp(*,boucle_temps)=dynsp(*,boucle_temps)+intensite_scl*source_intensite(boucle_sources)

endif else begin

;for longitude=0,359 do begin
;for longitude=220,220 do begin
for longitude=0,300,60 do begin
field_line_emission,xyz_obs,longitude,chemin(boucle_sources),intensite,frequence,position,theta,dtheta,src_data(*,boucle_sources*2),intensite_opt(boucle_sources)
scale_frequency,intensite,frequence,intensite_scl,freq_scl,intensite_opt(boucle_sources)
dynsp(*,boucle_temps)=dynsp(*,boucle_temps)+intensite_scl*source_intensite(boucle_sources)
endfor ;longitude

endelse


endfor;boucle_sources
;if (obs_mov eq "orb") then orbite
dynsp(*,0)=1.
xtmp=[xtmp,xyz_obs(0)]
ytmp=[ytmp,xyz_obs(1)]
ztmp=[ztmp,xyz_obs(2)]

if (boucle_temps mod 20) eq 0 then begin
if boucle_temps le 1000 then tvscl,-transpose(dynsp(2:*,0:*))
if boucle_temps gt 1000 then tvscl,-transpose(dynsp(2:*,boucle_temps-1000:boucle_temps))
;if boucle_temps ne 0 then plot,xtmp(1:n_elements(xtmp)-1),ytmp(1:n_elements(xtmp)-1)


endif
endfor;boucle_temps

ecrire_spectre,-dynsp,local_time(0),sim_time(0),freq_scl
end



pro set_local_time,t1,t2
common global, n_pas, n_sources, nsat, longitude_sat, obs_mov, local_time, sim_time, is_sat, pos_sat, xyz_obs, chemin,freq_scl,theta,dtheta,orbite_param,obs_name,rtp_obs, source_intensite,src_nom,src_data,rpd,intensite_opt
local_time=[t1,t2]
return
end

;**************************************************

pro set_observer,name,pos=pos,orb=orb
common global, n_pas, n_sources, nsat, longitude_sat, obs_mov, local_time, sim_time, is_sat, pos_sat, xyz_obs, chemin,freq_scl,theta,dtheta,orbite_param,obs_name,rtp_obs, source_intensite,src_nom,src_data,rpd,intensite_opt

;faire en fonction de local_time
if (n_elements(orb) eq 0) then begin
obs_mov="fixe"
endif else begin
obs_mov="orb"
orbite_param=orb ;param=[a,b,phia,i,angle] 
orbite_param[2:4]= orbite_param[2:4]*!pi/180.
endelse

obs_name=name

if (obs_mov eq "fixe") then begin
rtp_obs=pos
xyz_obs=[cos(rtp_obs(1)*!pi/180.)*cos(rtp_obs(2)*!pi/180.),-cos(rtp_obs(1)*!pi/180.)*sin(rtp_obs(2)*!pi/180.-!pi/2.),sin(rtp_obs(1)*!pi/180.)]
xyz_obs=rtp_obs(0)*xyz_obs
endif

if (obs_mov eq "orb") then begin
calc_orbite,orb,rpd
rtp_obs=[0.,rpd(1,0),0.]
orbite,orb,rpd,xyz_obs,rtp_obs(1),sim_time(1)
endif

print,xyz_obs

return
end

;**************************************************

pro set_simulation_time,t1,t2
common global, n_pas, n_sources, nsat, longitude_sat, obs_mov, local_time, sim_time, is_sat, pos_sat, xyz_obs, chemin,freq_scl,theta,dtheta,orbite_param,obs_name,rtp_obs, source_intensite,src_nom,src_data,rpd,intensite_opt


sim_time=[t1,t2]
n_pas=LONG(t1/t2)

return
end

;**************************************************

pro set_emission_cone,t1,t2
common global, n_pas, n_sources, nsat, longitude_sat, obs_mov, local_time, sim_time, is_sat, pos_sat, xyz_obs, chemin,freq_scl,theta,dtheta,orbite_param,obs_name,rtp_obs, source_intensite,src_nom,src_data,rpd,intensite_opt


theta=t1
dtheta=t2

return
end


;**************************************************

pro set_frequency,f1,f2,f3
common global, n_pas, n_sources, nsat, longitude_sat, obs_mov, local_time, sim_time, is_sat, pos_sat, xyz_obs, chemin,freq_scl,theta,dtheta,orbite_param,obs_name,rtp_obs, source_intensite,src_nom,src_data,rpd,intensite_opt


freq_scl=findgen(fix((f2-f1)/f3))*f3+f1

return
end

;**************************************************

pro set_new_source,name,camino,sat=sat,intensity=intensity,intensity_random=intensity_random,intensity_n_random=intensity_n_random,intensity_local_time=intensity_local_time,cone_emission=ce,lag=lag,shape=v,intensite_norm=int_n
common global, n_pas, n_sources, nsat, longitude_sat, obs_mov, local_time, sim_time, is_sat, pos_sat, xyz_obs, chemin,freq_scl,theta,dtheta,orbite_param,obs_name,rtp_obs, source_intensite,src_nom,src_data,rpd,intensite_opt

if (n_elements(is_sat) eq 0) then begin

help,ce
n_sources=1
is_sat=(N_elements(sat) ne 0)

	if is_sat then begin
	nsat=1
	pos_sat=sat(0)
	longitude_sat=sat(1)


src_data=fltarr(3,2)
if n_elements(ce) ne 0 then begin
src_data(0,*)=ce
endif else begin
src_data(0,*)=[-1.,-1]
endelse
if n_elements(lag) ne 0 then begin
src_data(1,*)=lag
endif else begin
src_data(1,*)=[0.,0.]
endelse
if n_elements(v) ne 0 then begin
src_data(2,*)=v
endif else begin
src_data(2,*)=[-1.,-1.]
endelse

	endif else begin
	nsat=0	
	pos_sat=0.
	longitude_sat=0.


src_data=fltarr(3,2)
if n_elements(ce) ne 0 then begin
src_data(0,*)=[ce,-1]
endif else begin
src_data(0,*)=[-1.,-1]
endelse
if n_elements(v) ne 0 then begin
src_data(2,*)=[v,-1.]
endif else begin
src_data(2,*)=[-1.,-1.]
endelse

	endelse ;endelse si sat (premier)

intensite_opt=(n_elements(int_n) ne 0)
chemin=camino
src_nom=name
source_intensite=1

endif else begin ;else si pas premier

help,ce
n_sources=n_sources+1
is_sat=[is_sat,(N_elements(sat) ne 0)]

	if is_sat(n_sources-1) then begin
	nsat=nsat+1
	pos_sat=[pos_sat,sat(0)]
	longitude_sat=[longitude_sat,sat(1)]



;if n_elements(ce) eq 0 then ce=[-1.,-1]
;if n_elements(lag) eq 0 then lag=[0.,0.]
;if n_elements(v) eq 0 then v=[-1.,-1.]

src_data=[[src_data(0,*),ce],[src_data(1,*),lag],[src_data(2,*),v]]

	endif else begin
	pos_sat=[pos_sat,0.]
	longitude_sat=[longitude_sat,0.]

help,ce
if n_elements(ce) ne 0 then begin
ce=[ce,-1.]
endif else begin
ce=[-1.,-1]
endelse
if n_elements(v) ne 0 then begin
v=[v,-1.]
endif else begin
v=[-1.,-1.]
endelse
help,ce,v
src_data20=transpose(src_data(0,*))
src_data20=[src_data20,ce]
src_data21=transpose(src_data(1,*))
src_data21=[src_data21,fltarr(2)]
src_data22=transpose(src_data(2,*))
src_data22=[src_data22,v]
src_data=[[src_data20],[src_data21],[src_data22]]
	endelse
intensite_opt=[intensite_opt,(n_elements(int_n) ne 0)]
chemin=[chemin,camino]
src_nom=[src_nom,name]


if (N_elements(intensity)) eq 0 then begin
x=2^(n_sources-1)
endif else begin
x=intensity
endelse
source_intensite=[source_intensite,x]

endelse

return
end

;**********************************************

pro rotation_planete_sat
common global, n_pas, n_sources, nsat, longitude_sat, obs_mov, local_time, sim_time, is_sat, pos_sat, xyz_obs, chemin,freq_scl,theta,dtheta,orbite_param,obs_name,rtp_obs, source_intensite,src_nom,src_data,rpd,intensite_opt


if (obs_mov eq "fixe") then begin
rtp_obs=rtp_obs+[0.,0.,360./595.5*sim_time(1)]
if rtp_obs[2] ge 360. then rtp_obs[2]=rtp_obs[2]-360.
if rtp_obs[2] lt 0 then rtp_obs[2]=360.+rtp_obs[2]
xyz_obs[0:1]=[cos(rtp_obs(1)*!pi/180.)*cos(rtp_obs(2)*!pi/180.),-cos(rtp_obs(1)*!pi/180.)*sin(rtp_obs(2)*!pi/180.)]
xyz_obs[0:1]=rtp_obs(0)*xyz_obs[0:1]
endif


if obs_mov eq "orb" then begin
rtp_obs=rtp_obs+[0.,0.,-2.*!pi/595.5*sim_time(1)]
tmpe=rtp_obs(1)
orbite, orbite_param,rpd,xyz_obs,tmpe,sim_time(1)
rtp_obs(1)=tmpe

xyz_to_rtp,xyz_obs(0),xyz_obs(1),xyz_obs(2),a,b,c
c=c+rtp_obs(2)
xyz_obs=[sin(b)*cos(c),sin(b)*sin(c),cos(b)]
xyz_obs=a*xyz_obs
endif



for boucle_sources=0,n_sources-1 do if (is_sat(boucle_sources)) then begin
longitude_sat(boucle_sources)=longitude_sat(boucle_sources)-sim_time(1)*360.*(1./(pos_sat(boucle_sources)^1.5*175.53)-1./595.5)
if longitude_sat(boucle_sources) ge 360. then longitude_sat(boucle_sources)=longitude_sat(boucle_sources)-360.
;print,longitude_sat(boucle_sources)
endif
;faire en fonction de local_time
return
end


