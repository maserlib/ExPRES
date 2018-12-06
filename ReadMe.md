# Exoplanetary and Planetary Radio Emission Simulator (ExPRES) V6.1

## Directories
* [src](src) contains the ExPRES code IDL routines.
* [mfl](mfl) stores the magnetic field lines used by ExPRES. When installing the code, precomputed data 
files must be retrieved from [http://maser.obspm.fr/support/serpe/mfl](http://maser.obspm.fr/support/serpe/mfl).
That URL provides precomputed data files as well as the IDL routines that can be used for computing the files.
* [ephem](ephem) stores ephemerides files used by ExPRES. IDL saveset files (.sav) are available for precomputed
ephemerides. Other files (plain text format, .txt) will be stored here, and correspond to the output of the 
MIRIADE IMCCE webservice calls.
* [cdawlib](cdawlib) is a placeholder for the NASA/GSFC CDAWLib library, required for the CDF files. 

## Configuration
The `config.ini.template`file must be rename `config.ini` and edited with the adequate path strings.

## Running the code
The code has been tested under IDL 8.5. 

The IDL interpreter must be configured to look for routines into the [src](src) and [cdawlib](cdawlib) directories.

The operation are initiated with the following batch script:
```
IDL> @serpe_compile
``` 
This compiles all the necessary routines in advance. Then the simulation can be launched:
```
IDL> main,'file.json'
```
where `file.json` is the input parameter file.

