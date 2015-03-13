; ************************************
; *                                  *
; *   Routines de simulation SERPE   *
; *                                  *
; ************************************
; S. Hess (9/2006), P. Zarka (10/2006), B. Cecconi (10/2006)


; ------------------------------------------------------------------------------------
  pro CONVERT, brtp, bxyz, xyz, n
; ------------------------------------------------------------------------------------

  bxyz=brtp*0.
  XYZ_TO_RTP, xyz(0,*), xyz(1,*), xyz(2,*), r, theta, phi
  bxyz(2,*)=cos(theta)*brtp(0,*)-sin(theta)*brtp(1,*)
  bxyz(0,*)=sin(theta)*cos(phi)*brtp(0,*)+cos(theta)*cos(phi)*brtp(1,*)-sin(phi)*brtp(2,*)
  bxyz(1,*)=sin(theta)*sin(phi)*brtp(0,*)+cos(theta)*sin(phi)*brtp(1,*)+cos(phi)*brtp(2,*)

return
end

