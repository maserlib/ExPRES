FUNCTION decode_header, header_raw

header_tags = ["calculation_type", "target", "observer", "reference_frame", "light_propagation", "time_system", "time_format", "time_range", "step", "state_representation"]
header_values = strarr(n_elements(header_tags))

header_data = make_struct(header_tags, header_values)

for i=0,n_elements(header_raw)-1 do begin
   if strpos(header_raw[i], " = ") ne -1 then begin
       header_tmp = strsplit(header_raw[i],' = ') 
       header_tmp_tag = strlowcase(repstr(strtrim(header_tmp[0],2), ' ', '_')) 
       header_tmp_tag_pos = (where(header_tags eq header_tmp_tag))[0]
       if header_tmp_tag_pos ne -1 then begin 
           header_data.(header_tmp_tag_pos) = strtrim(header_tmp[1],2)
       endif
   endif
enfor

return, header_data
end

PRO read_ephem_obs,ephem,time,observer,longitude,distance,lat,error

n_skip_lines_head = 19l
n_skip_lines_foot = 5l
if (file_lines(ephem) lt 20) then goto, erreur

openr,u,ephem,/get_lun
buf=''

header_raw = strarr(n_skip_lines_head)
for i=0,n_skip_lines_head-1 do begin
    readf,u,buf
    header_raw[i] = buf
endfor

n = file_lines(ephem)-nbr_lines_suppr-nbr_lines_end
year=''
month=''
day=''
hour=''
Minute=''
Second=''
Date=strarr(n)
longitude=dblarr(n)
lat=dblarr(n)
distance=dblarr(n)


for i=0l,n-1 do begin
	
	readf,u,format='(A4,1x,A2,1x,A2,1x,A2,1x,A2,1x,A2,15x,D13.8,4x,D12.8,1x,D16.8)',Year,Month,Day,Hour,Minute,Second,lon_tmp,lat_tmp,distance_tmp
	
	date[i]=strtrim(year,2)+strtrim(Month,2)+strtrim(Day,2)+strtrim(Hour,2)+strtrim(Minute,2)
	longitude[i]=(lon_tmp + 360d) mod 360d
	lat[i]=lat_tmp
	distance[i]=distance_tmp/71492d
endfor

close, u
free_lun, u


error=0

; # Set SCTIME
observer.start=date[0]

; # Set simulation Time
H1=fix(strmid(observer.start,8,2))
Mi1=fix(strmid(observer.start,10,2))
S1=fix(strmid(observer.start,12,2))
aj1=amj_aj(double(strmid(observer.start,0,8)))+double(h1)/24.+double(Mi1)/24./60.
H2=fix(strmid(date[-1],8,2))
Mi2=fix(strmid(date[-1],10,2))
S2=fix(strmid(date[-1],12,2))
aj2=amj_aj(double(strmid(date[-1],0,8)))+double(h2)/24.+double(Mi2)/24./60.

time.nbr=n
time.mini=0
time.maxi=(aj2-aj1)*24.*60.+1
;time.mini = double(strmid(observer.start,8,2))*60.+double(strmid(observer.start,10,2))
;time.maxi = double(strmid(observer.start,8,2))*60.+double(strmid(observer.start,10,2))+(aj2-aj1)*24.*60.+1
time.dt = (time.maxi-time.mini)/float(time.nbr)

return

erreur :
	error=1
	return
END
