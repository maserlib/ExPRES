PRO read_ephem_obs,ephem,time,observer,longitude,distance,lat,error




nbr_lines_suppr=19l
nbr_lines_end=5l
if (file_lines(ephem) lt 20) then goto, erreur

openr,u,ephem,/get_lun
buf=''


for i=0,nbr_lines_suppr-1 do readf,u,buf


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