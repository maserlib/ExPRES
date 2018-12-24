from . import *
import unittest
import datetime
import numpy


class amj_aj(unittest.TestCase):
    """
    Test cases for serpe/expres AMJ_AJ.PRO
    """

    def setUp(self):
        self.idl = init_serpe_idl()
        self.idl.run('.r amj_aj')

    def tearDown(self):
        self.idl.run('.reset_session')

    def test_amj_aj_4digitYear_long(self):
        dt_amj = datetime.date(2018, 12, 24)
        self.idl.run('aj = amj_aj({})'.format(dt_amj.strftime('%Y%m%d')))
        dt_aj = datetime.datetime.strptime(str(self.idl.aj), '%Y%j').date()
        self.assertEqual(dt_aj, dt_amj)

    def test_amj_aj_2digitYear_long(self):
        dt_amj = datetime.date(2018, 12, 24)
        self.idl.run('aj = amj_aj({})'.format(dt_amj.strftime('%Y%m%d')[2:]))
        dt_aj = datetime.datetime.strptime('20'+str(self.idl.aj), '%Y%j').date()
        self.assertEqual(dt_aj, dt_amj)

    def test_aj_amj_4digitYear_double(self):
        dt_amj = datetime.datetime(2018, 12, 24, 1, 2, 3)
        self.idl.run('aj = amj_aj({}d0)'.format(
            float(dt_amj.strftime('%Y%m%d'))+(dt_amj-dt_amj.replace(hour=0, minute=0, second=0)).total_seconds()/86400)
        )
        tmp = str(self.idl.aj).split('.')
        dt_aj = datetime.datetime.strptime(tmp[0], '%Y%j')+datetime.timedelta(seconds=float('0.'+tmp[1])*86400)
        self.assertLess(numpy.abs((dt_amj-dt_aj).total_seconds()), 10)

    def test_aj_amj_2digitYear_double(self):
        dt_amj = datetime.datetime(2018, 12, 24, 1, 2, 3)
        self.idl.run('aj = amj_aj({}d0)'.format(
            float(dt_amj.strftime('%Y%m%d')[2:])+(dt_amj-dt_amj.replace(hour=0, minute=0, second=0)).total_seconds()/86400)
        )
        tmp = str(self.idl.aj).split('.')
        dt_aj = datetime.datetime.strptime('20'+tmp[0], '%Y%j')+datetime.timedelta(seconds=float('0.'+tmp[1])*86400)
        self.assertLess(numpy.abs((dt_amj-dt_aj).total_seconds()), 10)
