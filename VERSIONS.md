# Version History

## Latest Release - 1.4.0 (2025)
Contributors: C. Louis, B. Cecconi

Change Log for version 1.4.0:
- Configuration:
  - Add the possibility for users to provide magnetic field and density models
  - The option to have sources located on magnetic field lines with the M Shell is now available for all target
  - Distance values units can either be in physical units (km) or in Planetary Radius (it needs to be consistent all through the config file).
  Physical units (km) are recommanded. Planetary Radius units can still be used, except in the two following cases:
     - If OBSERVER TYPE == Pre-Defined
     - If [BODY][PHASE] == "auto" (for body ≠ central body)
- Others:
  - Creation of codemeta.json file
- Documentation: 
  - Updated readthedocs documentation, available at: https://expres.readthedocs.io/en/latest/ 

Related Publications:
- Judy Chebly, Antoine Strugarek, Corentin K. Louis, Julian D. Alvarado Gomez, Philippe Zarka, "Predicting realistic radio emission from compact star-planet systems", to be submitted to Astronomy & Astrophysics

## Version 1.3.0 (2023)
Contributors: C. Louis, P. Zarka, B. Cecconi

Change Log for version 1.3.0:
- Configuration:
  - Added the wave propagation mode (LO or RX) as an (optional) input. Default value is RX.
- Documentation: 
  - Updated readthedocs documentation, available at: https://expres.readthedocs.io/en/latest/ 

Related Publication: 
- Philippe Zarka, Corentin K. Louis, Jiale Zhang, Hui Tian, Julien Morin and Yang Gao (2025), "Location and energy of electrons producing the radio bursts from AD Leo observed by FAST in December 2021", Astronomy & Astrophysics, 695, A95 (2025). https://doi.org/10.1051/0004-6361/202450950


## Version 1.2.0 (2023)
Contributors: C. Louis, B. Cecconi

Change Log for version 1.2.0:
- Configuration:
    - Validated the refraction effect module
    - Updated of input file schema
    - Added new lead angle models
      - Bonfond et al., 2009, [doi: 10.1029/2009JA014312](https://doi.org/10.1029/2009JA014312)
      - Bonfond et al., 2017, [doi: 10.1016/j.icarus.2017.01.009](https://doi.org/10.1016/j.icarus.2017.01.009)
      - Hinton et al., 2019, [doi: 10.1029/2009JA014394](https://doi.org/10.1029/2009JA014394)
      - Hue et al., 2023, [doi: 10.1029/2023JA031363](https://doi.org/10.1029/2023JA031363)
    - Added new Jupiter's magnetic field and current sheet model:
      - JRM33 ([Connerney et al., 2022, doi: 10.1029/2021JE007055.](https://doi.org/10.1029/2021JE007055)) + CON2020 ([Connerney et al., 2020, doi:10.1029/2020JA028138](https://doi.org/doi:10.1029/2020JA028138))
    - Added new Uranus' magnetic field models:
      - AH5 ([Herbert et al., 2009, doi:10.1029/2009JA014394](https://doi.org/doi:10.1029/2009JA014394.))
      - Q3 ([Connerney et al., 1998, doi:10.1029/JA092iA13p15329](https://doi.org/doi:10.1029/JA092iA13p15329))
- Others:
    - Fixed issue with theta = constant to take into account the surface and/or ionospheric cutoff  
- Documentation: 
  - Updated readthedocs documentation, available at: https://expres.readthedocs.io/en/latest/ 
Related Publication: 
- Louis, C. K, Lamy, L., Jackman, C. M., Cecconi, B., Hess, S. L. G. 2023. "Predictions for Unraus-moons radio emissions and comparison with Voyager 2/PRA observations." Planetary, Solar and Heliospheric Radio Emissions IX, edited by C. K. Louis, C. M. Jackman, G. Fischer, A. H. Sulaiman, P. Zucca, DIAS, TCD, Dublin, Ireland, [doi: 10.25546/103106](https://doi.org/10.25546/103106).
-  Hue, V., Gladstone, G. R., Louis, C. K., Greathouse, T. K., Bonfond, B., Szalay, J. R., Moirano, A., Giles, R. S., Kammer, J. A., Imai, M., Mura, A., Versteeg, M. H., Clark, G., Gérard, J. -C., Grodent, D. C., Rabia, J., Sulaiman, A. H., Bolton, S. J., Connerney, J. E. P. 2023. "The Io, Europa and Ganymede Auroral Footprints at Jupiter in the Ultraviolet: Positions and Equatorial Lead Angles." Journal of Geophysical Research: Space Physics, 128, 5, e2023JA031363, [doi: 10.1029/2023JA031363](https://doi.org/10.1029/2023JA031363).

## Version  1.1.0 (2020)
Contributors: C. Louis, B. Cecconi

Change Log for version 1.1.0:
- Documentation: 
  - Added readthedocs documentation, available at: https://expres.readthedocs.io/en/latest/ 
- Configuration:
  - `SIMU`.`NAME` and `SIMU`.`OUT` are not required anymore. `SIMU`.`NAME` is curently not used. The `SIMU`.`OUT` entry is given by the user in the `config.ini` file.
  - Adding user-provided frequency list option
  - New configuration option for output CDF: SRCPOS (position of the sources, in cartesian)
  - New configuration option for output CDF: SRCVIS (for each hemisphere, sum of the visible sources)
- Ephemeris:
  - Adding support for use-provided WebGeoCalc ephemeris files in csv format
  - Updated MIRIADE and WebGeoCalc ephemerides parsing methods (following undocumented webservice API changes)
  - Modification on the User-defined ephemeris: the ephemerides given by the user can be defined to an accuracy of one second
- Output CDF:
  - Changing the polarization output in cdf file: `Polarization` variable indicates LH or RH polarization, `VisibleSources` provides the sum of visible sources for LH and RH polarization.
  - Added Hemisphere_ID_Label variable in output CDF
  - Modified the calculation of CDF output `SrcFreqMaxCMI`
  - Modification of the CDF outputs if multiple sources
  - Correction of an error on the CDF output time table
- Other:
  - Modify CDF file output version to: `...._v11.cdf`
  - All CDF global attributes are now with type `CDF_CHAR`
  - Modifying call to MFL (`lsh` vs. `msh`, depending on the planet)
  - Added support for M-shell with JRM09 magnetic field model
  
Related Publication: 
- Cecconi, B. C. K. Louis, C. Muñoz, C. Vallat. 2021. "Jovian auroral radio source occultation modelling and application to the JUICE science mission planning." Planetary and Space Science, 209, 105344, [doi: 10.1016/j.pss.2021.105344](https://doi.org/10.1016/j.pss.2021.105344).
    

## Version  1.0.0 (2019)
In this version, the code is called ExPRES (Exoplanetary and Planetary Radio Emissions Simulator)

Contributors: C. Louis, S. L. G. Hess, P. Zarka, B. Cecconi, L. Lamy 

Main additions in this version:
- open source licence and distribution on github
- better documentation

Related Publications:
- Louis CK, SLG Hess, B Cecconi, P Zarka, L Lamy, S Aicardi and A Loh. 2019, "ExPRES: an Exoplanetary and Planetary Radio Emissions Simulator." Astronomy and Astrophysics 627: A30. [doi:10.1051/0004-6361/201935161](https://doi.org/10.1051/0004-6361/201935161).

## Version 0.6.1  (2018)
In this version, the code is called SERPE (Simulation d'Emission Radio Planétaires et Exoplanétaires)

Contributors: C. Louis, S. L. G. Hess, P. Zarka, B. Cecconi, L. Lamy 

Main additions in this version:
- better validation of the simulation steps
- access IMCCE/Miriade ephemeris webservice for observers and natural body locations
- output in CDF
- input in JSON or SRP (original input file format) 

Related publications:
- Louis, CK, L Lamy, P Zarka, B Cecconi, and SLG Hess. 2017. “Detection of Jupiter Decametric Emissions Controlled by Europa and Ganymede with Voyager/PRA and Cassini/RPWS.” J. Geophys. Res. Space Physics 122 (September): 1–20. [doi:10.1002/2016JA023779](https://dx.doi.org/10.1002/2016JA023779).
- Louis, CK, L Lamy, P Zarka, B Cecconi, SLG Hess, X Bonnin. 2018. Simulating Jupiter-satellite decametric emissions with ExPRES: a parametric study", PRE8 proceedings, [arXiv:1804.10499](https://arxiv.org/abs/1804.10499)
and Cassini/RPWS.” J. Geophys. Res. Space Physics 122 (September): 1–20. [doi:10.1002/2016JA023779](https://dx.doi.org/10.1002/2016JA023779).
- Louis, CK, L Lamy, P Zarka, B Cecconi, M Imai, WS Kurth, G Hospodarsky, et al. 2017. “Io-Jupiter Decametric Arcs Observed by Juno/Waves Compared to ExPRES Simulations.” Geophys. Res. Lett., 1–17. [doi:10.1002/2017GL073036](https://dx.doi.org/10.1002/2017GL073036).

## Version 0.6.0  (2011)
In this version, the code is called SERPE (Simulation d'Emission Radio Planétaires et Exoplanétaires)

Contributors: S. L. G. Hess, P. Zarka, B. Cecconi, L. Lamy 

Main additions in this version:
- major reorganization of the code
- output of 3D movies added

Related publication:
- Cecconi, B, SLG Hess, A Hérique, Maria Rosaria Santovito, Daniel Santos-Costa, Philippe Zarka, G Alberti, et al. 2012. “Natural Radio Emission of Jupiter as Interferences for Radar Investigations of the Icy Satellites of Jupiter.” Planet. Space Sci. 61: 32–45. [doi:10.1016/j.pss.2011.06.012](https://dx.doi.org/10.1016/j.pss.2011.06.012).

## Version 0.5.0  (2010)
In this version, the code is called SERPE (Simulation d'Emission Radio Planétaires et Exoplanétaires)

Contributors:  S. L. G. Hess, L. Lamy, P. Zarka, B. Cecconi

Main additions in this version:
- possibility to run simulations for exoplanetary radio emissions

Related publication:
- Hess, S L G, and P Zarka. 2011. “Modeling the Radio Signature of the Orbital Parameters, Rotation, and Magnetic Field of Exoplanets.” Astronomy and Astrophysics 531 (June): A29. [doi:10.1051/0004-6361/201116510](https://dx.doi.org/10.1051/0004-6361/201116510).

## Version 0.4.2  (Feb 2008)
In this version, the code is called SERPE (Simulation d'Emission Radio Planétaires et Exoplanétaires)

Contributors: L. Lamy, S. L. G. Hess, P. Zarka, B. Cecconi

Main additions in this version:
- added altitude of aurora (fmax_alt) parameter 

Related Publication:
- Lamy, L, Philippe Zarka, B Cecconi, SLG Hess, and Renée Prangé. 2008. “Modeling of Saturn Kilometric Radiation Arcs and Equatorial Shadow Zone.” J. Geophys. Res. 113 (A10213). doi:10.1029/2008JA013464.
- Lamy, L, B Cecconi, P Zarka, P Canu, P Schippers, W S Kurth, R L Mutel, D A Gurnett, D Menietti, and P Louarn. 2011. “Emission and Propagation of Saturn Kilometric Radiation: Magnetoionic Modes, Beaming Pattern, and Polarization State.” J. Geophys. Res. 116 (A04212). [doi:10.1029/2010JA016195](https://dx.doi.org/10.1029/2010JA016195)
- Lamy, L, R Prangé, W Pryor, J Gustin, S V Badman, H Melin, T Stallard, D G Mitchell, and P C Brandt. 2013. “Multispectral Simultaneous Diagnosis of Saturn's Aurorae Throughout a Planetary Rotation.” Journal of Geophysical Research (Space Physics) 118 (8): 4817–43. [doi:10.1002/jgra.50404](https://dx.doi.org/10.1002/jgra.50404).

## Version 0.4.1  (Oct 2007)
In this version, the code is called SERPE (Simulation d'Emission Radio Planétaires et Exoplanétaires)

Contributors: L. Lamy, S. L. G. Hess, P. Zarka, B. Cecconi

Main additions in this version:
- New feature to use any trajectory provided by the user.
- Plasma disc density contribution included. 

More details in the version history part of the `serpe.pro` header. 

Related publication:
- Hess, SLG, A Pétin, Philippe Zarka, B Bonfond, and B Cecconi. 2010. “Lead Angles and Emitting Electron Energies of Io-Controlled Decameter Radio Arcs.” Planet. Space Sci. 58 (10): 1188–98. [doi:10.1016/j.pss.2010.04.011](https://dx.doi.org/10.1016/j.pss.2010.04.011).

## Version 0.4.0 (Jun 2007)
In this version, the code is called JUNO.

Contributors: S. L. G. Hess, P. Zarka, B. Cecconi, L. Lamy 

Main added features:
- better portability (plotting option for Windows users)
- added effect of plasma density

## Version 0.3.7 (Mar 2007)
In this version, the code is called JUNO.

Contributors: L. Lamy, S. L. G. Hess, P. Zarka, B. Cecconi

Main added features:
- latitude axis output

## Version 0.3.6 (Feb 2007)
In this version, the code is called JUNO.

Contributors: S. L. G. Hess, P. Zarka, B. Cecconi, L. Lamy 

Main added features:
- ehanced planet description parameters
- fixed spdyn output
- local_time axis output

## Version 0.3.5 (Jan 2007)
In this version, the code is called JUNO.

Contributors: S. L. G. Hess, P. Zarka, B. Cecconi

Main added features:
- active_LT (local time) feature
- set other planet than Jupiter
- better portability for processing on different servers 

## Version 0.3.4 (Nov 2006)
In this version, the code is called JUNO.

Contributors: B. Cecconi, S. L. G. Hess, P. Zarka

Main added features:
- speed up of computing

## Version 0.3.3 (Nov 2006)
In this version, the code is called JUNO.

Contributors: B. Cecconi, S. L. G. Hess, P. Zarka

Main added features:
- speed up of computing (vector computation instead of loop)
- better spatial interpolation of magnetic field 

## Version 0.3.2 (Nov 2006)
In this version, the code is called JUNO.

Contributors: S. L. G. Hess, P. Zarka, B. Cecconi

Main added features:
- two spectrogram per source for moon controlled source (Nother and Southern sources) 

## Version 0.3.1 (Nov 2006)
In this version, the code is called JUNO.

Contributors: B Cecconi, S. L. G. Hess, P. Zarka

Main added features:
- spectral axis interpolation before computation (more accurate results)
- one spectrogram per source for better analysis of the results

## Version 0.3.0 (Oct 2006)
In this version, the code is called JUNO.

Contributors: B. Cecconi, S. L. G. Hess, P. Zarka

Main added features:
- no more common blocks, using pointers instead

## Version 0.2.0 (Sep 2006)
This is the first tracked version. In this version, the code is called JUNO.

Contributors: S. L. G. Hess, P. Zarka, B. Cecconi

Main features:
- computation of the Jovian radio emission visibility from an observer
- input of orbital parameters for observers in orbit around Jupiter 
