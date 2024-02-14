;+
; ***********************************************************
; ***                                                     ***
; ***         ExPRES V1.0                                  ***
; ***                                                     ***
; ***********************************************************
; ***                                                     ***
; ***       MODULE: FIELD                                 ***
; ***                                                     ***
; ***     function: INTEROGATE_FIELD; are the files there ***
; ***     DIPOLAR_FIELD_N; (North)                        ***
; ***     DIPOLAR_FIELD_S; (South)                        ***
; ***     INIT   [INIT_FIELD]                             ***
; ***     CALLBACK [CB_ROT_FIELD]                         ***
; ***                                                     ***
; ***********************************************************
;
; :Author:
;     Sebastien Hess, Corentin Louis, Baptiste Cecconi
; 
; :History:
;     V0.6.0: creation
;     V0.6.1: fmax calculation modification 
;     V1.0.1: updated comments
;-

;+
; ************************************************************** 
; FUNCTION INTEROGATE_FIELD
; 
; This function checks if there mfl files available where they are expected to be
; and if those files correspond to axisymmetric data or not
;
; If files/folders are not present, the pipeline stops.
;
; :Returns:
;    type=int
;        Boolean value: 0b = non-axisymmetric; 1b = axisymmetric
;
; :Params:
;    folder0: in, required, type=string
;        Path to magnetic field files (mfl root directory + magnetic field directory), including last directory separator 
;    fold:    in, required, type=string
;        name of sub-folder (non axisymmetric case) or stem file name (axisymmetric case) 
;    sig:     in, required, type=string
;        sign (e.g., hemisphere) in file name (axisymmetric case)
;-

FUNCTION INTEROGATE_FIELD,folder0,fold,sig
 
; file case (axisymmetric case)
file=folder0+sig+fold+'.lsr'
; folder case (non-axisymmetric)
folder=folder0+fold
; first check if file case, then return value is 1b:
a=FILE_SEARCH(file)
if a ne '' then return,1b
; second check if folder case, then return value is 0b:
a=FILE_SEARCH(folder,/TEST_DIRECTORY)
if a ne '' then return,0b
; if none of above conditions are met stop:
print,'Field files not found: ',folder
stop
end


; **************************************************************
; READ_BFIELD_AND_DENSITY_FROM_USER
; This function reads Magnetic Field information from a CSV field given by the user. It returns for each (x,y,z), (bx,by,bz), (fce), bz_read, gb_read, f_read and the density
;
; : Returns:
;    x_read: positions on the magnetic field line
;    b_read: corresponding (bx,by,bn) values 
;    bz_read: corresponding direction vector normal to the L-shell
;    gb_read: corresponding direction of the gradient of B
;    f_read: corresponding electron cyclotron frequency (in MHz)
;    density: corresponding density (in cm^{-3})
;
; :Params:
;    obj: in, required, type=pointer
;    ilat: in, required, type= int
;    ilongitude: in, required, type= int
;
pro read_Bfield_and_density_from_user, ilat, ilongitude, x_read, b_read, bz_read, gb_read, f_read, density
    if (*obj).nlat gt 1 then ilat_name = '' else ilat_name = '_'+strtrim(ilat,2)
    ilon_name = string(format='(I03)', ilon)

    ;#if (*obj).north then ihemisphere='north' else if (*obj).south then ihemisphere='south'
    if (*obj).north then ihemisphere='_m_' else if (*obj).south then ihemisphere='_p_'
    csv_file = (*obj).folder+'*'+ihemisphere+"*"+ilat_name+"*"+ilon_name+"*.csv"

    search_for_csv_file=FILE_SEARCH(csv_file)
    stop

    if search_for_csv_file eq '' then begin
        ; # In case csv_file doesnt exist, then values are set to 0.
        n=150 ;#random number so that the interpolation done later works
        b_read  = dblarr(3,n)
        f_read  = dblarr(n)
        x_read  = dblarr(3,n)
        gb_read = dblarr(n)
        bz_read = dblarr(3,n)
        density = dblarr(n)
    endif else begin
        data = READ_CSV(csv_file, header=header, count = n)
        n_header=0                                                            
        while strmid(data.field1[n_header],0,1) eq '#' do n_header=n_header+1

        data = READ_CSV(csv_file, header = header, count = n, table_header = table_header, n_table_header = n_header-1)
        

        b_read  = dblarr(3,n)
        f_read  = dblarr(n)
        x_read  = dblarr(3,n)
        gb_read = dblarr(n)
        bz_read = dblarr(3,n)
        density = dblarr(n)
        

        if strmatch(table_header, "*True*", /fold_case) then begin ;# so that if the Field line is not connected to the star, False will be set and magnetic field line will contain only 0
            fieldNames_data = TAG_NAMES(data)

            header[0] = strtrim(strmid(header[0], 1, strlen(header[0])-1),2)
            newHeader = strarr(n_elements(header))
            for iheader = 0,n_elements(header)-1 do newHeader[iheader] = STRMID(header[iheader], 0, STRPOS(header[iheader], '[') - 1)

            newStruct = HASH(newHeader)


            for i = 0, N_ELEMENTS(newHeader) - 1 do begin
                fieldNames_newstruc = STRMID(newHeader[i], 0, STRPOS(header[i], '[')-1)
                fieldName_data = fieldNames_data[i]                  
                newStruct[fieldNames_newstruc] = data.(fieldName_data)
            endfor

            x_read [0,*] = newStruct["X"]
            x_read [1,*] = newStruct["Y"]
            x_read [2,*] = newStruct["Z"]
            b_read [0,*] = newStruct["BX"]
            b_read [1,*] = newStruct["BY"]
            b_read [2,*] = newStruct["BZ"]
            
            if STRMATCH(newheader, "BZenith*",/FOLD_CASE) then begin
                bz_read [0,*] = newStruct["BZenithX"]
                bz_read [1,*] = newStruct["BZenithY"]
                bz_read [2,*] = newStruct["BZenithZ"]
            endif

            if STRMATCH(newheader, "GradB*",/FOLD_CASE) then $
                gb_read = newStruct["GradB"]

            if STRMATCH(newheader, "Rho", /FOLD_case) then $
                density = newStruct["Rho"]


            fsb = 2.79924835996 ; # electon cyclotron frequency [MHz] to B [Gauss] = (e*15.345970*1e-4)/(2*!pi*m_e)/1e6 with e = 1.602e-19 and  m_e = 9.109e-31. Should be fsb = 2.79906 to be more precise...

            f_read = total(b_read^2,1) * fsb
        endif
    endelse

return
end

; **************************************************************
; FMAX_CALCULATION
; This procedure determines the maximal frequency reachable by the cyclotron maser instability due to the surface of the bodies, per magnetic field line
;
;
; :Params:
;    obj: in, required, type=pointer
;    x_read: in, required, type= fltarr(3,n)
;    f_read: in, required, type= fltarr(n)
;    ilongitude: in, required, type= int

pro fmax_calculation, obj, x_read, f_read, ilongitude, ilatitude

    ; if the object is a satellite, take the flatenning of the central body
    if (*obj).sat then flat = (*(*(*obj).parent).parent).flat $
        else flat = (*(*obj).parent).flat                           

    ; calculion of the radius r of the magnetic field line at each point x_read
    r=sqrt(x_read[0,*]^2+x_read[1,*]^2+x_read[2,*]^2)           
    ; calculation of the angle between the equatorial plane and each point (r) of the magnetic field line
    beta=atan(x_read[2,*],sqrt(x_read[0,*]^2+x_read[1,*]^2))
    ; calculation of the radius of Jupiter ellipsoide
    r_el=sqrt(1./(cos(beta)^2+sin(beta)^2/(1-flat)^2))          
    alt_min=r_el
    w=where(r gt (r_el+(*obj).aurora_alt), nw) ; 
    
    if (*obj).north then ihemisphere=0 else if (*obj).south then ihemisphere=1
    
    (*((*obj).fmax))[ihemisphere,ilongitude,ilatitude]=f_read(w(nw-1l))
end

; **************************************************************
; FMAXCMI_CALCULATION
; This procedure determines the maximal frequency reachable by the cycltron maser instability due to the ratio w_p/w_c
;
;
; :Params:
;    obj: in, required, type=pointer

pro fmaxcmi_calculation, obj, parameters
    
    ff=(*(parameters.freq.freq_tab))
    if (*obj).north then begin
        ; # NORTHERN HEMISPHERE
        for ilat=0,(*obj).nlat-1 do begin
            for ilong=0,359 do begin
                nwf=where((*(*obj).dens_n)[*,ilong,ilat] lt 0.01)
                if ((nwf[-1]-nwf[0]+1) eq n_elements(nwf)) or (nwf[0] eq 0.) then (*((*obj).fmaxCMI))[0,ilong,ilat]=ff[nwf[-1]] $
                else begin
                    test=1
                    k=-1
                    while (test eq 1) and (k gt -(n_elements(nwf))) do begin
                        if (nwf[k] - nwf[k-1]) eq 1 then k=k-1 else test=0
                    endwhile
                    (*((*obj).fmaxCMI))[0,ilong,ilat]=ff[nwf[k-1]]
                endelse
            endfor
        endfor
    endif else if (*obj).south then begin
    ; # SOUTHERN HEMISPHERE
        for ilat=0,(*obj).nlat-1 do begin
            for ilong=0,359 do begin
                nwf=where((*(*obj).dens_s)[*,ilong,ilat] lt 0.01)
                if ((nwf[-1]-nwf[0]+1) eq n_elements(nwf)) or (nwf[0] eq 0.) then (*((*obj).fmaxCMI))[1,ilong,ilat]=ff[nwf[-1]] $
                else begin
                    test=1
                    k=-1
                    while (test eq 1) and (k gt -(n_elements(nwf))) do begin
                        if (nwf[k] - nwf[k-1]) eq 1 then k=k-1 else test=0
                    endwhile
                    (*((*obj).fmaxCMI))[1,ilong,ilat]=ff[nwf[k-1]]
                endelse
            endfor
        endfor
    endif
end

; **************************************************************
; DENSITY_CALCULATION, obj, parameters, dens
; This procedure determines the density along the magnetic field lines
;
; :Params:
;    obj: in, required, type=pointer
;    parameters: in, required, type=array
;    dens: in, required, type=string

pro density_calculation, obj, parameters, dens

    ; if the object is a satellite, take the flatenning of the central body
    if (*obj).sat then begin
        flat = (*(*(*obj).parent).parent).flat
        nd=n_elements((*((*((*((*obj).parent)).parent)).density)))
        if nd ne 0 then dens=(*((*((*((*obj).parent)).parent)).density))
    endif else begin
        flat = (*(*obj).parent).flat
        nd=n_elements((*((*((*obj).parent)).density)))
        if nd ne 0 then dens=(*((*((*obj).parent)).density))
    endelse

    ;*********************
    ;Calcul du alt_min entrant dans la determination de la densite dans le cas du modele 'ionospheric'
    ;*********************
    if (*obj).north then begin
        angle_n=atan((*(*obj).x_n)[2,*,*,*],sqrt((*(*obj).x_n)[0,*,*,*]^2+(*(*obj).x_n)[1,*,*,*]^2))
        alt_min_n=sqrt(1./(cos(angle_n)^2+sin(angle_n)^2/(1-flat)^2))
    endif else if (*obj).south then begin
        angle_s=atan((*(*obj).x_s)[2,*,*,*],sqrt((*(*obj).x_s)[0,*,*,*]^2+(*(*obj).x_s)[1,*,*,*]^2))
        alt_min_s=sqrt(1./(cos(angle_s)^2+sin(angle_s)^2/(1-flat)^2))
    endif
    ;*********************

    for i=0,nd-1 do begin
        case (*(dens[i])).type of
            'stellar': BEGIN
                if (*obj).north then begin
                    (*((*obj).dens_n))[*,*,*]=(*((*obj).dens_n))[*,*,*]+(*(dens[i])).rho0/total((*((*obj).x_n))^2,1)
                endif else if (*obj).south then begin
                    (*((*obj).dens_s))[*,*,*]=(*((*obj).dens_s))[*,*,*]+(*(dens[i])).rho0/total((*((*obj).x_s))^2,1)
                endif
                END
            'ionospheric': BEGIN
                if (*obj).north then begin
                    (*((*obj).dens_n))[*,*,*]=(*((*obj).dens_n))[*,*,*]+(*(dens[i])).rho0*$
                        exp(-((sqrt(total((*((*obj).x_n))^2,1))-(alt_min_n+(*(dens[i])).perp))>0)/((*(dens[i])).height))
                endif else if (*obj).south then begin
                    (*((*obj).dens_s))[*,*,*]=(*((*obj).dens_s))[*,*,*]+(*(dens[i])).rho0*$
                        exp(-((sqrt(total((*((*obj).x_s))^2,1))-(alt_min_s+(*(dens[i])).perp))>0)/((*(dens[i])).height))
                endif
                END
            'torus': BEGIN
                if (*obj).north then begin
                    (*((*obj).dens_n))[*,*,*]=(*((*obj).dens_n))[*,*,*]+(*(dens[i])).rho0*$
                        exp(-sqrt((sqrt(total(((*((*obj).x_n))[0:1,*,*,*])^2,1))-(*(dens[i])).perp)^2+$
                        ((*((*obj).x_n))[2,*,*,*])^2)/(*(dens[i])).height)
                endif else if (*obj).south then begin
                    (*((*obj).dens_s))[*,*,*]=(*((*obj).dens_s))[*,*,*]+(*(dens[i])).rho0*$
                        exp(-sqrt((sqrt(total(((*((*obj).x_s))[0:1,*,*,*])^2,1))-(*(dens[i])).perp)^2+$
                        ((*((*obj).x_s))[2,*,*,*])^2)/(*(dens[i])).height)
                endif
                END
            'disk' : BEGIN
                if (*obj).north then begin 
                    (*((*obj).dens_n))[*,*,*]=(*((*obj).dens_n))[*,*,*]+(*(dens[i])).rho0*$
                        exp(-(sqrt(total(((*((*obj).x_n))[0:1,*,*,*])^2,1)))/(*(dens[i])).perp)*$
                        exp(-(sqrt(((*((*obj).x_n))[2,*,*,*])^2))/(*(dens[i])).height) 
                endif else if (*obj).south then begin
                    (*((*obj).dens_s))[*,*,*]=(*((*obj).dens_s))[*,*,*]+(*(dens[i])).rho0*$
                        exp(-(sqrt(total(((*((*obj).x_s))[0:1,*,*,*])^2,1)))/(*(dens[i])).perp)*$
                        exp(-(sqrt(((*((*obj).x_s))[2,*,*,*])^2))/(*(dens[i])).height)
                endif
                END
        endcase
    ; fin boucle densite
    endfor

    ;w_p^2/w_c^2
    if (*obj).north then (*((*obj).dens_n))[*,*,*]=((0.009*sqrt((*((*obj).dens_n))[*,*,*]))/rebin(*parameters.freq.freq_tab,parameters.freq.n_freq,360,(*obj).nlat))^2 $
    else if (*obj).south then (*((*obj).dens_s))[*,*,*]=((0.009*sqrt((*((*obj).dens_s))[*,*,*]))/rebin(*parameters.freq.freq_tab,parameters.freq.n_freq,360,(*obj).nlat))^2 
end


;+
; ************************************************************** 
; PRO INIT_FIELD
; 
; This procedure initializes the FIELD processing part of ExPRES
; 
; :Params:
;    obj: in, required, type=pointer
;    parameters: in, required, type=array
;-

pro init_field,obj,parameters

(*obj).folder=(*obj).folder+'/'
tmp=fltarr(360)
(*obj).latitude=fltarr(360)+(*obj).oval_lat0

if STRTRIM((*obj).file_lat,2) ne '' then begin
    openr,unit,(*obj).file_lat,/get_lun
    readu,unit,tmp
    close,unit & free_lun,unit
    (*obj).latitude=tmp
endif

if STRTRIM((*obj).file_lg,2) ne '' then begin
    openr,unit,(*obj).file_lg,/get_lun
    readu,unit,tmp
    close,unit & free_lun,unit
    (*obj).longitude=tmp
endif

(*((*obj).grad_b_eq))=fltarr(2,360,(*obj).nlat)
(*((*obj).grad_b_in))=fltarr(2,360,(*obj).nlat)
(*((*obj).fmax))=fltarr(2,360,(*obj).nlat)
(*((*obj).fmaxCMI))=fltarr(2,360,(*obj).nlat)
(*((*obj).feq))=fltarr(2,360,(*obj).nlat)

if (*obj).north then begin
    (*((*obj).b_n))=dblarr(3,parameters.freq.n_freq,360,(*obj).nlat)
    (*((*obj).bz_n))=dblarr(3,parameters.freq.n_freq,360,(*obj).nlat)
    (*((*obj).x_n))=dblarr(3,parameters.freq.n_freq,360,(*obj).nlat)
    (*((*obj).gb_n))=dblarr(parameters.freq.n_freq,360,(*obj).nlat)
    (*((*obj).dens_n))=dblarr(parameters.freq.n_freq,360,(*obj).nlat)
    ff=(*(parameters.freq.freq_tab))

    if (*obj).sat then mfl_auto=(*((*((*obj).parent)).parent)).mfl $
        else mfl_auto=(*((*obj).parent)).mfl

    if STRMATCH(mfl_auto, 'auto', /FOLD_CASE) then begin
        for ilat=0,(*obj).nlat-1 do begin
            for ilongitude=0,359 do begin
                read_Bfield_and_density_from_user, obj, ilat, ilongitude, x_read, b_read, bz_read, gb_read, f_read, density

                ; # *******************************************
                ;# if density is included in the file and asked to be used by the user, we deal with the density here instead of later:
                if (*obj).sat then begin
                    nd=n_elements((*((*((*((*obj).parent)).parent)).density)))
                    if nd ne 0 then dens=(*((*((*((*obj).parent)).parent)).density))
                endif else begin
                    nd=n_elements((*((*((*obj).parent)).density)))
                    if nd ne 0 then dens=(*((*((*obj).parent)).density))
                endelse
                if nd eq 1 then $
                    if STRMATCH((*(dens)).type, 'auto', /FOLD_CASE) then $
                        (*((*obj).dens_n))[*,ilongitude,ilat] = interpol(density, f_read, ff)
                ; # *******************************************
                
                for k=0,2 do begin
                    (*((*obj).b_n))[k,*,ilongitude,ilat] = interpol(b_read(k,*),f_read,ff)
                    (*((*obj).x_n))[k,*,ilongitude,ilat] = interpol(x_read(k,*),f_read,ff)
                    (*((*obj).bz_n))[k,*,ilongitude,ilat] = interpol(bz_read(k,*),f_read,ff)
                    if (*obj).sat then (*((*obj).x_n))[k,*,ilongitude,ilat]=(*((*obj).x_n))[k,*,ilongitude,ilat]*(*((*((*obj).parent)).parent)).radius $
                        else (*((*obj).x_n))[k,*,ilongitude,ilat]=(*((*obj).x_n))[k,*,ilongitude,ilat]*(*((*obj).parent)).radius
                endfor
                (*((*obj).gb_n))[*,ilongitude,ilat] = interpol(gb_read,f_read,ff)

                ;*********************
                ;calculion of fmax
                ;*********************
                fmax_calculation, obj, x_read, f_read, ilongitude, ilat
            endfor
            ; # **** smoothing value of fmax                        
            (*((*obj).fmax))[0,*,i]=smooth(smooth(smooth(smooth((*((*obj).fmax))[0,*,i],5),5),5),5)
        endfor
    endif else begin
        for i=0,(*obj).nlat-1 do begin
            for j=0,359 do begin
                if strmid((*obj).folder,0,6) eq 'Dipole' then begin 
                    dipolar_field_N,(*obj).folder,obj,ff,fix(i+(*obj).l_min-(*obj).loffset),axisym,i,j 
                    alt_min=1.
                endif else begin
                    axisym=INTEROGATE_FIELD((*obj).folder,STRTRIM(STRING(fix(i+(*obj).l_min-(*obj).loffset)),2),'')
                    if (axisym and (j eq 0)) or ~axisym then begin
                        ;*************************************
                        ;test : lecture ligne de champ version de serpe 5.0
                        if axisym then file=(*obj).folder+STRTRIM(STRING(fix(i+(*obj).l_min-(*obj).loffset)),2)+'.lsr' $
                            else file=(*obj).folder+STRTRIM(STRING(fix(i+(*obj).l_min-(*obj).loffset)),2)+'/'+STRTRIM(STRING(j),2)+'.lsr'
                        ;*************************************				
                        n=0L
                        openr,unit, file,/get_lun,/swap_if_little_endian
                        readu,unit,n
                        b_read      = fltarr(3,n)
                        f_read      = fltarr(n)
                        x_read      = fltarr(3,n)
                        gb_read     = fltarr(n)
                        bz_read      =fltarr(3,n)
                        sc_gb_read  = fltarr(n)
                        xt          = fltarr(n)
                        readu,unit, xt
                        x_read(0,*) = xt
                        readu,unit, xt
                        x_read(1,*) = xt
                        readu,unit, xt
                        x_read(2,*) = xt
                        xt          = 0
                        readu,unit, b_read
                        readu,unit, f_read
                        readu,unit,sc_gb_read
                        readu,unit,bz_read
                        readu,unit,gb_read
                        close, unit & free_lun, unit

                        for k=0,2 do begin
                            (*((*obj).b_n))[k,*,j,i] = interpol(b_read(k,*),f_read,ff)
                            (*((*obj).x_n))[k,*,j,i] = interpol(x_read(k,*),f_read,ff)
                            (*((*obj).bz_n))[k,*,j,i] = interpol(bz_read(k,*),f_read,ff)
                            if (*obj).sat then (*((*obj).x_n))[k,*,j,i]=(*((*obj).x_n))[k,*,j,i]*(*((*((*obj).parent)).parent)).radius $
                                else (*((*obj).x_n))[k,*,j,i]=(*((*obj).x_n))[k,*,j,i]*(*((*obj).parent)).radius
                        endfor
                        (*((*obj).gb_n))[*,j,i] = interpol(gb_read,f_read,ff)
                    endif

                    if axisym then begin
                        rot=[[cos(!pi/180.*j),-sin(!pi/180.*j),0.],[sin(!pi/180.*j),cos(!pi/180.*j),0.],[0.,0.,1.]]
                        for k=0,parameters.freq.n_freq-1 do begin
                            (*((*obj).b_n))[*,k,j,i] =rot#(*((*obj).b_n))[*,k,0,i]
                            (*((*obj).bz_n))[*,k,j,i] =rot#(*((*obj).bz_n))[*,k,0,i]
                            (*((*obj).x_n))[*,k,j,i] =rot#(*((*obj).x_n))[*,k,0,i]
                        endfor
                    endif
						
    			
                    ;*********************
                    ;calculion of fmax
                    ;*********************
                    fmax_calculation, obj, x_read, f_read, j, i
                endelse
            ; end loop on longitude
            endfor
            ; # **** smoothing value of fmax						
            (*((*obj).fmax))[0,*,i]=smooth(smooth(smooth(smooth((*((*obj).fmax))[0,*,i],5),5),5),5)

        ; end loop on latitude
        endfor			
    endelse
; #*** end if loop on northern hemisphere
endif			

if (*obj).south then begin
    (*((*obj).b_s))=fltarr(3,parameters.freq.n_freq,360,(*obj).nlat)
    (*((*obj).bz_s))=fltarr(3,parameters.freq.n_freq,360,(*obj).nlat)
    (*((*obj).x_s))=fltarr(3,parameters.freq.n_freq,360,(*obj).nlat)
    (*((*obj).gb_s))=fltarr(parameters.freq.n_freq,360,(*obj).nlat)
    (*((*obj).dens_s))=fltarr(parameters.freq.n_freq,360,(*obj).nlat)
    ff=(*(parameters.freq.freq_tab))

    if (*obj).sat then mfl_auto=(*((*((*obj).parent)).parent)).mfl $
        else mfl_auto=(*((*obj).parent)).mfl
    if STRMATCH(mfl_auto, 'auto', /FOLD_CASE) then begin
        for ilat=0,(*obj).nlat-1 do begin
            for ilongitude=0,359 do begin
                read_Bfield_and_density_from_user, obj, ilat, ilongitude, x_read, b_read, bz_read, gb_read, f_read, density

                ; # *******************************************
                ;# if density is included in the file and asked to be used by the user, we deal with the density here instead of later:
                if (*obj).sat then begin
                    nd=n_elements((*((*((*((*obj).parent)).parent)).density)))
                    if nd ne 0 then dens=(*((*((*((*obj).parent)).parent)).density))
                endif else begin
                    nd=n_elements((*((*((*obj).parent)).density)))
                    if nd ne 0 then dens=(*((*((*obj).parent)).density))
                endelse
                if nd eq 1 then $
                    if STRMATCH((*(dens)).type, 'auto', /FOLD_CASE) then $
                    (*((*obj).dens_s))[*,ilongitude,ilat] = interpol(density, f_read, ff)
                ; # *******************************************
                
                for k=0,2 do begin
                    (*((*obj).b_s))[k,*,ilongitude,ilat] = interpol(b_read(k,*),f_read,ff)
                    (*((*obj).x_s))[k,*,ilongitude,ilat] = interpol(x_read(k,*),f_read,ff)
                    (*((*obj).bz_s))[k,*,ilongitude,ilat] = interpol(bz_read(k,*),f_read,ff)
                    if (*obj).sat then (*((*obj).x_s))[k,*,ilongitude,ilat]=(*((*obj).x_s))[k,*,ilongitude,ilat]*(*((*((*obj).parent)).parent)).radius $
                        else (*((*obj).x_s))[k,*,ilongitude,ilat]=(*((*obj).x_s))[k,*,ilongitude,ilat]*(*((*obj).parent)).radius
                endfor
                (*((*obj).gb_s))[*,ilongitude,ilat] = interpol(gb_read,f_read,ff)

                ;*********************
                ;calculion of fmax
                ;*********************
                fmax_calculation, obj, x_read, f_read, ilongitude, ilat
            endfor
            ; # **** smoothing value of fmax                        
            (*((*obj).fmax))[1,*,i]=smooth(smooth(smooth(smooth((*((*obj).fmax))[1,*,i],5),5),5),5)
        endfor
    endif else begin
        for i=0,(*obj).nlat-1 do begin
            for j=0,359 do begin
                if strmid((*obj).folder,0,6) eq 'Dipole' then begin
                    dipolar_field_S,(*obj).folder,obj,ff,fix(i+(*obj).l_min-(*obj).loffset),axisym,i,j 
                    alt_min=1.
                endif else begin
                    axisym=INTEROGATE_FIELD((*obj).folder,STRTRIM(STRING(fix(i+(*obj).l_min-(*obj).loffset)),2),'-')
                    if (axisym and (j eq 0)) or ~axisym then begin
                        if axisym then file=(*obj).folder+'-'+STRTRIM(STRING(fix(i+(*obj).l_min-(*obj).loffset)),2)+'.lsr' $
                            else file=(*obj).folder+STRTRIM(STRING(fix(i+(*obj).l_min-(*obj).loffset)),2)+'/-'+STRTRIM(STRING(j),2)+'.lsr'
                        n=0L
                        openr,unit, file,/get_lun,/swap_if_little_endian
                        readu,unit,n
                        b_read      = fltarr(3,n)
                        f_read      = fltarr(n)
                        gb_read     = fltarr(n) 
                        bz_read      = fltarr(3,n)
                        sc_gb_read  = fltarr(n)
                        x_read      = fltarr(3,n)
                        xt          = fltarr(n)
                        readu,unit, xt
                        x_read(0,*) = xt
                        readu,unit, xt
                        x_read(1,*) = xt
                        readu,unit, xt
                        x_read(2,*) = xt
                        xt          = 0
                        readu,unit, b_read
                        readu,unit, f_read
                        readu,unit,sc_gb_read
                        readu,unit,bz_read
                        readu,unit,gb_read
                        close, unit & free_lun, unit

                        for k=0,2 do begin
                            (*((*obj).b_s))[k,*,j,i] = interpol(b_read(k,*),f_read,ff)
                            (*((*obj).x_s))[k,*,j,i] = interpol(x_read(k,*),f_read,ff)
                            (*((*obj).bz_s))[k,*,j,i] = interpol(bz_read(k,*),f_read,ff)
                            if (*obj).sat then (*((*obj).x_s))[k,*,j,i]=(*((*obj).x_s))[k,*,j,i]*(*((*((*obj).parent)).parent)).radius $
                                else (*((*obj).x_s))[k,*,j,i]=(*((*obj).x_s))[k,*,j,i]*(*((*obj).parent)).radius
                        endfor
                        (*((*obj).gb_s))[*,j,i] = interpol(gb_read,f_read,ff)
                    endif

                    if axisym then begin
                        rot=[[cos(!pi/180.*j),-sin(!pi/180.*j),0.],[sin(!pi/180.*j),cos(!pi/180.*j),0.],[0.,0.,1.]]
                        for k=0,parameters.freq.n_freq-1 do begin
                            (*((*obj).b_s))[*,k,j,i] =rot#(*((*obj).b_s))[*,k,0,i]
                            (*((*obj).bz_s))[*,k,j,i] =rot#(*((*obj).bz_s))[*,k,0,i]
                            (*((*obj).x_s))[*,k,j,i] =rot#(*((*obj).x_s))[*,k,0,i]
                        endfor
                    endif
                    ;*********************
                    ;calculion of fmax (partie SUD)
                    ;*********************
                    fmax_calculation, obj, x_read, f_read, j, i
                endelse
            ; end loop on longitude
            endfor
            ; # **** smoothing value of fmax
            (*((*obj).fmax))[1,*,i]=smooth(smooth(smooth(smooth((*((*obj).fmax))[1,*,i],5),5),5),5)
        ; end loop on latitude
        endfor 						
    endelse
; fin boucle hemisphere sud
endif

; # *** Calculation of the density along the magnetic field lines
if (*obj).sat then begin
        nd=n_elements((*((*((*((*obj).parent)).parent)).density)))
        if nd ne 0 then dens=(*((*((*((*obj).parent)).parent)).density))
    endif else begin
        nd=n_elements((*((*((*obj).parent)).density)))
        if nd ne 0 then dens=(*((*((*obj).parent)).density))
    endelse
 for idens=0,nd-1 do $
    if STRMATCH((*(dens[idens])).type, 'auto', /FOLD_CASE) eq 0 then $
        density_calculation, obj, parameters


; # *** Calculation of the maximal frequency at the footprint of the magnetic field lines, based on the w_p/w_c ratio
fmaxcmi_calculation, obj, parameters


return;plot,sqrt(total((*((*obj).x_s))^2,1)),alog((*((*obj).dens_s))[*,90,*])


end

;************************************************************** CB_ROT_FIELD
pro cb_rot_field,obj,parameters
t=fix(parameters.time.istep)
;fait tourner le champ

if (*obj).sat eq 0 then (*obj).pos_xyz=(*((*((*obj).parent)).trajectory_xyz))[*,t]
if (*obj).sat eq 1 then (*obj).pos_xyz=(*((*((*((*obj).parent)).parent)).trajectory_xyz))[*,t]
if (*obj).sat eq 0 then (*obj).rot=(*((*obj).parent)).rot else (*obj).rot=(*((*((*obj).parent)).parent)).rot
if ((*obj).sat) eq 1 then begin
(*obj).latitude=fltarr(360)+(*((*((*obj).parent)).trajectory_rtp))[0,t];+(*((*((*((*obj).parent)).parent)).lg))[t]
(*obj).lg=(*((*((*obj).parent)).parent)).lg0+(360.*parameters.time.time/(*((*((*obj).parent)).parent)).period-$
(*((*((*obj).parent)).trajectory_rtp))[2,t]*!radeg) mod 360.
endif
if (*obj).sat eq 0 then begin
	per=(*((*obj).parent)).period
	if ((*obj).lct) eq 1 then begin
		(*obj).lg=(360.*parameters.time.time/per-(*((*obj).parent)).lct[t]) mod 360.
	endif
	if ((*obj).subcor) ne 0 then begin
		(*obj).lg=(360.*parameters.time.time/per*((*obj).subcor)) mod 360.
	endif
endif
if (*obj).lg lt 0. then (*obj).lg=360.+(*obj).lg
end

;************************************************************** DIPOLAR_FIELD


pro dipolar_field_N,name,obj,ff,ls,axisym,i,j
fsb=2.79924835996
bf=ff/fsb
txt=strsplit(name,'_',/EXTRACT)
g=txt[1]
tilt=float(strtrim(txt[2],2))
offset=[float(strtrim(txt[3],2)),float(strtrim(txt[4],2)),float(strtrim(txt[5],2))]
lt_ls=txt[6]

if ((tilt eq 0) and (total(offset^2) eq 0)) then axisym=1b else axisym=0b 

if (lt_ls eq 'lat/') then a=1./sin(ls*!dtor)^2 else begin
a=ls
a=sqrt((a*cos(j*!dtor)-offset[0])^2+(a*sin(j*!dtor)-offset[1])^2)
th=tilt*cos(j*!dtor)*!dtor+atan(offset[2]/a)
a=a/cos(th)^2
endelse

r0=(2.*g/bf*(1.-3/(8.*a)))^(1./3.)
c1=-2.*g/bf*(3.*(r0-1)/(8.*a)+r0^2/(12.*a^2))
c2=(1+2./(3.*bf*r0)*(3./(8.*a*r0)+1./(6.*a^2)))
;tested with a=10, g=9 error (r_th-r)/r_th<10-3 jusqu a r=7 ~10-2 a r=10
r=r0+(c1/c2)/(3.*r0^2) 
theta=asin(sqrt(r/a)) mod (0.5*!pi)
z=r*cos(theta) & x=r*sin(theta)
br=2.*g/(z^2+x^2)^2*z & bt=g/(z^2+x^2)^2*x & b=sqrt(br^2+bt^2)

zp=z+1e-4 & xp=x+1e-4
brz=2.*g/(zp^2+x^2)^2*zp & btz=g/(zp^2+x^2)^2*x & bz=sqrt(brz^2+btz^2)
brx=2.*g/(z^2+xp^2)^2*z & btx=g/(z^2+xp^2)^2*xp & bx=sqrt(brx^2+btx^2)
dbz=b-bz & dbx=b-bx & sc_gb=sqrt(dbz^2+dbx^2)

bz=(br*cos(theta)-bt*sin(theta))/b
bx=(br*sin(theta)+bt*cos(theta))/b
bv=[[bx],[fltarr(n_elements(bz))],[bz]]
gb=[[dbx],[fltarr(n_elements(bz))],[dbz]]
gb=gb/rebin(sqrt(dbx^2+dbz^2),n_elements(gb[*,0]),3)
gb=atan(total(gb*[[-bz],[fltarr(n_elements(bz))],[bx]],2),total(gb*bv,2))

bv=[[(bx*cos(tilt*!dtor)+bz*sin(tilt*!dtor))*cos((180-j)*!dtor+!pi)],[(bx*cos(tilt*!dtor)+bz*sin(tilt*!dtor))*sin((180-j)*!dtor+!pi)],[(bz*cos(tilt*!dtor)-bx*sin(tilt*!dtor))]]
bz=[[(-bz*cos(tilt*!dtor)+bx*sin(tilt*!dtor))*cos((180-j)*!dtor+!pi)],[(-bz*cos(tilt*!dtor)+bx*sin(tilt*!dtor))*sin((180-j)*!dtor+!pi)],[(bx*cos(tilt*!dtor)+bz*sin(tilt*!dtor))]]
x=[[(x*cos(tilt*!dtor)+z*sin(tilt*!dtor))*cos((180-j)*!dtor+!pi)],[(x*cos(tilt*!dtor)+z*sin(tilt*!dtor))*sin((180-j)*!dtor+!pi)],[(z*cos(tilt*!dtor)-x*sin(tilt*!dtor))]]+rebin(offset,3,n_elements(bx))

(*((*obj).b_n))[*,*,j,i] = transpose(bv)
(*((*obj).x_n))[*,*,j,i] = transpose(x)
(*((*obj).bz_n))[*,*,j,i] = transpose(bz)
if (*obj).sat then (*((*obj).x_n))[*,*,j,i]=(*((*obj).x_n))[*,*,j,i]*(*((*((*obj).parent)).parent)).radius $
  else (*((*obj).x_n))[*,*,j,i]=(*((*obj).x_n))[*,*,j,i]*(*((*obj).parent)).radius
(*((*obj).gb_n))[*,j,i] = gb
theta=(asin(sqrt(1/a)) mod (0.5*!pi))
z=cos(theta) & x=sin(theta)
br=2.*g/(z^2+x^2)^2*z & bt=g/(z^2+x^2)^2*x & b=sqrt(br^2+bt^2)
stop,'Verifier calcul de fmax (CL/LL), 16/04/2015'
    (*((*obj).fmax))[0,j,i]=b*fsb
z=0 & x=a
br=2.*g/(z^2+x^2)^2*z & bt=g/(z^2+x^2)^2*x & b=sqrt(br^2+bt^2)
    (*((*obj).feq))[0,j,i]=b*fsb

return
end

pro dipolar_field_S,name,obj,ff,ls,axisym,i,j
fsb=2.79924835996
bf=ff/fsb
txt=strsplit(name,'_',/EXTRACT)
g=txt[1]
tilt=float(strtrim(txt[2],2))
offset=[float(strtrim(txt[3],2)),float(strtrim(txt[4],2)),float(strtrim(txt[5],2))]
lt_ls=txt[6]

;r=asin2theta
if ((tilt eq 0) and (total(offset^2) eq 0)) then axisym=1b else axisym=0b 

if (lt_ls eq 'lat/') then a=1./sin(ls*!dtor)^2 else begin
a=ls
a=sqrt((a*cos(j*!dtor)-offset[0])^2+(a*sin(j*!dtor)-offset[1])^2)
th=tilt*cos(j*!dtor)*!dtor+atan(offset[2]/a)
a=a/cos(th)^2
endelse
r0=(2.*g/bf*(1.-3/(8.*a)))^(1./3.)
c1=-2.*g/bf*(3.*(r0-1)/(8.*a)+r0^2/(12.*a^2))
c2=(1+2./(3.*bf*r0)*(3./(8.*a*r0)+1./(6.*a^2)))
r=r0+(c1/c2)/(3.*r0^2) 
;tested with a=10, g=9 error (r_th-r)/r_th<10-3 jusqu a r=7 ~10-2 a r=10
theta=!pi-((asin(sqrt(r/a)) mod (0.5*!pi)))
z=r*cos(theta) & x=r*sin(theta)
br=2.*g/(z^2+x^2)^2*z & bt=g/(z^2+x^2)^2*x & b=sqrt(br^2+bt^2)

zp=z+1e-4 & xp=x+1e-4
brz=2.*g/(zp^2+x^2)^2*zp & btz=g/(zp^2+x^2)^2*x & bz=sqrt(brz^2+btz^2)
brx=2.*g/(z^2+xp^2)^2*z & btx=g/(z^2+xp^2)^2*xp & bx=sqrt(brx^2+btx^2)
dbz=b-bz & dbx=b-bx & sc_gb=sqrt(dbz^2+dbx^2)

bz=(br*cos(theta)-bt*sin(theta))/b
bx=(br*sin(theta)+bt*cos(theta))/b
bv=[[bx],[fltarr(n_elements(bz))],[bz]]
gb=[[dbx],[fltarr(n_elements(bz))],[dbz]]
gb=gb/rebin(sc_gb,n_elements(gb[*,0]),3)
gb=atan(total(gb*[[-bz],[fltarr(n_elements(bz))],[bx]],2),-total(gb*bv,2))


bv=[[(bx*cos(tilt*!dtor)+bz*sin(tilt*!dtor))*cos((180-j)*!dtor+!pi)],[(bx*cos(tilt*!dtor)+bz*sin(tilt*!dtor))*sin((180-j)*!dtor+!pi)],[(bz*cos(tilt*!dtor)-bx*sin(tilt*!dtor))]]
bz=[[(-bz*cos(tilt*!dtor)+bx*sin(tilt*!dtor))*cos((180-j)*!dtor+!pi)],[(-bz*cos(tilt*!dtor)+bx*sin(tilt*!dtor))*sin((180-j)*!dtor+!pi)],[(bx*cos(tilt*!dtor)+bz*sin(tilt*!dtor))]]
x=[[(x*cos(tilt*!dtor)+z*sin(tilt*!dtor))*cos((180-j)*!dtor+!pi)],[(x*cos(tilt*!dtor)+z*sin(tilt*!dtor))*sin((180-j)*!dtor+!pi)],[(z*cos(tilt*!dtor)-x*sin(tilt*!dtor))]]+rebin(offset,3,n_elements(bx))

(*((*obj).b_s))[*,*,j,i] = transpose(bv)
(*((*obj).x_s))[*,*,j,i] = transpose(x)
(*((*obj).bz_s))[*,*,j,i] = transpose(bz)
if (*obj).sat then (*((*obj).x_s))[*,*,j,i]=(*((*obj).x_s))[*,*,j,i]*(*((*((*obj).parent)).parent)).radius $
  else (*((*obj).x_s))[*,*,j,i]=(*((*obj).x_s))[*,*,j,i]*(*((*obj).parent)).radius
(*((*obj).gb_s))[*,j,i] = gb
theta=!pi-(asin(sqrt(1/a)) mod (0.5*!pi))
z=cos(theta) & x=sin(theta)
br=2.*g/(z^2+x^2)^2*z & bt=g/(z^2+x^2)^2*x & b=sqrt(br^2+bt^2)
    (*((*obj).fmax))[1,j,i]=b*fsb
stop,'Verifier calcul de fmax (CL/LL), 16/04/2015'
z=0 & x=a
br=2.*g/(z^2+x^2)^2*z & bt=g/(z^2+x^2)^2*x & b=sqrt(br^2+bt^2)
    (*((*obj).feq))[1,j,i]=b*fsb
return
end
