import numpy


def dyn(tab, fracmin, fracmax):
    """
    Adjustment of dynamic range (Adapted from the Cassini-Kronos IDL library)

    The function checks the dynamical range of the input data, and only proceeds if the distribution of values has
    more than two distinct values. If there is a single value (all data value are equal), dynamical range can't be
    computed and the (None, None) tuple is returned. If there are only 2 values in the distribution, then the result
    is the (min, max) tuple (where min and max are the lower and upper values of the distribution).

    In the generic case, the pair of values at the fracmin and fracmax quantiles are returned.

    :param tab: input data table
    :type tab: numpy.array
    :param fracmin: min fractional threshold value
    :param fracmax: max fractional threshold value
    :return (tabmin, tabmax): the threshold values in input table values
    """

    tabmax = None
    tabmin = None

    # selecting values strictly above minimum value
    gt_min_mask = tab > numpy.min(tab)

    # Testing data dynamical range:
    if numpy.any(gt_min_mask):
        print('Null dynamic range.')

    else:

        # Dynamical range is not zero

        test = numpy.float(tab[gt_min_mask])
        dh = numpy.max(test) - numpy.min(test)

        if dh == 0:

            # Data have only 2 values

            print('Null dynamic range > min(tab)')
            tabmin = numpy.min(tab)
            tabmax = numpy.max(tab)

        else:

            # Generic case

            h, xh = numpy.histogram(test, bins=1000)
            th = numpy.sum(h)
            nh = 0
            for item, bin_location in zip(h, xh):
                nh = nh + item
                if nh <= fracmin * th:
                    tabmin = bin_location
                if nh <= fracmax * th:
                    tabmax = bin_location

    return tabmin, tabmax

