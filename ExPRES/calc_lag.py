import numpy
import math

lag_dict = {  # True == North, False == South
    'Io': {True: (2.8, -3.5), False: (4.3, 3.5)},
    'Ganymede': {True: (6.8, -6.2), False: (6.8, 6.2)},
    'Europa': {True: (5.2, -4.8), False: (5.2, 4.8)}
}


def calc_lag(north, phase, satellite):
    """
    Compute the radio emission lead angle for the hemisphere, phase and moon.

    Reference: Hess et al 2011.

    :param north: True for Northern hemisphere, False for Southern Hemisphere
    :param phase: Angular phase, in degrees
    :param satellite: name of the moon
    :type north: bool
    :type phase: numpy.array
    :type satellite: str
    :return: computed lead angle
    :rtype: numpy.array
    """

    if satellite in lag_dict.keys():
        A, B = lag_dict[satellite][north]
        lag = -(A + B * numpy.cos(numpy.deg2rad(phase-202)))
    else:
        lag = 0.

    return lag
