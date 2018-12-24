from . import *
import unittest
import datetime
import numpy


class aj_amj(unittest.TestCase):
    """
    Test cases for serpe/expres AMJ_AJ.PRO
    """

    def setUp(self):
        self.idl = init_serpe_idl()
        self.idl.run('.r aj_amj')

    def tearDown(self):
        self.idl.run('.reset_session')

    def test_aj_amj_4digitYear_long(self):
        dt_aj = datetime.date(2018, 12, 24)
        self.idl.run('amj = aj_amj({}l)'.format(dt_aj.strftime('%Y%j')))
        dt_amj = datetime.datetime.strptime(str(self.idl.amj), '%Y%m%d').date()
        self.assertEqual(dt_amj, dt_aj)

    def test_aj_amj_2digitYear_long(self):
        dt_aj = datetime.date(2018, 12, 24)
        self.idl.run('amj = aj_amj({}l)'.format(dt_aj.strftime('%Y%j')[2:]))
        dt_amj = datetime.datetime.strptime('20'+str(self.idl.amj), '%Y%m%d').date()
        self.assertEqual(dt_amj, dt_aj)

    def test_aj_amj_4digitYear_double(self):
        dt_aj = datetime.datetime(2018, 12, 24, 1, 2, 3)
        self.idl.run('amj = aj_amj({}d0)'.format(
            float(dt_aj.strftime('%Y%j'))+(dt_aj-dt_aj.replace(hour=0, minute=0, second=0)).total_seconds()/86400)
        )
        tmp = str(self.idl.amj).split('.')
        dt_amj = datetime.datetime.strptime(tmp[0], '%Y%m%d')+datetime.timedelta(seconds=float('0.'+tmp[1])*86400)
        self.assertLess(numpy.abs((dt_amj-dt_aj).total_seconds()), 10)

    def test_aj_amj_2digitYear_double(self):
        dt_aj = datetime.datetime(2018, 12, 24, 1, 2, 3)
        self.idl.run('amj = aj_amj({}d0)'.format(
            float(dt_aj.strftime('%Y%j')[2:])+(dt_aj-dt_aj.replace(hour=0, minute=0, second=0)).total_seconds()/86400)
        )
        tmp = str(self.idl.amj).split('.')
        dt_amj = datetime.datetime.strptime('20'+tmp[0], '%Y%m%d')+datetime.timedelta(seconds=float('0.'+tmp[1])*86400)
        self.assertLess(numpy.abs((dt_amj-dt_aj).total_seconds()), 10)
