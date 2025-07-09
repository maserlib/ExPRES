PRO read_ephem_obs,ephem,radius_parent,time0,time,observer,longitude,distance,lat,error

radius_parent = DOUBLE(radius_parent)
tmp=(STRSPLIT(ephem,'.',/EXTRACT))

if radius_parent eq 1 then begin
	    CASE STRLOWCASE(observer.parent) OF
       		'Earth':   planet_radius = 6378.137
       		'Mars':    planet_radius = 3396.2
        	'Jupiter': planet_radius = 71492.00
        	'Saturn':  planet_radius = 60268.00
      	 	'Uranus':  planet_radius = 25559.00
   		    'Neptune':  planet_radius = 24764.00
           ELSE: stop, "In that case, you need to have all your distance units defined in km so that the code can correclty read and transform the distance units"
    	ENDCASE
endif
planet_radius = DOUBLE(planet_radius)
	
if tmp[-1] eq 'csv' then begin

	result=read_csv(ephem,n_table_header=14,table_header=head)
	if head[-2] ne 'State Vector Results' then result=read_csv(ephem,n_table_header=16,table_header=head)
	if n_tags(result) ge 10 then begin
		if n_elements(result.field01) lt 7 then goto, erreur
	endif else begin
		if n_elements(result.field1) lt 7 then goto, erreur
	endelse
	
	if n_tags(result) ge 10 then begin
		n=n_elements(where(result.field04 ne 0))
	endif else begin
		n=n_elements(where(result.field4 ne 0))
	endelse
	Date=strarr(n)
	longitude=dblarr(n)
	lat=dblarr(n)
	distance=dblarr(n)
	if n_tags(result) ge 10 then begin
		date=strmid(result.field01[0:n-1],0,4)+strmid(result.field01[0:n-1],5,2)+strmid(result.field01[0:n-1],8,2)+strmid(result.field01[0:n-1],11,2)+strmid(result.field01[0:n-1],14,2)+strmid(result.field01[0:n-1],17,2)
		longitude=(360+(-1.)*result.field02[0:n-1]+360.) mod 360d
		lat=result.field03[0:n-1]

    if radius_parent eq 1 then begin
        distance=result.field04[0:n-1]/planet_radius 
    endif else begin
        distance=result.field04[0:n-1]/radius_parent

	endif else begin
		date=strmid(result.field1[0:n-1],0,4)+strmid(result.field1[0:n-1],5,2)+strmid(result.field1[0:n-1],8,2)+strmid(result.field1[0:n-1],11,2)+strmid(result.field1[0:n-1],14,2)+strmid(result.field1[0:n-1],17,2)
		longitude=(360+(-1.)*result.field2[0:n-1]+360.) mod 360d
		lat=result.field3[0:n-1]
		
    if radius_parent eq 1 then begin
  		distance=result.field4[0:n-1]/planet_radius
    endif else begin
      distance=result.field4[0:n-1]/radius_parent

  endelse
endif

if tmp[-1] ne 'csv' then begin 
	openr,u,ephem,/get_lun
	buf=''
	readf,u,buf

	if strmatch(buf,'*Geographic Coordinate System*',/FOLD_CASE ) eq 1 then ephem_orig='UIowa' else ephem_orig='unknown'

	if ephem_orig eq 'UIowa' then begin
		nbr_lines_suppr=5l
		nbr_lines_end=0l
		if (file_lines(ephem) lt 4) then goto, erreur
	endif else goto,erreur

	for i=1,nbr_lines_suppr-1 do begin
		readf,u,buf
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
endif





error=0

; # Set SCTIME
time0=date[0]
; # Set simulation Time
Y1=double(strmid(time0,0,4))
Mo1=double(strmid(time0,4,2))
D1=double(strmid(time0,6,2))
H1=double(strmid(time0,8,2))
Mi1=double(strmid(time0,10,2))
S1=double(strmid(time0,12,2))
julday1=JULDAY(Mo1, D1, Y1, H1, Mi1, S1)     

Y2=double(strmid(date[-1],0,4))
Mo2=double(strmid(date[-1],4,2))
D2=double(strmid(date[-1],6,2))
H2=double(strmid(date[-1],8,2))
Mi2=double(strmid(date[-1],10,2))
S2=double(strmid(date[-1],12,2))
julday2=JULDAY(Mo2, D2, Y2, H2, Mi2, S2)     


time.nbr=n
time.mini=0
time.maxi=(julday2-julday1)*24.*60.
time.dt = (time.maxi-time.mini)/float(time.nbr-1)
return

erreur :
	error=1
	return
END
