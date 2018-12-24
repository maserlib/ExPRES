from . import *
import unittest
import datetime
import numpy


class aj_t70(unittest.TestCase):
    """
    Test cases for serpe/expres AMJ_AJ.PRO
    """

    def setUp(self):
        self.idl = init_serpe_idl()
        self.idl.run('.r aj_amj')

    def tearDown(self):
        self.idl.run('.reset_session')

    def test_aj_t70_4digitYear_long(self):
        dt_aj = datetime.date(2018, 12, 24)
        self.idl.run('t70 = aj_t70({}l)'.format(dt_aj.strftime('%Y%j')))
        dt_t70 = datetime.date(1970, 1, 1) + datetime.timedelta(days=self.idl.t70-1)
        self.assertEqual(dt_aj, dt_t70)

    def test_aj_t70_2digitYear_long(self):
        dt_aj = datetime.date(2018, 12, 24)
        self.idl.run('t70 = aj_t70({}l)'.format(dt_aj.strftime('%Y%j')[2:]))
        dt_t70 = datetime.date(1970, 1, 1) + datetime.timedelta(days=self.idl.t70-1)
        self.assertEqual(dt_aj, dt_aj)

    def test_aj_amj_4digitYear_double(self):
        dt_aj = datetime.datetime(2018, 12, 24, 1, 2, 3)
        self.idl.run('t70 = aj_t70({}d0)'.format(
            float(dt_aj.strftime('%Y%j'))+(dt_aj-dt_aj.replace(hour=0, minute=0, second=0)).total_seconds()/86400)
        )
        dt_t70 = datetime.datetime(1970, 1, 1) + datetime.timedelta(days=self.idl.t70-1)
        self.assertLess(numpy.abs((dt_t70-dt_aj).total_seconds()), 10)

    def test_aj_amj_2digitYear_double(self):
        dt_aj = datetime.datetime(2018, 12, 24, 1, 2, 3)
        self.idl.run('t70 = aj_t70({}d0)'.format(
            float(dt_aj.strftime('%Y%j')[2:])+(dt_aj-dt_aj.replace(hour=0, minute=0, second=0)).total_seconds()/86400)
        )
        dt_t70 = datetime.datetime(1970, 1, 1) + datetime.timedelta(days=self.idl.t70-1)
        self.assertLess(numpy.abs((dt_t70-dt_aj).total_seconds()), 10)
