;***********************************************************
;***                                                     ***
;***         SERPE V6.1		                             ***
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
;***          Initializes SERPE Parameter Structures     ***
;***     Version history                                 ***
;***     [BC] V6.1: Extracted from previous read_save    ***
;***                                                     ***
;***.....................................................***
;***     function: build_serpe_obj;                      ***
;***          Builds SERPE Parameters and Objects        ***
;***     Version history                                 ***
;***    [BC] V6.1: Extracted from previous read_save     ***
;***    [CL] V6.1: Ajout element pour calcul angle cst   ***
;***    [CL] V6.1: Ajout parametre altitude aurore		 ***
;***    [CL] V6.1: Ajout parametre calcul lag auto		 ***
;***    [CL] V6.1: Modification pour call_ephemph		 ***
;***    [CL] V6.1: Modifications pour sonde				 ***
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
;***     [BC] V1.0: Added config keyword                 ***
;***                                                     ***
;***.....................................................***
;***     pro: READ_SAVE                                  ***
;***          Reads Save file (in old format)            ***
;***     Version history                                 ***
;***     [SH] V6.0: First release                        ***
;***     [BC] V6.1: Using build_serpe_obj and            ***
;***                init_serpe_structures                ***
;***	 [CL] V6.1 : Ephem auto with MIRIADE		     ***
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
        'Linear&Log' :
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
    if (json_hash['FREQUENCY'])['MIN'] eq 0 and ((json_hash['FREQUENCY'])['TYPE'] eq 'Log') then begin
      nerr +=1 
      error = [error,"FREQUENCY.MIN Element cannot be 0 if FREQUENCY.TYPE: Log."]
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
    endif else if ((json_hash['FREQUENCY'])['TYPE'] eq 'Pre-Defined') then begin
      if (n_elements((json_hash['FREQUENCY'])['SC']) eq 0) then begin 
      			nerr +=1 
		      	error = [error,'Empty FREQUENCY.SC Value.']
      endif
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

    test = where(key_list_lev1 eq 'EPHEM',cnt)
    if cnt eq 0 then begin 
      nerr +=1 
      error = [error,'Missing OBSERVER.EPHEM Element.']
    endif

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

    test = where(key_list_lev1 eq 'CDF',cnt)
    if cnt eq 0 then begin 
      nerr +=1 
      error = [error,'Missing SPDYN.CDF Element.']
    endif else begin
     key_list_lev2 = ((json_hash['SPDYN'])['CDF']).keys()

        test = where(key_list_lev2 eq 'THETA',cnt)
              if cnt eq 0 then begin 
                  nerr +=1 
                error = [error,'Missing SPDYN.CDF.THETA Element.']
              endif  
        test = where(key_list_lev2 eq 'FP',cnt)
              if cnt eq 0 then begin 
                  nerr +=1 
                error = [error,'Missing SPDYN.CDF.FP Element.']
              endif  
        test = where(key_list_lev2 eq 'FC',cnt)
              if cnt eq 0 then begin 
                  nerr +=1 
                error = [error,'Missing SPDYN.CDF.FC Element.']
              endif  
        test = where(key_list_lev2 eq 'AZIMUTH',cnt)
              if cnt eq 0 then begin 
                  nerr +=1 
                error = [error,'Missing SPDYN.CDF.AZIMUTH Element.']
              endif  
        test = where(key_list_lev2 eq 'OBSLATITUDE',cnt)
              if cnt eq 0 then begin 
                  nerr +=1 
                error = [error,'Missing SPDYN.CDF.OBSLATITUDE Element.']
              endif  
        test = where(key_list_lev2 eq 'SRCLONGITUDE',cnt)
              if cnt eq 0 then begin 
                  nerr +=1 
                error = [error,'Missing SPDYN.CDF.SRCLONGITUDE Element.']
              endif  
        test = where(key_list_lev2 eq 'SRCFREQMAX',cnt)
              if cnt eq 0 then begin 
                  nerr +=1 
                error = [error,'Missing SPDYN.CDF.SRCFREQMAX Element.']
              endif  
        test = where(key_list_lev2 eq 'OBSDISTANCE',cnt)
              if cnt eq 0 then begin 
                  nerr +=1 
                error = [error,'Missing SPDYN.CDF.OBSDISTANCE Element.']
              endif  
        test = where(key_list_lev2 eq 'OBSLOCALTIME',cnt)
              if cnt eq 0 then begin 
                  nerr +=1 
                error = [error,'Missing SPDYN.CDF.OBSLOCALTIME Element.']
              endif  
        test = where(key_list_lev2 eq 'CML',cnt)
              if cnt eq 0 then begin 
                  nerr +=1 
                error = [error,'Missing SPDYN.CDF.CML Element.']
              endif  
        test = where(key_list_lev2 eq 'SRCPOS',cnt)
              if cnt eq 0 then begin 
                  nerr +=1 
                error = [error,'Missing SPDYN.CDF.SRCPOS Element.']
              endif  
        test = where(key_list_lev2 eq 'SRCVIS',cnt)
              if cnt eq 0 then begin 
                  nerr +=1 
                error = [error,'Missing SPDYN.CDF.SRCVIS Element.']
              endif  
      endelse

	test = where(key_list_lev1 eq 'INFOS',cnt)
    if cnt eq 0 then begin 
      nerr +=1 
      error = [error,'Missing SPDYN.INFOS Element.']
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

	    	test = where(key_list_lev1 eq 'FLAT',cnt)
	    	if cnt eq 0 then begin 
	    	  nerr +=1 
	   		  error = [error,'Missing BODY.FLAT Element.']
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

	    	test = where(key_list_lev1 eq 'AURORA_ALT',cnt)
	    	if cnt eq 0 then begin 
	    	  nerr +=1 
	   		  error = [error,'Missing SOURCE.AURORA_ALT Element.']
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

	    	test = where(key_list_lev1 eq 'CONSTANT',cnt)
	    	if cnt eq 0 then begin 
	    	  nerr +=1 
	   		  error = [error,'Missing SOURCE.CONSTANT Element.']
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
		    
		    test = where(key_list_lev1 eq 'REFRACTION',cnt)
	    	if cnt eq 0 then begin 
	    	  nerr +=1 
	   		  error = [error,'Missing SOURCE.REFRACTION Element.']
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
PRO init_serpe_structures,time,freq,observer,body,dens,src,spdyn,cdf,mov2d,mov3d

; ***** initializing local structures *****
time={TI,mini:0d,maxi:0d,nbr:0l,dt:0.}
freq={FR,mini:0.,maxi:0.,nbr:0l,df:0.,name:'',log:0b,predef:0b,freq_tab:PTR_NEW(/ALLOCATE_HEAP)}
observer={OB,motion:0b,smaj:0.,smin:0.,decl:0.,alg:0.,incl:0.,phs:0.,predef:0b,name:'',parent:'',start:''}
body={BO,on:0b,name:'',rad:0.,per:0.,flat:0.,orb1:0.,lg0:0.,sat:0b,smaj:0.,smin:0.,decl:0.,alg:0.,incl:0.,phs:0.,parent:'', mfl:'', folder:'',dens:intarr(4),ipar:0}
dens={DE,on:0b,name:'',type:'',rho0:0.,height:0.,perp:0.}
src={SO,on:0b,name:'',parent:'',sat:'',type:'',loss:0b,mode:'RX',lossbornes:0b,ring:0b,cavity:0b,constant:0.,width:0.,temp:0d,cold:0d,v:0d,lagauto:'off',lagmodel:'',lgmin:0.,lgmax:0.,lgnbr:1,lgstep:1.,latmin:0.,latmax:0.,latstep:1.,north:0b,south:0b,subcor:0.,aurora_alt:0d,refract:0b}
spdyn={SP,intensity:0b,polar:0b,f_t:0b,lg_t:0b,lat_t:0b,f_r:0b,lg_r:0b,lat_r:0b,f_lg:0b,lg_lg:0b,lat_lg:0b,f_lat:0b,lg_lat:0b,lat_lat:0b,f_lt:0b,lg_lt:0b,lat_lt:0b,$
khz:0b,pdf:0b,log:0b,xrange:[0.,0.],lgrange:[0.,0.],larange:[0.,0.],ltrange:[0.,0.],nr:0,dr:0.,nlg:0,dlg:0.,nlat:0,dlat:0.,nlt:0,dlt:0.,infos:0b}
cdf={CD,srcvis:0b,theta:0b,fp:0b,fc:0b,azimuth:0b,obslatitude:0b,srclongitude:0b,srcfreqmax:0b,srcfreqmaxCMI:0b,obsdistance:0b,obslocaltime:0b,cml:0b,srcpos:0b}
mov2d={M2D,on:0b,sub:0,range:0.}
mov3d={M3D,on:0b,sub:0,xrange:[0.,0.],yrange:[0.,0.],zrange:[0.,0.],obs:0b,traj:0b}

end

;************************************************************** BUILD_SERPE_OBJ
FUNCTION build_serpe_obj,version,adresse_mfl,file_name,nbody,ndens,nsrc,ticket,time,freq,observer,bd,ds,sc,spdyn,cdf,mov2d,mov3d

; ***** number of objects to build *****
nobj=n_elements(bd)-1+n_elements(ds)-1+2*(n_elements(sc)-1)+2+mov2d.on+mov3d.on+2;sacred&cdf

; ***** initializing variables *****
TEMPS={TIME,debut:time.mini,fin:time.maxi,step:time.dt,n_step:time.nbr,time:0d,t0:0.,istep:0}
FREQUE={FREQ,fmin:freq.mini,fmax:freq.maxi,n_freq:freq.nbr,step:freq.df,file:freq.name,log:freq.log,freq_tab:freq.freq_tab}
simu_name_tmp=strsplit(file_name,'/',/extract)
simu_name_tmp=strsplit(simu_name_tmp[-1],'.',/extract)
parameters={PARAMETERS,version:version,ticket:ticket,time:temps,freq:freque,name:simu_name_tmp[0],objects:PTRARR(nobj,/ALLOCATE_HEAP),out:''}


; ***** preparing DENSITY parameters *****
n=0
for i=0,n_elements(ds)-2 do begin
	tp=(ds[i+1]).type
	case tp of
		'Stellar': typ='stellar'
		'Ionospheric': typ='ionospheric'
		'Torus': typ='torus'
		'Disk': typ='disk'
    'auto': typ='auto'
	endcase

	(parameters.objects[n])=PTR_NEW({DENSITY,name:(ds[i+1]).name,type:typ,rho0:(ds[i+1]).rho0,height:(ds[i+1]).height,perp:(ds[i+1]).perp,it:[''],cb:[''],fz:['']})
	n=n+1
endfor

; ***** preparing BODY parameters *****
rank_bodies,bd

start_bodies=n

for i=0,n_elements(bd)-2 do begin
	(parameters.objects[n])=PTR_NEW({BODY,name:(bd[i+1]).name, mfl:(bd[i+1]).mfl, radius:(bd[i+1]).rad,period:(bd[i+1]).per,flat:(bd[i+1]).flat,orb_1r:(bd[i+1]).orb1,lg0:(bd[i+1]).lg0,motion:(bd[i+1]).sat,$
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
if (observer.predef) then begin
	nm1=observer.name
endif
;***** *****

(parameters.objects[n])=PTR_NEW({OBSERVER,name:observer.name,motion:observer.motion,predef:observer.predef,parent:PTR_NEW(/ALLOCATE_HEAP),initial_phase:observer.phs,semi_major_axis:observer.smaj,$
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
				loffset:0.,l_min:(sc[i+1]).latmin,l_max:(sc[i+1]).latmax,nlat:1,sat:sat,lct:0b,subcor:(sc[i+1]).subcor,oval_lat0:0.,aurora_alt:(sc[i+1]).aurora_alt,file_lat:'',file_lg:'',$
				b_n:PTR_NEW(/ALLOCATE_HEAP),x_n:PTR_NEW(/ALLOCATE_HEAP),bz_n:PTR_NEW(/ALLOCATE_HEAP),gb_n:PTR_NEW(/ALLOCATE_HEAP),$
				b_s:PTR_NEW(/ALLOCATE_HEAP),x_s:PTR_NEW(/ALLOCATE_HEAP),bz_s:PTR_NEW(/ALLOCATE_HEAP),gb_s:PTR_NEW(/ALLOCATE_HEAP),$
				fmax:PTR_NEW(/ALLOCATE_HEAP),fmaxCMI:PTR_NEW(/ALLOCATE_HEAP),feq:PTR_NEW(/ALLOCATE_HEAP),grad_b_eq:PTR_NEW(/ALLOCATE_HEAP),grad_b_in:PTR_NEW(/ALLOCATE_HEAP),$
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


	if sat then begin
    (*((parameters.objects[n]))).parent=satel
		a=(*satel).semi_major_axis
		b=(*satel).semi_minor_axis
		if (a eq b) and (a-fix(a) eq 0) then begin
      (*((parameters.objects[n]))).l_min=a
      (*((parameters.objects[n]))).l_max=b
      (*((parameters.objects[n]))).nlat=1
    endif else begin
      c=sqrt(a^2-b^2)
		  b=(fix(a-c))>2
		  a=(fix(a+c+1))<100
		  (*((parameters.objects[n]))).l_min=b
		  (*((parameters.objects[n]))).l_max=a
		  (*((parameters.objects[n]))).nlat=(a-b+1)
    endelse
	endif else (*((parameters.objects[n]))).parent=parent

	case mfl of 
		'O6+Connerney CS':fld='O6'
		'VIP4+Connerney CS' :fld='VIP4'
		'VIT4+Connerney CS' :fld='VIT4'
		'VIPAL+Connerney CS' : fld='VIPAL'
		'ISaAC+Connerney CS' : fld='ISaAC'
    'JRM09+Connerney CS' : fld='JRM09'
		'O6 Connerney CS':fld='O6'
		'VIP4 Connerney CS' :fld='VIP4'
		'VIT4 Connerney CS' :fld='VIT4'
		'VIPAL Connerney CS' : fld='VIPAL'
		'ISaAC Connerney CS' : fld='ISaAC'
    'JRM09 Connerney CS' : fld='JRM09'
		'SPV': fld='SPV'
		'Z3': fld='Z3'
    'Q3': fld ='Q3'
    'AH5': fld ='AH5'
    'auto': BEGIN
        fld = bd[wpar[0]].folder
    END
		else: BEGIN
      fld=mfl
      print,'Is your magnetic field model name correct?'
	   END
  endcase

	if (strmid(mfl,0,6) eq 'Dipole') then fld=mfl else if (mfl ne 'auto') then fld=adresse_mfl+fld

  if STRMATCH(mfl, 'auto', /FOLD_CASE) then (*((parameters.objects[n]))).folder=fld else $
    if ((sc[i+1]).type eq 'fixed in latitude') then (*((parameters.objects[n]))).folder=fld+'_lat' else begin
     ;#if strlowcase((*parent).name) eq 'jupiter' then begin
        case strlowcase((sc[i+1]).type) of
          'attached to a satellite': (*((parameters.objects[n]))).folder=fld+'_lsh'
          'l-shell': (*((parameters.objects[n]))).folder=fld+'_lsh'
          'm-shell': (*((parameters.objects[n]))).folder=fld+'_msh'
          else: (*((parameters.objects[n]))).folder=fld+'_msh'
        endcase
      ;#endif else (*((parameters.objects[n]))).folder=fld+'_lsh'
    endelse

  print, (*((parameters.objects[n]))).folder
  

	n=n+1
	(parameters.objects[n])=PTR_NEW({SOURCE,name:(sc[i+1]).name,parent:PTR_NEW(/ALLOCATE_HEAP),loss:(sc[i+1]).loss,mode:(sc[i+1]).mode,lossbornes:(sc[i+1]).lossbornes,ring:(sc[i+1]).ring,cavity:(sc[i+1]).cavity,rampe:0b,constant:(sc[i+1]).constant,asymp:0.,width:(sc[i+1]).width,$
				temp:(sc[i+1]).temp,cold:(sc[i+1]).cold,vmin:(sc[i+1]).v,vmax:(sc[i+1]).v,vstep:1.,lagauto:(sc[i+1]).lagauto,lagmodel:(sc[i+1]).lagmodel,lgmin:(sc[i+1]).lgmin,lgmax:(sc[i+1]).lgmax,$
				lgnbr:(sc[i+1]).lgnbr,lgstep:(sc[i+1]).lgstep,latmin:(sc[i+1]).latmin,latmax:(sc[i+1]).latmax,latstep:(sc[i+1]).latstep,$
				lgtov:0.,north:(sc[i+1]).north,south:(sc[i+1]).south,refract:(sc[i+1]).refract,grad_eq:0,grad_in:0,shield:0b,$
				nsrc:1,spdyn:PTR_NEW(/ALLOCATE_HEAP),th:PTR_NEW(/ALLOCATE_HEAP),azimuth:PTR_NEW(/ALLOCATE_HEAP),fp:PTR_NEW(/ALLOCATE_HEAP),f:PTR_NEW(/ALLOCATE_HEAP),fmax:PTR_NEW(/ALLOCATE_HEAP),fmaxCMI:PTR_NEW(/ALLOCATE_HEAP),v:PTR_NEW(/ALLOCATE_HEAP),$
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
				it:['init_spdyn'],cb:['cb_spdyn'],fz:['fz_spdyn'],nspd:0,out:PTR_NEW(/ALLOCATE_HEAP),save_out:spdyn.infos,f:0b,lg:0b,lat:0b,lct:0b,src_all:0b})
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
if (STRLEN(observer.start) ge 12) then begin
	Y=double(strmid(observer.start,0,4))
	Mo=double(strmid(observer.start,4,2))
	D=double(strmid(observer.start,6,2))
	H=double(strmid(observer.start,8,2))
	Mi=double(strmid(observer.start,10,2))
	S=double(strmid(observer.start,12,2))
endif
(parameters.objects[n])=PTR_NEW({SACRED,date:[Y,Mo,D,H,Mi,S],it:['init_sacred'],cb:['cb_sacred'],fz:['fz_sacred']})
n=n+1

; ***** preparing CDF parameters *****

	(parameters.objects[n])=PTR_NEW({CDF,id:0l,$
				it:['init_cdf'],cb:['cb_cdf'],fz:['fz_cdf'],$
        srcvis:cdf.srcvis,theta:cdf.theta,fp:cdf.fp,fc:cdf.fc,azimuth:cdf.azimuth,obslatitude:cdf.obslatitude,srclongitude:cdf.srclongitude,srcfreqmax:cdf.srcfreqmax,srcfreqmaxCMI:cdf.srcfreqmaxCMI,obsdistance:cdf.obsdistance,obslocaltime:cdf.obslocaltime,cml:cdf.cml,srcpos:cdf.srcpos})
; ***** returning parameters *****

return,parameters
end

;************************************************************** 
;READ_SAVE_JSON
;************************************************************** 
pro read_save_json,version,adresse_mfl,file_name,parameters,config=config
;************************************************************** 

; ***** initializing local variables *****
init_serpe_structures,time,freq,observer,body,dens,src,spdyn,cdf,mov2d,mov3d

; ***** loading JSON input *****
serpe_save = json_parse(file_name)

; ***** checking JSON input *****
check = check_save_json(serpe_save,error=error_messages)
if check ne 0 then begin
	find=strpos(error_messages,'CDF.',/reverse_search) 
  if min(find) eq -1 then begin 
    message,/info,'Something wrong happened with JSON file... Aborting.'
    print, 'In JSON file: '
    for ierror=0,n_elements(error_messages)-1 do print, error_messages[ierror]
  endif else for ierrorcdf=0,n_elements(find)-1 do begin
      print, error_messages[ierrorcdf]+': this element will not be in the CDF file'
    endfor
endif

;***** ticket number for the simulation *****
caldat,systime(/julian),month,day,year
ticket='ExPRES_simulation_'+strtrim(long((systime(/seconds)-aj_t70(amj_aj(year*10000+month*100+day-1))*24.*60.*60.)*1000),1)
;***** *****


; ***** loading NUMBER section *****
nbody = fix((serpe_save['NUMBER'])['BODY'])
ndens = fix((serpe_save['NUMBER'])['DENSITY'])
nsrc = fix((serpe_save['NUMBER'])['SOURCE'])

; ***** loading TIME section *****
if (serpe_save['OBSERVER'])['EPHEM'] eq '' then begin
  time.mini = double((serpe_save['TIME'])['MIN']);+double(strmid(observer.start,8,2))*60.+double(strmid(observer.start,10,2))
  time.maxi = double((serpe_save['TIME'])['MAX']);+double(strmid(observer.start,8,2))*60.+double(strmid(observer.start,10,2))
  time.nbr = long((serpe_save['TIME'])['NBR'])
  time.dt=(time.maxi-time.mini)/float(time.nbr)
endif

; ***** loading FREQ section *****
freq.log=0b
freq.predef=0b
case (serpe_save['FREQUENCY'])['TYPE'] of
	'Pre-Defined' : freq.predef=1b 
    'Log' : freq.log=1b
    'Linear': 
endcase
if freq.predef then begin
    freq.freq_tab=ptr_new(((serpe_save['FREQUENCY'])['SC']).toArray(dimension=0))
    freq.mini=min(*freq.freq_tab)
    freq.maxi=max(*freq.freq_tab)
    freq.nbr=n_elements(*freq.freq_tab)
    freq.df=0
    freq.name='User-defined'
    ;freq.name=(adresse_lib+'freq/'+(serpe_save['FREQUENCY'])['SC']) 
endif else begin
  freq.mini = float((serpe_save['FREQUENCY'])['MIN'])
  freq.maxi = float((serpe_save['FREQUENCY'])['MAX'])
  freq.nbr = long((serpe_save['FREQUENCY'])['NBR'])
  if freq.log then begin
    freq.df=(alog(freq.maxi)-alog(freq.mini))/(float(freq.nbr)-1)
    freq.freq_tab=ptr_new(exp(findgen(freq.nbr)*freq.df+alog(freq.mini)))
    freq.name='Logarithm'
  endif else begin
    freq.df=(freq.maxi-freq.mini)/(freq.nbr-1)
    freq.freq_tab=ptr_new(findgen(freq.nbr)*freq.df+freq.mini)
    freq.name='Linear'
  endelse
endelse


; ***** loading OBSERVER section *****
;# first for loop is useful to normalize all distance (observer.smin and observer.smax) by the main body radius
for i=0,nbody-1 do begin
    if ((serpe_save['BODY'])[i])['ON'] then $
        if ((serpe_save['BODY'])[i])['PARENT'] eq '' then $ ;# if body.parent == '' (i.e., as no parent) it means it is the central body 
            radius_parent = ((serpe_save['BODY'])[i])['RADIUS']
endfor

observer.motion=0b
observer.predef=0b
case (serpe_save['OBSERVER'])['TYPE'] of
    'Pre-Defined' : observer.predef=1b 
    'Orbiter' : observer.motion=1b
    'Fixed': 
endcase
observer.parent=(serpe_save['OBSERVER'])['PARENT']
observer.name=(serpe_save['OBSERVER'])['SC']

observer.start=(serpe_save['OBSERVER'])['SCTIME']


;************* ephemeris given by the users ************

;             ----------- WGC ----------

if (serpe_save['OBSERVER'])['EPHEM'] eq "@wgc" then begin

    if observer.name eq 'Earth' then begin
        py = Python.Import('read_ephem_obs')
        result = py.get_ephem_from_wgc(observer, serpe_save['TIME'])
        observer.start=result['time0']
        time.mini=(result['time'])['MINI']
        time.maxi=(result['time'])['MAXI']
        time.nbr=(result['time'])['NBR']
        time.dt=(result['time'])['DT']
        struct_replace_field,observer,'PHS',-result['longitude']
        struct_replace_field,observer,'DECL',result['lat']
        struct_replace_field,observer,'SMAJ',result['distance']
        struct_replace_field,observer,'SMIN',result['distance']
    endif

endif else if (serpe_save['OBSERVER'])['EPHEM'] ne '' then begin
  read_ephem_obs,(serpe_save['OBSERVER'])['EPHEM'],radius_parent,time0,time,observer,longitude,distance,lat,error 

  if error eq 1 then stop,'Check your ephemeris file'
  struct_replace_field,observer,'SMAJ',distance
  struct_replace_field,observer,'SMIN',distance
  struct_replace_field,observer,'PHS',-longitude
  struct_replace_field,observer,'DECL',lat
  observer.start=time0
endif

if strlen(observer.start) eq 12 then observer.start=observer.start+'00'
Y1=double(strmid(observer.start,0,4))  
Mo1=double(strmid(observer.start,4,2))  
D1=double(strmid(observer.start,6,2))  
H1=double(strmid(observer.start,8,2))
Mi1=double(strmid(observer.start,10,2))
S1=double(strmid(observer.start,12,2)) 
doy1=strtrim(amj_aj(long64(Y1*10000l+Mo1*100+D1)),2) 
julday1=JULDAY(Mo1, D1, Y1, H1, Mi1, S1) 
julday2=julday1+time.maxi/60./24.    
caldat,julday2,Mo2,D2,Y2,H2,Mi2,S2
doy2=strtrim(amj_aj(long64(Y2*10000l+Mo2*100+D2)),2) 


date=STRMID(observer.start,0,10)+':'+STRMID(observer.start,10,2)+':'+STRMID(observer.start,12,2)
adresse_ephem=loadpath('adresse_ephem',parameters,config=config)
if (serpe_save['OBSERVER'])['EPHEM'] eq '' then begin
    if ((observer.motion+observer.predef) eq 0b) then begin
  	if size(((serpe_save['OBSERVER'])['FIXE_DIST']),/type) eq 7 then begin			; if fixe_dist="auto"
  		if ((serpe_save['OBSERVER'])['SC'] eq 'Cassini' and (long64(strmid(observer.start,0,12)) ge 201603281700) and (long64(strmid(observer.start,0,12)) lt 201701010000)) then begin
  
  			restore,adresse_ephem+'Cassini/Ephem_Cassini_2016088-366.sav'
  			date2=strmid(strtrim(amj_aj(long64(strmid(date,0,8))),1),4,3)
  			heured=strmid(date,8,2)
  			mind=strmid(date,11,2)
  		
  			w=where(ephem.day eq date2 and ephem.hr eq heured and ephem.min eq mind)
  			longitude=ephem(w).oblon
  			distance=ephem(w).dist_RJ
  			lat=ephem(w).oblat
  		
  		endif else begin
  		; pour contrer les eventuels soucis de discussions avec l OV MIRIADE
  			error=1
  			error2=0
  			name=adresse_ephem+'ephemobs'+strtrim(ticket,1)+'.txt'
  			while (error eq 1) do begin
  				call_ephemph,(serpe_save['OBSERVER'])['PARENT'],spacecraft=(serpe_save['OBSERVER'])['SC'],date,name		; call ephemeride of Miriade VO
  				read_ephemph,name,distance=distance,longitude=longitude,lat=lat,error=error								; writing ephem of Miriade VO
          			if (error2 gt 30) then  stop,'Error on the call of MIRIADE ephemerides. Please restart the simulation and/or check that MIRIADE is working properly'
  				error2=error2+1
  			endwhile
		endelse
	  	; enregistrement des donnees lues
	  	observer.smaj=distance[0]
  	  	observer.smin=distance[0]
  	  	observer.phs=-longitude[0]
  		observer.decl=lat[0]
  		
  		
  	endif else begin	; sinon enregistre donnees entrees par utilisateur
  		observer.smaj=float((serpe_save['OBSERVER'])['FIXE_DIST'])/radius_parent ;# so that it will normalized observer.smin and observer.smax to planetary radius, whatever units users used (km or RP)
  	  	observer.smin=float((serpe_save['OBSERVER'])['FIXE_DIST'])/radius_parent ;# so that it will normalized observer.smin and observer.smax to planetary radius, whatever units users used (km or RP)
  		observer.phs=-float((serpe_save['OBSERVER'])['FIXE_SUBL'])
  		observer.decl=float((serpe_save['OBSERVER'])['FIXE_DECL'])
  	endelse
    endif else if (observer.predef eq 1b) then begin
  	if strlowcase((serpe_save['OBSERVER'])['SC']) eq 'juno' then begin
  		if long64(strmid(date,0,8)) le 20151231 then stop,'ephemeris before DoY 2015 365 are not defined. A file with the corresponding ephemeris needs to be loaded, please contact the ExPRES team - contact.maser@obspm.fr'
      		if long64(strmid(date,0,8)) ge 20251016 then stop,'ephemeris after DoY 2025 288 (October 15th, 2025) are not defined. A file with the corresponding ephemeris needs to be loaded, please contact the ExPRES team - contact.maser@obspm.fr'
  		if (strmid(strtrim(long64(observer.start),2),0,4) eq '2016') then $
  			restore,adresse_ephem+'Juno/2016_001-366.sav'
  		if (strmid(strtrim(long64(observer.start),2),0,4) eq '2017') then $
  			restore,adresse_ephem+'Juno/2017_001-365.sav'
  		if (strmid(strtrim(long64(observer.start),2),0,4) eq '2018') then $
  			restore,adresse_ephem+'Juno/2018_001-365.sav'
     		if (long64(strmid(observer.start,0,4)) ge 2019) and (long64(strmid(observer.start,0,4)) le 2024) then $
      			restore,adresse_ephem+'Juno/'+strmid(strtrim(long64(observer.start),2),0,4)+'.sav'
      		if (long64(strmid(observer.start,0,8)) ge 20250101) and (long64(strmid(observer.start,0,8)) lt 20251016) then $
      			restore,adresse_ephem+'Juno/2025_001-288.sav'

      
      
  	
    		w=where((long(ephem.day)+long(ephem.hr)/24.+long(ephem.min)/24./60. ge long(strmid(doy1,4,3))+long(H1)/24.+long(Mi1)/24./60.) and (long(ephem.day)+long(ephem.hr)/24.+long(ephem.min)/24./60. le (long(strmid(doy2,4,3))+long(H2)/24.+long(Mi2)/24./60.)))
      
    		longitude=ephem[w].oblon
    		distance=ephem[w].dist_RJ
    		lat=ephem[w].oblat
    		longitude=interpol(longitude,time.nbr)
    		distance=interpol(distance,time.nbr)
    		lat=interpol(lat,time.nbr)

     	endif else $
  	if strlowcase((serpe_save['OBSERVER'])['SC']) eq 'galileo' then begin
  		restore,adresse_ephem+'Galileo/1996_240-260.sav'
  		
      		w=where((long(ephem.day)+long(ephem.hr)/24.+long(ephem.min)/24./60. ge long(strmid(doy1,4,3))+long(H1)/24.+long(Mi1)/24./60.) and (long(ephem.day)+long(ephem.hr)/24.+long(ephem.min)/24./60. le (long(strmid(doy2,4,3))+long(H2)/24.+long(Mi2)/24./60.)))
      
      		longitude=ephem[w].oblon
      		distance=ephem[w].dist_RJ
      		lat=ephem[w].oblat
       
      		longitude=interpol(longitude,time.nbr)
      		distance=interpol(distance,time.nbr)
      		lat=interpol(lat,time.nbr)
  	
  	endif else $
  	if strlowcase((serpe_save['OBSERVER'])['SC']) eq 'voyager1' and strmid((serpe_save['OBSERVER'])['SCTIME'],0,4) eq '1979' then begin
  		restore,adresse_ephem+'Voyager/Voyager1_ephem_1979.sav'
  		w=where((long(ephem.day)+long(ephem.hr)/24.+long(ephem.min)/24./60. ge long(strmid(doy1,4,3))+long(H1)/24.+long(Mi1)/24./60.) and (long(ephem.day)+long(ephem.hr)/24.+long(ephem.min)/24./60. le (long(strmid(doy2,4,3))+long(H2)/24.+long(Mi2)/24./60.)))
      
      		longitude=ephem[w].oblon
      		distance=ephem[w].dist_RJ
      		lat=ephem[w].oblat
       
      		longitude=interpol(longitude,time.nbr)
      		distance=interpol(distance,time.nbr)
      		lat=interpol(lat,time.nbr)	
  	
  	endif else $
  	if strlowcase((serpe_save['OBSERVER'])['SC']) eq 'voyager2' and strmid((serpe_save['OBSERVER'])['SCTIME'],0,4) eq '1979' then begin
  		restore,adresse_ephem+'Voyager/Voyager2_ephem_1979.sav'
  		w=where((long(ephem.day)+long(ephem.hr)/24.+long(ephem.min)/24./60. ge long(strmid(doy1,4,3))+long(H1)/24.+long(Mi1)/24./60.) and (long(ephem.day)+long(ephem.hr)/24.+long(ephem.min)/24./60. le (long(strmid(doy2,4,3))+long(H2)/24.+long(Mi2)/24./60.)))
      
       		longitude=ephem[w].oblon
      		distance=ephem[w].dist_RJ
      		lat=ephem[w].oblat
      	
       		longitude=interpol(longitude,time.nbr)
      		distance=interpol(distance,time.nbr)
      		lat=interpol(lat,time.nbr)	
  	
  	endif else begin
  	
  		if (time.nbr le 5000) then begin
  			nbdate=strtrim(time.nbr,2)
  			step=strtrim(time.dt,2)+'m'
  		endif else if (time.nbr gt 5000) then begin ; MIRIADE n accepte pas plus de 5000 entrées de date d un coup
  			step=strtrim(time.dt,2)+'m'
  			nbnbdate=time.nbr/5000
  			nbdate=intarr(nbnbdate+1)
  		
  			for i=0,nbnbdate-2 do nbdate(i)='5000'
  			nbdate(nbnbdate)=strtrim(time.nbr-5000*nbnbdate,2)
  		endif
  	
  		if (time.nbr le 5000) then begin
  			error=1
  			error2=0
  			name=adresse_ephem+'ephemobs'+strtrim(ticket,1)+'.txt'
  			while (error eq 1) do begin
  				call_ephemph,(serpe_save['OBSERVER'])['PARENT'],spacecraft=(serpe_save['OBSERVER'])['SC'],date,name,nbdate=nbdate,step=step		; appel ephemeride OV Miriade
  				read_ephemph,name,distance=distance,longitude=longitude,lat=lat,error=error												; lecture ephem OV Miriade
  				if (error2 gt 30) then  stop,'Error on the call of MIRIADE ephemerides. Please restart the simulation and/or check that MIRIADE is working properly'
  				error2=error2+1
  			endwhile
  		
  		endif else if (time.nbr gt 5000l) then begin
  			longitude=[]
  			distance=[]
  			lat=[]
  			for i=0,nbnbdate-1 do begin
  				error=1
  				error2=0
  				name=adresse_ephem+'ephemobs'+strtrim(ticket,1)+'.txt'
  				while (error eq 1) do begin
  					call_ephemph,(serpe_save['OBSERVER'])['PARENT'],spacecraft=(serpe_save['OBSERVER'])['SC'],date,name,nbdate=nbdate(i),step=step		; appel ephemeride OV Miriade
  					read_ephemph,name,distance=distance2,longitude=longitude2,lat=lat2,error=error							; lecture ephem OV Miriade
  					if (error2 gt 30) then  stop,'Error on the call of MIRIADE ephemerides. Please restart the simulation and/or check that MIRIADE is working properly'
  					error2=error2+1												
  				endwhile
  				longitude=[longitude,longitude2]
  				distance=[distance,distance2]
  				lat=[lat,lat2]
  			endfor
  		endif
  	endelse
  	
    ; enregistrement des donnees lues (tableau de dimension nbdate)
    struct_replace_field,observer,'smaj',distance
    struct_replace_field,observer,'smin',distance
    struct_replace_field,observer,'phs',-longitude
    struct_replace_field,observer,'decl',lat
  endif
endif
; ********* ********	
	
if observer.motion then begin
	observer.smaj=(serpe_save['OBSERVER'])['SEMI_MAJ']/radius_parent ;# so that it will normalized observer.smin and observer.smax to planetary radius, whatever units users used (km or RP)
	observer.smin=(serpe_save['OBSERVER'])['SEMI_MIN']/radius_parent ;# so that it will normalized observer.smin and observer.smax to planetary radius, whatever units users used (km or RP)
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


cdf.theta=((serpe_save['SPDYN'])['CDF'])['THETA']
cdf.fp=((serpe_save['SPDYN'])['CDF'])['FP']
cdf.fc=((serpe_save['SPDYN'])['CDF'])['FC']
cdf.azimuth=((serpe_save['SPDYN'])['CDF'])['AZIMUTH']
cdf.obslatitude=((serpe_save['SPDYN'])['CDF'])['OBSLATITUDE']
cdf.srclongitude=((serpe_save['SPDYN'])['CDF'])['SRCLONGITUDE']
cdf.srcfreqmax=((serpe_save['SPDYN'])['CDF'])['SRCFREQMAX']
cdf.srcfreqmaxCMI=((serpe_save['SPDYN'])['CDF'])['SRCFREQMAX']
cdf.obsdistance=((serpe_save['SPDYN'])['CDF'])['OBSDISTANCE']
cdf.obslocaltime=((serpe_save['SPDYN'])['CDF'])['OBSLOCALTIME']
cdf.cml=((serpe_save['SPDYN'])['CDF'])['CML']
find=strpos(error_messages,'CDF.SRCPOS',/reverse_search)
if find[0] eq -1 then cdf.srcpos=((serpe_save['SPDYN'])['CDF'])['SRCPOS']
find=strpos(error_messages,'CDF.SRCVIS',/reverse_search)
if find[0] eq -1 then cdf.srcvis=((serpe_save['SPDYN'])['CDF'])['SRCVIS']

spdyn.infos=(serpe_save['SPDYN'])['INFOS']
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
		bd[n].flat=((serpe_save['BODY'])[i])['FLAT']
		bd[n].orb1=((serpe_save['BODY'])[i])['ORB_PER']    ; # orb_per=(2*pi*sqrt(a^3/(GM))/60 (in minutes) with a the radius of the body, G=6.67430e-11 and M the mass of thd body ; Third law of Kepler  
		bd[n].lg0=((serpe_save['BODY'])[i])['INIT_AX']
		bd[n].mfl=((serpe_save['BODY'])[i])['MAG']
    if bd[n].mfl eq 'auto' then begin
      test=where(((serpe_save['BODY'])[i]).keys() eq 'MAG_FOLDER',cnt)
      if cnt ne 0 then begin
        if ((serpe_save['BODY'])[i])['MAG_FOLDER'] ne '' then $
          bd[n].folder=((serpe_save['BODY'])[i])['MAG_FOLDER']
      endif
    endif

		bd[n].sat=((serpe_save['BODY'])[i])['MOTION']
		bd[n].parent=((serpe_save['BODY'])[i])['PARENT']
		bd[n].smaj=((serpe_save['BODY'])[i])['SEMI_MAJ']
		bd[n].smin=((serpe_save['BODY'])[i])['SEMI_MIN']

     		;#if bd[n].parent eq '' then $ ;# if no parent == central body
		;#	parent_body_radius = bd[n].rad 
   
    		bd[n].decl=((serpe_save['BODY'])[i])['DECLINATION']
		bd[n].alg=((serpe_save['BODY'])[i])['APO_LONG']
		bd[n].incl=((serpe_save['BODY'])[i])['INCLINATION']

;***** modification pour automatiser les ephémérides *****
; Si la phase a "auto" comme entree, on regarde si l observateur est prédéfini
; Si NON (0) : appel de MIRIADE pour avoir la phase au t=0 de la simulation
; Si OUI (1) : on regarde d abord si c est VOYAGER 1 ou VOYAGER 2 et si on est à la closest approach
; si c est le cas, on calcul à partir de la longitude au t=0 de la closest approach la longitude au t=0 de la simulation
; si c est pas le cas, alors on fait appelle à MIRIADE pour les éphémérides au t=0 de la simulation
		if size((((serpe_save['BODY'])[i])['PHASE']),/type) eq 7 then begin									; if phase = "auto"
    	
      ; # updating the date to take into account the light travel time
      ; # The longitude of a secondary body (a moon) is taken from the moon pov

      ; # It's necessary to go back in time, corresponding to the distance main body-observer
      if radius_parent eq 1 then begin
	    CASE ((serpe_save['BODY'])[i])['PARENT'] OF
     		'Earth':   radius_parent_fix = 6378.137
       		'Mars':    radius_parent_fix = 3396.2
        	'Jupiter': radius_parent_fix = 71492.00
        	'Saturn':  radius_parent_fix = 60268.00
	 	'Uranus':  radius_parent_fix = 25559.00
   		'Neptune':  radius_parent_fix = 24764.00
        	ELSE: stop, "In that case (['BODY']['PHASE'] = 'auto' and the ((serpe_save['BODY'])[i])['PARENT'] you have chosen), you need to have all your distance units defined in km so that the light travel time is correctly taken into account"
    	    ENDCASE
      endif
      
      if observer.motion eq 0 then begin
          if radius_parent eq 1 then begin
       	       caldat,julday1-(observer.smaj[0]*radius_parent_fix/3e5/60./60./24.),M0,D0,Y0,H0,Mi0,S0
          endif else begin
	      caldat,julday1-(observer.smaj[0]*radius_parent/3e5/60./60./24.),M0,D0,Y0,H0,Mi0,S0
          endelse
      endif else begin
        stop,"The ExPRES team has to configure the light travel time correction for the case where the observer is an orbiter..."
      endelse
      date=strtrim(Y0*1000000+M0*10000+D0*100+H0,2)+':'+strtrim(Mi0,2)+':'+strtrim(S0,2)
     ;date=STRMID(observer.start,0,10)+':'+STRMID(observer.start,10,2)+':'+STRMID(observer.start,12,2)

      ; #pour contrer les eventuels soucis de discussions avec l OV MIRIADE
			error=1
			error2=0
			adresse_ephem=loadpath('adresse_ephem',parameters,config=config)
      name=adresse_ephem+'ephembody'+strtrim(ticket,1)+'.txt'

			while (error eq 1) do begin
					call_ephemph,((serpe_save['BODY'])[i])['PARENT'],observer=((serpe_save['BODY'])[i])['NAME'],date,name		; search ephem (OV Miriade)
					read_ephemph,name,longitude=longitude,error=error												; read Miriade ephem
					if (error2 gt 30) then  stop,'Error on the call of MIRIADE ephemerides. Please restart the simulation and/or check that MIRIADE is working properly'
					error2=error2+1	
			endwhile
			; # phase eq auto is for a secondary body (moon). 
      ; # MIRIADE gives the real longitude of the moon (counted Eastward, 
      ; # thus 360°-SEP long to have the Westward longitude, which is done in read_ephemph).
      ; # Then to have the ExPRES Phase --> phs=360°-longitude_west
      bd[n].phs=360.-(longitude[0] mod 360.)
      
		endif else bd[n].phs=((serpe_save['BODY'])[i])['PHASE']												; sinon enregistre phase donnee par utilisateur
	endif
  ; ***** loading DENS section *****

	for l=0,ndens-1 do begin
		on=((((serpe_save['BODY'])[i])['DENS'])[l])['ON']
		if on then begin
			nd=nd+1
			ds=[ds,dens]
			bd[n].dens[nd-1]=nd
			ds[nd].name=((((serpe_save['BODY'])[i])['DENS'])[l])['NAME']
			ds[nd].type=((((serpe_save['BODY'])[i])['DENS'])[l])['TYPE']
			ds[nd].rho0=((((serpe_save['BODY'])[i])['DENS'])[l])['RHO0']
			ds[nd].height=((((serpe_save['BODY'])[i])['DENS'])[l])['SCALE']
			ds[nd].perp=((((serpe_save['BODY'])[i])['DENS'])[l])['PERP']
		endif
	endfor
endfor


for i=0,n_elements(bd)-1 do begin; So that every "distance" values are in planetary radius for sure, including parent body radius, whatever the units used by the users
 	bd[i].smaj/=radius_parent
	bd[i].smin/=radius_parent
 	bd[i].rad/=radius_parent
endfor
for i=0,n_elements(ds)-1 do begin
	ds[i].height/=radius_parent
	ds[i].perp/=radius_parent
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
		;# old version for adding an automatic lead angle... 
    ;# This will probably be obsolete in a future version
    ;# Compatible with the new version
    if size(((serpe_save['SOURCE'])[i])['LG_MIN'],/type) eq 7 then begin
        if ((serpe_save['SOURCE'])[i])['LG_MIN'] eq 'auto' then $
        	sc[n].lagauto='on'
     	if ((serpe_save['SOURCE'])[i])['LG_MIN'] eq 'auto+3' then $
        	sc[n].lagauto='on+3'
        if ((serpe_save['SOURCE'])[i])['LG_MIN'] eq 'auto-3' then $
        	sc[n].lagauto='on-3'
      	sc[n].lagmodel="Hess2011"

      if find[0] eq -1 then cdf.srcpos=((serpe_save['SPDYN'])['CDF'])['SRCPOS']

		endif else begin
			sc[n].lagauto='off'
			sc[n].lgmin=((serpe_save['SOURCE'])[i])['LG_MIN']
			sc[n].lgmax=((serpe_save['SOURCE'])[i])['LG_MAX']
		endelse
    
    ; # new version for adding an automatic lead angle, based on the lag_model entry
    ; # line 'test = ' is to test if the LAG_MODEL entry is present - entry not mandatory to be compatible with old json file version
    test=where(((serpe_save['SOURCE'])[i]).keys() eq 'LAG_MODEL',cnt)
    if cnt ne 0 then begin
      if ((serpe_save['SOURCE'])[i])['LAG_MODEL'] ne 'off' and  ((serpe_save['SOURCE'])[i])['LAG_MODEL'] ne ''  then begin
        sc[n].lagauto='on'
        sc[n].lagmodel=((serpe_save['SOURCE'])[i])['LAG_MODEL']
      endif
    endif


    sc[n].lgnbr=((serpe_save['SOURCE'])[i])['LG_NBR']
		sc[n].lgstep=(sc[n].lgmax-sc[n].lgmin)/float((fix(((serpe_save['SOURCE'])[i])['LG_NBR'])-1)>1)
		if sc[n].lgstep eq 0 then sc[n].lgstep=1
		sc[n].latmin=((serpe_save['SOURCE'])[i])['LAT']
		sc[n].latmax=((serpe_save['SOURCE'])[i])['LAT']
		sc[n].subcor=((serpe_save['SOURCE'])[i])['SUB']
    sc[n].aurora_alt=((serpe_save['SOURCE'])[i])['AURORA_ALT']
    if sc[n].parent ne '' then begin
      wparent = where(bd.name eq sc[n].parent)
      sc[n].aurora_alt /= bd[wparent[0]].rad
    endif
		sc[n].sat=((serpe_save['SOURCE'])[i])['SAT']
		sc[n].north=((serpe_save['SOURCE'])[i])['NORTH']
		sc[n].south=((serpe_save['SOURCE'])[i])['SOUTH']
		sc[n].width=((serpe_save['SOURCE'])[i])['WIDTH']

		case ((serpe_save['SOURCE'])[i])['CURRENT'] of
			'Transient (Alfvénic)': sc[n].loss=1b
     			'Transient (Alfvenic)': sc[n].loss=1b
     			'Transient (Aflvénic)': sc[n].loss=1b
			'Transient (Aflvenic)': sc[n].loss=1b
			'Transient (Aflvenic)+bornes': BEGIN
		 		sc[n].loss=1b
		 		sc[n].lossbornes=1b
		 	END
		 	'Steady-State': sc[n].cavity=1b
		 	'Constant': sc[n].constant=((serpe_save['SOURCE'])[i])['CONSTANT']
     			'Shell': sc[n].ring=1b
		 else:
		endcase
		;##################
		; # line 'test = ' is to test if the MODE entry is present - entry not mandatory to be compatible with old json file version
    		test=where(((serpe_save['SOURCE'])[i]).keys() eq 'MODE',cnt)
	    	if cnt ne 0 then begin
      			if ((serpe_save['SOURCE'])[i])['MODE'] ne '' then $ ;and sc[n].loss eq 1b  then $
        			sc[n].mode=STRUPCASE(((serpe_save['SOURCE'])[i])['MODE'])
    		endif
		;##################
		sc[n].v=sqrt(double(((serpe_save['SOURCE'])[i])['ACCEL'])/255.5)
		sc[n].cold=double(((serpe_save['SOURCE'])[i])['TEMP'])/255.5
		sc[n].temp=double(((serpe_save['SOURCE'])[i])['TEMPH'])/255.5
		sc[n].refract=((serpe_save['SOURCE'])[i])['REFRACTION']
	endif
endfor

; ***** building SERPE objects *****
parameters = build_serpe_obj(version,adresse_mfl,file_name,nbody,ndens,nsrc,ticket,time,freq,observer,bd,ds,sc,spdyn,cdf,mov2d,mov3d)

end
