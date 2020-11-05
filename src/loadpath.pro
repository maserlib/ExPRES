
;***********************************************************
;***                                                     ***
;***         ExPRES V1.0                                 ***
;***                                                     ***
;***********************************************************
;***                                                     ***
;***       MODULE: LOADPATH                              ***
;***                                                     ***
;***     function: loadpath 				 ***
;***                                                     ***
;***     Version history                                 ***
;***     [CL] V6.1: First release		         ***
;***     [BC] V6.2: reading paths from config.ini        ***
;***     [BC] V1.0: added keyword for config file path   ***
;***                                                     ***
;***********************************************************


; =============================================================================
function loadpath,adresse,parameters,config=config

if keyword_set(config) then begin
    config_file = config
endif else begin 
    config_file = 'config.ini'
endelse

if file_test(config_file) then begin 
    config_data = read_ascii_file(config_file)
endif else begin 
    stop,"Please configure your config.ini file (check config.ini.template file) in ExPRES distribution directory"
endelse

for i=0,n_elements(config_data)-1 do begin 

    ; loading current line and removing leading and trailing spaces
    this_line = strtrim(config_data[i],2)

    ; process lines that are not comments (starts with '#') nor section headers (starts with '[') nor this line is empty
    if strmid(this_line,0,1) ne '#' and strmid(this_line,0,1) ne "[" and strlen(this_line) ne 0 then begin
        equal_sign_position = strpos(this_line, '=')
        this_path_name = strtrim(strmid(this_line, 0, equal_sign_position),2)
        this_path_value = strtrim(strmid(this_line, equal_sign_position+1),2)
        case this_path_name of
             'cdf_dist_path': if adresse eq 'adresse_cdf' then adresse_out = this_path_value
             'ephem_path': if adresse eq 'adresse_ephem' then adresse_out = this_path_value
             'mfl_path': if adresse eq 'adresse_mfl' then adresse_out = this_path_value
             'save_path': if adresse eq 'adresse_save' then adresse_out = this_path_value
             'ffmpeg_path': if adresse eq 'ffmpeg' then adresse_out = this_path_value
             'ps2pdf_path': if adresse eq 'ps2pdf' then adresse_out = this_path_value
       endcase
    endif
endfor

if strmid(adresse_out,strlen(adresse_out)-1) ne '/' then adresse_out = adresse_out+'/'

if adresse eq 'adresse_save' then begin
	nobj=n_elements(parameters.objects)
	for i=0,nobj-1 do begin
		if TAG_NAMES(*(parameters.objects[i]),/str) eq 'SACRED' then begin
			year=string(format='(I04)',(*parameters.objects[i]).date[0])
			month=string(format='(I02)',(*parameters.objects[i]).date[1])
		endif
		if TAG_NAMES(*(parameters.objects[i]),/str) eq 'OBSERVER' then $
			observer=strlowcase((*parameters.objects[i]).name)
	endfor
	if adresse_out ne './' then begin 
		cmd='mkdir -m g+w '+adresse_out+observer
		spawn,cmd,resu
		cmd="chmod g+w "+adresse_out+observer
		spawn,cmd
		cmd='mkdir -m g+w '+adresse_out+observer+'/'+year
		spawn,cmd,resu
		cmd="chmod g+w "+adresse_out+observer+'/'+year
		spawn,cmd
		cmd='mkdir -m g+w '+adresse_out+observer+'/'+year+'/'+month
		spawn,cmd,resu
		cmd="chmod g+w "+adresse_out+observer+'/'+year+'/'+month
		spawn,cmd
		adresse_out=adresse_out+observer+'/'+year+'/'+month+'/'
	endif
endif

return,adresse_out
END
