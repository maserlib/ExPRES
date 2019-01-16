from . import *
import unittest
from pathlib import Path


class field(unittest.TestCase):
    """
    Test cases for serpe/expres FIELD.PRO
    """

    def setUp(self):
        self.idl = init_serpe_idl()
        self.mfl_dir = get_test_mfl_dir()
        load_test_mfl('Z3_lsh')
        load_test_mfl('VIP4_lat')

    def tearDown(self):
        self.idl.run('.reset_session')

    def test_field__interogate_field_0(self):
        self.idl.run("a = interogate_field('{}/Z3_lsh/','10','-')".format(self.mfl_dir))
        a = self.idl.a
        self.assertIsInstance(p, int8)
        self.assertEqual(a, 1)

    def test_field__interogate_field_1(self):
        self.idl.run("a = interogate_field('{}/VIP4_lat/','10','-')".format(self.mfl_dir))
        a = self.idl.a
        self.assertIsInstance(p, int8)
        self.assertEqual(a, 0)
    
    def test_field__interogate_field_stop(self):
        self.idl.run("a = interogate_field('{}/VIPAL_lsh/','10','-')".format(self.mfl_dir))
        a = self.idl.a
        self.assertIsInstance(p, int8)
        self.assertEqual(a, 0)
