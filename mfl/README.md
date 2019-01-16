# Magnetic Field Lines for ExPRES

## Available data

Data should be downloaded from http://maser.obspm.fr/support/expres/mfl/ 

The following precomputed datasets are available:

| Model Name | Planet  | Links | Bundles | Reference | 
|------------|-------- |-------|---------|-----------|
| ISaAC      | Jupiter | [ISaAC_lsh](http://maser.obspm.fr/support/expres/mfl/ISaAC_lsh) | [tar.gz](http://maser.obspm.fr/support/expres/mfl/ISaAC_lsh.tar.gz) (6.9 GB) | [Hess et al. 2017](#isaac)|
| JRM09      | Jupiter | [JRM09_lsh](http://maser.obspm.fr/support/expres/mfl/JRM09_lsh) | [tar.gz](http://maser.obspm.fr/support/expres/mfl/JRM09_lsh.tar.gz) (4.0 GB) | [Connerney et al. 2018](#jrm09)|
| O6         | Jupiter | [O6_lsh](http://maser.obspm.fr/support/expres/mfl/O6_lsh) | [tar.gz](http://maser.obspm.fr/support/expres/mfl/O6_lsh.tar.gz) (1.8 GB) | [Connerney et al. 1992](#o6)|
| SPV        | Saturn  | [SPV.lsh](http://maser.obspm.fr/support/expres/mfl/SPV_lsh)<br/>[SPV.lat](http://maser.obspm.fr/support/expres/mfl/SPV_lat) | [tar.gz](http://maser.obspm.fr/support/expres/mfl/SPV_lsh.tar.gz) (2.0 MB)<br/>[tar.gz](http://maser.obspm.fr/support/expres/mfl/SPV_lat.tar.gz) (3.3 MB) | [Davis and Smith. 1990](#spv) | 
| VIP4       | Jupiter | [VIP4_lsh](http://maser.obspm.fr/support/expres/mfl/VIP4_lsh)<br/>[VIP4_lat](http://maser.obspm.fr/support/expres/mfl/VIP4_lat) | [tar.gz](http://maser.obspm.fr/support/expres/mfl/VIP4_lsh.tar.gz) (2.0 GB)<br/>[tar.gz](http://maser.obspm.fr/support/expres/mfl/VIP4_lat.tar.gz) (0.8 GB) | [Connerney et al. 1998](#vip4)|
| VIPAL      | Jupiter | [VIPAL_lsh](http://maser.obspm.fr/support/expres/mfl/VIPAL_lsh) | [tar.gz](http://maser.obspm.fr/support/expres/mfl/VIPAL_lsh.tar.gz) (1.4 GB) | [Hess et al. 2011](#vipal)|
| VIT4       | Jupiter | [VIT4_lsh](http://maser.obspm.fr/support/expres/mfl/VIT4_lsh) | [tar.gz](http://maser.obspm.fr/support/expres/mfl/VIT4_lsh.tar.gz) (1.9 GB) | [Connerney 2007](#vit4) |
| Z3         | Saturn  | [Z3.lsh](http://maser.obspm.fr/support/expres/mfl/Z3_lsh)<br/>[Z3.lat](http://maser.obspm.fr/support/expres/mfl/Z3_lat) | [tar.gz](http://maser.obspm.fr/support/expres/mfl/Z3_lsh.tar.gz) (0.2 MB)<br/>[tar.gz](http://maser.obspm.fr/support/expres/mfl/Z3_lat.tar.gz) (3.4 MB) | [Connerney et al. 1984](#z3)|

## Directory setup

```
(1) FOLDERS XXX_lat and XXX_lsh (XXX=model's name)
|
|	contain field lines mapping at a given latitude on the planet (lat from 1 to 90 deg by 1deg step)
|	or a given distance in the equatorial plane (lsh from 2 to 50 by 1 planet radius step)
|
|_(2) Either FOLDERS (0,1,2,...N) or files (0,1,2,...N, -0,-1,...)
   |
   |	numbers correspond to lat or lsh, folder for non axisymmetric, files for axisymmetric (sign=north/south)
   |
   |_ files (0,1,2,...359, -0,-1,...,-359)
	numbers correspond to longitudes (sign to north/south)

	field lines are stored from 2.9*(1E-3 *dip moment in Gauss) MHz to the max frequency by steps 
	of 2.9*(1E-3 *dip moment in Gauss) MHz
```

## Data format
```
Format: Binary file, big endian
Variables:
  LONG  [1]  n = number of data points in the file
  FLOAT  [n]  x = x position of the points
  FLOAT  [n]  y = y position of the points
  FLOAT  [n]  z = z position of the points
  FLOAT  [3,n] b = b unit vector
  FLOAT  [n]  f = frequencies
  FLOAT  [n]  Gwc = delta ln(wc) over c/wc
  FLOAT  [3,n] bz = b basis zenith vector
  FLOAT  [n] gb = grad b direction (in b basis)
```

## References

- <a name='vit4'></a>Connerney, J E P. 2007. “Planetary Magnetism.” In Treatise on Geophysics: Planets and Moons, edited by Tilman Spohn, 10:243–80. Elsevier.
- <a name='z3'></a>Connerney, J. E. P. , M. H. Acuna, and N. F. Ness. 1984. “The Z3 Model of Saturn's Magnetic Field and the Pioneer 11 Vector Helium Magnetometer Observations.” J. Geophys. Res. 89: 7541–44. [doi:10.1029/JA089iA09p07541](https://doi.org/10.1029/JA089iA09p07541).
- <a name='vip4'></a>Connerney, J. E. P., M. H. Acuna, N. F. Ness, and T. Satoh. 1998. “New Models of Jupiter's Magnetic Field Constrained by the Io Flux Tube Footprint.” J. Geophys. Res. 103 (A6): 11929–39. [doi:10.1029/97JA03726](https://dx.doi.org/10.1029/97JA03726)
- <a name='jrm09'></a>Connerney, J. E. P., S. Kotsiaros, R. J. Oliversen, J. R. Espley, J. L. Joergensen, P. S. Joergensen, J. M. G. Merayo, et al. 2018. “A New Model of Jupiter's Magnetic Field From Juno's First Nine Orbits.” Geophys. Res. Lett. 45 (6): 2590–96. [doi:10.1007/s11214-009-9621-7](https:/dx.doi.org/10.1007/s11214-009-9621-7).
- <a name='isaac'></a>Hess, Sébastien L. G.,  Bertrand Bonfond, Fran Bagenal, and Laurent Lamy. 2017. "A Model of the Jovian Internal Field Derived from in-situ and Auroral Constraints", PRE8 Proceedings, Austrian Academy of Science. [doi:10.1553/PRE8s157](https://dx.doi.org/10.1553/PRE8s157).
- <a name='o6'></a>Connerney,J. E. P.. 1992 "Doing more with Jupiter's magnetic field", in Planetary Radio Emissions III, edited by S. J. Bauer and H. O. Rucker, pp. 13 - 33, Austria Acad. of Sci. Press, Vienna.
- <a name='spv'></a>Davis, Leverett Jr, and Edward Smith. 1990. “A Model of Saturn's Magnetic Field Based on All Available Data .” J. Geophys. Res. 95 (September): 15257–61. [doi:10.1029/JA095iA09p15257](https://dx.doi.org/10.1029/JA095iA09p15257).
- <a name='vipal'></a>Hess, Sébastien L. G., Bertrand Bonfond, Philippe Zarka, and Denis Grodent. 2011. “Model of the Jovian Magnetic Field Topology Constrained by the Io Auroral Emissions.” J. Geophys. Res. 116 (A5): 177. [doi:10.1029/2010JA016262](https://dx.doi.org/10.1029/2010JA016262)
