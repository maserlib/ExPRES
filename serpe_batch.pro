path_root_serpe = getenv('ROOT_SERPE')
!path = !path+':'+path_root_serpe+'/pro_V4.2:'+path_root_serpe+'\mag'

!except=2
t=systime(/seconds)

parameters = {SERPE_PARAMETERS}
parameters.working_dir=path_root_serpe
parameters.display_mgr='X'                ; 'X' pour linux/UNIX ou MAC OS X

print,'Launching SERPE simulations...'
SERPE,spdyn,parameters=parameters                ; Spdyn en sortie
SERPE_PTR_FREE,parameters
print,'Duration ='+string(systime(/seconds)-t)+' s'

