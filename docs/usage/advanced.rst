Advanced Users' Guide
======================

ExPRES (Exoplanetary and Planetary Radio Emission Simulator) is a versatile tool that is fully configurable through
the simulation run input file. We present here the details of each configuration parameter.

Main Concepts
-------------

The ExPRES tool is modeling planetary radio emission observability. It is described in details in :cite:`Louis:2019`.
It is implementing the Cyclotron Maser Instability (CMI) radio emission mechanism :cite:`wu_SSR_85`, which predicts
a strongly anisotropic radio source beaming pattern. The beaming pattern is a hollow cone, whose axis is aligned with
the local magnetic field direction, and the cone opening angle is related to the unstable particle distribution
function properties. ExPRES computes the *radio source* to *observer* spatial vector and compares is direction to the
modelled radio source beaming pattern.

The ExPRES code configuration requires the definition of:

- *The celestial bodies involved in the simulation.* At least one *central body* must be defined, which serves
  as the *spatial origin* for the simulation. When several bodies are defined, their relative location with the
  *central body* must be available either as precomputed data, or through orbital parameters provided
  in the configuration file.
- *The location of the observer with respect to the central body.* The location data must be available (either as
  precomputed data, or through parameters provided in the configuration file.
- *The magnetic field and plasma density models associated to the celestial bodies.* Several type of models can be
  configured. ExPRES is using a set of pre-computed magnetic field lines from a series of magnetic field models. The
  plasma density models are set through configuration parameters.
- *The spatial distribution of the radio sources*. This location is related to the magnetic field line carrying the
  unstable particles. The range of radio source frequencies must also be set.
- *The radio source properties.* The radio emission mechanism is defined by a set of parameters characterising the radio
  source beaming pattern.

All spatial parameters of the simulation configuration (distances, radii, lengths...) must be defined in the same units
as that of provided *central body* radius. Hence, setting the central body radius to *1* implies that all other spatial
parameters are provided in units of the central body planetary radii. On the contrary, providing the radius of the
central body in km implies that all other spatial parameters must be also provided in km. The recommended convention
is to provide all spatial parameters in units of the *central body* radius. This convention is followed in the examples
provided below.

Simulation Setup
----------------

The simulation setup is configured via an ExPRES configuration file (in *JSON* format), following the `ExPRES
JSON-Schema v1.1 <https://voparis-ns.pages.obspm.fr/maser/expres/v1.1/schema#>`_.

Configuration File Description
++++++++++++++++++++++++++++++

The ExPRES configuration file should start with the reference to the validation schema to be used. The configuration
sections and structure are summarised below:

.. code-block::

  {
    "$schema": "https://voparis-ns.obspm.fr/maser/expres/v1.1/schema#",
    "SIMU": {...},
    "NUMBER": {...},
    "TIME": {...},
    "FREQUENCY": {...},
    "OBSERVER": {...},
    "SPDYN": {...},
    "MOVIE2D": {...},
    "MOVIE3D": {...},
    "BODY": [{...}, {...}]
    "SOURCE": [{...}, {...}]
  }

Each JSON entry shown here is described in the next sections. The *BODY* section is specific: it is a list of *BODY*
elements, each of which containing a list of *DENS* elements.

+------------------------+-------------------+--------------------------------------+
| Section                | Mandatory in v1.1 | Description                          |
+========================+===================+======================================+
| :ref:`SIMU<SIM>`       | no                | Simulation run description           |
+------------------------+-------------------+--------------------------------------+
| :ref:`NUMBER<NBR>`     | yes               | Number of elements for lists         |
+------------------------+-------------------+--------------------------------------+
| :ref:`TIME<TIME>`      | yes               | Time axis configuration              |
+------------------------+-------------------+--------------------------------------+
| :ref:`FREQUENCY<FREQ>` | yes               | Spectral axis configuration          |
+------------------------+-------------------+--------------------------------------+
| :ref:`OBSERVER<OBS>`   | yes               | Observer's configuration             |
+------------------------+-------------------+--------------------------------------+
| :ref:`SPDYN<SPD>`      | yes               | Dynamic Spectra output configuration |
+------------------------+-------------------+--------------------------------------+
| :ref:`MOVIE2D<M2D>`    | yes               | 2D movie output configuration        |
+------------------------+-------------------+--------------------------------------+
| :ref:`MOVIE3D<M3D>`    | yes               | 3D movie output configuration        |
+------------------------+-------------------+--------------------------------------+
| :ref:`BODY<BODY>`      | yes               | Celestial bodies configuration       |
+------------------------+-------------------+--------------------------------------+
| :ref:`SOURCE<SRC>`     | yes               | Radio Sources configuration          |
+------------------------+-------------------+--------------------------------------+

General Parameters
++++++++++++++++++

The general parameters cover the time and frequency domain covered by the simulation, allow to give it a name to set
the number of objects that will be included in the model. It is composed of 4 sections: ``SIMU``, ``NUMBER``, ``TIME``,
``FREQUENCY``.

.. _SIM:

Simulation Run Description
..........................

The ``SIMU`` section contains the simulation run description. It is composed of 2 keywords:

- ``NAME``: The name of the simulation
- ``OUT``: Output directory location (full path). If this path is empty, the current execution location is used. If this
  path points a file, the parent directory is selected.

**Example:** The simulation name is set to *Io2015-04-30*, and the output directory is defined from the path of the
ExPRES configuration file.

.. code-block::

  "SIMU": {
    "NAME": "Io2015-04-30",
    "OUT": "/Groups/SERPE/SERPE_6.1/Corentin/save/Earth/VIPAL/2015/3kev/Io/Io2015-04-30.json"
  },

.. _NBR:

Simulation List Sizes
.....................

The ``NUMBER`` section defines maximum numbers of ``BODY``, ``DENSITY`` and ``SOURCE`` objects, which can be
configured in the simulation run. It is composed of 3 keywords:

- ``BODY``: The number of planetary bodies in the simulation (e.g., 2 for Jupiter and Io)
- ``DENSITY``: The number of plasma density model in the simulation (usually 1 per body)
- ``SOURCE``: The number of radio source types in the simulation (usually 1 per interaction and per hemisphere)

**Example:** We want to define two bodies (Jupiter and Io), two density models (one for Jupiter's ionosphere, and
the other for the Io Torus) and two sets of radio sources (one for each hemisphere).

.. code-block::

  "NUMBER": {
    "BODY": 2,
    "DENSITY": 2,
    "SOURCE": 2
  },

.. _TIME:

Temporal Axis
.............

The ``TIME`` section contains the simulation time configuration. Times are given in minute from the simulation time
origin. The time origin is either set by the input ephemeris data or by the input orbital parameters. It is composed
of 3 keywords:

- ``MIN``: The start time of the simulation (in minutes), usually set to 0.
- ``MAX``: The end time of the simulation (in minutes).
- ``NBR``: The number of time steps of the simulation.

**Example:** The simulation starts at the simulation time origin, with 1440 minutes duration (one day), with one step
per minute.

.. code-block::

   "TIME": {
     "MIN": 0,
     "MAX": 1439,
     "NBR": 1440
   }

.. _FREQ:

Spectral Axis
.............

The ``FREQUENCY`` section contains the simulation spectral configuration. Frequency values are always in MHz units.

The spectral axis can be defined in several ways. The more generic way is to set the spectral axis bounds, the number
of steps and the linear and logarithmic scale (see example below). It is also possible to use a predefined set of
frequencies, corresponding to an existing instrument. Finally an external file containing a list of frequencies can be
provided.

This section is composed of 5 keywords:

- ``TYPE``: The spectral axis type. The allowed values are *Linear*, *Log* and *Pre-Defined*.
- ``MIN``: The spectral axis lower bound in MHZ. Not used in *TYPE=Pre-Defined*
- ``MAX``: The spectral axis upper bound in MHZ. Not used in *TYPE=Pre-Defined*
- ``NBR``: The number of steps of the spectral axis. Not used in *TYPE=Pre-Defined*
- ``SC``: In case ``TYPE="Pre-Defined"``, the name of the specific spacecraft (allowed values TBD), or a list of
  frequency values.

**Example:** The simulation spectral axis is a linear scale, ranging from 10 kHz to 44 MHz, with 781 steps.

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

.. _OBS:

Observer Definition
+++++++++++++++++++

The ``OBSERVER`` section contains the observer's configuration. There are three types of observers, configured by the
``TYPE`` keyword:

- ``Fixed`` observers, whose position does not vary in the reference frame of the simulation;
- ``Orbiter``, which moves in the reference frame of the simulation, orbiting around a celestial body;
- ``Pre-Defined`` observers, which concerns known space mission around celestial bodies.

The observer's location is provided with respect to the simulation *central body*, defined in the ``BODY`` section.

This section is composed of a series of keywords. The table below provides which keyword shall be used, or
left empty, or with a specific value. The following subsections give details for each observer's type.

+-----------------+--------------------------------------------------+
| Keyword         | Observer's type                                  |
+=================+===========+====================+=================+
| ``TYPE``        | ``Fixed`` | ``Orbiter``        | ``Pre-Defined`` |
+-----------------+-----------+--------------------+-----------------+
| ``EPHEM``       | empty     | empty              | file name       |
+-----------------+-----------+--------------------+-----------------+
| ``FIXE_DIST``   | distance  | ``auto``           | ``auto``        |
+-----------------+-----------+--------------------+-----------------+
| ``FIXE_SUBL``   | longitude | ``auto``           | ``auto``        |
+-----------------+-----------+--------------------+-----------------+
| ``FIXE_DECL``   | latitude  | ``auto``           | ``auto``        |
+-----------------+-----------+--------------------+-----------------+
| ``PARENT``      | *central body*                                   |
+-----------------+--------------------------------------------------+
| ``SC``          | Observer's name                                  |
+-----------------+--------------------------------------------------+
| ``SCTIME``      | Start time                                       |
+-----------------+-----------+--------------------+-----------------+
| ``SEMI_MAJ``    | 0         | Semi major axis    | 0               |
+-----------------+-----------+--------------------+-----------------+
| ``SEMI_MIN``    | 0         | Semi minor axis    | 0               |
+-----------------+-----------+--------------------+-----------------+
| ``SUBL``        | 0         | Apoapsis longitude | 0               |
+-----------------+-----------+--------------------+-----------------+
| ``DECL``        | 0         | Apoapsis latitude  | 0               |
+-----------------+-----------+--------------------+-----------------+
| ``PHASE``       | 0         | Phase from apoapis | 0               |
+-----------------+-----------+--------------------+-----------------+
| ``INCL``        | 0         | Inclination        | 0               |
+-----------------+-----------+--------------------+-----------------+

The observer's name (``SC`` keyword) must be set, and can't be empty. The currently allowed values are: ``Juno``,
``Earth``, ``Galileo``, ``JUICE``, ``Cassini``, ``Voyager1``, ``Voyager2``.

The ``PARENT`` keyword must be set to the *central body* name.

The simulation start time (``SCTIME`` keyword) is provided in SCET (spacecraft event time), with a ``YYYYMMDDHHMMSS``
format.

Fixed Observer
..............

A fixed observer is configured by its distance (``FIXE_DIST`` keyword) to the *central body*, its sub-longitude in
degrees (``FIXE_SUBL`` keyword) and its declination in degrees (``FIXE_DECL`` keyword) in the *central body* reference
frame, and at the simulation time origin.

Orbiter
.......

The observer's orbital parameters are its semi-major (``SEMI_MAJ`` keyword) and semi-minor (``SEMI_MIN`` keyword) axis
distances, its apoapsis sub-longitude (``SUBL`` keyword) and declination (``DECL`` keyword), as well as the inclination
of the orbit plane around the semi-major axis (``INCL`` keyword). All angles are provided in the *central body*
reference frame, and at the simulation time origin. Finally, the orbiter position requires the definition of its
initial phase (``PHASE`` keyword) on the orbit, i.e., 0 degree is at the apoapsis position.

Pre-Defined
...........

In the case of predefined observers, the code is expecting to have access to ephemeris information. For a set of space
missions (Cassini, Voyager1, Voyager2, Juno) or planetary bodies (Ganymede, Earth), the code will call the *Miriade*
``ephemph`` webservice at IMCCE. For all other cases, an ephemeris file extracted from WebGeoCalc shall be provided
using the ``EPHEM`` keyword.

**Example:** We configure a simulation with an observer at Earth, with a simulation starting on ``2015-04-30T00:00:00``.

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
    "SEMI_MAJ": 0,
    "SEMI_MIN": 0,
    "SUBL": 0,
    "DECL": 0,
    "PHASE": 0,
    "INCL": 0
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

.. _BODY:

Celestial Bodies Definition
+++++++++++++++++++++++++++

The ``BODY`` section contains the celestial bodies configuration.

Two types of celestial bodies can be included in the simulations:

- ``Fixed`` bodies, at least is one needed: the simulation run reference body;
- ``Orbiting`` bodies, which can orbit both fixed and orbiting bodies.

Each body must be given a unique name within the configuration file, since the name is used internally by ExPRES to
refer to them. Each body radius must be specified. All distances and scales units must be consistent throughout a
configuration file.

Celestial body definitions include the following keywords:

- ``ON``: Flag to activate the current body (``true`` or ``false``)
- ``NAME``: The name of the current body (must be unique in the configuration file)
- ``RADIUS``: The radius of the current body (in consistent units throughout the configuration file)
- ``PERIOD``: The sidereal rotation period of the current body (in minutes)
- ``FLAT``: The polar flatening ratio of the current body.
- ``ORB_PER``: The orbital period according to 3rd Kepler's law at 1 radius (in minutes)
- ``INIT_AX``: The reference longitude (in degrees)
- ``MAG``: The internal body magnetic field model (see the :ref:`Magnetic Field Model<MFL>` section below)
- ``MOTION``: Flag to indicate if the current body is moving in the simulation frame (must be ``false`` for the central
  body)
- ``PARENT``: Named body, around which the current body is orbiting (must be one of the defined bodies, and must be
  empty for the central body)
- ``SEMI_MAJ``: The semi-major axis orbital parameter of the current body (must be 0 for the central body)
- ``SEMI_MIN``: The semi-minor axis orbital parameter of the current body (must be 0 for the central body)
- ``DECLINATION``: The declination orbital parameter of the current body (must be 0 for the central body)
- ``APO_LONG``: The apoapsis Longitude parameter of the current body (must be 0 for the central body)
- ``INCLINATION``: The inclination orbital parameter of the current body (must be 0 for the central body)
- ``PHASE``: The initial orbital phase (at simulation start time) of the current body (must be 0 for the central body)
- ``DENS``: A list of configuration of the plasma density model(s) related to the current body (see the
  :ref:`DENS<DENS>` section)

**Example:** Defining Jupiter with the latest JRM09 magnetic field model and the CAN81 current sheet model. The body
radius is set to 1, so that all distance and scale parameters must be given in Jovian radii in the configuration file.

.. code-block::

  {
    "ON": true,
    "NAME": "Jupiter",
    "RADIUS": 1,
    "PERIOD": 595.5,
    "FLAT": 0.064935,
    "ORB_PER": 177.83,
    "INIT_AX": 0,
    "MAG": "JRM09+Connerney CS",
    "MOTION": false,
    "PARENT": "",
    "SEMI_MAJ": 0,
    "SEMI_MIN": 0,
    "DECLINATION": 0,
    "APO_LONG": 0,
    "INCLINATION": 0,
    "PHASE": 0,
    "DENS": [...]
  }

Orbital Parameters
..................

.. _SRC:

Radio Source Configuration
++++++++++++++++++++++++++

- ``ON``: Flag to activate the current radio source (``true`` or ``false``)
- ``NAME``: The name of the current radio source
- ``PARENT``: The name of the parent body for this source (must correspond to a defined ``BODY`` name)
- ``TYPE``: The type of radio source location. Four allowed values ``fixed in latitude``,  ``attached to a satellite``,
  ``L-shell``, ``M-shell``.
- ``LG_MIN``: The lower bound value of the source longitude (in degrees)
- ``LG_MAX``: The upper bound value of the source longitude (in degrees)
- ``LG_NBR``: The number of steps for the source longitude.
- ``LAT``: If ``Fixed in latitude``: Latitude in degree; else: apex distance in planetary radii.
- ``SUB``: The subcorotation rate of the source (0 = no corotation)
- ``AURORA_ALT``: The altitude of the aurora (in planetary radii)
- ``SAT``: The name of the satellite when ``attached to a satellite`` is selected
- ``NORTH``: Flag to activate the Northern hemisphere source (exclusive with ``SOUTH`` item)
- ``SOUTH``: Flag to activate the Southern hemisphere source (exclusive with ``NORTH`` item)
- ``WIDTH``: The thickness of the radio emission sheet (in degrees)
- ``CURRENT``: The type of electron distribution in the source (see documentation). Allowed values:
  ``Transient (Alfvenic)``, ``Constant``, ``Steady-State``, ``Shell``
- ``CONSTANT``: The value of beaming pattern half-cone opening angle (if ``Constant`` is selected), in degrees
- ``ACCEL``: The value of resonant electron beam energy in keV (not used when ``Constant`` is selected)
- ``TEMP``: The value of the cold electron distribution temperature (in keV)
- ``TEMPH``: The value of the halo electron distribution temperature (in keV)
- ``REFRACTION``: Flag to activate refraction effects (**not implemented yet**)

Output Configuration
+++++++++++++++++++++

.. _SPD:

Dynamic Spectrum Output
.......................

.. _M2D:

2D Movie Output
...............

.. _M3D:

3D Movie Output
...............


.. _DENS:

Plasma Density Models
---------------------

Various types of plasma density models can be used in ExPRES. They are configured by the ``DENS`` section in the
``BODY`` section (see the :ref:`Celestial Body<BODY>` section above). Four types of density models are available:

- ``Ionospheric``: exponential decrease with distance,
- ``Stellar``: decreases with the distance squared,
- ``Disk``: exponential decrease with altitude relative to equatorial plane and radial distance,
- ``Torus``: exponential decrease from the center of a torus of given radius.

Plasma density model definitions include the following keywords:

- ``ON``: Set to ``true`` to activate the density model or to ``false`` deactivate.
- ``NAME``: The name of the density model (must be present, not empty and unique in the configuration file).
- ``TYPE``: The type of the density model, with the allowed values: ``Ionospheric``, ``Stellar``, ``Disk``, ``Torus``.
- ``RHO0``: Definition depends on density model type (see below).
- ``SCALE``: Definition depends on density model type (see below).
- ``PERP``: Definition depends on density model type (see below).

Ionospheric Model
+++++++++++++++++

The ``Ionospheric`` density profile is modeled as:

.. math::

    \rho = \rho_0 \exp\left(-\frac{r-(1+h_0)}{H}\right)

where:

+----------------+-----------------------------------------+----------------------------+---------------+
| Parameter      | Definition                              | Unit                       | Keyword       |
+================+=========================================+============================+===============+
| :math:`\rho_0` | Reference plasma number density         | :math:`\textrm{cm}^{-3}`   | ``RHO0``      |
+----------------+-----------------------------------------+----------------------------+---------------+
| :math:`r`      | Radial distance                         | :math:`R_p`                |               |
+----------------+-----------------------------------------+----------------------------+---------------+
| :math:`h_0`    | Peak density altitude above 1 bar level | :math:`R_p`                | ``PERP``      |
+----------------+-----------------------------------------+----------------------------+---------------+
| :math:`H`      | Scale-height                            | :math:`R_p`                | ``SCALE``     |
+----------------+-----------------------------------------+----------------------------+---------------+

**Example:** We define a Jovian ionospheric model, with a peak reference density of :math:`3.5\,10^5\,\textrm{cm}^{-3}`
at an altitude of 650 km above the 1 bar level (1.009092 :math:`R_p`) and a scale height of 1600 km (0.0223801
:math:`R_p`), as defined in :cite:`doi:10.1029/97JA03689`.

.. code-block::

  {
    "ON": true,
    "NAME": "Body1_density1",
    "TYPE": "Ionospheric",
    "RHO0": 350000.0,
    "SCALE": 0.0223801,
    "PERP": 0.009092
  }


Stellar Model
+++++++++++++

The ``Stellar`` density profile is modeled as:

.. math::

    \rho = \rho_0 / r^2

where:

+----------------+-----------------------------------------+----------------------------+---------------+
| Parameter      | Definition                              | Unit                       | Keyword       |
+================+=========================================+============================+===============+
| :math:`\rho_0` | Reference plasma number density         | :math:`\textrm{cm}^{-3}`   | ``RHO0``      |
+----------------+-----------------------------------------+----------------------------+---------------+
| :math:`r`      | Radial distance                         | :math:`R_p`                |               |
+----------------+-----------------------------------------+----------------------------+---------------+

**Note:** Configuration keywords ``SCALE`` and ``PERP`` are not used for this model.

Disk Model
++++++++++

The ``Disk`` density profile is modeled as:

.. math::

    \rho = \rho_0 \exp\left(-\frac{r}{H_r}\right) \exp\left(-\frac{z}{H_z}\right)

where:

+----------------+-----------------------------------------+----------------------------+---------------+
| Parameter      | Definition                              | Unit                       | Keyword       |
+================+=========================================+============================+===============+
| :math:`\rho_0` | Reference plasma number density         | :math:`\textrm{cm}^{-3}`   | ``RHO0``      |
+----------------+-----------------------------------------+----------------------------+---------------+
| :math:`r`      | Equatorial radial distance              | :math:`R_p`                |               |
+----------------+-----------------------------------------+----------------------------+---------------+
| :math:`z`      | Altitude above equator                  | :math:`R_p`                |               |
+----------------+-----------------------------------------+----------------------------+---------------+
| :math:`H_r`    | Equatorial radial scale-height          | :math:`R_p`                | ``PERP``      |
+----------------+-----------------------------------------+----------------------------+---------------+
| :math:`H_z`    | Vertical scale-height                   | :math:`R_p`                | ``SCALE``     |
+----------------+-----------------------------------------+----------------------------+---------------+

Torus Model
+++++++++++

The ``Torus`` density profile is modeled as:

.. math::

    \rho = \rho_0 \exp\left(-\frac{\sqrt{(r-r_0)^2 + z^2}}{H}\right)

where:

+----------------+-----------------------------------------+----------------------------+---------------+
| Parameter      | Definition                              | Unit                       | Keyword       |
+================+=========================================+============================+===============+
| :math:`\rho_0` | Reference plasma number density         | :math:`\textrm{cm}^{-3}`   | ``RHO0``      |
+----------------+-----------------------------------------+----------------------------+---------------+
| :math:`r`      | Equatorial radial distance              | :math:`R_p`                |               |
+----------------+-----------------------------------------+----------------------------+---------------+
| :math:`z`      | Altitude above equator                  | :math:`R_p`                |               |
+----------------+-----------------------------------------+----------------------------+---------------+
| :math:`r_0`    | Torus center equatorial diameter        | :math:`R_p`                | ``PERP``      |
+----------------+-----------------------------------------+----------------------------+---------------+
| :math:`H`      | Torus scale-height                      | :math:`R_p`                | ``SCALE``     |
+----------------+-----------------------------------------+----------------------------+---------------+

**Example:** We define the Io torus, with a peak reference density of :math:`2000\,\textrm{cm}^{-3}`, an equatorial
diameter of 5.91 Jovian Radii (orbit of Io) and a torus scale-height of 1 Jovian radius, as defined in
:cite:`doi:10.1029/93JA02908`.

.. code-block::

  {
    "ON": true,
    "NAME": "Body1_density2",
    "TYPE": "Torus",
    "RHO0": 2000,
    "SCALE": 1,
    "PERP": 5.91
  }


.. _MFL:

Magnetic Field Models
---------------------

The detailed magnetic field models available for ExPRES are listed in the `LESIA_mag
<https://gitlab.obspm.fr/maser/lesia-mag/lesia-mag_idl>`_ repository. We recall below the list of models and the
related references.

+---------+----------------------------+----------------------------+------------------------+
| Planet  | Magnetic Field Model       | Current Sheet Model        | ``BODY.MAG`` Value     |
|         +------------+---------------+------------+---------------+                        |
|         | Short Name | Reference     | Model Name | Reference     |                        |
+=========+============+===============+============+===============+========================+
| Mercury | A12        | :cite:`And12` |                            | ``A12``                |
+---------+------------+---------------+------------+---------------+------------------------+
| Jupiter | ISaAC      | :cite:`HBZ11` | CAN81      | :cite:`CAN81` | ``ISaAC+Connerney CS`` |
|         +------------+---------------+            |               +------------------------+
|         | JRM09      | :cite:`CKO18` |            |               | ``JRM09+Connerney CS`` |
|         +------------+---------------+            |               +------------------------+
|         | O6         | :cite:`C1992` |            |               | ``O6+Connerney CS``    |
|         +------------+---------------+            |               +------------------------+
|         | VIP4       | :cite:`CAN98` |            |               | ``VIP4+Connerney CS``  |
|         +------------+---------------+            |               +------------------------+
|         | VIPAL      | :cite:`HBB17` |            |               | ``VIPAL+Connerney CS`` |
|         +------------+---------------+            |               +------------------------+
|         | VIT4       | :cite:`C2007` |            |               | ``VIT4+Connerney CS``  |
+---------+------------+---------------+------------+---------------+------------------------+
| Saturn  | SPV        | :cite:`DS90`  |                            | ``SPV``                |
|         +------------+---------------+----------------------------+------------------------+
|         | Z3         | :cite:`CAN84` |                            | ``Z3``                 |
+---------+------------+---------------+----------------------------+------------------------+
| Uranus  | AH5        | :cite:`H2009` |                            | ``AH5``                |
|         +------------+---------------+----------------------------+------------------------+
|         | Q3         | :cite:`CAN87` |                            | ``Q3``                 |
+---------+------------+---------------+----------------------------+------------------------+


References
----------

.. bibliography:: /refs.bib