pro COEFF_IGRF2000,g,h,n,dip,crt,tdip;coefficients du Dipole de 7 Gauss (Z96);g et h:coeff. des polynomes de Legendre;n:ordre du developpement;dip:position du dipole/axe de rotation;crt:anneau de courantG=fltarr(6,6) & H=fltarr(6,6)n=3G(1,0)=-0.29615G(1,1)=-0.01728 &  H(1,1)=0.05186G(2,0)=-0.02267G(2,1)=0.03072  &  H(2,1)=-0.02478G(2,2)=0.01672  &  H(2,2)=-0.00458G(3,0)=0.01341G(3,1)=-0.02290 &  H(3,1)=-0.00227G(3,2)=0.01253  &  H(3,2)=0.00296G(3,3)=0.00715  &  H(3,3)=-0.00492; tilt = 11� et longitude ouest prise = 100�dip=[11,100]crt=[0,0,0,0]; tdip = matrice de passage de l'axe magn�tique � l'axe de rotation (a=-100/b=11) = ; [cosa.cosb -sina cosa.sinb]; [sina.cosb  cosa sina.sinb]; [    -sinb     0      cosb]; Application num�rique � rev�rifier avant utilisation  tdip=[[-0.170458,0.984808,-0.0331336],$	[-0.966714,-0.173648,-0.187910],$	[-0.190809,0.,0.981627]]returnend