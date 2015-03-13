; efface les common
.full_reset_session		

!path = 'pro_V2:'+!path
.run ./mag/xyz_to_rtp
.run JUNO_INIT
; .run JUNO_LIBS
; .run JUNO_MAIN
.run JUNO_routines
t=systime(/seconds)
JUNO, spdyn;,/verb		; tableau spectre dynamique en sortie
print,systime(/seconds)-t