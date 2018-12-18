from . import *
import numpy
import math
import unittest


class serpe_lesia(unittest.TestCase):
    """
    Test cases for serpe/expres SERPE_LESIA.PRO 
    """

    def test_STRREPLACE(self):

        idl = init_serpe_idl()
        idl('.r serpe_lesia')

        idl('s = "test_str_test_str_test"')
        idl('STRREPLACE,s,"str","STR"')
        self.assertIsInstance(idl.s, numpy.ndarray)
        self.assertEqual(str(idl.s), 'test_STR_test_str_test')

        idl.close()


    def test_XYZ_TO_RTP(self):

        idl = init_serpe_idl()
        idl('.r serpe_lesia')

        idl('xyz = [[0,0,0], [1,0,0], [0,1,0], [0,0,1], [-10,0,10]]')
        idl('rtp = XYZ_TO_RTP(xyz)')
        self.assertIsInstance(idl.rtp, numpy.ndarray)
        self.assertEqual(idl.rtp.shape, (5, 3))
        self.assertAlmostEqual(idl.rtp[0,0], 0, 5)
        self.assertAlmostEqual(idl.rtp[1,0], 1, 5)
        self.assertAlmostEqual(idl.rtp[1,1], math.pi/2, 5)
        self.assertAlmostEqual(idl.rtp[1,2], 0, 5)
        self.assertAlmostEqual(idl.rtp[2,0], 1, 5)
        self.assertAlmostEqual(idl.rtp[2,1], math.pi/2, 5)
        self.assertAlmostEqual(idl.rtp[2,2], math.pi/2, 5)
        self.assertAlmostEqual(idl.rtp[3,0], 1, 5)
        self.assertAlmostEqual(idl.rtp[3,1], 0, 5)
        self.assertAlmostEqual(idl.rtp[4,0], 10*math.sqrt(2), 5)
        self.assertAlmostEqual(idl.rtp[4,1], math.pi/4, 5)
        self.assertAlmostEqual(idl.rtp[4,2], math.pi, 5)

        idl.close()

    def test_TOTALE(self):

        idl = init_serpe_idl()
        idl('.r serpe_lesia')

        idl('v1 = [[1,1,1],[2,2,2]]')
        idl('t1 = TOTALE(v1,2)')
        self.assertIsInstance(idl.t1, numpy.ndarray)
        self.assertEqual(idl.v1.shape, (2,3,))
        self.assertEqual(idl.t1.shape, (3,))
        self.assertEqual(idl.t1[0], 3)

        idl('v2 = [[1,1,1]]')
        idl('t2 = TOTALE(v1,2)')
        self.assertIsInstance(idl.t2, numpy.ndarray)
        self.assertEqual(idl.t2.shape, (3,))
        self.assertEqual(idl.v2.shape, (3,))
        self.assertEqual(idl.v2[0], 1)

        idl.close()

    def test_FIND_MIN(self):

        idl = init_serpe_idl()
        idl('.r serpe_lesia')
        idl('.r read_save')
        print('test_FIND_MIN not implemented')
        idl.close()

    
