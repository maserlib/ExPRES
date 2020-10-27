from ExPRES.test import *
import numpy
import math
import unittest


class serpe_lesia(unittest.TestCase):
    """
    Test cases for serpe/expres SERPE_LESIA.PRO 
    """

    def setUp(self):
        self.idl = init_serpe_idl()
        self.idl.run('.r serpe_lesia')

    def tearDown(self):
        self.idl.run('.reset_session')

    def test_STRREPLACE(self):
        self.idl.run('s = "test_str_test_str_test"')
        self.idl.run('STRREPLACE,s,"str","STR"')
        self.assertEqual(self.idl.s, 'test_STR_test_str_test')

    def test_XYZ_TO_RTP(self):
        self.idl.run('xyz = [[0,0,0], [1,0,0], [0,1,0], [0,0,1], [-10,0,10]]')
        self.idl.run('rtp = XYZ_TO_RTP(xyz)')
        self.assertIsInstance(self.idl.rtp, numpy.ndarray)
        self.assertEqual(self.idl.rtp.shape, (5, 3))
        self.assertAlmostEqual(self.idl.rtp[0,0], 0, 5)
        self.assertAlmostEqual(self.idl.rtp[1,0], 1, 5)
        self.assertAlmostEqual(self.idl.rtp[1,1], math.pi/2, 5)
        self.assertAlmostEqual(self.idl.rtp[1,2], 0, 5)
        self.assertAlmostEqual(self.idl.rtp[2,0], 1, 5)
        self.assertAlmostEqual(self.idl.rtp[2,1], math.pi/2, 5)
        self.assertAlmostEqual(self.idl.rtp[2,2], math.pi/2, 5)
        self.assertAlmostEqual(self.idl.rtp[3,0], 1, 5)
        self.assertAlmostEqual(self.idl.rtp[3,1], 0, 5)
        self.assertAlmostEqual(self.idl.rtp[4,0], 10*math.sqrt(2), 5)
        self.assertAlmostEqual(self.idl.rtp[4,1], math.pi/4, 5)
        self.assertAlmostEqual(self.idl.rtp[4,2], math.pi, 5)

    def test_TOTALE(self):
        self.idl.run('v1 = [[1,1,1],[2,2,2]]')
        self.idl.run('t1 = TOTALE(v1,2)')
        self.assertIsInstance(self.idl.t1, numpy.ndarray)
        self.assertEqual(self.idl.v1.shape, (2,3,))
        self.assertEqual(self.idl.t1.shape, (3,))
        self.assertEqual(self.idl.t1[0], 3)

        self.idl.run('v2 = [[1,1,1]]')
        self.idl.run('t2 = TOTALE(v1,2)')
        self.assertIsInstance(self.idl.t2, numpy.ndarray)
        self.assertEqual(self.idl.t2.shape, (3,))
        self.assertEqual(self.idl.v2.shape, (3,))
        self.assertEqual(self.idl.v2[0], 1)

    def test_FIND_MIN(self):
        self.idl.run('.r read_save')
        print('test_FIND_MIN not implemented')

    
