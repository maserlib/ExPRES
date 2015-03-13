print,'Intializing path for JUNO_RAR simulations...'
path_root_juno = getenv('ROOT_JUNO')
!path = !path+':'+path_root_juno+'/pro_V3.5:'+path_root_juno+'/mag'
print,'Launching JUNO'
;print,'with /VERB keyword.'

;!except=2

t=systime(/seconds)
JUNO;,/verb		; tableau spectre dynamique en sortie
print,systime(/seconds)-t