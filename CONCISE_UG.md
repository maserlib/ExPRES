# Concise User's Guide to ExPRES

## ExPRES Configuration Description

An ExPRES run is configured through a configuration file (in `JSON` format). Examples of configuration files (and the associated results files) are available from 
[the MASER data repository](http://maser.obspm.fr/data/expres/) for Io-, Europa- and Ganymede-controlled emissions, and for various observers.  The parameters for 
these _routine simulation files_ are the following: 
- JRM09 (or ISaAC for some of them) + CAN current sheet models,
- Electon energy = 3 keV,
- position of the Active flux tube (AFT) for Io based on the (corrected) lead angle model of Hess et al., 2008 (for Europa and Ganymede the AFT is the same than the flux 
tube connected to the moon).

The file names are constructed automatically by ExPRES. For instance, the file `expres_juno_jupiter_io_jrm09_lossc-wid1deg_3kev_20180913_v01.json` 
(available [here](http://maser.obspm.fr/data/expres/juno/2018/09/expres_juno_jupiter_io_jrm09_lossc-wid1deg_3kev_20180913_v01.json)) corresponds to:
- `expres` is name of the simulation code,
- `juno` is the observer name,
- `jupiter` is the main planet name,
- `io` is the source control name,
- `jrm09` is magnetic field model name, 
- `lossc-wid1deg` is the type of model (here: Loss-Cone distribution + a emission cone thickness of 1 degree),
- `3kev`is the resonant electron energy,
- `20180913` is the simulation date
- `v01` is the versio of ExPRES used for this run (v01 corresponds to version 0.1)

The easiest option to build your configuration file is to update an existing one.     

## Updating a Configuration File

You can download a configuration file to get a template (please be sure to take one using JRM09 magnetic field model, for up-to-date description). 
There are many items and options in this file. Here are the important ones.

### Setting the temporal axis

The temporal axis is configured in the `TIME` section. The parameters are:
- `MIN`: start time (in minutes)
- `MAX`: end time (in minutes)
- `NBR`: number of time steps.

The resolution of ExPRES is 1 minute. This time axis is defined as a relative axis. It is attached to the absolute time reference given in the `OBSERVER` section, 
with the `SCTIME`keyword. Hence, `MIN` should always be set to 0. All parameters must be integers.

Example:
> ```"TIME":{"MIN": 0, "MAX": 1440, "NBR": 1440},```

### Setting the spectral axis 

The spectral axis is configured in the `FREQUENCY` section. The parameters are:
- `MIN`: lower bound of the spectral axis (in MHz),
- `MAX`: upper bound of the spectral axis (in MHz)
- `NBR`: number of spectral steps,
- `TYPE`: the type of spectral axis,
- `SC`: This option is not implemented.

The two main values for `TYPE` are `Log` or `Linear`, but the `Pre-Defined` option can be used to upload a custom spectral axis (see the [Advanced User's Guide](ADVANCED_UG.md)). 

Example:
> ```"FREQUENCY": {"TYPE": "Linear", "MIN": 0.01, "MAX": 40.0, "NBR": 781, "SC": ""},```

### Setting the observer

The observer defines the place from which the observation will be done. Basic users only need to use a limited set of parameters:
- `TYPE`: Use the `Pre-Defined` option here, which means that it will a pre-defined observer's ephemeris.
- `PARENT`: Sets is the main planetary body of the simulation (do not change this, but rather use another ExPRES configuration file, with the desired planet)  
- `SC`: Sets the name of the observer.
- `SCTIME`: sets the start time (Spacecraft time) of the modeling (this corresponds to the absolute starting point o fthe time axis). The format 
is `YYYYMMDDhhmmss` (`YYYY` = year, `MM` = month, `DD` = day, `hh` = hour, `mm` = minute, `ss` = second, all 0-padded) 
- `FIXE_DIST`, `FIXE_SUBL` and `FIXE_DECL` (corresponding to _distance_, _longitude_ and _latitude_) must be set to `auto` in this case.

The other parameters are not used in this case. They are described in the [Advanced User's Guide](ADVANCED_UG.md).

Example: 
> ```"OBSERVER": {"TYPE": "Pre-Defined", "EPHEM": "", "FIXE_DIST": "auto", "FIXE_SUBL": "auto", "FIXE_DECL": "auto", "PARENT": "Jupiter", "SC": "Juno", "SCTIME": "201809130000", "SEMI_MAJ": 0.0, "SEMI_MIN": 0.0, "SUBL": 0.0, "DECL": 0.0, "PHASE": 0.0, "INCL": 0.0},```


### Setting the output parameters

The `CDF` sub-section of `SPDYN` defines the parameters that will be provided in the resulting CDF file. Each parameters can be selected/deselected setting 
its value to `true`/`false`.
- `Theta`: value of the beaming angle at each time/frequency step
- `Fp`: value of the plasma frequency at the source
- `Fc`: value of the electron cyclotron frequency at the source
- `azimuth`: not currently available 
- `obslatitude`: latitude of the observer at each time step
- `CML`: longitude of the observer at each time step
- `obsdistance`: longitude of the observer at each time step
- `Obslocaltime`: not currently available
- `srclongitude`: longitude of the source
- `srcfreqmax`: maximal frequency at the magnetic flux tube footprint
- `srcpos`: [x,y,z] position of each sources

In most cases, setting `Theta` to `true` is the minimal acceptable setup. Note that the more options are set, the bigger is the output file.

### Setting the plasma model parameters

The main set of parameters that can be adjusted is the plasma density model at the source. This is done through the `DENS` sub-section of `BODY`. The 
default model parameters, in case of the Io-controlled emissions, are:
- an Ionospheric model (based on Hinson et al., 1998)
- an Io torus model (based on Bagenal, 1994).

The parameters can be adjusted:
- `RHO0` is the peak density, in _cm^-3_
- `SCALE` is the scale height, in _km_
- `PERP` is the location of the peak density, in planetary radii.

### Setting the radio source parameters 
The `SOURCE` section defines teh radio source parameters. There may be several sources in the configuration file. The parameters are:
- `TYPE`: `attached to a satellite`, which means that the magnetic field lines used will be those connected to a moon.
- `SAT`: if `TYPE=attached to a satellite`, then provide the name of the moon (which also needs to be defined as a `BODY`)
- `aurora_alt`: sets the altitude (in Jovian radius) of the UV aurora (altitude below which electrons are lost by collision with the atmosphere)
- `NORTH`: emission will be produce in the northern hemisphere
- `SOUTH`: emission will be produce in the southern hemisphere
- `Width`: width of the beaming hollow cone (in degrees)
- `current`: 
  - In most cases it should be set to `Transient (Alfvenic)`, which calculates self-consistently the beaming angle using the Cyclotron maser Instability (CMI) and a loss cone distribution function
  - It can also be set to `Constant`, so that the beaming angle will not be calculated using the CMI, but will be set at a chosen values (see next parameters)
- `Constant`: if `Current=Constant` then provide here the value in degree (80.0 for example)
- `Accel`: the energy of the resonant electrons (in keV)
- `Refraction`: to take into account refraction in the source’s vicinity (not implemented yet)

## Run ExPRES

The code is available for Run-on-Demand at Observatoire de Paris: https://voparis-uws-maser.obspm.fr/client/

Short worksflow to use this interface:
- Click on ''Job List’’ (top left)
- In `Job List for`, select `ExPRES`
- Click on `+ Create New Job` (top right)
- In `config` choose the configuration file (`***.json`) you want to run. The other parameters (`runId`, `slurp_mem` and `Add control parameters` have to be left as there are)
- Click on `Submit`, and wait for a response. It will first marked as `Queued` and then as `Executing`. It will last a few tens of second to a few minutes (depends on how many time/frequency steps and how many cdf-output parameters you asked for). 
- Then it will be marked as `Completed`,
- In `> Job Results`  you will be able to download resulting files.
- If the Job is marked as `Error`, something went wrong during the simulation. Then, look at the `> Job Details`, and check the `stdout` and `stderr` sections. 
