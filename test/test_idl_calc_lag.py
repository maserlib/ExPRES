from . import *
import unittest
import datetime
import numpy


class calc_lag(unittest.TestCase):
    """
    Test cases for serpe/expres CALC_LAG.PRO
    """

    def setUp(self):
        self.idl = init_serpe_idl()
        self.idl.run('.r calc_lag')

    def tearDown(self):
        self.idl.run('.reset_session')
