PRO cdf_getvar,cdf_file,rvar,zvar

;+
; NAME:
;   cdf_getvar
;
; PURPOSE:
;   Get information about the variables
;   defined in a cdf file.
;
; CATEGORY:
;   I/O 
;
; CALLING SEQUENCE:
;   cdf_getvar,cdf_file,rvar,zvar       
;   
; INPUTS:
;   cdf_file - cdf file to read.
; 
; OPTIONAL INPUTS:
;   None.
;               
; KEYWORD PARAMETERS:
;   None.
;
; OUTPUTS:
;   rvar - Structure containing information about the regular variables.
;   zvar - Structure containing information about the Z variables.
;
; OPTIONAL OUTPUTS:
;   None.
;
; COMMON BLOCKS:
;   None.
;
; SIDE EFFECTS:
;   None.
;
; RESTRICTIONS/COMMENTS:
;   none.
;
; CALL:
;   None.
;
; EXAMPLE:
;   None.
;
; MODIFICATION HISTORY:
;   Written by X.Bonnin (LESIA, CNRS)
;
;-

if not (keyword_set(cdf_file)) then begin
    message,/INFO,'Usage:'
    print,'cdf_getvar,cdf_file,rvar,zvar'
    return
endif

if not (file_test(cdf_file)) then message,'ERROR - Input cdf_file does not exist: '+cdf_file+'!'

cdfid=cdf_open(cdf_file,/READONLY)

inq=cdf_inquire(cdfid)
nvars=inq.nvars
nzvars=inq.nzvars

if (nvars gt 0) then begin
    rvar={name:'',id:0l,datatype:'',numelem:0l, $
          recvar:'',dimvar:''}
    rvar=replicate(rvar,nvars)
    for i=0,nvars-1 do begin
        vinq_i=cdf_varinq(cdfid,i)
        rvar[i].name=vinq_i.name
        rvar[i].id=i
        rvar[i].datatype=vinq_i.datatype
        rvar[i].numelem=vinq_i.numelem
        rvar[i].recvar=vinq_i.recvar
        rvar[i].dimvar=strjoin(strtrim(vinq_i.dimvar,2),',')
    endfor
endif

if (nzvars gt 0) then begin
    zvar={name:'',id:0l,datatype:'',numelem:0l, $
          recvar:'',dimvar:'',dim:''}
    zvar=replicate(zvar,nzvars)
    for i=0,nzvars-1 do begin
        vinq_i=cdf_varinq(cdfid,i,/ZVAR)
        zvar[i].name=vinq_i.name
        zvar[i].id=i
        zvar[i].datatype=vinq_i.datatype
        zvar[i].numelem=vinq_i.numelem
        zvar[i].recvar=vinq_i.recvar
        zvar[i].dimvar=strjoin(strtrim(vinq_i.dimvar,2),',')
        zvar[i].dim=strjoin(strtrim(vinq_i.dim,2),',')
    endfor
endif
cdf_close,cdfid

END


PRO cdf_getatt,cdf_file,gattrs,vattrs

;+
; NAME:
;   cdf_getatt
;
; PURPOSE:
;   Get information about the global and variable 
;   attributes defined in a cdf file.
;
; CATEGORY:
;   I/O 
;
; CALLING SEQUENCE:
;   cdf_getatt,cdf_file,gattrs,vattrs      
;   
; INPUTS:
;   cdf_file - cdf file to read.
; 
; OPTIONAL INPUTS:
;   None.
;               
; KEYWORD PARAMETERS:
;   None.
;
; OUTPUTS:
;   gattrs - Structure containing information about the global attributes.
;   vattrs - Structure containing information about the variable attributes.
;
; OPTIONAL OUTPUTS:
;   None.
;
; COMMON BLOCKS:
;   None.
;
; SIDE EFFECTS:
;   None.
;
; RESTRICTIONS/COMMENTS:
;   none.
;
; CALL:
;   None.
;
; EXAMPLE:
;   None.
;
; MODIFICATION HISTORY:
;   Written by X.Bonnin (LESIA, CNRS)
;
;-

if not (keyword_set(cdf_file)) then begin
    message,/INFO,'Usage:'
    print,'cdf_getatt,cdf_file,gattrs,vattrs'
    return
endif

if not (file_test(cdf_file)) then message,'ERROR - Input cdf_file does not exist: '+cdf_file+'!'

cdfid=cdf_open(cdf_file,/READONLY)

inq=cdf_inquire(cdfid)
natts=inq.natts

if (natts gt 0) then begin
    gattrs={name:'',id:0l,scope:'',maxentry:0l,maxzentry:0l}
    vattrs={name:'',id:0l,scope:'',maxentry:0l,maxzentry:0l}
    gattrs=replicate(gattrs,natts)
    vattrs=replicate(vattrs,natts)
    gcount=0 & vcount=0
    for i=0,natts-1 do begin
        cdf_attinq,cdfid,i,name_i,scope_i,maxentry_i,maxzentry_i
        if (scope_i eq 'GLOBAL_SCOPE') then begin
            gattrs[gcount].name=name_i
            gattrs[gcount].id=i
            gattrs[gcount].scope=scope_i
            gattrs[gcount].maxentry=maxentry_i
            gattrs[gcount].maxzentry=maxzentry_i
            gcount++
        endif else begin
            vattrs[vcount].name=name_i
            vattrs[vcount].id=i
            vattrs[vcount].scope=scope_i
            vattrs[vcount].maxentry=maxentry_i
            vattrs[vcount].maxzentry=maxzentry_i
            vcount++
        endelse
    endfor
    if (gcount gt 0) then gattrs=gattrs[0:gcount-1]
    if (vcount gt 0) then vattrs=vattrs[0:vcount-1]    
endif
cdf_close,cdfid

END


PRO make_cdf,master_cdf,output_cdf,variables, $
            vattributes=vattributes, $
            gattributes=gattributes, $
            VERBOSE=VERBOSE

;+
; NAME:
;   make_cdf
;
; PURPOSE:
;   Produces a CDF format file from a
;   given master cdf file.
;
; CATEGORY:
;   I/O 
;
; CALLING SEQUENCE:
;   make_cdf,master_cdf,output_cdf,variables       
;   
; INPUTS:
;   master_cdf  - Path of the template cdf file.
;   output_cdf  - Path and name of the output cdf file.
;   variables   - Structure providing data values 
;                 to be written into the output_cdf file,
;                 for each cdf variable defined in the master file.
;                 Structure contains the following item:
;                       .NAME_OF_CDF_VARIABLE
;                 , where "NAME_OF_CDF_VARIABLE" is the name of the cdf variable for
;                 which data must be written.
; 
; OPTIONAL INPUTS:
;   vattributes - Structure providing variable attribute values 
;                 to be written into the output_cdf file,
;                 for one or more cdf variable defined in the master file.
;                 Structure contains the following item:
;                       .NAME_OF_CDF_VARIABLE.NAME_OF_VATTRIBUTE
;                 , where "NAME_OF_VATTRIBUTE" is the name of the variable attribute to edit,
;                 and "NAME_OF_CDF_VARIABLE" is the name of the corresponding cdf variable.
;
;   gattributes - Structure containing global attribute values to be written into the output cdf.
;                 If it is not provided, then the global attribute values will be copied from 
;                 the master to the output cdf, and the GENERATION_DATE global attribute will be  
;                 update to the current date and time in the output cdf.
;                 Structure contains the following item:
;                       .NAME_OF_GATTRIBUTE
;                 , where "NAME_OF_GATTRIBUTE" is name of the global attribute to edit.
;               
; KEYWORD PARAMETERS:
;   /VERBOSE - Verbose mode.
;
; OUTPUTS:
;   The routine will produce a cdf format file.
;
; OPTIONAL OUTPUTS:
;   None.
;
; COMMON BLOCKS:
;   None.
;
; SIDE EFFECTS:
;   None.
;
; RESTRICTIONS/COMMENTS:
;   Only works with Z variables.
;
;   Make sure that the IDL CDWAlib
;   (http://spdf.gsfc.nasa.gov/CDAWlib.html) 
;   is correctly installed, and that the
;   IDLmakecdf routines are compiled 
;   (the routine called compile_IDLmakecdf.pro 
;   in CDAWlib directory
;   can be used for that purpose.)
;
; CALL:
;   cdf_getatt
;   cdf_getvar
;   read_master_cdf
;   write_data_to_cdf
;
; EXAMPLE:
;   None.
;
; MODIFICATION HISTORY :
;   Written by X.Bonnin (LESIA, CNRS)
;
;   24-MAR-2014, X.Bonnin (LESIA, CNRS):    Rename var_values input structure to variables.
;                                           Add the possibility to modify global/variable attribute values
;                                           in the output cdf file, using vattributes and gattributes optional inputs.
;                                           Remove results optional output.
;
;-

if (n_params() lt 2) then begin
    message,/INFO,'Usage:'
    print,'make_cdf,master_cdf_output_cdf,variables, $'
    print,'         gattributes=gattributes, $'
    print,'         vattributes=vattributes, $'
    print,'         /VERBOSE'
    return
endif
VERBOSE=keyword_set(VERBOSE)

pref='['+output_cdf+']: ' 

; Retrieve the variables in master_cdf and copy master_cdf to output_cdf
if (VERBOSE) then print,'Reading '+master_cdf+' and creating '+output_cdf+'...'
if not (file_test(master_cdf)) then message,'ERROR - Master cdf file ('+master_cdf+') does not exist!'
buf1=read_master_cdf(master_cdf,output_cdf)
if not (file_test(output_cdf)) then message,'ERROR - Output cdf file ('+output_cdf+') does not exist!'
nvar=n_tags(variables)

; Get list of variables in output_cdf
cdf_getvar,output_cdf,rvar,zvar
nzvar=n_elements(zvar)

; Get list of global and variable attributes in output_cdf
cdf_getatt,output_cdf,gattrs,vattrs
ngatt=n_elements(gattrs) & nvatt=n_elements(vattrs)

; Fill variables with input data (and update variable attributes if required)
if (nvar gt 0) and (nzvar gt 0) then begin
    buf1_varnames=strupcase(tag_names(buf1))
    varnames=strupcase(tag_names(variables))

    for i=0l,nvar-1l do begin
        where_i=(where(varnames[i] eq buf1_varnames))[0]
        if (where_i eq -1) then begin
            if (VERBOSE) then message,/CONT,pref+'Warning - '+$
                    varnames[i]+' variable not found in the master cdf!'
            continue
        endif
        if (VERBOSE) then print,pref+'Copying values of '+strtrim(varnames[i],2)+' cdf variable...'
        *buf1.(where_i).data=variables.(i)
    endfor
endif
isdata=write_data_to_cdf(output_cdf,buf1,/DEBUG)
isok=(file_test(output_cdf)) and (isdata)
if (VERBOSE) then begin
   if (isok) then print,'Input data have been correctly written into '+output_cdf $
   else message,'ERROR - Input data have not been correctly written into '+output_cdf+'!'
endif

; Modify variable attributes in output_cdf
if (keyword_set(vattributes)) and (nvatt gt 0) and (nzvar gt 0) then begin
    varnames=strupcase(tag_names(vattributes))

    for i=0,n_elements(varnames)-1 do begin
        where_var=(where(varnames[i] eq strupcase(zvar.name)))[0]
        if (where_var eq -1) then begin
            message,/CONT,'Warning - Variable '+varnames[i]+' not found in '+output_cdf+'!'
            continue
        endif         
        vattnames=strupcase(tag_names(vattributes.(i)))

        cdfid=cdf_open(output_cdf)
        for j=0,nvatt-1 do begin
            where_j=(where(strupcase(vattrs[j].name) eq vattnames))[0]
            if (where_j ne -1) then begin
                cdf_attput,cdfid,vattrs[j].name,zvar[where_var].name,vattributes.(i).(where_j)
                if (VERBOSE) then print,pref+'New value for the variable attribute '+ $
                        zvar[where_var].name+'.'+vattrs[j].name+' --> '+strtrim(vattributes.(i).(where_j),2)
            endif
        endfor
        cdf_close,cdfid
    endfor
endif
 
; Modify global attributes in output_cdf
if (keyword_set(gattributes)) and (ngatt gt 0) then begin
    gattnames=strupcase(tag_names(gattributes))
    cdfid=cdf_open(output_cdf)
    for j=0,ngatt-1 do begin
        where_j=(where(strupcase(gattrs[j].name) eq gattnames))[0]
        if (where_j ne -1) then begin
            for k=0,n_elements(gattributes.(where_j))-1 do begin
                cdf_attput,cdfid,gattrs[j].name,k,gattributes.(where_j)[k]
                if (VERBOSE) then print,pref+'New value for the global attribute '+ $
                        gattrs[j].name+'['+strtrim(k,2)+'] --> '+strtrim(gattributes.(where_j)[k],2)
            endfor
        endif
    endfor
    cdf_close,cdfid
endif

END
