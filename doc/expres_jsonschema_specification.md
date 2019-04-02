
# *expres-v1.0.0.json* schema documentation

+ Generated by [doctor\_jsonschema\_md](https://github.com/rdpickard/doctor_jsonschema_md) (and then fixed mannually)
+ Source file: ```https://voparis-ns.obspm.fr/maser/expres/v1.0/expres-v1.0.0.json```
+ Documentation generation date: 2019-03-28 15:23

---

## Title: MASER/ExPRES input files schema

+ Description: _None_
+ Schema Name: https://voparis-ns.obspm.fr/maser/expres/v1.0/schema#
+ Schema: http://json-schema.org/draft-07/schema#
+ ID: _None_

---

## Property Index:

* [BODY](#body)
* [MOVIE2D](#movie2d)
* [SIMU](#simu)
* [OBSERVER](#observer)
* [SPDYN](#spdyn)
* [MOVIE3D](#movie3d)
* [NUMBER](#number)
* [SOURCE](#source)
* [FREQUENCY](#frequency)
* [TIME](#time)

---

## Property Details:

### <a id="body"></a> BODY Property
+ _Type:_ array
+ _Required:_ True
+ _Description:_ Configuration of the Natural Bodies of the Simulation Run
+ _Allowed values:_ Any
+ _Unique Items:_ False
+ _Minimum Items:_ NA
+ _Maximum Items:_ NA
+ <a id="body.items"></a> **BODY array items**
	+ _Type:_ object
	+ _Required:_ False
	+ _Description:_ None
	+ _Allowed values:_ Any
	+ _Children_:
		+ <a id="body.items.orb_per"></a> **ORB\_PER property**
			+ _Type:_ number
			+ _Required:_ True
			+ _Description:_ ???
			+ _Allowed values:_ Any
		+ <a id="body.items.on"></a> **ON property**
			+ _Type:_ boolean
			+ _Required:_ True
			+ _Description:_ Flag to activate the current natural body
			+ _Allowed values:_ Any
		+ <a id="body.items.name"></a> **NAME property**
			+ _Type:_ string
			+ _Required:_ True
			+ _Description:_ Name of the current natural body
			+ _Allowed values:_ Any
		+ <a id="body.items.parent"></a> **PARENT property**
			+ _Type:_ string
			+ _Required:_ True
			+ _Description:_ Named natural body around which the current body is orbiting (must be one of the defined bodies)
			+ _Allowed values:_ Any
		+ <a id="body.items.flat"></a> **FLAT property**
			+ _Type:_ number
			+ _Required:_ True
			+ _Description:_ Flatening ratio of the current natural body
			+ _Allowed values:_ Any
		+ <a id="body.items.dens"></a> **DENS property**
			+ _Type:_ array
			+ _Required:_ True
			+ _Description:_ Configuration of the plasma density model aroud the current body
			+ _Allowed values:_ Any
			+ _Unique Items:_ False
			+ _Minimum Items:_ NA
			+ _Maximum Items:_ NA
			+ <a id="body.items.dens.items"></a> **DENS array items**
				+ _Type:_ object
				+ _Required:_ False
				+ _Description:_ None
				+ _Allowed values:_ Any
				+ _Children_:
					+ <a id="body.items.dens.items.on"></a> **ON property**
						+ _Type:_ boolean
						+ _Required:_ True
						+ _Description:_ Flag to activate the plasma density model
						+ _Allowed values:_ Any
					+ <a id="body.items.dens.items.scale"></a> **SCALE property**
						+ _Type:_ number
						+ _Required:_ True
						+ _Description:_ Scale-height parameter for the current plasma denisty model
						+ _Allowed values:_ Any
					+ <a id="body.items.dens.items.name"></a> **NAME property**
						+ _Type:_ string
						+ _Required:_ True
						+ _Description:_ Name of the current plasma density model
						+ _Allowed values:_ Any
					+ <a id="body.items.dens.items.rho0"></a> **RHO0 property**
						+ _Type:_ number
						+ _Required:_ True
						+ _Description:_ Rho0 parameter for the current plasma density model
						+ _Allowed values:_ Any
					+ <a id="body.items.dens.items.perp"></a> **PERP property**
						+ _Type:_ number
						+ _Required:_ True
						+ _Description:_ Perp ??? parameter for the current plasma denisty model
						+ _Allowed values:_ Any
					+ <a id="body.items.dens.items.type"></a> **TYPE property**
						+ _Type:_ string
						+ _Required:_ True
						+ _Description:_ Type of density model
						+ _Allowed values:_ ```Ionospheric```,```Torus```
		+ <a id="body.items.period"></a> **PERIOD property**
			+ _Type:_ number
			+ _Required:_ True
			+ _Description:_ Sidereal rotation period of the current natural body (in minutes)
			+ _Allowed values:_ Any
		+ <a id="body.items.motion"></a> **MOTION property**
			+ _Type:_ boolean
			+ _Required:_ True
			+ _Description:_ Flag to indicate if the natural body is moving in the simulation frame
			+ _Allowed values:_ Any
		+ <a id="body.items.declination"></a> **DECLINATION property**
			+ _Type:_ number
			+ _Required:_ True
			+ _Description:_ Declination orbital parameter of the current body
			+ _Allowed values:_ Any
		+ <a id="body.items.radius"></a> **RADIUS property**
			+ _Type:_ number
			+ _Required:_ True
			+ _Description:_ Radius of the current natural body
			+ _Allowed values:_ Any
		+ <a id="body.items.mag"></a> **MAG property**
			+ _Type:_ string
			+ _Required:_ True
			+ _Description:_ Internal body magnetic field model
			+ _Allowed values:_ None,```JRM09+Connerney CS```
		+ <a id="body.items.semi_min"></a> **SEMI\_MIN property**
			+ _Type:_ number
			+ _Required:_ True
			+ _Description:_ Semi minor axis orbital parameter of the current body
			+ _Allowed values:_ Any
		+ <a id="body.items.phase"></a> **PHASE property**
			+ _Required:_ True
			+ _Description:_ Phase orbital parameter of the current body
			+ _Allowed values:_ Any
		+ <a id="body.items.semi_maj"></a> **SEMI\_MAJ property**
			+ _Type:_ number
			+ _Required:_ True
			+ _Description:_ Semi major axis orbital parameter of the current body
			+ _Allowed values:_ Any
		+ <a id="body.items.apo_long"></a> **APO\_LONG property**
			+ _Type:_ number
			+ _Required:_ True
			+ _Description:_ Apoapsis Longitude parameter of the current body
			+ _Allowed values:_ Any
		+ <a id="body.items.init_ax"></a> **INIT\_AX property**
			+ _Type:_ number
			+ _Required:_ True
			+ _Description:_ ???
			+ _Allowed values:_ Any
		+ <a id="body.items.inclination"></a> **INCLINATION property**
			+ _Type:_ number
			+ _Required:_ True
			+ _Description:_ Inclination orbital parameter of the current body
			+ _Allowed values:_ Any

### <a id="movie2d"></a> MOVIE2D property
+ _Type:_ object
+ _Required:_ True
+ _Description:_ 2D Movie output setup
+ _Allowed values:_ Any
+ _Children_:
	+ <a id="movie2d.on"></a> **ON property**
		+ _Type:_ boolean
		+ _Required:_ True
		+ _Description:_ Flag to activate Movie2D generation
		+ _Allowed values:_ Any
	+ <a id="movie2d.range"></a> **RANGE property**
		+ _Type:_ integer
		+ _Required:_ True
		+ _Description:_ ???
		+ _Allowed values:_ Any
	+ <a id="movie2d.subcycle"></a> **SUBCYCLE property**
		+ _Type:_ integer
		+ _Required:_ True
		+ _Description:_ ???
		+ _Allowed values:_ Any

### <a id="simu"></a> SIMU property
+ _Type:_ object
+ _Required:_ True
+ _Description:_ Simulation run description
+ _Allowed values:_ Any
+ _Children_:
	+ <a id="simu.name"></a> **NAME property**
		+ _Type:_ string
		+ _Required:_ True
		+ _Description:_ Name of the simulation
		+ _Allowed values:_ Any
	+ <a id="simu.out"></a> **OUT property**
		+ _Type:_ string
		+ _Required:_ True
		+ _Description:_ Output file location (full path)
		+ _Allowed values:_ Any

### <a id="observer"></a> OBSERVER property
+ _Type:_ object
+ _Required:_ True
+ _Description:_ Simulation run observer setup
+ _Allowed values:_ Any
+ _Children_:
	+ <a id="observer.decl"></a> **DEC propertyL**
		+ _Type:_ number
		+ _Required:_ True
		+ _Description:_ Declination of ??? (in case of 'Orbiter' type)
		+ _Allowed values:_ Any
	+ <a id="observer.fixe_subl"></a> **FIXE\_SUBL property**
		+ _Required:_ True
		+ _Description:_ 
		+ _Allowed values:_ Any
	+ <a id="observer.parent"></a> **PARENT property**
		+ _Type:_ string
		+ _Required:_ True
		+ _Description:_ 
		+ _Allowed values:_ ```Jupiter```
	+ <a id="observer.fixe_decl"></a> **FIXE\_DECL property**
		+ _Required:_ True
		+ _Description:_ 
		+ _Allowed values:_ Any
	+ <a id="observer.type"></a> **TYPE property**
		+ _Type:_ string
		+ _Required:_ True
		+ _Description:_ Type of observer (Pre-Defined, Orbiter or Fixed)
		+ _Allowed values:_ ```Pre-Defined```,```Orbiter```,```Fixed```
	+ <a id="observer.sctime"></a> **SCTIME property**
		+ _Type:_ string
		+ _Required:_ True
		+ _Description:_ Start time of the simulation run in SCET (YYYYMMDDHHMM format)
		+ _Allowed values:_ Any
	+ <a id="observer.ephem"></a> **EPHEM property**
		+ _Type:_ string
		+ _Required:_ True
		+ _Description:_ 
		+ _Allowed values:_ Any
	+ <a id="observer.phase"></a> **PHASE property**
		+ _Type:_ number
		+ _Required:_ True
		+ _Description:_ Phase of ??? (in case of 'Orbiter' type)
		+ _Allowed values:_ Any
	+ <a id="observer.incl"></a> **INCL property**
		+ _Type:_ number
		+ _Required:_ True
		+ _Description:_ Inclination of ??? (in case of 'Orbiter' type)
		+ _Allowed values:_ Any
	+ <a id="observer.semi_min"></a> **SEMI\_MIN property**
		+ _Type:_ number
		+ _Required:_ True
		+ _Description:_ Semi minor axis (in case of 'Orbiter' type)
		+ _Allowed values:_ Any
	+ <a id="observer.sc"></a> **SC property**
		+ _Type:_ string
		+ _Required:_ True
		+ _Description:_ 
		+ _Allowed values:_ ```Juno```,```Earth```
	+ <a id="observer.subl"></a> **SUBL property**
		+ _Type:_ number
		+ _Required:_ True
		+ _Description:_ Sublongitude of ??? (in case of 'Orbiter' type)
		+ _Allowed values:_ Any
	+ <a id="observer.semi_maj"></a> **SEMI\_MAJ property**
		+ _Type:_ number
		+ _Required:_ True
		+ _Description:_ Semi major axis (in case of 'Orbiter' type)
		+ _Allowed values:_ Any
	+ <a id="observer.fixe_dist"></a> **FIXE\_DIST property**
		+ _Required:_ True
		+ _Description:_ 
		+ _Allowed values:_ Any

### <a id="spdyn"></a> SPDYN property
+ _Type:_ object
+ _Required:_ True
+ _Description:_ Dynamic Spectra ouput setup
+ _Allowed values:_ Any
+ _Children_:
	+ <a id="spdyn.ltrange"></a> **LTRANGE property**
		+ _Type:_ array
		+ _Required:_ True
		+ _Description:_ Local-Time range for plot setup
		+ _Allowed values:_ Any
		+ _Unique Items:_ False
		+ _Minimum Items:_ 2
		+ _Maximum Items:_ 2
		+ <a id="spdyn.items"></a> **LTRANGE array items**
			+ _Type:_ number
			+ _Required:_ False
			+ _Description:_ None
			+ _Allowed values:_ Any
	+ <a id="spdyn.polar"></a> **POLAR property**
		+ _Type:_ boolean
		+ _Required:_ True
		+ _Description:_ Flag to ouput 'Polar' plots
		+ _Allowed values:_ Any
	+ <a id="spdyn.khz"></a> **KHZ property**
		+ _Type:_ boolean
		+ _Required:_ True
		+ _Description:_ Flag for spectral axis output in kHz (default is MHz)
		+ _Allowed values:_ Any
	+ <a id="spdyn.log"></a> **LOG property**
		+ _Type:_ boolean
		+ _Required:_ True
		+ _Description:_ Flag for spectral axis output in log scale
		+ _Allowed values:_ Any
	+ <a id="spdyn.larange"></a> **LARANGE property**
		+ _Type:_ array
		+ _Required:_ True
		+ _Description:_ Latitude range for plot setup
		+ _Allowed values:_ Any
		+ _Unique Items:_ False
		+ _Minimum Items:_ 2
		+ _Maximum Items:_ 2
		+ <a id="spdyn.items"></a> **LARANGE array items**
			+ _Type:_ number
			+ _Required:_ False
			+ _Description:_ None
			+ _Allowed values:_ Any
	+ <a id="spdyn.drange"></a> **DRANGE property**
		+ _Type:_ array
		+ _Required:_ True
		+ _Description:_ Distance range for plot setup
		+ _Allowed values:_ Any
		+ _Unique Items:_ False
		+ _Minimum Items:_ 2
		+ _Maximum Items:_ 2
		+ <a id="spdyn.items"></a> **DRANGE array items**
			+ _Type:_ number
			+ _Required:_ False
			+ _Description:_ None
			+ _Allowed values:_ Any
	+ <a id="spdyn.long"></a> **LONG property**
		+ _Type:_ array
		+ _Required:_ True
		+ _Description:_ Flags to setup output plot longitude axes
		+ _Allowed values:_ Any
		+ _Unique Items:_ False
		+ _Minimum Items:_ 5
		+ _Maximum Items:_ 5
		+ <a id="spdyn.items"></a> **LONG array items**
			+ _Type:_ boolean
			+ _Required:_ False
			+ _Description:_ None
			+ _Allowed values:_ Any
	+ <a id="spdyn.cdf"></a> **CDF property**
		+ _Type:_ object
		+ _Required:_ True
		+ _Description:_ Configuration of CDF file output
		+ _Allowed values:_ Any
		+ _Children_:
			+ <a id="spdyn.cdf.fp"></a> **FP property**
				+ _Type:_ boolean
				+ _Required:_ True
				+ _Description:_ Flag for FP parameter output in the CDF file.
				+ _Allowed values:_ Any
			+ <a id="spdyn.cdf.obsdistance"></a> **OBSDISTANCE property**
				+ _Type:_ boolean
				+ _Required:_ True
				+ _Description:_ Flag for OBSDISTANCE parameter output in the CDF file.
				+ _Allowed values:_ Any
			+ <a id="spdyn.cdf.cml"></a> **CML property**
				+ _Type:_ boolean
				+ _Required:_ True
				+ _Description:_ Flag for CML parameter output in the CDF file.
				+ _Allowed values:_ Any
			+ <a id="spdyn.cdf.obslocaltime"></a> **OBSLOCALTIME property**
				+ _Type:_ boolean
				+ _Required:_ True
				+ _Description:_ Flag for OBSLOCALTIME parameter output in the CDF file.
				+ _Allowed values:_ Any
			+ <a id="spdyn.cdf.obslatitude"></a> **OBSLATITUDE property**
				+ _Type:_ boolean
				+ _Required:_ True
				+ _Description:_ Flag for OBSLATITUDE parameter output in the CDF file.
				+ _Allowed values:_ Any
			+ <a id="spdyn.cdf.srcfreqmax"></a> **SRCFREQMAX property**
				+ _Type:_ boolean
				+ _Required:_ True
				+ _Description:_ Flag for SRCFREQMAX parameter output in the CDF file.
				+ _Allowed values:_ Any
			+ <a id="spdyn.cdf.srcpos"></a> **SRCPOS property**
				+ _Type:_ boolean
				+ _Required:_ True
				+ _Description:_ Flag for SRCPOS parameter output in the CDF file.
				+ _Allowed values:_ Any
			+ <a id="spdyn.cdf.fc"></a> **FC property**
				+ _Type:_ boolean
				+ _Required:_ True
				+ _Description:_ Flag for FC parameter output in the CDF file.
				+ _Allowed values:_ Any
			+ <a id="spdyn.cdf.azimuth"></a> **AZIMUTH property**
				+ _Type:_ boolean
				+ _Required:_ True
				+ _Description:_ Flag for AZIMUTH parameter output in the CDF file.
				+ _Allowed values:_ Any
			+ <a id="spdyn.cdf.theta"></a> **THETA property**
				+ _Type:_ boolean
				+ _Required:_ True
				+ _Description:_ Flag for THETA parameter output in the CDF file.
				+ _Allowed values:_ Any
			+ <a id="spdyn.cdf.srclongitude"></a> **SRCLONGITUDE property**
				+ _Type:_ boolean
				+ _Required:_ True
				+ _Description:_ Flag for SRCLONGITUDE parameter output in the CDF file.
				+ _Allowed values:_ Any
	+ <a id="spdyn.intensity"></a> **INTENSITY property**
		+ _Type:_ boolean
		+ _Required:_ True
		+ _Description:_ Flag to ouput 'Intensity' plots
		+ _Allowed values:_ Any
	+ <a id="spdyn.lgrange"></a> **LGRANGE property**
		+ _Type:_ array
		+ _Required:_ True
		+ _Description:_ Longitude range for plot setup
		+ _Allowed values:_ Any
		+ _Unique Items:_ False
		+ _Minimum Items:_ 2
		+ _Maximum Items:_ 2
		+ <a id="spdyn.items"></a> **LGRANGE array items**
			+ _Type:_ number
			+ _Required:_ False
			+ _Description:_ None
			+ _Allowed values:_ Any
	+ <a id="spdyn.lat"></a> **LAT property**
		+ _Type:_ array
		+ _Required:_ True
		+ _Description:_ Flags to setup output plot latitude axes
		+ _Allowed values:_ Any
		+ _Unique Items:_ False
		+ _Minimum Items:_ 5
		+ _Maximum Items:_ 5
		+ <a id="spdyn.items"></a> **LAT array items**
			+ _Type:_ boolean
			+ _Required:_ False
			+ _Description:_ None
			+ _Allowed values:_ Any
	+ <a id="spdyn.pdf"></a> **PDF property**
		+ _Type:_ boolean
		+ _Required:_ True
		+ _Description:_ Flag for PDF file output
		+ _Allowed values:_ Any
	+ <a id="spdyn.freq"></a> **FREQ property**
		+ _Type:_ array
		+ _Required:_ True
		+ _Description:_ Flags to setup output plot spectral axes
		+ _Allowed values:_ Any
		+ _Unique Items:_ False
		+ _Minimum Items:_ 5
		+ _Maximum Items:_ 5
		+ <a id="spdyn.items"></a> **FREQ array items**
			+ _Type:_ boolean
			+ _Required:_ False
			+ _Description:_ None
			+ _Allowed values:_ Any
	+ <a id="spdyn.infos"></a> **INFOS property**
		+ _Type:_ boolean
		+ _Required:_ True
		+ _Description:_ ???
		+ _Allowed values:_ Any
		
### <a id="movie3d"></a> MOVIE3 property
+ _Type:_ object
+ _Required:_ True
+ _Description:_ 3D Movie output setup
+ _Allowed values:_ Any
+ _Children_:
	+ <a id="movie3d.on"></a> **ON property**
		+ _Type:_ boolean
		+ _Required:_ True
		+ _Description:_ Flag to activate Movie3D generation
		+ _Allowed values:_ Any
	+ <a id="movie3d.yrange"></a> **YRANGE**
		+ _Type:_ array
		+ _Required:_ True
		+ _Description:_ Plotting Range in Y axis (in central planet radius units).
		+ _Allowed values:_ Any
		+ _Unique Items:_ False
		+ _Minimum Items:_ 2
		+ _Maximum Items:_ 2
		+ <a id="movie3d.items"></a> **YRANGE array items**
			+ _Type:_ number
			+ _Required:_ False
			+ _Description:_ None
			+ _Allowed values:_ Any
	+ <a id="movie3d.xrange"></a> **XRANGE property**
		+ _Type:_ array
		+ _Required:_ True
		+ _Description:_ Plotting Range in X axis (in central planet radius units).
		+ _Allowed values:_ Any
		+ _Unique Items:_ False
		+ _Minimum Items:_ 2
		+ _Maximum Items:_ 2
		+ <a id="movie3d.items"></a> **XRANGE array items**
			+ _Type:_ number
			+ _Required:_ False
			+ _Description:_ None
			+ _Allowed values:_ Any
	+ <a id="movie3d.traj"></a> **TRAJ property**
		+ _Type:_ boolean
		+ _Required:_ True
		+ _Description:_ Flag to activate plotting the trajectories of the objects
		+ _Allowed values:_ Any
	+ <a id="movie3d.subcycle"></a> **SUBCYCLE property**
		+ _Type:_ integer
		+ _Required:_ True
		+ _Description:_ ???
		+ _Allowed values:_ Any
	+ <a id="movie3d.obs"></a> **OBS property**
		+ _Type:_ boolean
		+ _Required:_ True
		+ _Description:_ Flag to activate plotting the location of the observer
		+ _Allowed values:_ Any
	+ <a id="movie3d.zrange"></a> **ZRANGE property**
		+ _Type:_ array
		+ _Required:_ True
		+ _Description:_ Plotting Range in Z axis (in central planet radius units).
		+ _Allowed values:_ Any
		+ _Unique Items:_ False
		+ _Minimum Items:_ 2
		+ _Maximum Items:_ 2
		+ <a id="movie3d.items"></a> **ZRANGE array items**
			+ _Type:_ number
			+ _Required:_ False
			+ _Description:_ None
			+ _Allowed values:_ Any

### <a id="number"></a> NUMBER property
+ _Type:_ object
+ _Required:_ True
+ _Description:_ Simulation run source setup
+ _Allowed values:_ Any
+ _Children_:
	+ <a id="number.body"></a> **BODY property**
		+ _Type:_ integer
		+ _Required:_ True
		+ _Description:_ Number of natural bodies in the simulation
		+ _Allowed values:_ Any
	+ <a id="number.source"></a> **SOURCE property**
		+ _Type:_ integer
		+ _Required:_ True
		+ _Description:_ Number of radio sources in the simulation
		+ _Allowed values:_ Any
	+ <a id="number.density"></a> **DENSITY property**
		+ _Type:_ integer
		+ _Required:_ True
		+ _Description:_ Number of density models in the simulation
		+ _Allowed values:_ Any

### <a id="source"></a> SOURCE property
+ _Type:_ array
+ _Required:_ True
+ _Description:_ Configuration of the Radio Sources of the Simulation Run
+ _Allowed values:_ Any
+ _Unique Items:_ False
+ _Minimum Items:_ NA
+ _Maximum Items:_ NA
+ <a id="items"></a> **SOURCE array items**
	+ _Type:_ object
	+ _Required:_ False
	+ _Description:_ None
	+ _Allowed values:_ Any
	+ _Children_:
		+ <a id="items.on"></a> **ON property**
			+ _Type:_ boolean
			+ _Required:_ True
			+ _Description:_ Flag to activate the current radio source
			+ _Allowed values:_ Any
		+ <a id="items.lg_nbr"></a> **LG\_NBR property**
			+ _Type:_ integer
			+ _Required:_ True
			+ _Description:_ Number of steps for the source longitude (deg)
			+ _Allowed values:_ Any
		+ <a id="items.lg_min"></a> **LG\_MIN property**
			+ _Required:_ True
			+ _Description:_ Lower bound value of the source longitude (deg)
			+ _Allowed values:_ Any
		+ <a id="items.name"></a> **NAME property**
			+ _Type:_ string
			+ _Required:_ True
			+ _Description:_ Name of the current radio source
			+ _Allowed values:_ Any
		+ <a id="items.parent"></a> **PARENT property**
			+ _Type:_ string
			+ _Required:_ True
			+ _Description:_ Name of the parent body for this source (must correspond to a defined BODY name)
			+ _Allowed values:_ Any
		+ <a id="items.aurora_alt"></a> **AURORA\_ALT property**
			+ _Type:_ number
			+ _Required:_ True
			+ _Description:_ Altitude of the aurora
			+ _Allowed values:_ Any
		+ <a id="items.temph"></a> **TEMPH property**
			+ _Type:_ number
			+ _Required:_ True
			+ _Description:_ ???
			+ _Allowed values:_ Any
		+ <a id="items.accel"></a> **ACCEL property**
			+ _Type:_ number
			+ _Required:_ True
			+ _Description:_ ???
			+ _Allowed values:_ Any
		+ <a id="items.temp"></a> **TEMP property**
			+ _Type:_ number
			+ _Required:_ True
			+ _Description:_ ???
			+ _Allowed values:_ Any
		+ <a id="items.current"></a> **CURRENT property**
			+ _Type:_ string
			+ _Required:_ True
			+ _Description:_ Type of electron distribution in the source
			+ _Allowed values:_ ```Transient (Alfvenic)```
		+ <a id="items.width"></a> **WIDTH property**
			+ _Type:_ number
			+ _Required:_ True
			+ _Description:_ Width of the radio emission sheet (deg)
			+ _Allowed values:_ Any
		+ <a id="items.constant"></a> **CONSTANT property**
			+ _Type:_ number
			+ _Required:_ True
			+ _Description:_ ???
			+ _Allowed values:_ Any
		+ <a id="items.refraction"></a> **REFRACTION property**
			+ _Type:_ boolean
			+ _Required:_ True
			+ _Description:_ Flag to activate refraction effects (current not implemented)
			+ _Allowed values:_ ```False```
		+ <a id="items.lat"></a> **LAT property**
			+ _Type:_ integer
			+ _Required:_ True
			+ _Description:_ Latitude of the source (deg)
			+ _Allowed values:_ Any
		+ <a id="items.north"></a> **NORTH property**
			+ _Type:_ boolean
			+ _Required:_ True
			+ _Description:_ Flag to activate the Northern hemisphere source 
			+ _Allowed values:_ Any
		+ <a id="items.lg_max"></a> **LG\_MAX property**
			+ _Required:_ True
			+ _Description:_ Upper bound value of the source longitude (deg)
			+ _Allowed values:_ Any
		+ <a id="items.sat"></a> **SAT property**
			+ _Type:_ string
			+ _Required:_ True
			+ _Description:_ Name of the satellite when 'attached to a satellite' is selected
			+ _Allowed values:_ Any
		+ <a id="items.type"></a> **TYPE property**
			+ _Type:_ string
			+ _Required:_ True
			+ _Description:_ Type of radio source
			+ _Allowed values:_ ```attached to a satellite```
		+ <a id="items.south"></a> **SOUTH property**
			+ _Type:_ boolean
			+ _Required:_ True
			+ _Description:_ Flag to activate the Soutern hemisphere source 
			+ _Allowed values:_ Any
		+ <a id="items.sub"></a> **SUB property**
			+ _Type:_ integer
			+ _Required:_ True
			+ _Description:_ ??? of the source
			+ _Allowed values:_ Any

### <a id=".frequency"></a> FREQUENCY property
+ _Type:_ object
+ _Required:_ True
+ _Description:_ Simulation run spectral axis setup
+ _Allowed values:_ Any
+ _Children_:
	+ <a id="frequency.sc"></a> **SC property**
		+ _Type:_ string
		+ _Required:_ True
		+ _Description:_ Spacecraft name (use only when spectral type is 'Pre-defined') [not yet implemented]
		+ _Allowed values:_ Any
	+ <a id="frequency.max"></a> **MAX property**
		+ _Type:_ number
		+ _Required:_ True
		+ _Description:_ Upper bound of the spectral axis (MHz)
		+ _Allowed values:_ Any
	+ <a id="frequency.type"></a> **TYPE property**
		+ _Type:_ string
		+ _Required:_ True
		+ _Description:_ Type of spectral axis (linear or logarithmic scale)
		+ _Allowed values:_ ```Pre-Defined```,```Linear```,```Log```
	+ <a id="frequency.nbr"></a> **NBR property**
		+ _Type:_ integer
		+ _Required:_ True
		+ _Description:_ Number of steps of the spectral axis
		+ _Allowed values:_ Any
	+ <a id="frequency.min"></a> **MIN property**
		+ _Type:_ number
		+ _Required:_ True
		+ _Description:_ Lower bound of the spectral axis (MHz)
		+ _Allowed values:_ Any

### <a id=".time"></a> TIME property
+ _Type:_ object
+ _Required:_ True
+ _Description:_ Simulation run time axis setup
+ _Allowed values:_ Any
+ _Children_:
	+ <a id="time.max"></a> **MAX property**
		+ _Type:_ integer
		+ _Required:_ True
		+ _Description:_ End time index of the simulation (in minutes)
		+ _Allowed values:_ Any
	+ <a id="time.nbr"></a> **NBR property**
		+ _Type:_ integer
		+ _Required:_ True
		+ _Description:_ Number of time steps of the simulation
		+ _Allowed values:_ Any
	+ <a id="time.min"></a> **MIN property**
		+ _Type:_ integer
		+ _Required:_ True
		+ _Description:_ Start time index of the simulation (in minutes)
		+ _Allowed values:_ Any

    