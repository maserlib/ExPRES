from . import *
import numpy
import unittest
import collections


def init_test():
    idl = init_serpe_idl()
    cfg = get_config()

    idl.run(".r read_save")

    return idl


class read_save(unittest.TestCase):
    """
    Test cases for serpe/expres READ_SAVE.PRO
    """

    def setUp(self):
        self.idl = init_test()
        self.idl.run("init_serpe_structures,time,freq,observer,body,dens,src,spdyn,cdf,mov2d,mov3d")

    def tearDown(self):
        self.idl.run('.reset_session')

    def test_INIT_SERPE_STRUCTURES__time(self):

        self.assertIsInstance(self.idl.time, collections.OrderedDict)
        self.assertSetEqual(set(self.idl.time.keys()), {'MINI', 'MAXI', 'NBR', 'DT'})

    def test_INIT_SERPE_STRUCTURES__freq(self):
        self.assertIsInstance(self.idl.freq, collections.OrderedDict)
        self.assertSetEqual(set(self.idl.freq.keys()), {'MINI', 'MAXI', 'NBR', 'DF', 'NAME', 'LOG', 'PREDEF'})

    def test_INIT_SERPE_STRUCTURES__observer(self):
        self.assertIsInstance(self.idl.observer, collections.OrderedDict)
        self.assertSetEqual(set(self.idl.observer.keys()), {'MOTION', 'SMAJ', 'SMIN', 'DECL', 'ALG', 'INCL', 'PHS',
                                                            'PREDEF', 'NAME', 'PARENT', 'START'})

    def test_INIT_SERPE_STRUCTURES__body(self):
        self.assertIsInstance(self.idl.body, collections.OrderedDict)
        self.assertSetEqual(set(self.idl.body.keys()), {'ON', 'NAME', 'RAD', 'PER', 'FLAT', 'ORB1', 'LG0', 'SAT', 'SMAJ',
                                                   'SMIN', 'DECL', 'ALG', 'INCL', 'PHS', 'PARENT', 'MFL', 'DENS', 'IPAR'})

    def test_INIT_SERPE_STRUCTURES__dens(self):
        self.assertIsInstance(self.idl.dens, collections.OrderedDict)
        self.assertSetEqual(set(self.idl.dens.keys()), {'ON', 'NAME', 'TYPE', 'RHO0', 'HEIGHT', 'PERP'})

    def test_INIT_SERPE_STRUCTURES__src(self):
        self.assertIsInstance(self.idl.src, collections.OrderedDict)
        self.assertSetEqual(set(self.idl.src.keys()), {'ON', 'NAME', 'PARENT', 'SAT', 'TYPE', 'LOSS', 'LOSSBORNES',
                                                  'RING', 'CAVITY', 'CONSTANT', 'WIDTH', 'TEMP', 'COLD', 'V',
                                                  'LGAUTO', 'LGMIN', 'LGMAX', 'LGNBR', 'LGSTEP', 'LATMIN', 'LATMAX',
                                                  'LATSTEP', 'NORTH', 'SOUTH', 'SUBCOR', 'AURORA_ALT', 'REFRACT'})

    def test_INIT_SERPE_STRUCTURES__spdyn(self):
        self.assertIsInstance(self.idl.spdyn, collections.OrderedDict)
        self.assertSetEqual(set(self.idl.spdyn.keys()), {'INTENSITY', 'POLAR', 'F_T', 'LG_T', 'LAT_T', 'F_R', 'LG_R',
                                                    'LAT_R', 'F_LG', 'LG_LG', 'LAT_LG', 'F_LAT', 'LG_LAT',
                                                    'LAT_LAT', 'F_LT', 'LG_LT', 'LAT_LT', 'KHZ', 'PDF', 'LOG',
                                                    'XRANGE', 'LGRANGE', 'LARANGE', 'LTRANGE', 'NR', 'DR', 'NLG',
                                                    'DLG', 'NLAT', 'DLAT', 'NLT', 'DLT', 'INFOS'})

    def test_INIT_SERPE_STRUCTURES__cdf(self):
        self.assertIsInstance(self.idl.cdf, collections.OrderedDict)
        self.assertSetEqual(set(self.idl.cdf.keys()), {'THETA', 'FP', 'FC', 'AZIMUTH', 'OBSLATITUDE', 'SRCLONGITUDE',
                                                   'SRCFREQMAX', 'SRCFREQMAXCMI', 'OBSDISTANCE', 'OBSLOCALTIME',
                                                   'CML', 'SRCPOS'})

    def test_INIT_SERPE_STRUCTURES__mov2d(self):
        self.assertIsInstance(self.idl.mov2d, collections.OrderedDict)
        self.assertSetEqual(set(self.idl.mov2d.keys()), {'ON', 'SUB', 'RANGE'})

    def test_INIT_SERPE_STRUCTURES__mov3d(self):
        self.assertIsInstance(self.idl.mov3d, collections.OrderedDict)
        self.assertSetEqual(set(self.idl.mov3d.keys()), {'ON', 'SUB', 'XRANGE', 'YRANGE', 'ZRANGE', 'OBS', 'TRAJ'})

    def test_RANK_BODIES(self):
        self.idl.run("bodies = [body, body]")
        self.idl.run("bodies[0].name = 'Io'")
        self.idl.run("bodies[0].parent = 'Jupiter'")
        self.idl.run("bodies[0].name = 'Jupiter'")
        self.idl.run("rank_bodies,bodies")
        print(self.idl.bodies[0])
        self.assertIsInstance(self.idl.bodies, list)
        self.assertIsInstance(self.idl.bodies[0], collections.OrderedDict)

    def test_READ_SAVE_JSON(self):
        self.idl.run(".r loadpath")
        self.idl.run("adresse_mfl = loadpath('adresse_mfl',parameters, config='../test/config.ini')")
        self.idl.run("read_save_json, adresse_mfl, '{}', param, config='../test/config.ini'".format(str(get_test_json_file())))
        self.idl.run("test = param.ticket")
        self.assertTrue(self.idl.test.startswith("Io2015-04-30_"))
        self.idl.run("test = param.time")
        self.assertIsInstance(self.idl.test, collections.OrderedDict)
        self.assertSetEqual(set(self.idl.test.keys()), {"DEBUT", "FIN", "STEP", "N_STEP", "TIME", "T0", "ISTEP"})
        self.idl.run("test = *param.freq.freq_tab")
        self.assertIsNone(self.idl.test)
        self.idl.run("test = param.name")
        self.assertEqual(self.idl.test, 'expres_earth_jupiter_io_vipal_lossc-wid1deg_3kev_20150430_v01')
        self.idl.run("test = n_elements(param.objects)")
        self.assertEqual(self.idl.test, 12)
        self.idl.run("test = *param.objects[0]")
        self.assertSetEqual(set(self.idl.test.keys()), {"NAME", "TYPE", "RHO0", "HEIGHT", "PERP", "IT", "CB", "FZ"})
        self.idl.run("test = (*param.objects[0]).name")
        self.assertEqual(self.idl.test, "Body1_density1")
