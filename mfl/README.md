# Magnetic Field Lines for ExPRES

## Available data

Data should be downloaded from http://maser.obspm.fr/support/expres/mfl/ 

The following precomputed datasets are available:
- [ISaAC_lsh](http://maser.obspm.fr/support/expres/mfl/ISaAC_lsh) (bundled [tgz](http://maser.obspm.fr/support/expres/mfl/ISaAC_lsh.tgz), 6.9 GB): Jupiter ISaAC magnetic field model (ref?)
- [JRM09_lsh](http://maser.obspm.fr/support/expres/mfl/JRM09_lsh) (bundled [tgz](http://maser.obspm.fr/support/expres/mfl/JRM09_lsh.tgz), 4.0 GB): Jupiter JRM09 magnetic field model ([Connerney et al. 2018](#jrm09))
- [VIPAL_lsh](http://maser.obspm.fr/support/expres/mfl/VIPAL_lsh) (bundled [tgz](http://maser.obspm.fr/support/expres/mfl/VIPAL_lsh.tgz)): Jupiter VIPAL magnetic field model ([Hess et al. 2011](#vipal))
- [VIT4_lsh](http://maser.obspm.fr/support/expres/mfl/VIT4_lsh) (bundled [tgz](http://maser.obspm.fr/support/expres/mfl/VIT4_lsh.tgz)): Jupiter VIT4 magnetic field model (ref?)
- [VIP4_lsh](http://maser.obspm.fr/support/expres/mfl/VIP4_lsh) (bundled [tgz](http://maser.obspm.fr/support/expres/mfl/VIP4_lsh.tgz)): Jupiter VIP4 magnetic field model (ref?)



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

- <a name='vipal'></a>Hess, Sébastien L. G., Bertrand Bonfond, Philippe Zarka, and Denis Grodent. 2011. “Model of the Jovian Magnetic Field Topology Constrained by the Io Auroral Emissions.” J. Geophys. Res. 116 (A5): 177. [doi:10.1029/2010JA016262](https://dx.doi.org/10.1029/2010JA016262)
- <a name='jrm09'></a>Connerney, J E P, S Kotsiaros, R J Oliversen, J R Espley, J L Joergensen, P S Joergensen, J M G Merayo, et al. 2018. “A New Model of Jupiter‘S Magnetic Field From Juno’S First Nine Orbits.” Geophys. Res. Lett. 45 (6): 2590–96. [doi:10.1007/s11214-009-9621-7](https:/dx.doi.org/10.1007/s11214-009-9621-7).
