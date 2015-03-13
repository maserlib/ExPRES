print,'Intializing path for JUNO_RAR simulations...'
path_root_juno = getenv('ROOT_JUNO')
!path = !path+':'+path_root_juno+'/pro_V3.6:'+path_root_juno+'/mag'
print,'Launching JUNO'
;print,'with /VERB keyword.'

;!except=2

t=systime(/seconds)
print,'Launching Juno with Loops on n parameters'
JUNO;,/verb		; tableau spectre dynamique en sortie
print,systime(/seconds)-t