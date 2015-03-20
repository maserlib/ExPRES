;***********************************************************
;***                                                     ***
;***         SERPE V6.1b0                                ***
;***                                                     ***
;***********************************************************
;***                                                     ***
;***       MODULE: READ_SAVE                             ***
;***                                                     ***
;***.....................................................***
;***     function: rank_bodies;                          ***
;***          Ranks Bodies (using Parent links)          ***
;***     Version history                                 ***
;***     [SH] V6.0: First release                        ***
;***                                                     ***
;***.....................................................***
;***     function: init_serpe_structures;                ***
;***          Initiliazes SERPE Parameter Structures     ***
;***     Version history                                 ***
;***     [BC] V6.1: Extracted from previous read_save    ***
;***                                                     ***
;***.....................................................***
;***     function: build_serpe_obj;                      ***
;***          Builds SERPE Parameters and Objects        ***
;***     Version history                                 ***
;***     [BC] V6.1: Extracted from previous read_save    ***
;***                                                     ***
;***.....................................................***
;***     function: check_save_json;                      ***
;***          Checks JSON content                        ***
;***     Version history                                 ***
;***     [BC] V6.1: First release                        ***
;***                                                     ***
;***.....................................................***
;***     pro: READ_SAVE_JSON                             ***
;***          Reads Save file (in JSON format)           ***
;***     Version history                                 ***
;***     [BC] V6.1: First release            	         ***
;***                                                     ***
;***.....................................................***
;***     pro: READ_SAVE                                  ***
;***          Reads Save file (in old format)            ***
;***     Version history                                 ***
;***     [SH] V6.0: First release                        ***
;***     [BC] V6.1: Using build_serpe_obj and            ***
;***                init_serpe_structures               ***
;***                                                     ***
;***********************************************************


;************************************************************** RANK_BODIES
pro rank_bodies,bd
ntot=n_elements(bd)
bd2=bd
n=0
for i=0,ntot-1 do begin
	if bd[i].parent eq '' then begin
		bd2[n]=bd[i]
		n=n+1
	endif
endfor
for k=0,ntot-1 do begin
	w=where(bd2[0:n-1].name eq bd[k].name)
	if w[0] eq -1 then begin
        	w=where(bd2[0:n-1].name eq bd[k].parent)
		if w[0] ne -1 then begin
			bd2[n]=bd[k]
			bd2[n].ipar=w[0]
			n=n+1
		endif
	endif
endfor
bd=bd2
return
end	


;************************************************************** CHECK_SAVE_JSON
function check_save_json,json_hash,error=error

nerr = 0l
error = [""]

key_list_lev0 = json_hash.keys()

test = where(key_list_lev0 eq 'SIMU',cnt)
if cnt ne 0 then begin 

    key_list_lev1 = json_hash['SIMU'].keys()
    
    test = where(key_list_lev1 eq 'NAME',cnt)
    if cnt eq 0 then begin 
      nerr +=1 
      error = [error,'Missing SIMU.NAME Element.']
    endif
    
    test = where(key_list_lev1 eq 'OUT',cnt)
    if cnt eq 0 then begin 
      nerr +=1 
      error = [error,'Missing SIMU.OUT Element.']
    endif
    
endif else begin
    nerr +=1 
    error = [error,'Missing SIMU Group.']
endelse

test = where(key_list_lev0 eq 'NUMBER',cnt)
if cnt ne 0 then begin 

    key_list_lev1 = json_hash['NUMBER'].keys()
    
    test = where(key_list_lev1 eq 'BODY',cnt)
    if cnt eq 0 then begin 
      nerr +=1 
      error = [error,'Missing NUMBER.BODY Element.']
    endif

    test = where(key_list_lev1 eq 'DENSITY',cnt)
    if cnt eq 0 then begin 
      nerr +=1 
      error = [error,'Missing NUMBER.DENSITY Element.']
    endif

    test = where(key_list_lev1 eq 'SOURCE',cnt)
    if cnt eq 0 then begin 
      nerr +=1 
      error = [error,'Missing NUMBER.SOURCE Element.']
    endif
    
endif else begin
    nerr +=1 
    error = [error,'Missing NUMBER Group.']
endelse

test = where(key_list_lev0 eq 'TIME',cnt)
if cnt ne 0 then begin 

    key_list_lev1 = json_hash['TIME'].keys()
    
    test = where(key_list_lev1 eq 'MIN',cnt)
    if cnt eq 0 then begin 
      nerr +=1 
      error = [error,'Missing TIME.MIN Element.']
    endif

    test = where(key_list_lev1 eq 'MAX',cnt)
    if cnt eq 0 then begin 
      nerr +=1 
      error = [error,'Missing TIME.MAX Element.']
    endif

    test = where(key_list_lev1 eq 'NBR',cnt)
    if cnt eq 0 then begin 
      nerr +=1 
      error = [error,'Missing TIME.NBR Element.']
    endif

endif else begin 
    nerr +=1 
    error = [error,'Missing TIME Group.']
endelse

test = where(key_list_lev0 eq 'FREQUENCY',cnt)
if cnt ne 0 then begin 

    key_list_lev1 = json_hash['FREQUENCY'].keys()

    test = where(key_list_lev1 eq 'TYPE',cnt)
    if cnt eq 0 then begin 
      nerr +=1 
      error = [error,'Missing FREQUENCY.TYPE Element.']
    endif else case (json_hash['FREQUENCY'])['TYPE'] of
        'Pre-Defined' : 
        'Log' : 
        'Linear': 
        else : begin 
	      nerr +=1 
    	  error = [error,'Wrong FREQUENCY.TYPE Value.']
    	end
    endcase

    test = where(key_list_lev1 eq 'MIN',cnt)
    if cnt eq 0 then begin 
      nerr +=1 
      error = [error,'Missing FREQUENCY.MIN Element.']
    endif 

    test = where(key_list_lev1 eq 'MAX',cnt)
    if cnt eq 0 then begin 
      nerr +=1 
      error = [error,'Missing FREQUENCY.MAX Element.']
    endif 

    test = where(key_list_lev1 eq 'NBR',cnt)
    if cnt eq 0 then begin 
      nerr +=1 
      error = [error,'Missing FREQUENCY.NBR Element.']
    endif 
    
    test = where(key_list_lev1 eq 'SC',cnt)
    if cnt eq 0 then begin 
      nerr +=1 
      error = [error,'Missing FREQUENCY.SC Element.']
    endif else if ((json_hash['FREQUENCY'])['TYPE'] eq 'Pre-Defined') $
			and ((json_hash['FREQUENCY'])['SC'] eq "") then begin 
      			nerr +=1 
		      	error = [error,'Empty FREQUENCY.SC Value.']
    endif 
    
endif else begin
    nerr +=1 
    error = [error,'Missing FREQUENCY Group.']
endelse

test = where(key_list_lev0 eq 'OBSERVER',cnt)
if cnt ne 0 then begin 

    key_list_lev1 = json_hash['OBSERVER'].keys()

    test = where(key_list_lev1 eq 'TYPE',cnt)
    if cnt eq 0 then begin 
      nerr +=1 
      error = [error,'Missing OBSERVER.TYPE Element.']
    endif else case (json_hash['OBSERVER'])['TYPE'] of
        'Pre-Defined' : 
        'Orbiter' : 
        'Fixed': 
        else : begin 
	      nerr +=1 
    	  error = [error,'Wrong OBSERVER.TYPE Value.']
    	end
    endcase

    test = where(key_list_lev1 eq 'FIXE_DIST',cnt)
    if cnt eq 0 then begin 
      nerr +=1 
      error = [error,'Missing OBSERVER.FIXE_DIST Element.']
    endif 

    test = where(key_list_lev1 eq 'FIXE_SUBL',cnt)
    if cnt eq 0 then begin 
      nerr +=1 
      error = [error,'Missing OBSERVER.FIXE_SUBL Element.']
    endif 

    test = where(key_list_lev1 eq 'FIXE_DECL',cnt)
    if cnt eq 0 then begin 
      nerr +=1 
      error = [error,'Missing OBSERVER.FIXE_DECL Element.']
    endif 

    test = where(key_list_lev1 eq 'PARENT',cnt)
    if cnt eq 0 then begin 
      nerr +=1 
      error = [error,'Missing OBSERVER.PARENT Element.']
    endif 

    test = where(key_list_lev1 eq 'SC',cnt)
    if cnt eq 0 then begin 
      nerr +=1 
      error = [error,'Missing OBSERVER.SC Element.']
    endif 

    test = where(key_list_lev1 eq 'SCTIME',cnt)
    if cnt eq 0 then begin 
      nerr +=1 
      error = [error,'Missing OBSERVER.SCTIME Element.']
    endif 

    test = where(key_list_lev1 eq 'SEMI_MAJ',cnt)
    if cnt eq 0 then begin 
      nerr +=1 
      error = [error,'Missing OBSERVER.SEMI_MAJ Element.']
    endif 

    test = where(key_list_lev1 eq 'SEMI_MIN',cnt)
    if cnt eq 0 then begin 
      nerr +=1 
      error = [error,'Missing OBSERVER.SEMI_MIN Element.']
    endif 

    test = where(key_list_lev1 eq 'SUBL',cnt)
    if cnt eq 0 then begin 
      nerr +=1 
      error = [error,'Missing OBSERVER.SUBL Element.']
    endif 

    test = where(key_list_lev1 eq 'DECL',cnt)
    if cnt eq 0 then begin 
      nerr +=1 
      error = [error,'Missing OBSERVER.DECL Element.']
    endif 

    test = where(key_list_lev1 eq 'PHASE',cnt)
    if cnt eq 0 then begin 
      nerr +=1 
      error = [error,'Missing OBSERVER.PHASE Element.']
    endif 

    test = where(key_list_lev1 eq 'INCL',cnt)
    if cnt eq 0 then begin 
      nerr +=1 
      error = [error,'Missing OBSERVER.INCL Element.']
    endif 

endif else begin
    nerr +=1 
    error = [error,'Missing OBSERVER Group.']
endelse

test = where(key_list_lev0 eq 'SPDYN',cnt)
if cnt ne 0 then begin 

    key_list_lev1 = json_hash['SPDYN'].keys()

    test = where(key_list_lev1 eq 'INTENSITY',cnt)
    if cnt eq 0 then begin 
      nerr +=1 
      error = [error,'Missing SPDYN.INTENSITY Element.']
    endif 

    test = where(key_list_lev1 eq 'POLAR',cnt)
    if cnt eq 0 then begin 
      nerr +=1 
      error = [error,'Missing SPDYN.POLAR Element.']
    endif 

    test = where(key_list_lev1 eq 'FREQ',cnt)
    if cnt eq 0 then begin 
      nerr +=1 
      error = [error,'Missing SPDYN.FRED Element.']
    endif else begin 
    	if n_elements((json_hash['SPDYN'])['FREQ']) ne 5 then begin 
	      nerr +=1 
    	  error = [error,'Wrong SPDYN.FREQ Number of elements.']
    	endif 
    endelse

    test = where(key_list_lev1 eq 'LONG',cnt)
    if cnt eq 0 then begin 
      nerr +=1 
      error = [error,'Missing SPDYN.LONG Element.']
    endif else begin 
    	if n_elements((json_hash['SPDYN'])['LONG']) ne 5 then begin 
	      nerr +=1 
    	  error = [error,'Wrong SPDYN.LONG Number of elements.']
    	endif 
    endelse

    test = where(key_list_lev1 eq 'LAT',cnt)
    if cnt eq 0 then begin 
      nerr +=1 
      error = [error,'Missing SPDYN.LAT Element.']
    endif else begin 
    	if n_elements((json_hash['SPDYN'])['LAT']) ne 5 then begin 
	      nerr +=1 
    	  error = [error,'Wrong SPDYN.LAT Number of elements.']
    	endif 
    endelse

    test = where(key_list_lev1 eq 'DRANGE',cnt)
    if cnt eq 0 then begin 
      nerr +=1 
      error = [error,'Missing SPDYN.DRANGE Element.']
    endif else begin 
    	if n_elements((json_hash['SPDYN'])['DRANGE']) ne 2 then begin 
	      nerr +=1 
    	  error = [error,'Wrong SPDYN.DRANGE Number of elements.']
    	endif 
    endelse

    test = where(key_list_lev1 eq 'LGRANGE',cnt)
    if cnt eq 0 then begin 
      nerr +=1 
      error = [error,'Missing SPDYN.LGRANGE Element.']
    endif else begin 
    	if n_elements((json_hash['SPDYN'])['LGRANGE']) ne 2 then begin 
	      nerr +=1 
    	  error = [error,'Wrong SPDYN.LGRANGE Number of elements.']
    	endif 
    endelse

    test = where(key_list_lev1 eq 'LARANGE',cnt)
    if cnt eq 0 then begin 
      nerr +=1 
      error = [error,'Missing SPDYN.LARANGE Element.']
    endif else begin 
    	if n_elements((json_hash['SPDYN'])['LARANGE']) ne 2 then begin 
	      nerr +=1 
    	  error = [error,'Wrong SPDYN.LARANGE Number of elements.']
    	endif 
    endelse

    test = where(key_list_lev1 eq 'LTRANGE',cnt)
    if cnt eq 0 then begin 
      nerr +=1 
      error = [error,'Missing SPDYN.LTRANGE Element.']
    endif else begin 
    	if n_elements((json_hash['SPDYN'])['LTRANGE']) ne 2 then begin 
	      nerr +=1 
    	  error = [error,'Wrong SPDYN.LTRANGE Number of elements.']
    	endif 
    endelse

    test = where(key_list_lev1 eq 'KHZ',cnt)
    if cnt eq 0 then begin 
      nerr +=1 
      error = [error,'Missing SPDYN.KHZ Element.']
    endif  

    test = where(key_list_lev1 eq 'LOG',cnt)
    if cnt eq 0 then begin 
      nerr +=1 
      error = [error,'Missing SPDYN.LOG Element.']
    endif  

    test = where(key_list_lev1 eq 'PDF',cnt)
    if cnt eq 0 then begin 
      nerr +=1 
      error = [error,'Missing SPDYN.PDF Element.']
    endif  

endif else begin
    nerr +=1 
    error = [error,'Missing SPDYN Group.']
endelse

test = where(key_list_lev0 eq 'MOVIE2D',cnt)
if cnt ne 0 then begin 

    key_list_lev1 = json_hash['MOVIE2D'].keys()

    test = where(key_list_lev1 eq 'ON',cnt)
    if cnt eq 0 then begin 
      nerr +=1 
      error = [error,'Missing MOVIE2D.ON Element.']
    endif  

    test = where(key_list_lev1 eq 'SUBCYCLE',cnt)
    if cnt eq 0 then begin 
      nerr +=1 
      error = [error,'Missing MOVIE2D.SUBCYCLE Element.']
    endif  

    test = where(key_list_lev1 eq 'RANGE',cnt)
    if cnt eq 0 then begin 
      nerr +=1 
      error = [error,'Missing MOVIE2D.RANGE Element.']
    endif  
    
endif else begin
    nerr +=1 
    error = [error,'Missing MOVIE2D Group.']
endelse

test = where(key_list_lev0 eq 'MOVIE3D',cnt)
if cnt ne 0 then begin 

    key_list_lev1 = json_hash['MOVIE3D'].keys()

    test = where(key_list_lev1 eq 'ON',cnt)
    if cnt eq 0 then begin 
      nerr +=1 
      error = [error,'Missing MOVIE3D.ON Element.']
    endif  

    test = where(key_list_lev1 eq 'SUBCYCLE',cnt)
    if cnt eq 0 then begin 
      nerr +=1 
      error = [error,'Missing MOVIE3D.SUBCYCLE Element.']
    endif  

    test = where(key_list_lev1 eq 'XRANGE',cnt)
    if cnt eq 0 then begin 
      nerr +=1 
      error = [error,'Missing MOVIE3D.XRANGE Element.']
    endif  
    
    test = where(key_list_lev1 eq 'YRANGE',cnt)
    if cnt eq 0 then begin 
      nerr +=1 
      error = [error,'Missing MOVIE3D.YRANGE Element.']
    endif  

    test = where(key_list_lev1 eq 'ZRANGE',cnt)
    if cnt eq 0 then begin 
      nerr +=1 
      error = [error,'Missing MOVIE3D.ZRANGE Element.']
    endif  
    
    test = where(key_list_lev1 eq 'OBS',cnt)
    if cnt eq 0 then begin 
      nerr +=1 
      error = [error,'Missing MOVIE3D.OBS Element.']
    endif  

    test = where(key_list_lev1 eq 'TRAJ',cnt)
    if cnt eq 0 then begin 
      nerr +=1 
      error = [error,'Missing MOVIE3D.TRAJ Element.']
    endif  
    
endif else begin
    nerr +=1 
    error = [error,'Missing MOVIE3D Group.']
endelse

test = where(key_list_lev0 eq 'BODY',cnt)
if cnt ne 0 then begin 

    nbody = n_elements(json_hash['BODY'])
    
    if nbody eq (json_hash['NUMBER'])['BODY'] then begin 
    
	    for i=0,nbody-1 do begin 
	
		    key_list_lev1 = ((json_hash['BODY'])[i]).keys()

	    	test = where(key_list_lev1 eq 'ON',cnt)
	    	if cnt eq 0 then begin 
	    	  nerr +=1 
	   		  error = [error,'Missing BODY.ON Element.']
		    endif  

	    	test = where(key_list_lev1 eq 'NAME',cnt)
	    	if cnt eq 0 then begin 
	    	  nerr +=1 
	   		  error = [error,'Missing BODY.NAME Element.']
		    endif  

	    	test = where(key_list_lev1 eq 'RADIUS',cnt)
	    	if cnt eq 0 then begin 
	    	  nerr +=1 
	   		  error = [error,'Missing BODY.RADIUS Element.']
		    endif  

	    	test = where(key_list_lev1 eq 'PERIOD',cnt)
	    	if cnt eq 0 then begin 
	    	  nerr +=1 
	   		  error = [error,'Missing BODY.PERIOD Element.']
		    endif  

	    	test = where(key_list_lev1 eq 'ORB_PER',cnt)
	    	if cnt eq 0 then begin 
	    	  nerr +=1 
	   		  error = [error,'Missing BODY.ORB_PER Element.']
		    endif  

	    	test = where(key_list_lev1 eq 'INIT_AX',cnt)
	    	if cnt eq 0 then begin 
	    	  nerr +=1 
	   		  error = [error,'Missing BODY.INIT_AX Element.']
		    endif  

	    	test = where(key_list_lev1 eq 'MAG',cnt)
	    	if cnt eq 0 then begin 
	    	  nerr +=1 
	   		  error = [error,'Missing BODY.MAG Element.']
		    endif  

	    	test = where(key_list_lev1 eq 'MOTION',cnt)
	    	if cnt eq 0 then begin 
	    	  nerr +=1 
	   		  error = [error,'Missing BODY.MOTION Element.']
		    endif  

	    	test = where(key_list_lev1 eq 'PARENT',cnt)
	    	if cnt eq 0 then begin 
	    	  nerr +=1 
	   		  error = [error,'Missing BODY.PARENT Element.']
		    endif  

	    	test = where(key_list_lev1 eq 'SEMI_MAJ',cnt)
	    	if cnt eq 0 then begin 
	    	  nerr +=1 
	   		  error = [error,'Missing BODY.SEMI_MAJ Element.']
		    endif  

	    	test = where(key_list_lev1 eq 'SEMI_MIN',cnt)
	    	if cnt eq 0 then begin 
	    	  nerr +=1 
	   		  error = [error,'Missing BODY.SEMI_MIN Element.']
		    endif  

	    	test = where(key_list_lev1 eq 'DECLINATION',cnt)
	    	if cnt eq 0 then begin 
	    	  nerr +=1 
	   		  error = [error,'Missing BODY.DECLINATION Element.']
		    endif  

	    	test = where(key_list_lev1 eq 'APO_LONG',cnt)
	    	if cnt eq 0 then begin 
	    	  nerr +=1 
	   		  error = [error,'Missing BODY.APO_LONG Element.']
		    endif  

	    	test = where(key_list_lev1 eq 'INCLINATION',cnt)
	    	if cnt eq 0 then begin 
	    	  nerr +=1 
	   		  error = [error,'Missing BODY.INCLINATION Element.']
		    endif  

	    	test = where(key_list_lev1 eq 'PHASE',cnt)
	    	if cnt eq 0 then begin 
	    	  nerr +=1 
	   		  error = [error,'Missing BODY.PHASE Element.']
		    endif  

	    	test = where(key_list_lev1 eq 'DENS',cnt)
	    	if cnt eq 0 then begin 
	    	  nerr +=1 
	   		  error = [error,'Missing BODY.DENS Element.']
		    endif else begin

	  			ndens = n_elements(((json_hash['BODY'])[i])['DENS'])
    
   		 		if ndens eq (json_hash['NUMBER'])['DENSITY'] then begin 
    
	    			for k=0,ndens-1 do begin 
	
		    			key_list_lev2 = ((((json_hash['BODY'])[i])['DENS'])[k]).keys()
		    	
	    				test = where(key_list_lev2 eq 'ON',cnt)
	    				if cnt eq 0 then begin 
	  			  		  nerr +=1 
	   					  error = [error,'Missing BODY.DENS.ON Element.']
			    		endif  

	    				test = where(key_list_lev2 eq 'NAME',cnt)
	    				if cnt eq 0 then begin 
	    				  nerr +=1 
	   					  error = [error,'Missing BODY.DENS.NAME Element.']
		 		  	 	endif  		

	  			  		test = where(key_list_lev2 eq 'TYPE',cnt)
	  	 	 			if cnt eq 0 then begin 
	    				  nerr +=1 
	   					  error = [error,'Missing BODY.DENS.TYPE Element.']
		    			endif  

	    				test = where(key_list_lev2 eq 'RHO0',cnt)
	    				if cnt eq 0 then begin 
	    				  nerr +=1 
	   					  error = [error,'Missing BODY.DENS.RHO0 Element.']
		    			endif  

	    				test = where(key_list_lev2 eq 'SCALE',cnt)
	    				if cnt eq 0 then begin 
	    				  nerr +=1 
	   					  error = [error,'Missing BODY.DENS.SCALE Element.']
		    			endif  

	    				test = where(key_list_lev2 eq 'PERP',cnt)
	    				if cnt eq 0 then begin 
	    				  nerr +=1 
	   					  error = [error,'Missing BODY.DENS.PERP Element.']
		    			endif  

		    		endfor

		    	endif else begin
				  nerr +=1 
				  error = [error,'Inconsistent Number of BODY.DENS Elements.']		    
				endelse
			
			endelse

		endfor
		
	endif else begin 
	  nerr +=1 
	  error = [error,'Inconsistent Number of BODY Elements.']
	endelse  

endif else begin
    nerr +=1 
    error = [error,'Missing BODY Group.']
endelse

test = where(key_list_lev0 eq 'SOURCE',cnt)
if cnt ne 0 then begin 

    nsrc = n_elements(json_hash['SOURCE'])
    
    if nsrc eq (json_hash['NUMBER'])['SOURCE'] then begin 
    
	    for i=0,nsrc-1 do begin 
	
		    key_list_lev1 = ((json_hash['SOURCE'])[i]).keys()

	    	test = where(key_list_lev1 eq 'ON',cnt)
	    	if cnt eq 0 then begin 
	    	  nerr +=1 
	   		  error = [error,'Missing SOURCE.ON Element.']
		    endif  

	    	test = where(key_list_lev1 eq 'NAME',cnt)
	    	if cnt eq 0 then begin 
	    	  nerr +=1 
	   		  error = [error,'Missing SOURCE.NAME Element.']
		    endif  

	    	test = where(key_list_lev1 eq 'PARENT',cnt)
	    	if cnt eq 0 then begin 
	    	  nerr +=1 
	   		  error = [error,'Missing SOURCE.PARENT Element.']
		    endif  

	    	test = where(key_list_lev1 eq 'TYPE',cnt)
	    	if cnt eq 0 then begin 
	    	  nerr +=1 
	   		  error = [error,'Missing SOURCE.TYPE Element.']
		    endif  

	    	test = where(key_list_lev1 eq 'LG_MIN',cnt)
	    	if cnt eq 0 then begin 
	    	  nerr +=1 
	   		  error = [error,'Missing SOURCE.LG_MIN Element.']
		    endif  

	    	test = where(key_list_lev1 eq 'LG_MAX',cnt)
	    	if cnt eq 0 then begin 
	    	  nerr +=1 
	   		  error = [error,'Missing SOURCE.LG_MAX Element.']
		    endif  

	    	test = where(key_list_lev1 eq 'LG_NBR',cnt)
	    	if cnt eq 0 then begin 
	    	  nerr +=1 
	   		  error = [error,'Missing SOURCE.LG_NBR Element.']
		    endif  

	    	test = where(key_list_lev1 eq 'LAT',cnt)
	    	if cnt eq 0 then begin 
	    	  nerr +=1 
	   		  error = [error,'Missing SOURCE.LAT Element.']
		    endif  

	    	test = where(key_list_lev1 eq 'SUB',cnt)
	    	if cnt eq 0 then begin 
	    	  nerr +=1 
	   		  error = [error,'Missing SOURCE.SUB Element.']
		    endif  
		    
	    	test = where(key_list_lev1 eq 'SAT',cnt)
	    	if cnt eq 0 then begin 
	    	  nerr +=1 
	   		  error = [error,'Missing SOURCE.SAT Element.']
		    endif  

	    	test = where(key_list_lev1 eq 'NORTH',cnt)
	    	if cnt eq 0 then begin 
	    	  nerr +=1 
	   		  error = [error,'Missing SOURCE.NORTH Element.']
		    endif  

	    	test = where(key_list_lev1 eq 'SOUTH',cnt)
	    	if cnt eq 0 then begin 
	    	  nerr +=1 
	   		  error = [error,'Missing SOURCE.SOUTH Element.']
		    endif  

	    	test = where(key_list_lev1 eq 'WIDTH',cnt)
	    	if cnt eq 0 then begin 
	    	  nerr +=1 
	   		  error = [error,'Missing SOURCE.WIDTH Element.']
		    endif  

	    	test = where(key_list_lev1 eq 'WIDTH',cnt)
	    	if cnt eq 0 then begin 
	    	  nerr +=1 
	   		  error = [error,'Missing SOURCE.WIDTH Element.']
		    endif  

	    	test = where(key_list_lev1 eq 'CURRENT',cnt)
	    	if cnt eq 0 then begin 
	    	  nerr +=1 
	   		  error = [error,'Missing SOURCE.CURRENT Element.']
		    endif  

	    	test = where(key_list_lev1 eq 'ACCEL',cnt)
	    	if cnt eq 0 then begin 
	    	  nerr +=1 
	   		  error = [error,'Missing SOURCE.ACCEL Element.']
		    endif  

	    	test = where(key_list_lev1 eq 'TEMP',cnt)
	    	if cnt eq 0 then begin 
	    	  nerr +=1 
	   		  error = [error,'Missing SOURCE.TEMP Element.']
		    endif  

	    	test = where(key_list_lev1 eq 'TEMPH',cnt)
	    	if cnt eq 0 then begin 
	    	  nerr +=1 
	   		  error = [error,'Missing SOURCE.TEMPH Element.']
		    endif  
		endfor
		
	endif else begin 
	  nerr +=1 
	  error = [error,'Inconsistent Number of SOURCE Elements.']
	endelse

endif else begin
    nerr +=1 
    error = [error,'Missing SOURCE Group.']
endelse


if nerr ne 0 then error = error[1:*]
return, nerr
end

;************************************************************** BUILD_SERPE_OBJ
PRO init_serpe_structures,time,freq,observer,body,dens,src,spdyn,mov2d,mov3d

; ***** initializing local structures *****
time={TI,mini:0.,maxi:0.,nbr:0l,dt:0.}
freq={FR,mini:0.,maxi:0.,nbr:0l,df:0.,name:'',log:0b,predef:0b}
observer={OB,motion:0b,smaj:0.,smin:0.,decl:0.,alg:0.,incl:0.,phs:0.,predef:0b,name:'',parent:'',start:''}
body={BO,on:0b,name:'',rad:0.,per:0.,orb1:0.,lg0:0.,sat:0b,smaj:0.,smin:0.,decl:0.,alg:0.,incl:0.,phs:0.,parent:'', mfl:'',dens:intarr(4),ipar:0}
dens={DE,on:0b,name:'',type:'',rho0:0.,height:0.,perp:0.}
src={SO,on:0b,name:'',parent:'',sat:'',type:'',loss:0b,width:0.,temp:0.,cold:0.,v:0.,lgmin:0.,lgmax:0.,lgstep:1.,latmin:0.,latmax:0.,latstep:1.,north:0b,south:0b,subcor:0.}
spdyn={SP,intensity:0b,polar:0b,f_t:0b,lg_t:0b,lat_t:0b,f_r:0b,lg_r:0b,lat_r:0b,f_lg:0b,lg_lg:0b,lat_lg:0b,f_lat:0b,lg_lat:0b,lat_lat:0b,f_lt:0b,lg_lt:0b,lat_lt:0b,$
khz:0b,pdf:0b,log:0b,xrange:[0.,0.],lgrange:[0.,0.],larange:[0.,0.],ltrange:[0.,0.],nr:0,dr:0.,nlg:0,dlg:0.,nlat:0,dlat:0.,nlt:0,dlt:0.}
mov2d={M2D,on:0b,sub:0,range:0.}
mov3d={M3D,on:0b,sub:0,xrange:[0.,0.],yrange:[0.,0.],zrange:[0.,0.],obs:0b,traj:0b}

end

;************************************************************** BUILD_SERPE_OBJ
FUNCTION build_serpe_obj,adresse_lib,simulation_name,simulation_out,nbody,ndens,nsrc,time,freq,observer,bd,ds,sc,spdyn,mov2d,mov3d

; ***** number of objects to build *****
nobj=n_elements(bd)-1+n_elements(ds)-1+2*(n_elements(sc)-1)+2+mov2d.on+mov3d.on+1;sacred

; ***** initializing variables *****
TEMPS={TIME,debut:time.mini,fin:time.maxi,step:time.dt,n_step:time.nbr,time:0.,t0:0.,istep:0}
FREQUE={FREQ,fmin:freq.mini,fmax:freq.maxi,n_freq:freq.nbr,step:freq.df,file:freq.name,log:freq.log,freq_tab:PTR_NEW(/ALLOCATE_HEAP)}
parameters={PARAMETERS,time:temps,freq:freque,name:simulation_name,objects:PTRARR(nobj,/ALLOCATE_HEAP),out:simulation_out}


; ***** preparing DENSITY parameters *****
n=0
for i=0,n_elements(ds)-2 do begin
	tp=(ds[i+1]).type
	case tp of
		'Stellar': typ='stellar'
		'Ionospheric': typ='ionospheric'
		'Torus': typ='torus'
		'Disk': typ='disk'
	endcase

	(parameters.objects[n])=PTR_NEW({DENSITY,name:(ds[i+1]).name,type:typ,rho0:(ds[i+1]).rho0,height:(ds[i+1]).height,perp:(ds[i+1]).perp,it:[''],cb:[''],fz:['']})
	n=n+1
endfor

; ***** preparing BODY parameters *****
rank_bodies,bd

start_bodies=n

for i=0,n_elements(bd)-2 do begin
	(parameters.objects[n])=PTR_NEW({BODY,name:(bd[i+1]).name,radius:(bd[i+1]).rad,period:(bd[i+1]).per,orb_1r:(bd[i+1]).orb1,lg0:(bd[i+1]).lg0,motion:(bd[i+1]).sat,$
				parent:PTR_NEW(/ALLOCATE_HEAP),initial_phase:(bd[i+1]).phs,semi_major_axis:(bd[i+1]).smaj,semi_minor_axis:(bd[i+1]).smin,apoapsis_declination:(bd[i+1]).decl,$
				apoapsis_longitude:(bd[i+1]).alg,orbit_inclination:(bd[i+1]).incl,traj_file:'',density:PTR_NEW(/ALLOCATE_HEAP),$
				lg:PTR_NEW(/ALLOCATE_HEAP),lct:PTR_NEW(/ALLOCATE_HEAP),trajectory_xyz:PTR_NEW(/ALLOCATE_HEAP),trajectory_rtp:PTR_NEW(/ALLOCATE_HEAP),$
				it:['init_body','init_orb'],cb:['cb_body'],fz:[''],rot:fltarr(3,3),body_rank:0})
	if (bd[i+1]).ipar ne 0 then (*((parameters.objects)[n])).parent=(parameters.objects[n-i+(bd[i+1]).ipar-1])
	w=where(((bd[i+1]).dens) ne 0)
	if w[0] eq -1 then ndd=0 else begin
		ndd=n_elements(w)
		(*((parameters.objects[n]))).density=PTR_NEW(PTRARR(ndd,/ALLOCATE_HEAP))
		n0=0
		for j=0,ndens-1 do if ((bd[i+1]).dens)[j] ne 0 then begin
			(*((*((parameters.objects[n]))).density))[n0]=(parameters.objects[((bd[i+1]).dens)[j]-1])
			n0=n0+1
		endif
	endelse
	n=n+1
endfor

; ***** preparing OBSERVER parameters *****

nm1=""
if (observer.name ne "") then begin
	nm1=file_name
	STRREPLACE,nm1,'on-going','tmp'
	nm1=strsplit(nm1,".",/EXTRACT)
	nm1=nm1[0]+'.eph'
endif

(parameters.objects[n])=PTR_NEW({OBSERVER,name:observer.name,motion:observer.motion,parent:PTR_NEW(/ALLOCATE_HEAP),initial_phase:observer.phs,semi_major_axis:observer.smaj,$
semi_minor_axis:observer.smin,apoapsis_declination:observer.decl,apoapsis_longitude:observer.alg,orbit_inclination:observer.incl,traj_file:nm1,$
				trajectory_xyz:PTR_NEW(/ALLOCATE_HEAP),trajectory_rtp:PTR_NEW(/ALLOCATE_HEAP),$
				lg:PTR_NEW(/ALLOCATE_HEAP),it:['init_orb'],cb:['cb_orb'],fz:['']})
x=bd[*].name
wpar=where(x eq (observer.parent))

if wpar[0] gt 0 then begin
	wpar=wpar[0]-1+start_bodies
	(*parameters.objects[n]).parent=(parameters.objects[wpar])
endif

if (wpar[0] eq -1) then begin
	print,'An observer has no parent.'
	return,parameters
endif
help,*(parameters.objects[n]),/str
n=n+1


; ***** preparing SOURCE parameters *****

for i=0,n_elements(sc)-2 do begin
	if ((sc[i+1]).type eq 'attached to a satellite') then sat=1b else sat=0b
	nm=(sc[i+1]).name+'_ft'
	(parameters.objects[n])=PTR_NEW({FEATURE,name:nm,parent:PTR_NEW(/ALLOCATE_HEAP),folder:'',north:(sc[i+1]).north,south:(sc[i+1]).south,$
				loffset:0.,l_min:(sc[i+1]).latmin,l_max:(sc[i+1]).latmax,nlat:1,sat:sat,lct:0b,subcor:(sc[i+1]).subcor,oval_lat0:0.,aurora_alt:0.,file_lat:'',file_lg:'',$
				b_n:PTR_NEW(/ALLOCATE_HEAP),x_n:PTR_NEW(/ALLOCATE_HEAP),bz_n:PTR_NEW(/ALLOCATE_HEAP),gb_n:PTR_NEW(/ALLOCATE_HEAP),$
				b_s:PTR_NEW(/ALLOCATE_HEAP),x_s:PTR_NEW(/ALLOCATE_HEAP),bz_s:PTR_NEW(/ALLOCATE_HEAP),gb_s:PTR_NEW(/ALLOCATE_HEAP),$
				fmax:PTR_NEW(/ALLOCATE_HEAP),feq:PTR_NEW(/ALLOCATE_HEAP),grad_b_eq:PTR_NEW(/ALLOCATE_HEAP),grad_b_in:PTR_NEW(/ALLOCATE_HEAP),$
				dens_n:PTR_NEW(/ALLOCATE_HEAP),dens_s:PTR_NEW(/ALLOCATE_HEAP),rot:fltarr(3,3),lg:0.,pos_xyz:fltarr(3),$
				it:['init_field'],cb:['cb_rot_field'],fz:[''],latitude:fltarr(360),longitude:findgen(360)})
	x=bd[*].name
	wpar=where(x eq (sc[i+1]).parent)
	if wpar[0] gt 0 then begin
		mfl=bd[wpar[0]].mfl
		(*((parameters.objects[n]))).name=mfl+'__'+(*((parameters.objects[n]))).name
		wpar=wpar[0]-1+start_bodies
		parent=(parameters.objects[wpar])
	endif
	if sat and (wpar[0] eq -1) then begin
		print,'A source attached to a satellite has no parent.'
		return,parameters
	endif

	x=bd[*].name
	wsat=where(x eq (sc[i+1]).sat)
	if wsat[0] gt 0 then begin
		wsat=wsat[0]-1+start_bodies
		satel=(parameters.objects[wsat])
	endif
	if sat and (wsat[0] eq -1) then begin
		print,'A source attached to a satellite is actually attached to a fixed body.'
		return,parameters
	endif


	if sat then (*((parameters.objects[n]))).parent=satel else (*((parameters.objects[n]))).parent=parent
	if sat then begin
		a=(*satel).semi_major_axis
		b=(*satel).semi_minor_axis
		c=sqrt(a^2-b^2)
		b=(fix(a-c))>2
		a=(fix(a+c+1))<50
		(*((parameters.objects[n]))).l_min=b
		(*((parameters.objects[n]))).l_max=a
		(*((parameters.objects[n]))).nlat=(a-b+1)
	endif

	case mfl of 
		'O6+Connerney CS':fld='O6'
		'VIP4+Connerney CS' :fld='VIP4'
		'VIT4+Connerney CS' :fld='VIT4'
		'VIPAL+Connerney CS' : fld='VIPAL'
		'O6 Connerney CS':fld='O6'
		'VIP4 Connerney CS' :fld='VIP4'
		'VIT4 Connerney CS' :fld='VIT4'
		'VIPAL Connerney CS' : fld='VIPAL'
		'SPV': fld='SPV'
		'Z3': fld='Z3'
		else: fld=''
	endcase

	if strmid(mfl,0,6) eq 'Dipole' then fld=mfl else fld=adresse_lib+'/mfl/'+fld
	if ((sc[i+1]).type eq 'fixed in latitude') then (*((parameters.objects[n]))).folder=fld+'_lat' else (*((parameters.objects[n]))).folder=fld+'_lsh'


	n=n+1
	(parameters.objects[n])=PTR_NEW({SOURCE,name:(sc[i+1]).name,parent:PTR_NEW(/ALLOCATE_HEAP),loss:(sc[i+1]).loss,ring:0b,cavity:(1b-(sc[i+1]).loss),rampe:0b,constant:0.,asymp:0.,width:(sc[i+1]).width,$
				temp:(sc[i+1]).temp,cold:(sc[i+1]).cold,vmin:(sc[i+1]).v,vmax:(sc[i+1]).v,vstep:1.,lgmin:(sc[i+1]).lgmin,lgmax:(sc[i+1]).lgmax,$
				lgstep:(sc[i+1]).lgstep,latmin:0.,latmax:0.,latstep:1.,$
				lgtov:0.,north:(sc[i+1]).north,south:(sc[i+1]).south,grad_eq:0,grad_in:0,shield:1b,$
				nsrc:1,spdyn:PTR_NEW(/ALLOCATE_HEAP),v:PTR_NEW(/ALLOCATE_HEAP),$
				lat:PTR_NEW(/ALLOCATE_HEAP),lg:PTR_NEW(/ALLOCATE_HEAP),x:PTR_NEW(/ALLOCATE_HEAP),it:['init_src'],cb:['cb_src'],fz:['']})
	(*((parameters.objects[n]))).parent=(parameters.objects[n-1])

	n=n+1

endfor

; ***** preparing SPDYN parameters *****

	(parameters.objects[n])=PTR_NEW({SPDYN,name:'',src_each:0b,src_pole:0b,dif_each:0b,pol:spdyn.polar,pdf:spdyn.pdf,log:spdyn.log,khz:spdyn.khz,$
				f_t:spdyn.f_t,lg_t:spdyn.lg_t,lat_t:spdyn.lat_t,f_r:spdyn.f_r,lg_r:spdyn.lg_r,lat_r:spdyn.lat_r,f_lg:spdyn.f_lg,lg_lg:spdyn.lg_lg,$
				lat_lg:spdyn.lat_lg,f_lat:spdyn.f_lat,lg_lat:spdyn.lg_lat,lat_lat:spdyn.lat_lat,f_lt:spdyn.f_lt,lg_lt:spdyn.lg_lt,lat_lt:spdyn.lat_lt,$
				lgmin:spdyn.lgrange[0],nlg:spdyn.nlg,lgstp:spdyn.dlg,latmin:spdyn.larange[0],nlat:spdyn.nlat,latstp:spdyn.dlat,$
				ltmin:spdyn.ltrange[0],nlt:spdyn.nlt,ltstp:spdyn.dlt,rmin:spdyn.xrange[0],nr:spdyn.nr,rstp:spdyn.dr,$
				it:['init_spdyn'],cb:['cb_spdyn'],fz:['fz_spdyn'],nspd:0,out:PTR_NEW(/ALLOCATE_HEAP),f:0b,lg:0b,lat:0b,lct:0b,src_all:0b})
	n=n+1

; ***** preparing MOVIE2D parameters *****

if mov2d.on then begin
	(parameters.objects[n])=PTR_NEW({MOVIE2D,name:'movie_2d',sub:mov2d.sub,obs:0b,mfl:0b,traj:0b,xr:[-mov2d.range,mov2d.range],yr:[-mov2d.range,mov2d.range],zr:[-mov2d.range,mov2d.range],it:[''],cb:['cb_movie2d'],fz:['fz_movie2d']})
	n=n+1
endif

; ***** preparing MOVIE3D parameters *****

if mov3d.on then begin
	(parameters.objects[n])=PTR_NEW({MOVIE3D,name:'movie_3d',sub:mov3d.sub,obs:mov3d.obs,mfl:1b,traj:mov3d.traj,xr:mov3d.xrange,yr:mov3d.yrange,zr:mov3d.zrange,it:[''],cb:['cb_movie'],fz:['fz_movie']})
	n=n+1
endif

; ***** preparing SACRED parameters *****

CALDAT,SYSTIME(/JULIAN), Mo, D, Y, H, Mi, S
if (STRLEN(observer.start) eq 10) then begin
	Y=2000+fix(strmid(observer.start,0,2))
	Mo=fix(strmid(observer.start,2,2))
	D=fix(strmid(observer.start,4,2))
	H=fix(strmid(observer.start,6,2))
	Mi=fix(strmid(observer.start,8,2))
	S=0
endif
(parameters.objects[n])=PTR_NEW({SACRED,date:[Y,Mo,D,H,Mi,S],it:['init_sacred'],cb:['cb_sacred'],fz:['fz_sacred']})

; ***** returning parameters *****

return,parameters
end

;************************************************************** READ_SAVE_JSON
pro read_save_json,adresse_lib,file_name,parameters
;************************************************************** 

; ***** initializing local variables *****
init_serpe_structures,time,freq,observer,body,dens,src,spdyn,mov2d,mov3d

; ***** loading JSON input *****
serpe_save = json_parse(file_name)

; ***** checking JSON input *****
check = check_save_json(serpe_save,error=error_messages)
if check ne 0 then begin
	message,/info,'Something wrong happened with JSON file... Aborting.'
	print,error_messages
	stop
endif

; ***** loading SIMU section *****
simulation_name = (serpe_save['SIMU'])['NAME']
simulation_out = (serpe_save['SIMU'])['OUT']

; ***** loading NUMBER section *****
nbody = fix((serpe_save['NUMBER'])['BODY'])
ndens = fix((serpe_save['NUMBER'])['DENSITY'])
nsrc = fix((serpe_save['NUMBER'])['SOURCE'])

; ***** loading TIME section *****
time.mini = float((serpe_save['TIME'])['MIN'])
time.maxi = float((serpe_save['TIME'])['MAX'])
time.nbr = long((serpe_save['TIME'])['NBR'])
time.dt=(time.maxi-time.mini)/float(time.nbr)

; ***** loading FREQ section *****
freq.log=0b
freq.predef=0b
case (serpe_save['FREQUENCY'])['TYPE'] of
	'Pre-Defined' : freq.predef=1b 
    'Log' : freq.log=1b
    'Linear': 
endcase
freq.mini = float((serpe_save['FREQUENCY'])['MIN'])
freq.maxi = float((serpe_save['FREQUENCY'])['MAX'])
freq.nbr = long((serpe_save['FREQUENCY'])['NBR'])
freq.df=(freq.maxi-freq.mini)/float(freq.nbr)
freq.name=''
if freq.predef then if (serpe_save['FREQUENCY'])['SC'] ne "" then begin 
	freq.name=(adresse_lib+'freq/'+(serpe_save['FREQUENCY'])['SC']) 
endif

; ***** loading OBSERVER section *****
observer.motion=0b
observer.predef=0b
case (serpe_save['OBSERVER'])['TYPE'] of
	'Pre-Defined' : observer.predef=1b 
    'Orbiter' : observer.motion=1b
    'Fixed': 
endcase

if ((observer.motion+observer.predef) eq 0b) then begin
	observer.smaj=float((serpe_save['OBSERVER'])['FIXE_DIST'])
    observer.smin=float((serpe_save['OBSERVER'])['FIXE_DIST'])
	observer.phs=-float((serpe_save['OBSERVER'])['FIXE_SUBL'])
	observer.decl=float((serpe_save['OBSERVER'])['FIXE_DECL'])
endif

observer.parent=(serpe_save['OBSERVER'])['PARENT']
observer.name=(serpe_save['OBSERVER'])['SC']
observer.start=(serpe_save['OBSERVER'])['SCTIME']

if observer.motion then begin
	observer.smaj=(serpe_save['OBSERVER'])['SEMI_MAJ']
	observer.smin=(serpe_save['OBSERVER'])['SEMI_MIN']
	observer.alg=(serpe_save['OBSERVER'])['SUBL']
	observer.decl=(serpe_save['OBSERVER'])['DECL']
	observer.phs=(serpe_save['OBSERVER'])['PHASE']
	observer.incl=(serpe_save['OBSERVER'])['INCL']
endif

; ***** loading SPDYN section *****
spdyn.intensity=(serpe_save['SPDYN'])['INTENSITY']
spdyn.polar=(serpe_save['SPDYN'])['POLAR']

spdyn.f_t=((serpe_save['SPDYN'])['FREQ'])[0]
spdyn.f_r=((serpe_save['SPDYN'])['FREQ'])[1]
spdyn.f_lg=((serpe_save['SPDYN'])['FREQ'])[2]
spdyn.f_lat=((serpe_save['SPDYN'])['FREQ'])[3]
spdyn.f_lt=((serpe_save['SPDYN'])['FREQ'])[4]

spdyn.lg_t=((serpe_save['SPDYN'])['LONG'])[0]
spdyn.lg_r=((serpe_save['SPDYN'])['LONG'])[1]
spdyn.lg_lg=((serpe_save['SPDYN'])['LONG'])[2]
spdyn.lg_lat=((serpe_save['SPDYN'])['LONG'])[3]
spdyn.lg_lt=((serpe_save['SPDYN'])['LONG'])[4]

spdyn.lat_t=((serpe_save['SPDYN'])['LAT'])[0]
spdyn.lat_r=((serpe_save['SPDYN'])['LAT'])[1]
spdyn.lat_lg=((serpe_save['SPDYN'])['LAT'])[2]
spdyn.lat_lat=((serpe_save['SPDYN'])['LAT'])[3]
spdyn.lat_lt=((serpe_save['SPDYN'])['LAT'])[4]

spdyn.xrange[0]=float(((serpe_save['SPDYN'])['DRANGE'])[0])
spdyn.xrange[1]=float(((serpe_save['SPDYN'])['DRANGE'])[1])
if (spdyn.xrange[0] ne spdyn.xrange[1]) then begin 
	spdyn.nr=101
	spdyn.dr=(spdyn.xrange[1]-spdyn.xrange[0])*0.01
endif else begin
	spdyn.nr=1
	spdyn.dr=1.
endelse

spdyn.lgrange[0]=float(((serpe_save['SPDYN'])['LGRANGE'])[0])
spdyn.lgrange[1]=float(((serpe_save['SPDYN'])['LGRANGE'])[1])
if (spdyn.lgrange[0] ne spdyn.lgrange[1]) then begin 
	spdyn.nlg=101
	spdyn.dlg=(spdyn.lgrange[1]-spdyn.lgrange[0])*0.01
endif else begin
	spdyn.nlg=1
	spdyn.dlg=1.
endelse

spdyn.larange[0]=float(((serpe_save['SPDYN'])['LARANGE'])[0])
spdyn.larange[1]=float(((serpe_save['SPDYN'])['LARANGE'])[1])
if (spdyn.larange[0] ne spdyn.larange[1]) then begin 
	spdyn.nlat=101
	spdyn.dlat=(spdyn.larange[1]-spdyn.larange[0])*0.01
endif else begin
	spdyn.nlat=1
	spdyn.dlat=1.
endelse

spdyn.ltrange[0]=float(((serpe_save['SPDYN'])['LTRANGE'])[0])
spdyn.ltrange[1]=float(((serpe_save['SPDYN'])['LTRANGE'])[1])
if (spdyn.ltrange[0] ne spdyn.ltrange[1]) then begin 
	spdyn.nlt=101
	spdyn.dlt=(spdyn.ltrange[1]-spdyn.ltrange[0])*0.01
endif else begin
	spdyn.nlt=1
	spdyn.dlt=1.
endelse

spdyn.khz=(serpe_save['SPDYN'])['KHZ']
spdyn.log=(serpe_save['SPDYN'])['LOG']
spdyn.pdf=(serpe_save['SPDYN'])['PDF']

; ***** loading MOVIE2D section *****
mov2d.on=(serpe_save['MOVIE2D'])['ON']
mov2d.sub=(serpe_save['MOVIE2D'])['SUBCYCLE']>1
mov2d.range=(serpe_save['MOVIE2D'])['RANGE']

; ***** loading MOVIE3D section *****
mov3d.on=(serpe_save['MOVIE3D'])['ON']
mov3d.sub=(serpe_save['MOVIE3D'])['SUBCYCLE']>1
mov3d.xrange[0]=((serpe_save['MOVIE3D'])['XRANGE'])[0]
mov3d.xrange[1]=((serpe_save['MOVIE3D'])['XRANGE'])[1]
mov3d.yrange[0]=((serpe_save['MOVIE3D'])['YRANGE'])[0]
mov3d.yrange[1]=((serpe_save['MOVIE3D'])['YRANGE'])[1]
mov3d.zrange[0]=((serpe_save['MOVIE3D'])['ZRANGE'])[0]
mov3d.zrange[1]=((serpe_save['MOVIE3D'])['ZRANGE'])[1]
mov3d.obs=(serpe_save['MOVIE3D'])['OBS']
mov3d.traj=(serpe_save['MOVIE3D'])['TRAJ']

; ***** loading BODY section *****
bd=[body]
n=0

ds=[dens]
nd=0

for i=0,nbody-1 do begin
	on=((serpe_save['BODY'])[i])['ON']
	if on then begin
		n=n+1
		bd=[bd,body]
		bd[n].name=((serpe_save['BODY'])[i])['NAME']
		bd[n].rad=((serpe_save['BODY'])[i])['RADIUS']
		bd[n].per=((serpe_save['BODY'])[i])['PERIOD']
		bd[n].orb1=((serpe_save['BODY'])[i])['ORB_PER']
		bd[n].lg0=((serpe_save['BODY'])[i])['INIT_AX']
		bd[n].mfl=((serpe_save['BODY'])[i])['MAG']
		bd[n].sat=((serpe_save['BODY'])[i])['MOTION']
		bd[n].parent=((serpe_save['BODY'])[i])['PARENT']
		bd[n].smaj=((serpe_save['BODY'])[i])['SEMI_MAJ']
		bd[n].smin=((serpe_save['BODY'])[i])['SEMI_MIN']
		bd[n].decl=((serpe_save['BODY'])[i])['DECLINATION']
		bd[n].alg=((serpe_save['BODY'])[i])['APO_LONG']
		bd[n].incl=((serpe_save['BODY'])[i])['INCLINATION']
		bd[n].phs=((serpe_save['BODY'])[i])['PHASE']
	endif

; ***** loading DENS section *****

	for l=0,ndens-1 do begin
		on=((((serpe_save['BODY'])[i])['DENS'])[l])['ON']
		if on then begin
			nd=nd+1
			ds=[ds,dens]
			bd[n].dens[i]=nd
			ds[nd].name=((((serpe_save['BODY'])[i])['DENS'])[l])['NAME']
			ds[nd].type=((((serpe_save['BODY'])[i])['DENS'])[l])['TYPE']
			ds[nd].rho0=((((serpe_save['BODY'])[i])['DENS'])[l])['RHO0']
			ds[nd].height=((((serpe_save['BODY'])[i])['DENS'])[l])['SCALE']
			ds[nd].perp=((((serpe_save['BODY'])[i])['DENS'])[l])['PERP']
		endif
	endfor
endfor

; ***** loading SOURCE section *****
sc=[src]
n=0

for i=0,nsrc-1 do begin
	on=((serpe_save['SOURCE'])[i])['ON']
	if on then begin
		n=n+1
		sc=[sc,src]
		sc[n].name=((serpe_save['SOURCE'])[i])['NAME']
		sc[n].parent=((serpe_save['SOURCE'])[i])['PARENT']
		sc[n].type=((serpe_save['SOURCE'])[i])['TYPE']
		sc[n].lgmin=((serpe_save['SOURCE'])[i])['LG_MIN']
		sc[n].lgmax=((serpe_save['SOURCE'])[i])['LG_MAX']
		sc[n].lgstep=(sc[n].lgmax-sc[n].lgmin)/float((fix(((serpe_save['SOURCE'])[i])['LG_NBR'])-1)>1)
		if sc[n].lgstep eq 0 then sc[n].lgstep=1
		sc[n].latmin=((serpe_save['SOURCE'])[i])['LAT']
		sc[n].latmax=((serpe_save['SOURCE'])[i])['LAT']
		sc[n].subcor=((serpe_save['SOURCE'])[i])['SUB']
		sc[n].sat=((serpe_save['SOURCE'])[i])['SAT']
		sc[n].north=((serpe_save['SOURCE'])[i])['NORTH']
		sc[n].south=((serpe_save['SOURCE'])[i])['SOUTH']
		sc[n].width=((serpe_save['SOURCE'])[i])['WIDTH']
		sc[n].loss=(((serpe_save['SOURCE'])[i])['CURRENT'] eq 'Transient (Aflvénic)')
		sc[n].v=sqrt(float(((serpe_save['SOURCE'])[i])['ACCEL'])/255.5)
		sc[n].cold=float(((serpe_save['SOURCE'])[i])['TEMP'])/255.5
		sc[n].temp=float(((serpe_save['SOURCE'])[i])['TEMPH'])/255.5
	endif
endfor

; ***** building SERPE objects *****
parameters = build_serpe_obj(adresse_lib,simulation_name,simulation_out,nbody,ndens,nsrc,time,freq,observer,bd,ds,sc,spdyn,mov2d,mov3d)

end

;************************************************************** READ_SAVE
pro read_save,adresse_lib,file_name,parameters

; ***** initializing local variables *****
init_serpe_structures,time,freq,observer,body,dens,src,spdyn,mov2d,mov3d

lecture=''
openr,unit,file_name,/get_lun
readf,unit,lecture;<SIMU>
if lecture ne '<SIMU>' then begin
	print,'File is not a valid SERPE save file (<SIMU>)'
	return
endif
readf,unit,lecture;<NAME=...>
if strmid(lecture,0,6) ne '<NAME=' then begin
	print,strmid(lecture,0,5)
	print,'File is not a valid SERPE save file (<NAME>)'
	return
endif
lecture=(STRSPLIT(((STRSPLIT(lecture,'=',/EXTRACT))[1]),'>',/EXTRACT))[0]
simulation_name=lecture
readf,unit,lecture;<OUT=...>
if strmid(lecture,0,5) ne '<OUT=' then begin
	print,'File is not a valid SERPE save file (<OUT>)'
	return
endif
lecture=(STRSPLIT(((STRSPLIT(lecture,'=',/EXTRACT))[1]),'>',/EXTRACT))[0]
simulation_out=lecture
readf,unit,lecture;</SIMU>
if lecture ne '</SIMU>' then begin
	print,'File is not a valid SERPE save file (</SIMU>)'
	return
endif
readf,unit,lecture;<NUMBER>
if lecture ne '<NUMBER>' then begin
	print,'File is not a valid SERPE save file (<NUMBER>)'
	return
endif
readf,unit,lecture;<BODY=...>
if strmid(lecture,0,6) ne '<BODY=' then begin
	print,'File is not a valid SERPE save file (<BODY>)'
	return
endif
lecture=(STRSPLIT(((STRSPLIT(lecture,'=',/EXTRACT))[1]),'>',/EXTRACT))[0]
nbody=fix(lecture)
readf,unit,lecture;<DENS=...>
if strmid(lecture,0,9) ne '<DENSITY=' then begin
	print,'File is not a valid SERPE save file (<DENSITY>)'
	return
endif
lecture=(STRSPLIT(((STRSPLIT(lecture,'=',/EXTRACT))[1]),'>',/EXTRACT))[0]
ndens=fix(lecture)
readf,unit,lecture;<SOURCE=...>
if strmid(lecture,0,8) ne '<SOURCE=' then begin
	print,'File is not a valid SERPE save file (<SOURCE>)'
	return
endif
lecture=(STRSPLIT(((STRSPLIT(lecture,'=',/EXTRACT))[1]),'>',/EXTRACT))[0]
nsrc=fix(lecture)
readf,unit,lecture;</NUMBER>
if lecture ne '</NUMBER>' then begin
	print,'File is not a valid SERPE save file (</NUMBER>)'
	return
endif
readf,unit,lecture;<TIME>
if lecture ne '<TIME>' then begin
	print,'File is not a valid SERPE save file (<TIME>)'
	return
endif
readf,unit,lecture;<MIN=...>
lecture=(STRSPLIT(((STRSPLIT(lecture,'=',/EXTRACT))[1]),'>',/EXTRACT))[0]
time.mini=float(lecture)
readf,unit,lecture;<MAX=...>
lecture=(STRSPLIT(((STRSPLIT(lecture,'=',/EXTRACT))[1]),'>',/EXTRACT))[0]
time.maxi=float(lecture)
readf,unit,lecture;<NBR=...>
lecture=(STRSPLIT(((STRSPLIT(lecture,'=',/EXTRACT))[1]),'>',/EXTRACT))[0]
time.nbr=fix(lecture)
time.dt=(time.maxi-time.mini)/float(time.nbr)
readf,unit,lecture;</TIME>
if lecture ne '</TIME>' then begin
	print,'File is not a valid SERPE save file (</TIME>)'
	return
endif
readf,unit,lecture;<FREQUENCY>
if lecture ne '<FREQUENCY>' then begin
	print,'File is not a valid SERPE save file (<FREQUENCY>)'
	return
endif
readf,unit,lecture;<TYPE=...>
lecture=(STRSPLIT(((STRSPLIT(lecture,'=',/EXTRACT))[1]),'>',/EXTRACT))[0]
if lecture eq 'Linear' then begin
freq.log=0b & freq.predef=0b
endif
if lecture eq 'Log' then begin
freq.log=1b & freq.predef=0b
endif
if lecture eq 'Pre-Defined' then begin
freq.log=0b & freq.predef=1b
endif
readf,unit,lecture;<MIN=...>
lecture=(STRSPLIT(((STRSPLIT(lecture,'=',/EXTRACT))[1]),'>',/EXTRACT))[0]
freq.mini=float(lecture)
readf,unit,lecture;<MAX=...>
lecture=(STRSPLIT(((STRSPLIT(lecture,'=',/EXTRACT))[1]),'>',/EXTRACT))[0]
freq.maxi=float(lecture)
readf,unit,lecture;<NBR=...>
lecture=(STRSPLIT(((STRSPLIT(lecture,'=',/EXTRACT))[1]),'>',/EXTRACT))[0]
freq.nbr=fix(lecture)
freq.df=(time.maxi-time.mini)/float(time.nbr)
readf,unit,lecture;<SC=...>
lecture=(STRSPLIT(((STRSPLIT(lecture,'=',/EXTRACT))[1]),'>',/EXTRACT))[0]
if freq.predef then freq.name=(adresse_lib+'freq/'+lecture) else freq.name=''
readf,unit,lecture;</FREQUENCY>
if lecture ne '</FREQUENCY>' then begin
	print,'File is not a valid SERPE save file (</FREQUENCY>)'
	return
endif
readf,unit,lecture;<OBSERVER>
if lecture ne '<OBSERVER>' then begin
	print,'File is not a valid SERPE save file (<OBSERVER>)'
	return
endif
readf,unit,lecture;<TYPE=...>
lecture=(STRSPLIT(((STRSPLIT(lecture,'=',/EXTRACT))[1]),'>',/EXTRACT))[0]
if lecture eq 'Fixed' then begin
observer.motion=0b & observer.predef=0b
endif
if lecture eq 'Orbiter' then begin
observer.motion=1b & observer.predef=0b
endif
if lecture eq 'Pre-Defined' then begin
observer.motion=0b & observer.predef=1b
endif
readf,unit,lecture;<FIXE_DIST=...>
lecture=(STRSPLIT(((STRSPLIT(lecture,'=',/EXTRACT))[1]),'>',/EXTRACT))[0]
if ((observer.motion+observer.predef) eq 0b) then begin
observer.smaj=float(lecture)
observer.smin=float(lecture)
endif
readf,unit,lecture;<FIXE_SUBL=...>
lecture=(STRSPLIT(((STRSPLIT(lecture,'=',/EXTRACT))[1]),'>',/EXTRACT))[0]
if ((observer.motion+observer.predef) eq 0b) then observer.phs=-float(lecture)
readf,unit,lecture;<FIXE_DECL=...>
lecture=(STRSPLIT(((STRSPLIT(lecture,'=',/EXTRACT))[1]),'>',/EXTRACT))[0]
if ((observer.motion+observer.predef) eq 0b) then observer.decl=float(lecture)
readf,unit,lecture;<PARENT=...>
lecture=(STRSPLIT(((STRSPLIT(lecture,'=',/EXTRACT))[1]),'>',/EXTRACT))[0]
observer.parent=lecture
readf,unit,lecture;<SC=...>
lecture=(STRSPLIT(((STRSPLIT(lecture,'=',/EXTRACT))[1]),'>',/EXTRACT))[0]
observer.name=lecture
readf,unit,lecture;<SCTIME=...>
lecture=(STRSPLIT(((STRSPLIT(lecture,'=',/EXTRACT))[1]),'>',/EXTRACT))[0]
observer.start=lecture
readf,unit,lecture;<SEMI_MAJ=...>
lecture=(STRSPLIT(((STRSPLIT(lecture,'=',/EXTRACT))[1]),'>',/EXTRACT))[0]
if observer.motion then observer.smaj=float(lecture)
readf,unit,lecture;<SEMI_MIN=...>
lecture=(STRSPLIT(((STRSPLIT(lecture,'=',/EXTRACT))[1]),'>',/EXTRACT))[0]
if observer.motion then observer.smin=float(lecture)
readf,unit,lecture;<SUBL=...>
lecture=(STRSPLIT(((STRSPLIT(lecture,'=',/EXTRACT))[1]),'>',/EXTRACT))[0]
if observer.motion then observer.alg=float(lecture)
readf,unit,lecture;<DECL=...>
lecture=(STRSPLIT(((STRSPLIT(lecture,'=',/EXTRACT))[1]),'>',/EXTRACT))[0]
if observer.motion then observer.decl=float(lecture)
readf,unit,lecture;<PHASE=...>
lecture=(STRSPLIT(((STRSPLIT(lecture,'=',/EXTRACT))[1]),'>',/EXTRACT))[0]
if observer.motion then observer.phs=float(lecture)
readf,unit,lecture;<INCL=...>
lecture=(STRSPLIT(((STRSPLIT(lecture,'=',/EXTRACT))[1]),'>',/EXTRACT))[0]
if observer.motion then observer.incl=float(lecture)
readf,unit,lecture;</OBSERVER>
if lecture ne '</OBSERVER>' then begin
	print,'File is not a valid SERPE save file (</OBSERVER>)'
	return
endif
readf,unit,lecture;<SPDYN>
if lecture ne '<SPDYN>' then begin
	print,'File is not a valid SERPE save file (<SPDYN>)'
	return
endif
readf,unit,lecture;<INTENSITY=...>
lecture=(STRSPLIT(((STRSPLIT(lecture,'=',/EXTRACT))[1]),'>',/EXTRACT))[0]
spdyn.intensity=(lecture eq 'true')
readf,unit,lecture;<POLAR=...>
lecture=(STRSPLIT(((STRSPLIT(lecture,'=',/EXTRACT))[1]),'>',/EXTRACT))[0]
spdyn.polar=(lecture eq 'true')
readf,unit,lecture;<FREQ=...>
lecture=STRSPLIT(((STRSPLIT(((STRSPLIT(lecture,'=',/EXTRACT))[1]),'>',/EXTRACT))[0]),':',/EXTRACT)
spdyn.f_t=(lecture[0] eq 'true')
spdyn.f_r=(lecture[1] eq 'true')
spdyn.f_lg=(lecture[2] eq 'true')
spdyn.f_lat=(lecture[3] eq 'true')
spdyn.f_lt=(lecture[4] eq 'true')
lecture=''
readf,unit,lecture;<LONG=...>
lecture=STRSPLIT(((STRSPLIT(((STRSPLIT(lecture,'=',/EXTRACT))[1]),'>',/EXTRACT))[0]),':',/EXTRACT)
spdyn.lg_t=(lecture[0] eq 'true')
spdyn.lg_r=(lecture[1] eq 'true')
spdyn.lg_lg=(lecture[2] eq 'true')
spdyn.lg_lat=(lecture[3] eq 'true')
spdyn.lg_lt=(lecture[4] eq 'true')
lecture=''
readf,unit,lecture;<LAT=...>
lecture=STRSPLIT(((STRSPLIT(((STRSPLIT(lecture,'=',/EXTRACT))[1]),'>',/EXTRACT))[0]),':',/EXTRACT)
spdyn.lat_t=(lecture[0] eq 'true')
spdyn.lat_r=(lecture[1] eq 'true')
spdyn.lat_lg=(lecture[2] eq 'true')
spdyn.lat_lat=(lecture[3] eq 'true')
spdyn.lat_lt=(lecture[4] eq 'true')
lecture=''
readf,unit,lecture;<DRANGE=...>
lecture=STRSPLIT(((STRSPLIT(((STRSPLIT(lecture,'=',/EXTRACT))[1]),'>',/EXTRACT))[0]),':',/EXTRACT)
spdyn.xrange=float(lecture)
if (spdyn.xrange[0] ne spdyn.xrange[1]) then begin 
spdyn.nr=101
spdyn.dr=(spdyn.xrange[1]-spdyn.xrange[0])*0.01
endif else begin
spdyn.nr=1
spdyn.dr=1.
endelse
lecture=''
readf,unit,lecture;<LGRANGE=...>
lecture=STRSPLIT(((STRSPLIT(((STRSPLIT(lecture,'=',/EXTRACT))[1]),'>',/EXTRACT))[0]),':',/EXTRACT)
spdyn.lgrange=float(lecture)
if (spdyn.lgrange[0] ne spdyn.lgrange[1]) then begin 
spdyn.nlg=101
spdyn.dlg=(spdyn.lgrange[1]-spdyn.lgrange[0])*0.01
endif else begin
spdyn.nlg=1
spdyn.dlg=1.
endelse
lecture=''
readf,unit,lecture;<LARANGE=...>
lecture=STRSPLIT(((STRSPLIT(((STRSPLIT(lecture,'=',/EXTRACT))[1]),'>',/EXTRACT))[0]),':',/EXTRACT)
spdyn.larange=float(lecture)
if (spdyn.larange[0] ne spdyn.larange[1]) then begin 
spdyn.nlat=101
spdyn.dlat=(spdyn.larange[1]-spdyn.larange[0])*0.01
endif else begin
spdyn.nlat=1
spdyn.dlat=1.
endelse
lecture=''
readf,unit,lecture;<LTRANGE=...>
lecture=STRSPLIT(((STRSPLIT(((STRSPLIT(lecture,'=',/EXTRACT))[1]),'>',/EXTRACT))[0]),':',/EXTRACT)
spdyn.ltrange=float(lecture)
if (spdyn.ltrange[0] ne spdyn.ltrange[1]) then begin 
spdyn.nlt=101
spdyn.dlt=(spdyn.ltrange[1]-spdyn.ltrange[0])*0.01
endif else begin
spdyn.nlt=1
spdyn.dlt=1.
endelse
lecture=''
readf,unit,lecture;<KHZ=...>
lecture=(STRSPLIT(((STRSPLIT(lecture,'=',/EXTRACT))[1]),'>',/EXTRACT))[0]
spdyn.khz=(lecture eq 'true')
readf,unit,lecture;<LOG=...>
lecture=(STRSPLIT(((STRSPLIT(lecture,'=',/EXTRACT))[1]),'>',/EXTRACT))[0]
spdyn.log=(lecture eq 'true')
readf,unit,lecture;<PDF=...>
lecture=(STRSPLIT(((STRSPLIT(lecture,'=',/EXTRACT))[1]),'>',/EXTRACT))[0]
spdyn.pdf=(lecture eq 'true')
readf,unit,lecture;</SPDYN>
if lecture ne '</SPDYN>' then begin
	print,'File is not a valid SERPE save file (</SPDYN>)'
	return
endif
readf,unit,lecture;<MOVIE2D>
if lecture ne '<MOVIE2D>' then begin
	print,'File is not a valid SERPE save file (<MOVIE2D>)'
	return
endif
readf,unit,lecture;<ON=...>
lecture=(STRSPLIT(((STRSPLIT(lecture,'=',/EXTRACT))[1]),'>',/EXTRACT))[0]
mov2d.on=(lecture eq 'true')
readf,unit,lecture;<SUBCYCLE=...>
lecture=(STRSPLIT(((STRSPLIT(lecture,'=',/EXTRACT))[1]),'>',/EXTRACT))[0]
mov2d.sub=fix(lecture)>1
readf,unit,lecture;<RANGE=...>
lecture=(STRSPLIT(((STRSPLIT(lecture,'=',/EXTRACT))[1]),'>',/EXTRACT))[0]
mov2d.range=float(lecture)
readf,unit,lecture;</MOVIE2D>
if lecture ne '</MOVIE2D>' then begin
	print,'File is not a valid SERPE save file (</MOVIE2D>)'
	return
endif
readf,unit,lecture;<MOVIE3D>
if lecture ne '<MOVIE3D>' then begin
	print,'File is not a valid SERPE save file (<MOVIE3D>)'
	return
endif
readf,unit,lecture;<ON=...>
lecture=(STRSPLIT(((STRSPLIT(lecture,'=',/EXTRACT))[1]),'>',/EXTRACT))[0]
mov3d.on=(lecture eq 'true')
readf,unit,lecture;<SUBCYCLE=...>
lecture=(STRSPLIT(((STRSPLIT(lecture,'=',/EXTRACT))[1]),'>',/EXTRACT))[0]
mov3d.sub=fix(lecture)>1
readf,unit,lecture;<XRANGE=...>
lecture=STRSPLIT(((STRSPLIT(((STRSPLIT(lecture,'=',/EXTRACT))[1]),'>',/EXTRACT))[0]),':',/EXTRACT)
mov3d.xrange=float(lecture)
lecture=''
readf,unit,lecture;<YRANGE=...>
lecture=STRSPLIT(((STRSPLIT(((STRSPLIT(lecture,'=',/EXTRACT))[1]),'>',/EXTRACT))[0]),':',/EXTRACT)
mov3d.yrange=float(lecture)
lecture=''
readf,unit,lecture;<ZRANGE=...>
lecture=STRSPLIT(((STRSPLIT(((STRSPLIT(lecture,'=',/EXTRACT))[1]),'>',/EXTRACT))[0]),':',/EXTRACT)
mov3d.zrange=float(lecture)
lecture=''
readf,unit,lecture;<OBS=...>
lecture=(STRSPLIT(((STRSPLIT(lecture,'=',/EXTRACT))[1]),'>',/EXTRACT))[0]
mov3d.obs=(lecture eq 'true')
readf,unit,lecture;<TRAJ=...>
lecture=(STRSPLIT(((STRSPLIT(lecture,'=',/EXTRACT))[1]),'>',/EXTRACT))[0]
mov3d.traj=(lecture eq 'true')
readf,unit,lecture;</MOVIE3D>
if lecture ne '</MOVIE3D>' then begin
	print,'File is not a valid SERPE save file (</MOVIE3D>)'
	return
endif
bd=[body]
ds=[dens]
n=0
nd=0
for i=1,nbody do begin
readf,unit,lecture;<BODY>
readf,unit,lecture;<ON=...>
lecture=(STRSPLIT(((STRSPLIT(lecture,'=',/EXTRACT))[1]),'>',/EXTRACT))[0]
on=(lecture eq 'true')
if on then begin
	n=n+1
	bd=[bd,body]
readf,unit,lecture;<NAME=...>
lecture=(STRSPLIT(((STRSPLIT(lecture,'=',/EXTRACT))[1]),'>',/EXTRACT))[0]
bd[n].name=lecture
readf,unit,lecture;<RADIUS=...>
lecture=(STRSPLIT(((STRSPLIT(lecture,'=',/EXTRACT))[1]),'>',/EXTRACT))[0]
bd[n].rad=float(lecture)
readf,unit,lecture;<PERIOD=...>
lecture=(STRSPLIT(((STRSPLIT(lecture,'=',/EXTRACT))[1]),'>',/EXTRACT))[0]
bd[n].per=float(lecture)
readf,unit,lecture;<ORB_PER=...>
lecture=(STRSPLIT(((STRSPLIT(lecture,'=',/EXTRACT))[1]),'>',/EXTRACT))[0]
bd[n].orb1=float(lecture)
readf,unit,lecture;<INIT_AX=...>
lecture=(STRSPLIT(((STRSPLIT(lecture,'=',/EXTRACT))[1]),'>',/EXTRACT))[0]
bd[n].lg0=float(lecture)
readf,unit,lecture;<MAG=...>
lecture=(STRSPLIT(((STRSPLIT(lecture,'=',/EXTRACT))[1]),'>',/EXTRACT))[0]
bd[n].mfl=lecture
readf,unit,lecture;<MOTION=...>
lecture=(STRSPLIT(((STRSPLIT(lecture,'=',/EXTRACT))[1]),'>',/EXTRACT))[0]
bd[n].sat=(lecture eq 'true')
readf,unit,lecture;<PARENT=...>
lecture=(STRSPLIT(((STRSPLIT(lecture,'=',/EXTRACT))[1]),'>',/EXTRACT))[0]
bd[n].parent=strtrim(lecture,2)
readf,unit,lecture;<SEMI_MAJ=...>
lecture=(STRSPLIT(((STRSPLIT(lecture,'=',/EXTRACT))[1]),'>',/EXTRACT))[0]
bd[n].smaj=float(lecture)
readf,unit,lecture;<SEMI_MIN=...>
lecture=(STRSPLIT(((STRSPLIT(lecture,'=',/EXTRACT))[1]),'>',/EXTRACT))[0]
bd[n].smin=float(lecture)
readf,unit,lecture;<DECLINATION=...>
lecture=(STRSPLIT(((STRSPLIT(lecture,'=',/EXTRACT))[1]),'>',/EXTRACT))[0]
bd[n].decl=float(lecture)
readf,unit,lecture;<APO_LONG=...>
lecture=(STRSPLIT(((STRSPLIT(lecture,'=',/EXTRACT))[1]),'>',/EXTRACT))[0]
bd[n].alg=float(lecture)
readf,unit,lecture;<INCLINATION=...>
lecture=(STRSPLIT(((STRSPLIT(lecture,'=',/EXTRACT))[1]),'>',/EXTRACT))[0]
bd[n].incl=float(lecture)
readf,unit,lecture;<PHASE=...>
lecture=(STRSPLIT(((STRSPLIT(lecture,'=',/EXTRACT))[1]),'>',/EXTRACT))[0]
bd[n].phs=float(lecture)
	readf,unit,lecture;</BODY>
for l=1,ndens do begin
readf,unit,lecture;<DENSITY>
readf,unit,lecture;<ON=...>
lecture=(STRSPLIT(((STRSPLIT(lecture,'=',/EXTRACT))[1]),'>',/EXTRACT))[0]
on=(lecture eq 'true')
	if on then begin
		nd=nd+1
		ds=[ds,dens]
		bd[n].dens[i-1]=nd
readf,unit,lecture;<NAME=...>
lecture=(STRSPLIT(((STRSPLIT(lecture,'=',/EXTRACT))[1]),'>',/EXTRACT))[0]
ds[nd].name=lecture
readf,unit,lecture;<TYPE=...>
lecture=(STRSPLIT(((STRSPLIT(lecture,'=',/EXTRACT))[1]),'>',/EXTRACT))[0]
ds[nd].type=lecture
readf,unit,lecture;<RHO0=...>
lecture=(STRSPLIT(((STRSPLIT(lecture,'=',/EXTRACT))[1]),'>',/EXTRACT))[0]
ds[nd].rho0=float(lecture)
readf,unit,lecture;<SCALE=...>
lecture=(STRSPLIT(((STRSPLIT(lecture,'=',/EXTRACT))[1]),'>',/EXTRACT))[0]
ds[nd].height=float(lecture)
readf,unit,lecture;<PERP=...>
lecture=(STRSPLIT(((STRSPLIT(lecture,'=',/EXTRACT))[1]),'>',/EXTRACT))[0]
ds[nd].perp=float(lecture)
readf,unit,lecture;</DENSITY>
	endif else for j=0,5 do readf,unit,lecture
endfor
endif else begin
;skip if body not used
for j=0,14 do readf,unit,lecture
for k=1,ndens do for j=0,7 do readf,unit,lecture
endelse
endfor

sc=[src]
n=0
for i=1,nsrc do begin
readf,unit,lecture;<SOURCE>
readf,unit,lecture;<ON=...>
lecture=(STRSPLIT(((STRSPLIT(lecture,'=',/EXTRACT))[1]),'>',/EXTRACT))[0]
on=(lecture eq 'true')
if on then begin
	n=n+1
	sc=[sc,src]
readf,unit,lecture;<NAME=...>
lecture=(STRSPLIT(((STRSPLIT(lecture,'=',/EXTRACT))[1]),'>',/EXTRACT))[0]
sc[n].name=lecture
readf,unit,lecture;<PARENT=...>
lecture=(STRSPLIT(((STRSPLIT(lecture,'=',/EXTRACT))[1]),'>',/EXTRACT))[0]
sc[n].parent=STRTRIM(lecture,2)
readf,unit,lecture;<TYPE=...>
lecture=(STRSPLIT(((STRSPLIT(lecture,'=',/EXTRACT))[1]),'>',/EXTRACT))[0]
sc[n].type=lecture
readf,unit,lecture;<LG_MIN=...>
lecture=(STRSPLIT(((STRSPLIT(lecture,'=',/EXTRACT))[1]),'>',/EXTRACT))[0]
sc[n].lgmin=float(lecture)
readf,unit,lecture;<LG_MAX=...>
lecture=(STRSPLIT(((STRSPLIT(lecture,'=',/EXTRACT))[1]),'>',/EXTRACT))[0]
sc[n].lgmax=float(lecture)
readf,unit,lecture;<LG_NBR=...>
lecture=(STRSPLIT(((STRSPLIT(lecture,'=',/EXTRACT))[1]),'>',/EXTRACT))[0]
sc[n].lgstep=(sc[n].lgmax-sc[n].lgmin)/float((fix(lecture)-1)>1)
if sc[n].lgstep eq 0 then sc[n].lgstep=1
readf,unit,lecture;<LAT=...>
lecture=(STRSPLIT(((STRSPLIT(lecture,'=',/EXTRACT))[1]),'>',/EXTRACT))[0]
sc[n].latmin=float(lecture)
sc[n].latmax=float(lecture)
readf,unit,lecture;<SUB=...>
lecture=(STRSPLIT(((STRSPLIT(lecture,'=',/EXTRACT))[1]),'>',/EXTRACT))[0]
sc[n].subcor=float(lecture)
readf,unit,lecture;<SAT=...>
lecture=(STRSPLIT(((STRSPLIT(lecture,'=',/EXTRACT))[1]),'>',/EXTRACT))[0]
sc[n].sat=STRTRIM(lecture,2)
readf,unit,lecture;<NORTH=...>
lecture=(STRSPLIT(((STRSPLIT(lecture,'=',/EXTRACT))[1]),'>',/EXTRACT))[0]
sc[n].north=(lecture eq 'true')
readf,unit,lecture;<SOUTH=...>
lecture=(STRSPLIT(((STRSPLIT(lecture,'=',/EXTRACT))[1]),'>',/EXTRACT))[0]
sc[n].south=(lecture eq 'true')
readf,unit,lecture;<WIDTH=...>
lecture=(STRSPLIT(((STRSPLIT(lecture,'=',/EXTRACT))[1]),'>',/EXTRACT))[0]
sc[n].width=float(lecture)
readf,unit,lecture;<CURRENT=...>
lecture=(STRSPLIT(((STRSPLIT(lecture,'=',/EXTRACT))[1]),'>',/EXTRACT))[0]
sc[n].loss=(lecture eq 'Transient (Aflvénic)')
readf,unit,lecture;<ACCEL=...>
lecture=(STRSPLIT(((STRSPLIT(lecture,'=',/EXTRACT))[1]),'>',/EXTRACT))[0]
sc[n].v=sqrt(float(lecture)/255.5)
readf,unit,lecture;<TEMP=...>
lecture=(STRSPLIT(((STRSPLIT(lecture,'=',/EXTRACT))[1]),'>',/EXTRACT))[0]
sc[n].cold=float(lecture)/255.5
readf,unit,lecture;<TEMPH=...>
lecture=(STRSPLIT(((STRSPLIT(lecture,'=',/EXTRACT))[1]),'>',/EXTRACT))[0]
sc[n].temp=float(lecture)/255.5
readf,unit,lecture;</SOURCE>
endif else for j=0,16 do readf,unit,lecture
endfor

parameters = build_serpe_obj(adresse_lib,simulation_name,simulation_out,nbody,ndens,nsrc,time,freq,observer,bd,ds,sc,spdyn,mov2d,mov3d)

end
