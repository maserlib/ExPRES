# Magnetic Field Lines for ExPRES

## Available data

Data should be downloaded from http://maser.obspm.fr/support/expres/mfl/ 



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
  LONG  [1]  n = number of points in the file
  FLOAT  [n]  x = x position of the points
  FLOAT  [n]  y = y position of the points
  FLOAT  [n]  z = z position of the points
  FLOAT  [3,n] b = b unitary vector
  FLOAT  [n]  f = frequencies
  FLOAT  [n]  Gwc = delta ln(wc) over c/wc
  FLOAT  [3,n] bz = b basis zenith vector
  FLOAT  [3,n] gb = grad b direction (in b basis)
```
