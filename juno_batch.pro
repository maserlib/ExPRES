print,'Intializing path for JUNO_RAR simulations...'
;path_root_juno = 'C:\Documents and Settings\Seb\Bureau\idl\Simu-JUNO'
path_root_juno = getenv('ROOT_JUNO')
!path = !path+':'+path_root_juno+'/pro_V4.0:'+path_root_juno+'\mag'
print,'Launching JUNO'
;print,'with /VERB keyword.'

;!except=2

t=systime(/seconds)
parameters = {JUNO_PARAMETERS}
parameters.working_dir=path_root_juno
parameters.display_mgr='X' ;mettre 'X' pour linux/UNIX ou MAC OS X
print,'Launching Juno with Loops on n parameters'
JUNO,parameters=parameters;,/verb     ; tableau spectre dynamique en sortie
print,systime(/seconds)-t
