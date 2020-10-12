Installation Guide
=========================

Local installation
------------------

ExPRES can be downloaded from: https://github.com/maserlib/ExPRES

The single step installation is to clone the repository:

.. code-block:: bash

   git clone https://github.com/maserlib/ExPRES.git

Running the code requires to install other softwares, as described below.

Required software
-----------------

IDL
+++

The ExpRES code is running under `IDL (Interactive Data Language) <https://www.harrisgeospatial.com/Software-Technology/IDL>`_, has
been developed and tested on IDL version 8.5, 8.6 and 8.7. This software must be installed for running the ExPRES code.

**Note**
  The code has not been tested with `GDL (GNU Data Language) <https://github.com/gnudatalanguage/gdl>`_, the open source
  version of IDL. This is part of future developments of the code.

The ExPRES uses several external IDL libraries, which are described in the following sections.

CDF and CDAWLib
+++++++++++++++

The ExPRES code writes output files in `CDF (Common Data Format) <https://cdf.gsfc.nasa.gov>`_. The CDF library of IDL requires the
installation of several packages:

- The CDF C-Library corresponding to your operating platform, see: https://spdf.sci.gsfc.nasa.gov/pub/software/cdf/dist/latest-release/
  Note that the code has been tested with the CDF C-Library version 3.6.4.
- The CDF IDL Library, available at: https://spdf.sci.gsfc.nasa.gov/pub/software/cdf/dist/latest-release/idl/
- The CDAWLib IDL routines, available at: https://cdaweb.gsfc.nasa.gov/pub/software/cdawlib/

IDL Astro
+++++++++

The ExPRES code also uses some routines from the `IDLAstro <https://github.com/wlandsman/IDLAstro>`_ library.

Precomputed data
----------------

Precomputed sets of data providing planetary magnetic field line models used by the ExPRES code must to download before
any operation. The data is available from the `ExPRES section of the MASER data server
<http://maser.obspm.fr/support/expres/mfl>`_.

More details on the additional files: https://gitlab.obspm.fr/maser/lesia-mag/lesia-mag_idl


Testing
-------

The test suite are still under development. It uses `unittest` under Python 3.6 and the IDL-Python bridge (idlpy) provided with IDL version 8.7.




