Run-on-Demand
=============

The ExPRES code is available on https://voparis-uws-maser.obspm.fr/client
for run-on-demand requests. This server is implementing the `UWS
(Universal Worker Service Pattern) <https://www.ivoa.net/documents/UWS/>`_,
using the `OPUS (Observatoire de Paris UWS System)
<https://github.com/ParisAstronomicalDataCentre/OPUS>`_ framework. The service
can thus be used from the web interface, or through UWS command line clients,
such as the `uws-client <https://github.com/aipescience/uws-client>`_ (python
2) or one of its forks available at `uws-client
<https://github.com/aicardi-obspm/uws-client>`_ implementing Python 3 support.

Guest Access
------------
This type of access doesn't require to log in the server (no account). This allows guest
users to run the code openly. There are some limitation to the usage:

- Run data and results are visible to all
- Run duration is limited to 10 minutes
- Job can only use the *master* branch

Authenticated Access
--------------------
The authenticated access has be to requested to the `MASER team
<mailto:contact.maser@obspm.fr>`_. This type of access has the following features:

- Run data and results are only accessible to the user
- The maximum run duration is 3 hours.
- Any of the ExPRES git repository branches can be selected

Command Line Interface
----------------------
