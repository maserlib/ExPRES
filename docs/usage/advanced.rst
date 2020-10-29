Advanced Users' Guide
======================

ExPRES (Exoplanetary and Planetary Radio Emission Simulator) is a versatile tool that is fully configurable through
the simulation run input file. We present here the details of each configuration parameter.

Simulation Setup
----------------

The simulation setup is configured via an ExPRES configuration file (in *JSON* format), following the `ExPRES
JSON-Schema v1.1 <https://voparis-ns.pages.obspm.fr/maser/expres/v1.1/schema#>`_.

The ExPRES configuration file should start with the reference to the validation schema to be used:

.. code-block::

  "$schema": "https://voparis-ns.obspm.fr/maser/expres/v1.1/schema#",

General Parameters
++++++++++++++++++

The general parameters cover the time and frequency domain covered by the simulation, allow to give it a name to set
the number of objects that will be included in the model. It is composed of 4 sections: *SIMU*, *NUMBER*, *TIME*,
*FREQUENCY*

SIMU
....

The *SIMU* section is optional in ExPRES v1.1. It contains the simulation run description. It is composed of 2 keywords:

- **NAME**: The name of the simulation
- **OUT**: Output directory location (full path). If this path is empty, the current execution location is used. If this
  path points a file, the parent directory is selected.

**Example:** The simulation name is set to *Io2015-04-30*, and the output directory is defined from the path of the
ExPRES configuration file.

.. code-block::

  "SIMU": {
    "NAME": "Io2015-04-30",
    "OUT": "/Groups/SERPE/SERPE_6.1/Corentin/save/Earth/VIPAL/2015/3kev/Io/Io2015-04-30.json"
  },

NUMBER
......

The *NUMBER* section is required in ExPRES v1.1. It defines maximum numbers of *BODY*, *DENSITY* and *SOURCE* objects,
which can be configured in the simulation run. It is composed of 3 keywords:

- **BODY**: The number of planetary bodies in the simulation (e.g., 2 for Jupiter and Io)
- **DENSITY**: The number of plasma density model in the simulation (usually 1 per body)
- **SOURCE**: The number of radio source types in the simulation (usually 1 per interaction and per hemisphere)

**Example:** We will define two bodies (Jupiter and Io), two density models (one for Jupiter, the other for the Io
Torus) and two sets of radio sources (one for each hemisphere).

.. code-block::

  "NUMBER": {
    "BODY": 2,
    "DENSITY": 2,
    "SOURCE": 2
  },

TIME
....

The *TIME* section is required in ExPRES v1.1. It contains the simulation time configuration. Times are given in
minute from the simulation time origin. The time origin is either set by the input ephemeris data or by the input
orbital parameters. It is composed of 3 keywords:

- **MIN**: The start time of the simulation (in minutes), usually set to 0.
- **MAX**: The end time of the simulation (in minutes).
- **NBR**: The number of time steps of the simulation.

**Example:** The simulation starts at the simulation time origin, with 1440 minutes duration (one day), with one step
per minute.

.. code-block::

   "TIME": {
     "MIN": 0,
     "MAX": 1440,
     "NBR": 1440
   }

FREQUENCY
.........

The *FREQUENCY* section is required in ExPRES v1.1. It contains the simulation spectral configuration. Frequency
values are always in MHz units.

The spectral axis can be defined in several ways. The more generic way is to set the spectral axis bounds, the number
of steps and the linear and logarithmic scale (see example below). It is also possible to use a predefined set of
frequencies, corresponding to an existing instrument. Finally an external file containing a list of frequencies can be
provided.

This section is composed of 5 keywords:

- **TYPE**: The spectral axis type. The allowed values are *Linear*, *Log* and *Pre-Defined*.
- **MIN**: The spectral axis lower bound in MHZ. Not used in *TYPE=Pre-Defined*
- **MAX**: The spectral axis upper bound in MHZ. Not used in *TYPE=Pre-Defined*
- **NBR**: The number of steps of the spectral axis. Not used in *TYPE=Pre-Defined*
- **SC**: In case *TYPE=Pre-Defined*, the name of the specific spacecraft (allowed values TBD), or a list of frequency
  values.

**Example:** The simulation spectral axis is a linear scale, ranging from 10 kHz to 40 MHz, with 781 steps.

.. code-block::

  "FREQUENCY": {
    "TYPE": "Linear",
    "MIN": 0.01,
    "MAX": 44.0,
    "NBR": 781,
    "SC": ""
  },

**Example:** The simulation spectral axis is set of predefined frequencies.

.. code-block::

  "FREQUENCY": {
    "TYPE": "Pre-Defined",
    "MIN": 0,
    "MAX": 0,
    "NBR": 0,
    "SC": [0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1, 1.1, 1.2, 1.3, 1.4, 1.5, 1.6, 1.7, 1.8, 1.9, 2,
      2.1, 2.2, 2.3, 2.4, 2.5, 2.6, 2.7, 2.8, 2.9, 3, 3.1, 3.2, 3.3, 3.4, 3.5, 3.6, 3.7, 3.8, 3.9, 4, 4.1,
      4.2, 4.3, 4.4, 4.5, 4.6, 4.7, 4.8, 4.9, 5, 6, 7, 8, 9, 10, 11, 12]
  },



Observer Definition
+++++++++++++++++++

The *OBSERVER* section is required in ExPRES v1.1. It contains the observer's configuration.

There are three types of observers:

- *fixed* observers, whose position does not vary in the reference frame of the simulation;
- *orbiters*, which moves in the reference frame of the simulation, orbiting around a celestial body;
- *predefined* observers, which concerns known space mission around celestial bodies.

In any cases, it is necessary to define the celestial body which serves as reference for the position of the observer.
The list of reference position body must be defined in the *BODY* section.

This section is composed of several keywords:

- **TYPE**: The observer's type (see above). Allowed values: *Pre-Defined*, *Orbiter*, *Fixed*.
- **EPHEM**: File name containing user defined ephemeris of observer.
- **FIXE_DIST**: Observer's distance to *PARENT* body (if TYPE=Fixed), set to 'auto' is other cases.
- **FIXE_SUBL**: Observer's longitude to *PARENT* (if TYPE=Fixed), set to 'auto' is other cases.
- **FIXE_DECL**: Observer's latitude to *PARENT* (if TYPE=Fixed), set to 'auto' is other cases.
- **PARENT**: Simulation reference frame centre (must be the same as the source parent, and the first element of the
  list of bodies)
- **SC**: Observer's name. Allowed values: *Juno*, *Earth*, *Galileo*, *JUICE*, *Cassini*, *Voyager1*, *Voyager2*
- **SCTIME**: Start time of the simulation run in SCET (YYYYMMDDHHMMSS format)
- **SEMI_MAJ**: Semi major axis (in case of 'Orbiter' type)
- **SEMI_MIN**: Semi minor axis (in case of 'Orbiter' type)
- **SUBL**: Sublongitude of apoapsis (in case of 'Orbiter' type)
- **DECL**: Declination of apoapsis (in case of 'Orbiter' type)
- **PHASE**: Phase (East-Longitude shift) of observer from apoapsis (in case of 'Orbiter' type)
- **INCL**: Inclination of orbit plane (in case of 'Orbiter' type)

Fixed Observer
..............

Fixed observer are configured by their distance to the reference body, their sublongitude and their declination (in
the reference body reference frame, and at the simulation time origin).

Orbiter
.......

Orbiter orbits are defined by their semi-major and semi-minor axis, the apoapsis sublongitude and declination (in the
reference body reference frame, and at the simulation time origin) and the inclination of the orbit plane around the
semi-major axis). Finally, the orbiter position requires the definition of its initial phase on the orbit (0 degree is
at the apoapsis position).

Pre-Defined
...........

In the case of predefined observers, the code is expecting to have access to ephemeris information. For a set of space
missions (Cassini, Voyager1, Voyager2, Juno) or planetary bodies (Ganymede, Earth), the code will call the Miriade
*ephemph* webservice at IMCCE. For all other cases, an ephemeris file extracted from WebGeoCalc shall be provided
using the *EPHEM* keyword.

**Example:** We configure a simulation with an observer at Earth, with a simulation starting on 2015-04-30T00:00.

.. code-block::

  "OBSERVER": {
    "TYPE": "Fixed",
    "EPHEM": "",
    "FIXE_DIST": "auto",
    "FIXE_SUBL": "auto",
    "FIXE_DECL": "auto",
    "PARENT": "Jupiter",
    "SC": "Earth",
    "SCTIME": "201504300000",
    "SEMI_MAJ": 0.0,
    "SEMI_MIN": 0.0,
    "SUBL": 0.0,
    "DECL": 0.0,
    "PHASE": 0.0,
    "INCL": 0.0
  },

**Example:** We configure a simulation from the JUICE spacecraft, providing a WebGeocalc output CSV file.

.. code-block::

  "OBSERVER": {
    "TYPE": "Pre-Defined",
    "EPHEM": "WGC_StateVector_JUICE_SC_20320111T175800_20320111T185900.csv",
    "FIXE_DIST": "auto",
    "FIXE_SUBL": "auto",
    "FIXE_DECL": "auto",
    "PARENT": "Jupiter",
    "SC": "JUICE",
    "SCTIME": "",
    "SEMI_MAJ": 0,
    "SEMI_MIN": 0,
    "SUBL": 0,
    "DECL": 0,
    "PHASE": 0,
    "INCL": 0
  },


Plasma Density Profiles
+++++++++++++++++++++++

The *DENS* sections are required in ExPRES v1.1. They contain the plasma density model configurations. These sections
are defined in the *BODY* sections (see below).

Several kinds of plasma density profile can be defined in ExPRES, and are associated to celestial bodies. Four types of
density models are available:

- *Ionospheric*: exponential decrease versus distance,
- *Stellar*: decreases as the distance squared,
- *Disk*: exponential decrease with altitude relative to equatorial plane and distance,
- *Torus*: exponential decrease from the center of a torus of given radius.

Profile definitions include the following keywords:

- **ON**: Set to *true* to activate the density model or to *false* deactivate.
- **NAME**: The name of the density model (must be present, not empty and unique in the configuration file).
- **TYPE**: The type of the density model, with the allowed values: *Ionospheric*, *Stellar*, *Disk*, *Torus*.
- **RHO0**: Definition depends on density model type (see below).
- **SCALE**: Definition depends on density model type (see below).
- **PERP**: Definition depends on density model type (see below).

Ionospheric Type Profile
........................

The ionospheric density profile is modeled as:

.. math::

    \rho = \rho_0 \exp\left(-\frac{r-(R_p+h_0)}{H}\right)

where:

- :math:`\rho_0` is the reference plasma number density (in :math:`\textrm{cm}^{-3}`). Configuration keyword: **RHO0**.
- :math:`r` is the radial distance (in planetary radii).
- :math:`R_p` is the planetary radius (defined in the *BODY* section).
- :math:`h_0` is the reference peak density altitude above 1 :math:`R_p` (in planetary radii). Configuration keyword:
  **PERP**.
- :math:`H` is the reference scale-height (in planetary radii). Configuration keyword: **SCALE**.

**Example:** We define a Jovian ionospheric model, with a peak reference density of :math:`350\,10^3\,\textrm{cm}^{-3}`
at an altitude of 890 km (1.012465 :math:`R_p`) and a scale height of 1600 km (0.0223801 :math:`R_p`).

.. code-block::

  {
    "ON": true,
    "NAME": "Body1_density1",
    "TYPE": "Ionospheric",
    "RHO0": 350000.0,
    "SCALE": 0.0223801,
    "PERP": 0.012465
  }


Stellar Type Profile
....................

The stellar density profile is modeled as:

.. math::

    \rho = \rho_0 / r^2

where:

- :math:`\rho_0` is the reference plasma number density (in :math:`\textrm{cm}^{-3}`). Configuration keyword: **RHO0**.
- :math:`r` is the radial distance (in planetary radii).

Configuration keywords **SCALE** and **PERP** are not used for this model.

Disk Type Profile
.................

The disk density profile is modeled as:

.. math::

    \rho = \rho_0 \exp\left(-\frac{r}{H_r}\right) \exp\left(-\frac{z}{H_z}\right)

where:

- :math:`\rho_0` is the reference plasma number density (in :math:`\textrm{cm}^{-3}`). Configuration keyword: **RHO0**.
- :math:`r` is the equatorial radial distance (in planetary radii).
- :math:`H_r` is the equatorial radial scale-height (in planetary radii). Configuration keyword: **PERP**.
- :math:`z` is the altitude above the equator (in planetary radii).
- :math:`H_z` is the vertical scale-height (in planetary radii). Configuration keyword: **SCALE**.

Torus Type Profile
..................

The disk density profile is modeled as:

.. math::

    \rho = \rho_0 \exp\left(-\frac{\sqrt{(r-r_0)^2 + z^2}}{H}\right)

where:

- :math:`\rho_0` is the reference plasma number density (in :math:`\textrm{cm}^{-3}`). Configuration keyword: **RHO0**.
- :math:`r` is the equatorial radial distance (in planetary radii).
- :math:`r_0` is the torus equatorial diameter (in planetary radii). Configuration keyword: **PERP**.
- :math:`z` is the altitude above the equator (in planetary radii).
- :math:`H` is the torus scale-height (in planetary radii). Configuration keyword: **SCALE**.

**Example:** We define the Io torus, with a peak reference density of :math:`2000\,\textrm{cm}^{-3}`, an equatorial
diameter of 5.91 Jovian Radii (orbit of Io) and a torus scale-height of 1 Jovian radius.

.. code-block::

  {
    "ON": true,
    "NAME": "Body1_density2",
    "TYPE": "Torus",
    "RHO0": 2000,
    "SCALE": 1,
    "PERP": 5.91
  }


Celestial Bodies Definition
+++++++++++++++++++++++++++

The *BODY* section is required in ExPRES v1.1. It contains the celestial bodies configuration.

Two types of celestial bodies can be included in the simulations, fixed bodies (at least one needed, the simulation run
reference body) and orbiting bodies (which can orbit both fixed and orbiting bodies).

