;***********************************************************
;***                                                     ***
;***         SERPE V6.1                                  ***
;***                                                     ***
;***********************************************************
;***                                                     ***
;***       MODULE: call_ephemph                          ***
;***        CL : 27/10/2015                              ***
;***     function: call_ephemph							 ***
;***         call MIRIADE   							 ***
;***         give the ephemeris of the chosen body		 ***
;***********************************************************


;date : allowed formats : 
;2015-10-26T12:00
;2015-10-2612:00
;2015102612:00
;2015-10-26T12:00:00

pro call_ephemph, name,spacecraft=spacecraft, date, filename, nbdate=nbdate, step=step, observer=observer

case name of
	'Mercury': BEGIN
		type_new='p'
		type='planet'
		END
	'Mercure': BEGIN
		type_new='p'
		type='planet'
		END
	'Venus' : BEGIN
		type_new='p'
		type='planet'
		END
	'Earth' : BEGIN
		type_new='p'
		type='planet'
		END
	'Terre' : BEGIN
		type_new='p'
		type='planet'
		END
	'Mars' : BEGIN
		type_new='p'
		type='planet'
		END
	'Jupiter' : BEGIN
		type_new='p'
		type='planet'
		END
	'Saturn' : BEGIN
		type_new='p'
		type='planet'
		END
	'Saturne' : BEGIN
		type_new='p'
		type='planet'
		END
	'Uranus' : BEGIN
		type_new='p'
		type='planet'
		END
	'Neptune' : BEGIN
		type_new='p'
		type='planet'
		END
	ELSE : BEGIN
		type_new='s'
		type='satel'
		END
endcase

; Web service URL
;#perious url : url='http://vo.imcce.fr/webservices/miriade/ephemph_query.php?'

url='https://ssp.imcce.fr/webservices/miriade/api/ephemph.php?'


;#Example : 'https://ssp.imcce.fr/webservices/miriade/api/ephemph.php?-name=p:Jupiter&-observer=@io&-type=&-ep=2030-01-01T0:0:0&-nbd=5&-step=1d&-so=3&-mime=text&-output=&-from=MiriadeDoc'



; Target
target='-name='+type_new+':'+name+'&'

;type (planet, satellit, asteroid, comet)
;type_fin='-type='+type+'&'

; Epoch -- allowed formats : 
;2015-10-26T12:00
;2015-10-26T12:00:00 
;2015-10-2612:00

date2=strmid(date,0,4)+'-'+strmid(date,4,2)+'-'+strmid(date,6,2)+'T'+strmid(date,8,2)+':'+strmid(date,11,2)

epoch='-ep='+date2+'&'



; Number of date
if keyword_set(nbdate) then nbdate='-nbd='+strtrim(nbdate,1)+'&' $
else nbdate='-nbd=1&'

; Step size (e.g. 1h or 0.2d (m)inutes or (s)econds...)
if keyword_set(step) then stepp='-step='+strtrim(step,1)+'&' $
else stepp='-step=1d&'

; Observer location code
if keyword_set(spacecraft) then begin
	if spacecraft eq 'Cassini' then observer_fin='-observer=@-82&' $; Cassini 
	else if spacecraft eq 'Voyager1' then observer_fin='-observer=@-31&' $; Voyager1
	else if spacecraft eq 'Voyager2' then observer_fin='-observer=@-32&' $; Voyager2
	else if spacecraft eq 'Ganymede' then observer_fin='-observer=@-503&' $
	else if spacecraft eq 'Juno' then observer_fin='-observer=@-61&' $
	else if spacecraft eq 'Earth' then observer_fin='-observer=@500&' $; Terre
	else begin 
		observer_fin='-observer=@500&'
		print,observer_fin
		stop,'Are you sure of your observer ? Please check the name'
	endelse
endif else if keyword_set(observer) then observer_fin='-observer='+observer+'&' $
else observer_fin='-observer=@500&'

; Mime type of the output (e.g. votable, html, text)
mime='-mime=text&'

; Number of decimals of results
;output='--jd&'
output=''
; Magnetic System
if name eq 'Jupiter' then so='-so=3&'

; Miriade arguments
url=url+target+epoch+nbdate+stepp+observer_fin+mime+output+so+'-from=MiriadeDoc'
print, url

; Call Miriade.ephemcc method
spawn, "curl '"+url+"' -o '"+filename+"' --create-dirs"

end