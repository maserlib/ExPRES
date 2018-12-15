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
The `config.ini.template` file (in [src](src)) must be renamed `config.ini` and edited with the adequate paths:
- `cdf_dist_path` must point to the local CDF distribution directory.
- `ephem_path` is the path to the directory where the precomputed ephemerides files are
located, and where temporary ephemerides files will be written.
- `mfl_path` is the path to the directory where the precomputed magnetic field line data.
- `save_path` is the path where the data will be saved.
- `ffmpeg_path` points to the `ffmpeg` executable, e.g., `/opt/local/bin/ffmpeg`
- `ps2pdf_path` points to the `ps2pdf` executable, e.g., `/opt/local/bin/ps2pdf`

Examples are provided in the header of [config.ini.template](src/config.ini.template).


## Running the code
The code has been tested under IDL 8.5. You must have a functional installation of IDL 8.5 (or better) on your system.

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

