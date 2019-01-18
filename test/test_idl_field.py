from . import *
import unittest
from pathlib import Path
import numpy


class field(unittest.TestCase):
    """
    Test cases for serpe/expres FIELD.PRO
    """

    def setUp(self):
        self.idl = init_serpe_idl()
        self.idl.run('.r field')
        self.mfl_dir = get_test_mfl_dir()
        load_test_mfl('Z3_lsh')
        load_test_mfl('VIP4_lat')
        load_test_mfl('VIPAL_lsh')

    def tearDown(self):
        self.idl.run('.reset_session')

    def test_field__interogate_field_0(self):
        self.idl.run("a = interogate_field('{}/Z3_lsh/','10','-')".format(self.mfl_dir))
        a = self.idl.a
        self.assertIsInstance(a, numpy.uint8)
        self.assertEqual(a, 1)

    def test_field__interogate_field_1(self):
        self.idl.run("a = interogate_field('{}/VIPAL_lat/','10','-')".format(self.mfl_dir))
        a = self.idl.a
        self.assertIsInstance(a, numpy.uint8)
        self.assertEqual(a, 0)
    
    def test_field__interogate_field_stop(self):
        self.idl.run("a = interogate_field('{}/O6_lsh/','10','-')".format(self.mfl_dir))
        a = self.idl.a
        self.assertIsInstance(a, str)
        self.assertEqual(a, '')

    def test_field__init_field(self):
        self.idl.run(".r read_save")
        self.idl.run(".r loadpath")    
        self.idl.run("adresse_mfl = loadpath('adresse_mfl',parameters, config='../test/config.ini')")
        self.idl.run("read_save_json, adresse_mfl, '{}', parameters, config='../test/config.ini'".format(str(get_test_json_file())))
        self.idl.run("nobj=n_elements(parameters.objects)")
        self.idl.run("it=strarr(nobj)")
        self.idl.run("for i=0,nobj-1 do it[i]=(*(parameters.objects[i])).it")
        self.assertEqual(self.idl.it[5], 'init_field')
        self.assertEqual(self.idl.it[7], 'init_field')
        self.idl.run("init_field, parameters.objects[5], parameters")
        self.idl.run("init_field, parameters.objects[7], parameters")
