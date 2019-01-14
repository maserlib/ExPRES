# Installation guide

## IDL

The ExpRES code is running under [IDL (Interactive Data Language)](https://www.harrisgeospatial.com/Software-Technology/IDL), has 
been developed and tested on IDL version 8.5. This software must be installed for running the ExPRES code. 

**Note** The code has not been tested with [GDL (GNU Data Language)](https://github.com/gnudatalanguage/gdl), the open source 
version of IDL. This is part of future developments of the code.

The ExPRES uses several external IDL libraries, which are described in the following sections.

## CDF and CDAWLib

The ExPRES code writes output files in [CDF (Common Data Format)](https://cdf.gsfc.nasa.gov). The CDF library of IDL requires the 
installation of several packages:
- The CDF C-Library corresponding to your operating platform, see [here](https://spdf.sci.gsfc.nasa.gov/pub/software/cdf/dist/latest-release/). 
Note that the code has been tested with the CDF C-Library version 3.6.4. 
- The CDF IDL Library, available [here](https://spdf.sci.gsfc.nasa.gov/pub/software/cdf/dist/latest-release/idl/)
- The CDAWLib IDL routines, available [here](ftp://cdaweb.gsfc.nasa.gov/pub/software/cdawlib/)

## IDL Astro

The ExPRES code also uses some routines from the [IDLAstro](https://github.com/wlandsman/IDLAstro) library: ``

## Precomputed datasets

Precomputed datasets providing planetary magnetic field line models used by the ExPRES code must to download before any operation. The 
data is available from [the ExPRES section of the MASER data server](http://maser.obspm.fr/support/expres/). Files can be downloaded 
individually (but it will take ages), or using compressed TAR files:
 

## Testing the code functions

The test suite uses `unittest` under Python 3.5 and the IDL-Python bridge (idlpy) provided with IDL version 8.7.  




