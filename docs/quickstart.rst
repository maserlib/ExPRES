Quickstart
==========

This section presents a concise user's guide to ExPRES.

Configuration File
----------------------

An ExPRES run is configured through a configuration file (in *JSON* format). Examples of configuration files
(and the associated results files) are available from the `ExPRES section of the MASER data repository
<http://maser.obspm.fr/data/expres/>`_ for Io-, Europa- and Ganymede-controlled emissions, and for various observers.
These *routine simulation files* are configured for using the JRM09 :cite:`CKO18` magnetic field model (or ISaAC
:cite:`HBZ11` for some of them), the CAN81 :cite:`CAN81` current sheet model, and an electron energy of 3 keV. The
position of the *Active Flux Tube* (AFT) for Io is based on the (corrected) lead angle model of :cite:`hess_GRL_08`,
whereas for Europa and Ganymede the AFT is the same as the flux tube connected to the moon. The file names are built
automatically by ExPRES. The easiest option to build your configuration file is to update an existing one.

Updating a Configuration File
-----------------------------

You can download a configuration file to get a template (please be sure to take one using the JRM09 magnetic field
model :cite:`CKO18`, for up-to-date description). There are many items and options in this file. Here are the main ones.

Setting the temporal axis
+++++++++++++++++++++++++

The temporal axis is configured in the ``TIME`` section. The *start time* (``MIN`` keyword) and *end time* (``MAX``
keyword) should be provided in minutes relative to the simulation run time origin. The *time sampling step* is computed
from the number of time steps (``NBR`` keyword). The absolute time reference of the simulation run given in the
``OBSERVER`` section, with the ``SCTIME`` keyword. Hence, in most cases, ``MIN`` should be set to 0.

`More detailed temporal axis setting description <usage/advanced.html#temporal-axis>`_

Setting the spectral axis
+++++++++++++++++++++++++

The spectral axis is configured in the ``FREQUENCY`` section. The lower and upper bounds (``MIN`` and ``MAX`` keywords)
are given in MHz. The sampling interval is cimputed from the number of spectral step (``NBR`` keyword). The spectral
axis can use either a ``Linear`` or ``Log`` scale (``TYPE`` keyword values). It is also possible to use a customised
spectral axis.

`More detailed spectral axis setting description <usage/advanced.html#spectral-axis>`_

Setting the observer
++++++++++++++++++++

The observer defines the place, from which the observation will be done. Basic users only need to use a limited set of
parameters. In this short guide, we present the ``Pre-Defined`` type of observer (set in the ``TYPE`` keyword). If you
need to change the *central body* (``PARENT`` keyword), it is recommended to use a configuration file using the
desired *central body*. The name of the observer (``SC`` keyword) should then be a name known by ExPRES. The current
list of known observers is: ``Cassini``, ``Juno``, ``Earth``, ``Voyager1``, ``Voyager2``. The *time origin* of the
simulation run is set with the ``SCTIME`` keyword, with the format: ``YYYYMMDDhhmm``, with ``YYYY`` is the year, ``MM``
the month, ``DD`` the day, ``hh`` the hour, ``mm`` the minute, all 0-padded. The other parameters are not used in this
case.

`More detailed observer's setting description <usage/advanced.html#observer-definition>`_

Setting the output parameters
+++++++++++++++++++++++++++++

The ``CDF`` sub-section of ``SPDYN`` defines the parameters that will be provided in the resulting CDF file. Each
parameters can be selected/deselected setting its value to ``true``/``false``. In most cases, setting ``Theta`` keyword
(opening angle of the emission cone in the direction of the observer) to ``true`` is the minimal recommended setup.
Note that the more options are set, the bigger is the output file.

`More detailed output parameter's description <usage/advanced.html#output-configuration>`_

Setting the plasma model parameters
+++++++++++++++++++++++++++++++++++

The main set of parameters that can be adjusted is the plasma density model at the source. This is done
through the ``DENS`` sub-section of ``BODY``. The default model parameters, in case of the Io-controlled emissions,
are an Ionospheric model (based on :cite:`doi:10.1029/97JA03689`) and an Io torus model (based on
:cite:`doi:10.1029/93JA02908`).

`More detailed the plasma density model's description <usage/advanced.html#plasma-density-models>`_

Setting the radio source parameters
+++++++++++++++++++++++++++++++++++

The ``SOURCE`` section defines the radio source parameters. There may be several sources in the configuration file.
The parameters are:

- ``TYPE``: here, ``attached to a satellite``, which means that the magnetic field lines used will be those connected
  to a moon.
- ``SAT``: if ``TYPE="attached to a satellite"``, then provide the name of the moon (which also needs to be defined as
  a ``BODY``)
- ``aurora_alt``: sets the altitude (in Planetary radius) of the UV aurora (altitude below which electrons are lost by
  collision with the atmosphere)
- ``NORTH``: emission will be produced in the northern hemisphere
- ``SOUTH``: emission will be produced in the southern hemisphere
- ``Width``: width of the beaming hollow cone (in degrees)
- ``current``:

  - In most cases it should be set to ``Transient (Alfvenic)``, which calculates self-consistently the
    beaming angle using the Cyclotron maser Instability (CMI) and a loss cone distribution function
  - It can also be set to ``Constant``, so that the beaming angle will not be calculated using the CMI,
    but will be set at a chosen values (see next parameters)

- ``Constant``: if ``Current="Constant"`` then provide here the value in degree (80.0 for example)
- ``Accel``: the energy of the resonant electrons (in keV)
- ``Refraction``: to take into account refraction in the source’s vicinity (not implemented yet)

Running ExPRES Online
---------------------

The code is available for Run-on-Demand at Observatoire de Paris: https://voparis-uws-maser.obspm.fr/client/

Short workflow to use this interface:

- Click on *Job List* (top left)
- In *Job List for*, select *ExPRES*
- Click on *+ Create New Job* (top right)
- In *config* choose the configuration file (*.json*) you want to run. The other parameters (*runId*,
  *slurp_mem* and *Add control parameters* have to be left as there are)
- Click on *Submit*, and wait for a response. It will first marked as *Queued* and then as *Executing*.
  It will last a few tens of second to a few minutes (depends on how many time/frequency steps and how
  many cdf-output parameters you asked for).
- Then it will be marked as *Completed*,
- In *> Job Results* you will be able to download resulting files.
- If the Job is marked as *Error*, something went wrong during the simulation. Then, look at the
  *> Job Details*, and check the *stdout* and *stderr* sections.

For more details see the `Run-on-Demand <usage/uws.html>`_ page.
