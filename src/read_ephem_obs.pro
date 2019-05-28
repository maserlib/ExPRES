PRO read_ephem_obs,ephem,time0,time,observer,longitude,distance,lat,error

openr,u,ephem,/get_lun
buf=''
readf,u,buf

if strmatch(buf,'*Geographic Coordinate System*',/FOLD_CASE ) eq 1 then ephem_orig='UIowa'
if strmatch(buf,'*State Vector Results*',/FOLD_CASE ) eq 1 then ephem_orig='WebGeoCalc'


if ephem_orig eq 'WebGeoCalc' then begin
	nbr_lines_suppr=19l
	nbr_lines_end=5l
	if (file_lines(ephem) lt 20) then goto, erreur	
endif

if ephem_orig eq 'UIowa' then begin
	nbr_lines_suppr=5l
	nbr_lines_end=0l
	if (file_lines(ephem) lt 4) then goto, erreur
	
endif

for i=1,nbr_lines_suppr-1 do begin
	readf,u,buf
	if strmatch(buf,'*IAU_JUPITER*',/FOLD_CASE ) eq 1 then inverse_long=-1 else inverse_long=1
endfor


n = file_lines(ephem)-nbr_lines_suppr-nbr_lines_end
Date=strarr(n)
longitude=dblarr(n)
lat=dblarr(n)
distance=dblarr(n)
year=''
month=''
day=''
hour=''
Minute=''
Second=''


for i=0l,n-1 do begin	
	if ephem_orig eq 'WebGeoCalc' then begin
		readf,u,format='(A4,1x,A2,1x,A2,1x,A2,1x,A2,1x,A2,15x,D13.8,4x,D12.8,1x,D16.8)',Year,Month,Day,Hour,Minute,Second,lon_tmp,lat_tmp,distance_tmp
		date[i]=strtrim(year,2)+strtrim(Month,2)+strtrim(Day,2)+strtrim(Hour,2)+strtrim(Minute,2)
		longitude[i]=(360+inverse_long*lon_tmp+360.) mod 360d
		lat[i]=lat_tmp
		distance[i]=distance_tmp/71492d
	endif
	
	
	if ephem_orig eq 'UIowa' then begin
		readf,u,format='(A4,1x,A3,1x,A2,1x,A2,1x,A6,9x,F7.3,9x,F7.3,9x,F7.3,9x,F7.3,8x,F8.3,7x,F9.3,8x,F8.3,6x,F7.3)',Year,Day,Hour,Minute,Second,lon_tmp,lat_tmp,MLat_tmp,LocalTime_tmp,distance_tmp,L,IoPhase
		date[i]=strtrim(aj_amj(year*1000l+day),2)+strtrim(Hour,2)+strtrim(Minute,2)
		longitude[i]=(lon_tmp + 360d) mod 360d
		lat[i]=lat_tmp
		distance[i]=distance_tmp
	endif
		
	
endfor

close, u
free_lun, u


error=0

; # Set SCTIME
time0=date[0]

; # Set simulation Time
H1=fix(strmid(time0,8,2))
Mi1=fix(strmid(time0,10,2))
S1=fix(strmid(time0,12,2))
aj1=amj_aj(double(strmid(time0,0,8)))+double(h1)/24.+double(Mi1)/24./60.
H2=fix(strmid(date[-1],8,2))
Mi2=fix(strmid(date[-1],10,2))
S2=fix(strmid(date[-1],12,2))
aj2=amj_aj(double(strmid(date[-1],0,8)))+double(h2)/24.+double(Mi2)/24./60.

time.nbr=n
time.mini=0
time.maxi=(aj2-aj1)*24.*60.+1
;time.mini = double(strmid(time0,8,2))*60.+double(strmid(time0,10,2))
;time.maxi = double(strmid(time0,8,2))*60.+double(strmid(time0,10,2))+(aj2-aj1)*24.*60.+1
time.dt = (time.maxi-time.mini)/float(time.nbr)
return

erreur :
	error=1
	return
END