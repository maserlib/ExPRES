from . import *
import unittest
import datetime
import numpy

longitude = numpy.arange(0, 359, 1)
lag_io_north = 3.5*numpy.cos(numpy.deg2rad(longitude-202)) - 2.8
lag_io_south = -3.5*numpy.cos(numpy.deg2rad(longitude-202)) - 4.3


class Python_calc_lag(unittest.TestCase):
    """
    Test cases for expres calc_lag.py
    """

    def setUp(self):
        import sys
        sys.path.append('../src/')
        import calc_lag

    def test_calc_lag__io_north(self):
        lag_computed = calc_lag.calc_lag(True, longitude, 'Io')
        self.assertEqual(len(lag_io_north), len(lag_computed))
        for cur_index, cur_lag in enumerate(lag_computed):
            self.assertAlmostEqual(cur_lag, lag_io_north[cur_index], 5)


class IDL_calc_lag(unittest.TestCase):
    """
    Test cases for serpe/expres CALC_LAG.PRO
    """

    def setUp(self):
        self.idl = init_serpe_idl()
        self.idl.run('.r calc_lag')

    def tearDown(self):
        self.idl.run('.reset_session')

    def test_calc_lag__io_north(self):
        self.idl.longitude = longitude
        self.idl.run('lag = calc_lag(1, longitude, satellite="Io")')
        lag_computed = self.idl.lag
        self.assertEqual(len(lag_io_north), len(lag_computed))
        for cur_index, cur_lag in enumerate(lag_computed):
            self.assertAlmostEqual(cur_lag, lag_io_north[cur_index], 5)

    def test_calc_lag__io_south(self):
        self.idl.longitude = longitude
        self.idl.run('lag = calc_lag(0, longitude, satellite="Io")')
        lag_computed = self.idl.lag
        self.assertEqual(len(lag_io_south), len(lag_computed))
        for cur_index, cur_lag in enumerate(lag_computed):
            self.assertAlmostEqual(cur_lag, lag_io_south[cur_index], 5)
