;***********************************************************
;***                                                     ***
;***         SERPE V6.0                                  ***
;***                                                     ***
;***********************************************************
;***                                                     ***
;***       MODULE: MAIN_LESIA                            ***
;***                                                     ***
;***     STRREPLACE                                      ***
;***     XYZ_TO_RTP                                      ***
;***     TOTALE                                          ***
;***     FIND_MIN                                        ***
;***     MAIN                                            ***
;***     INIT                                            ***
;***     CALLBACK                                        ***
;***     FINALIZE                                        ***
;***                                                     ***
;***********************************************************

;************************************************************** STRREPLACE
pro STRREPLACE, Strings, Find1, Replacement1

;   Check integrity of input parameter

         NP        = N_PARAMS()
         if (NP ne 3) then message,'Must be called with 3 parameters, '+$
                   'Strings, Find, Replacement'

         sz        = SIZE(Strings)
         ns        = n_elements(sz)
         if (sz(ns-2) ne 7) then message,'Parameter must be of string type.'

         Find      = STRING(Find1)
         pos       = STRPOS(Strings,Find)
         here      = WHERE(pos ne -1, nreplace)

         if (nreplace eq 0) then return

         Replacement=STRING(Replacement1)
         Flen      = strlen(Find)
         for i=0,nreplace-1 do begin

              j         = here(i)
              prefix    = STRMID(Strings(j),0,pos(j))
              suffix    = STRMID(Strings(j),pos(j)+Flen,$
                                       strlen(Strings(j))-(pos(j)+Flen))
              Strings(j) = prefix + replacement + suffix
         endfor
end


;************************************************************** XYZ_TO_RTP
FUNCTION XYZ_TO_RTP, xyz
; x,y,z & r en Rp
; theta, phi en rad
  x=reform(xyz(0,*)*1.) & y=reform(xyz(1,*)*1.) & z=reform(xyz(2,*)*1.)
  i=where(x eq 0.) & if i(0) ne -1 then x(i)=0.000001
  i=where(y eq 0.) & if i(0) ne -1 then y(i)=0.000001
  r=sqrt(x^2+y^2+z^2)
  theta=!pi/2.-atan(z/sqrt(x^2+y^2))
  phi=atan(y/x)
  i=where(x lt 0 and y gt 0) & if i(0) ne -1 then phi(i)=phi(i)+!pi
  i=where(x lt 0 and y lt 0) & if i(0) ne -1 then phi(i)=phi(i)+!pi
  i=where(x gt 0 and y lt 0) & if i(0) ne -1 then phi(i)=phi(i)+2*!pi
return,transpose([[r],[theta],[phi]])
end

;************************************************************** TOTALE
function totale,a,b
;IDL considere qu'un tableau dont la derniere dimension a une taille 1
;n'a pas cette dimension. Donc cette fonction  corrige un bug IDL
if size(a,/n_dim) lt b then return,a
return,total(a,b)
end

;************************************************************** FIND_MIN
function find_min,x1,x2,dist
z1=where((x1 lt 0.) or (x1 gt dist))
z2=where((x2 lt 0.) or (x2 gt dist))
z=fltarr(n_elements(x1))
if z1[0] ne -1 then z[z1]=1
if z2[0] ne -1 then z[z2]=z[z2]+2
w=where((z eq 0) or (z eq 3))
if w[0] ne -1 then for h=0,n_elements(w)-1 do z[w[h]]=min([(x1[w[h]]>0.)<dist[w[h]],(x2[w[h]]>0.)<dist[w[h]]])
w=where(z eq 1)
if w[0] ne -1 then z[w]=x1[w]
w=where(z eq 2)
if w[0] ne -1 then z[w]=x2[w]
return,z
end



;**************************************************************
;************************************************************** MAIN
pro main,buf
;**************************************************************
; Main routine, starting serpe 
;**************************************************************
t=systime(/seconds)
buf='' & read,buf
tmp=(STRSPLIT(buf,'/',/EXTRACT))
tmp=tmp[n_elements(tmp)-1]
print,'+++++++++++++++ SERPE SIMULATION #',tmp,' +++++++++++++++'
print,buf
buf2=buf;+'*.srp'
name_r=FILE_SEARCH(buf2)
name_r=name_r[0]

if name_r eq '' then message,'Simulation File not found'

name_rold=name_r
STRREPLACE,name_r,'queue', 'on-going'
comd='mv '+name_rold+' '+name_r
spawn,comd


adresse_lib='/Library/Server/Web/Data/Sites/Default/maser/serpe/data'
;adresse_lib='/Library/Server/Documents/maser/serpe/data/'
;adresse_lib='/home/seb/Bureau/Work/SERPE/'

case strlowcase(strmid(name_r,strlen(name_r)-3)) of
  'srp' : read_save,adresse_lib,name_r,parameters
  'son' : read_save_json,adresse_lib,name_r,parameters
  else: message,'Illegal input file name.'
endcase 

;restore,name_r
print,'Simulation file ok'
print,'Results will be saved under the name ',parameters.out


if parameters.freq.log then begin
parameters.freq.step=(alog(parameters.freq.fmax)-alog(parameters.freq.fmin))/(parameters.freq.n_freq-1)
parameters.freq.freq_tab=ptr_new(exp(findgen(parameters.freq.n_freq)*parameters.freq.step+alog(parameters.freq.fmin)))
endif else begin
parameters.freq.step=(parameters.freq.fmax-parameters.freq.fmin)/(parameters.freq.n_freq-1)
parameters.freq.freq_tab=ptr_new(findgen(parameters.freq.n_freq)*parameters.freq.step+parameters.freq.fmin)
endelse

print,'Initialization'
INIT,parameters

print,'Looping...'
for i=0,parameters.time.n_step-1 do begin
parameters.time.time=float(i)*parameters.time.step+parameters.time.t0
parameters.time.istep=i
print,'time',parameters.time.time
CALLBACK,parameters
endfor

print,'Finalization'
FINALIZE,parameters
parameters=''
HEAP_GC
print,"That's pretty much it..."
end


;**************************************************************
;************************************************************** INIT
pro init,parameters
;**************************************************************
; Calls all INIT procedures for selected objects 
;**************************************************************
nobj=n_elements(parameters.objects)
for i=0,nobj-1 do begin
it=(*(parameters.objects[i])).it
if it[0] ne '' then for j=0,n_elements(it)-1 do CALL_PROCEDURE,it[j],parameters.objects[i],parameters
endfor
end

;**************************************************************
;************************************************************** CALLBACK
pro callback,parameters
;**************************************************************
; Calls all CALLBACK procedures for the selected objects
;**************************************************************
nobj=n_elements(parameters.objects)

for i=0,nobj-1 do begin
cb=(*(parameters.objects[i])).cb
if cb[0] ne '' then for j=0,n_elements(cb)-1 do CALL_PROCEDURE,cb[j],parameters.objects[i],parameters
endfor
end

;**************************************************************
;************************************************************** FINALIZE
pro finalize,parameters
;**************************************************************
; Calls all FINALIZE procedures for the selected objects
;**************************************************************
nobj=n_elements(parameters.objects)

for i=0,nobj-1 do begin
fz=(*(parameters.objects[i])).fz
if fz[0] ne '' then for j=0,n_elements(fz)-1 do CALL_PROCEDURE,fz[j],parameters.objects[i],parameters
endfor
end

;**************************************************************




