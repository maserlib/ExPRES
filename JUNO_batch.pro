print,'Intializing path for JUNO_RAR simulations...'
!path = !path+':./pro_V3.2:./mag'
print,'Launching JUNO with /VERB keyword.'

t=systime(/seconds)
JUNO,/verb		; tableau spectre dynamique en sortie
print,systime(/seconds)-t