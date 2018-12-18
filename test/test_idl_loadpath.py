from . import *
import numpy
import unittest


class loadpath(unittest.TestCase):
    """
    Test cases for serpe/expres LOADPATH.PRO
    """

    def test_loadpath__mfl(self):
        idl = init_serpe_idl()
        cfg = get_config()

        p = idl.ev("loadpath('adresse_mfl',parameters)")
        self.assertIsInstance(p, numpy.ndarray)
        self.assertEqual(str(p), cfg['Paths']['mfl_path'])

        idl.close()

    def test_loadpath__cdf(self):
        idl = init_serpe_idl()
        cfg = get_config()

        p = idl.ev("loadpath('adresse_cdf',parameters)")
        self.assertIsInstance(p, numpy.ndarray)
        self.assertEqual(str(p), cfg['Paths']['cdf_dist_path'])

        idl.close()

    def test_loadpath__ephem(self):
        idl = init_serpe_idl()
        cfg = get_config()

        p = idl.ev("loadpath('adresse_ephem',parameters)")
        self.assertIsInstance(p, numpy.ndarray)
        self.assertEqual(str(p), cfg['Paths']['ephem_path'])

        idl.close()

    def test_loadpath__save(self):
        idl = init_serpe_idl()
        cfg = get_config()
        idl(".r serpe_lesia")
        idl(".r read_save")
        idl("name_r = '{}'".format(str(get_test_json_file())))
        idl("adress_mfl = loadpath('adresse_mfl',parameters)")
        idl("read_save_json,adresse_mfl,name_r,parameters")

        p = idl.ev("loadpath('adresse_save',parameters)")
        self.assertIsInstance(p, numpy.ndarray)
        self.assertEqual(str(p), cfg['Paths']['save_path'])

        idl.close()

    def test_loadpath__ffmpeg(self):
        idl = init_serpe_idl()
        cfg = get_config()

        p = idl.ev("loadpath('ffmpeg',parameters)")
        self.assertIsInstance(p, numpy.ndarray)
        self.assertEqual(str(p), cfg['Paths']['ffmpeg_path'])

        idl.close()

    def test_loadpath__ps2pdf(self):
        idl = init_serpe_idl()
        cfg = get_config()

        p = idl.ev("loadpath('ps2pdf',parameters)")
        self.assertIsInstance(p, numpy.ndarray)
        self.assertEqual(str(p), cfg['Paths']['ps2pdf_path'])

        idl.close()
