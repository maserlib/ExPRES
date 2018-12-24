from . import *
import unittest
from pathlib import Path


class loadpath(unittest.TestCase):
    """
    Test cases for serpe/expres LOADPATH.PRO
    """

    def setUp(self):
        self.idl = init_serpe_idl()
        self.cfg = get_config()

    def tearDown(self):
        self.idl.run('.reset_session')

    def test_loadpath__mfl(self):
        self.idl.run("p = loadpath('adresse_mfl',parameters)")
        p = self.idl.p
        self.assertIsInstance(p, str)
        self.assertEqual(p, self.cfg['Paths']['mfl_path'])

    def test_loadpath__cdf(self):
        self.idl.run("p = loadpath('adresse_cdf',parameters)")
        p = self.idl.p
        self.assertIsInstance(p, str)
        self.assertEqual(p, self.cfg['Paths']['cdf_dist_path'])

    def test_loadpath__ephem(self):
        self.idl.run("p = loadpath('adresse_ephem',parameters)")
        p = self.idl.p
        self.assertIsInstance(p, str)
        self.assertEqual(p, self.cfg['Paths']['ephem_path'])

    def test_loadpath__save(self):
        self.idl.run(".r serpe_lesia")
        self.idl.run(".r read_save")
        self.idl.run("name_r = '{}'".format(str(get_test_json_file())))
        self.idl.run("adresse_mfl = loadpath('adresse_mfl',parameters)")
        self.idl.run("read_save_json,adresse_mfl,name_r,parameters")

        self.idl.run("p = loadpath('adresse_save',parameters)")
        p = self.idl.p
        self.assertIsInstance(p, str)
        self.assertEqual(Path(p), Path(self.cfg['Paths']['save_path']) / 'earth' / '2015' / '04')

    def test_loadpath__ffmpeg(self):
        self.idl.run("p = loadpath('ffmpeg',parameters)")
        p = self.idl.p
        self.assertIsInstance(p, str)
        self.assertEqual(p, self.cfg['Paths']['ffmpeg_path'])

    def test_loadpath__ps2pdf(self):
        self.idl.run("p = loadpath('ps2pdf',parameters)")
        p = self.idl.p
        self.assertIsInstance(p, str)
        self.assertEqual(p, self.cfg['Paths']['ps2pdf_path'])
