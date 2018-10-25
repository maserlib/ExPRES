;***********************************************************
;***                                                     ***
;***         SERPE V6.1                                  ***
;***                                                     ***
;***********************************************************
;***                                                     ***
;***       MODULE: READ_ASCII_FILE                       ***
;***                                                     ***
;***     function: read_ascii_file                       ***
;***                                                     ***
;***     Version history                                 ***
;***     [BC] V6.1: imported from other project          ***
;***                                                     ***
;***********************************************************


; =============================================================================
FUNCTION read_ascii_file,file,nlines

; open file (read mode)
openr,lun,file,/get_lun

; getting number of lines
skip_lun,lun,/eof,/lines,transfer_count=nlines

; creating empty string array
str_raw_data = strarr(nlines)

; back to file start, and read all lines
point_lun,lun,0
readf,lun,str_raw_data

; housekeeping
close,lun
free_lun,lun

; returning string array
return, str_raw_data
end
