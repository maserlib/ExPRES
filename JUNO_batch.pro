print,'Intializing path for JUNO_RAR simulations...'
!path = !path+':./pro_V3.4:./mag'
print,'Launching JUNO'
;print,'with /VERB keyword.'

;!except=2

t=systime(/seconds)
JUNO;,/verb		; tableau spectre dynamique en sortie
print,systime(/seconds)-t