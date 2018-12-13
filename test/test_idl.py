import pidly
import pathlib
import numpy
import math
import configparser

import unittest

cur_dir = pathlib.Path(__file__).parent
src_dir = cur_dir.parent / 'src'
test_json = cur_dir.parent / 'support' / 'expres_earth_jupiter_io_jrm09_lossc-wid1deg_3kev_20150430_v01.json'

def get_config():
    config = configparser.ConfigParser()
    config.read(str(src_dir / 'config.ini'))
    return config

def init_serpe_idl():
    idl = pidly.IDL('/Applications/exelis/idl84/bin/idl')
    idl("CD, '{}'".format(str(src_dir)))
#    idl('!path = !path + ":{}:{}:{}"'.format(str(src_dir), '/Users/baptiste/Projets/JUNO/Ground-Support/cdf/cdawlib', '/Users/baptiste/Development/idl_lib/coyote'))
    idl('!path = !path + ":" + EXPAND_PATH("+{}") + ":" + EXPAND_PATH("+{}")'.format('/Users/baptiste/Projets/JUNO/Ground-Support/cdf/cdawlib', '/Users/baptiste/Development/idl_lib/coyote'))

#    idl('@serpe_compile')
    return idl

def fix_empty_string_in_struct(idl, struct_attr_string, revert=False):
    """
        pIDLy cannot import an IDL structure into python if the value of a string type attribute is empty, we fix this here. 
    """

    if revert:
       idl("{} = ''".format(struct_attr_string))
    else:
       idl("{} = 'test'".format(struct_attr_string))


class read_save(unittest.TestCase):
    """
    Test cases for serpe/expres READ_SAVE.PRO 
    """

    def init_test():
        idl = init_serpe_idl()
        cfg = get_config()

        idl(".r read_save")

        return idl


    def test_INIT_SERPE_STRUCTURES(self):

        def struct_attr_test(var, type, dtype, shape):
            self.assertIsInstance(var, type)
            self.assertEqual(var.dtype, dtype)
            self.assertEqual(var.shape, shape)

        def test_INIT_SERPE_STRUCTURES__time(self):
            idl = read_save.init_test()
            idl("init_serpe_structures,time,freq,observer,body,dens,src,spdyn,cdf,mov2d,mov3d")
            self.assertIsInstance(idl.time, dict)
            self.assertSetEqual(set(idl.time.keys()), {'mini', 'maxi', 'nbr', 'dt'})
            struct_attr_test(idl.time['mini'], numpy.ndarray, 'float64', ())
            struct_attr_test(idl.time['maxi'], numpy.ndarray, 'float64', ())
            struct_attr_test(idl.time['nbr'], numpy.ndarray, 'int32', ())
            struct_attr_test(idl.time['dt'], numpy.ndarray, 'float32', ())
            idl.close()

        def test_INIT_SERPE_STRUCTURES__freq(self):
            idl = read_save.init_test()
            idl("init_serpe_structures,time,freq,observer,body,dens,src,spdyn,cdf,mov2d,mov3d")
            fix_empty_string_in_struct(idl, 'freq.name')
            self.assertIsInstance(idl.freq, dict)
            self.assertSetEqual(set(idl.freq.keys()), {'mini', 'maxi', 'nbr', 'df', 'name', 'log', 'predef'})
            struct_attr_test(idl.freq['mini'], numpy.ndarray, 'float32', ())
            struct_attr_test(idl.freq['maxi'], numpy.ndarray, 'float32', ())
            struct_attr_test(idl.freq['nbr'], numpy.ndarray, 'int32', ())
            struct_attr_test(idl.freq['df'], numpy.ndarray, 'float32', ())
            struct_attr_test(idl.freq['name'], numpy.ndarray, '<U4', ())
            struct_attr_test(idl.freq['log'], numpy.ndarray, 'uint8', ())
            struct_attr_test(idl.freq['predef'], numpy.ndarray, 'uint8', ())
            fix_empty_string_in_struct(idl, 'freq.name', revert=True)
            idl.close()

        def test_INIT_SERPE_STRUCTURES__observer(self):
            idl = read_save.init_test()
            idl("init_serpe_structures,time,freq,observer,body,dens,src,spdyn,cdf,mov2d,mov3d")
            fix_empty_string_in_struct(idl, 'observer.name')
            fix_empty_string_in_struct(idl, 'observer.parent')
            fix_empty_string_in_struct(idl, 'observer.start')
            self.assertIsInstance(idl.observer, dict)
            self.assertSetEqual(set(idl.observer.keys()), {'motion', 'smaj', 'smin', 'decl', 'alg', 'incl', 'phs', 'predef', 'name', 'parent', 'start'})
            struct_attr_test(idl.observer['motion'], numpy.ndarray, 'uint8', ())
            struct_attr_test(idl.observer['smaj'], numpy.ndarray, 'float32', ())
            struct_attr_test(idl.observer['smin'], numpy.ndarray, 'float32', ())
            struct_attr_test(idl.observer['decl'], numpy.ndarray, 'float32', ())
            struct_attr_test(idl.observer['alg'], numpy.ndarray, 'float32', ())
            struct_attr_test(idl.observer['incl'], numpy.ndarray, 'float32', ())
            struct_attr_test(idl.observer['phs'], numpy.ndarray, 'float32', ())
            struct_attr_test(idl.observer['predef'], numpy.ndarray, 'uint8', ())
            struct_attr_test(idl.observer['name'], numpy.ndarray, '<U4', ())
            struct_attr_test(idl.observer['parent'], numpy.ndarray, '<U4', ())
            struct_attr_test(idl.observer['start'], numpy.ndarray, '<U4', ())
            fix_empty_string_in_struct(idl, 'observer.name', revert=True)
            fix_empty_string_in_struct(idl, 'observer.parent', revert=True)
            fix_empty_string_in_struct(idl, 'observer.start', revert=True)
            idl.close()

        def test_INIT_SERPE_STRUCTURES__body(self):
            idl = read_save.init_test()
            idl("init_serpe_structures,time,freq,observer,body,dens,src,spdyn,cdf,mov2d,mov3d")
            fix_empty_string_in_struct(idl, 'body.name')
            fix_empty_string_in_struct(idl, 'body.parent')
            fix_empty_string_in_struct(idl, 'body.mfl')
            self.assertIsInstance(idl.body, dict)
            self.assertSetEqual(set(idl.body.keys()), {'on', 'name', 'rad', 'per', 'flat', 'orb1', 'lg0', 'sat', 'smaj', 
                                                       'smin', 'decl', 'alg', 'incl', 'phs', 'parent', 'mfl', 'dens', 'ipar'})
            struct_attr_test(idl.body['on'], numpy.ndarray, 'uint8', ())
            struct_attr_test(idl.body['name'], numpy.ndarray, '<U4', ())
            struct_attr_test(idl.body['rad'], numpy.ndarray, 'float32', ())
            struct_attr_test(idl.body['per'], numpy.ndarray, 'float32', ())
            struct_attr_test(idl.body['flat'], numpy.ndarray, 'float32', ())
            struct_attr_test(idl.body['orb1'], numpy.ndarray, 'float32', ())
            struct_attr_test(idl.body['lg0'], numpy.ndarray, 'float32', ())
            struct_attr_test(idl.body['sat'], numpy.ndarray, 'uint8', ())
            struct_attr_test(idl.body['smaj'], numpy.ndarray, 'float32', ())
            struct_attr_test(idl.body['smin'], numpy.ndarray, 'float32', ())
            struct_attr_test(idl.body['decl'], numpy.ndarray, 'float32', ())
            struct_attr_test(idl.body['alg'], numpy.ndarray, 'float32', ())
            struct_attr_test(idl.body['incl'], numpy.ndarray, 'float32', ())
            struct_attr_test(idl.body['phs'], numpy.ndarray, 'float32', ())
            struct_attr_test(idl.body['parent'], numpy.ndarray, '<U4', ())
            struct_attr_test(idl.body['mfl'], numpy.ndarray, '<U4', ())
            struct_attr_test(idl.body['dens'], numpy.ndarray, 'int16', (4,))
            struct_attr_test(idl.body['ipar'], numpy.ndarray, 'int16', ())
            fix_empty_string_in_struct(idl, 'body.name', revert=True)
            fix_empty_string_in_struct(idl, 'body.parent', revert=True)
            fix_empty_string_in_struct(idl, 'body.mfl', revert=True)
            idl.close()

        def test_INIT_SERPE_STRUCTURES__dens(self):
            idl = read_save.init_test()
            idl("init_serpe_structures,time,freq,observer,body,dens,src,spdyn,cdf,mov2d,mov3d")
            fix_empty_string_in_struct(idl, 'dens.name')
            fix_empty_string_in_struct(idl, 'dens.type')
            self.assertIsInstance(idl.dens, dict)
            self.assertSetEqual(set(idl.dens.keys()), {'on', 'name', 'type', 'rho0', 'height', 'perp'})
            struct_attr_test(idl.dens['on'], numpy.ndarray, 'uint8', ())
            struct_attr_test(idl.dens['name'], numpy.ndarray, '<U4', ())
            struct_attr_test(idl.dens['type'], numpy.ndarray, '<U4', ())
            struct_attr_test(idl.dens['rho0'], numpy.ndarray, 'float32', ())
            struct_attr_test(idl.dens['height'], numpy.ndarray, 'float32', ())
            struct_attr_test(idl.dens['perp'], numpy.ndarray, 'float32', ())
            fix_empty_string_in_struct(idl, 'dens.name', revert=True)
            fix_empty_string_in_struct(idl, 'dens.type', revert=True)
            idl.close()

        def test_INIT_SERPE_STRUCTURES__src(self):
            idl = read_save.init_test()
            idl("init_serpe_structures,time,freq,observer,body,dens,src,spdyn,cdf,mov2d,mov3d")
            fix_empty_string_in_struct(idl, 'src.name')
            fix_empty_string_in_struct(idl, 'src.parent')
            fix_empty_string_in_struct(idl, 'src.sat')
            fix_empty_string_in_struct(idl, 'src.type')
            fix_empty_string_in_struct(idl, 'src.lgauto')
            self.assertIsInstance(idl.src, dict)
            self.assertSetEqual(set(idl.src.keys()), {'on', 'name', 'parent', 'sat', 'type', 'loss', 'lossbornes', 
                                                      'ring', 'cavity', 'constant', 'width', 'temp', 'cold', 'v', 
                                                      'lgauto', 'lgmin', 'lgmax', 'lgnbr', 'lgstep', 'latmin', 'latmax', 
                                                      'latstep', 'north', 'south', 'subcor', 'aurora_alt', 'refract'})
            struct_attr_test(idl.src['on'], numpy.ndarray, 'uint8', ())
            struct_attr_test(idl.src['name'], numpy.ndarray, '<U4', ())
            struct_attr_test(idl.src['parent'], numpy.ndarray, '<U4', ())
            struct_attr_test(idl.src['sat'], numpy.ndarray, '<U4', ())
            struct_attr_test(idl.src['type'], numpy.ndarray, '<U4', ())
            struct_attr_test(idl.src['loss'], numpy.ndarray, 'uint8', ())
            struct_attr_test(idl.src['ring'], numpy.ndarray, 'uint8', ())
            struct_attr_test(idl.src['cavity'], numpy.ndarray, 'uint8', ())
            struct_attr_test(idl.src['constant'], numpy.ndarray, 'float32', ())
            struct_attr_test(idl.src['width'], numpy.ndarray, 'float32', ())
            struct_attr_test(idl.src['temp'], numpy.ndarray, 'float64', ())
            struct_attr_test(idl.src['cold'], numpy.ndarray, 'float64', ())
            struct_attr_test(idl.src['v'], numpy.ndarray, 'float64', ())
            struct_attr_test(idl.src['lgauto'], numpy.ndarray, '<U4', ())
            struct_attr_test(idl.src['lgmin'], numpy.ndarray, 'float32', ())
            struct_attr_test(idl.src['lgmax'], numpy.ndarray, 'float32', ())
            struct_attr_test(idl.src['lgnbr'], numpy.ndarray, 'int16', ())
            struct_attr_test(idl.src['lgstep'], numpy.ndarray, 'float32', ())
            struct_attr_test(idl.src['latmin'], numpy.ndarray, 'float32', ())
            struct_attr_test(idl.src['latmax'], numpy.ndarray, 'float32', ())
            struct_attr_test(idl.src['latstep'], numpy.ndarray, 'float32', ())
            struct_attr_test(idl.src['north'], numpy.ndarray, 'uint8', ())
            struct_attr_test(idl.src['south'], numpy.ndarray, 'uint8', ())
            struct_attr_test(idl.src['subcor'], numpy.ndarray, 'float32', ())
            struct_attr_test(idl.src['aurora_alt'], numpy.ndarray, 'float64', ())
            struct_attr_test(idl.src['refract'], numpy.ndarray, 'uint8', ())
            fix_empty_string_in_struct(idl, 'src.name', revert=True)
            fix_empty_string_in_struct(idl, 'src.parent', revert=True)
            fix_empty_string_in_struct(idl, 'src.sat', revert=True)
            fix_empty_string_in_struct(idl, 'src.type', revert=True)
            fix_empty_string_in_struct(idl, 'src.lgauto', revert=True)
            idl.close()

        def test_INIT_SERPE_STRUCTURES__spdyn(self):
            idl = read_save.init_test()
            idl("init_serpe_structures,time,freq,observer,body,dens,src,spdyn,cdf,mov2d,mov3d")
            self.assertIsInstance(idl.spdyn, dict)
            self.assertSetEqual(set(idl.spdyn.keys()), {'intensity', 'polar', 'f_t', 'lg_t', 'lat_t', 'f_r', 'lg_r', 
                                                        'lat_r', 'f_lg', 'lg_lg', 'lat_lg', 'f_lat', 'lg_lat', 
                                                        'lat_lat', 'f_lt', 'lg_lt', 'lat_lt', 'khz', 'pdf', 'log', 
                                                        'xrange', 'lgrange', 'larange', 'ltrange', 'nr', 'dr', 'nlg', 
                                                        'dlg', 'nlat', 'dlat', 'nlt', 'dlt', 'infos'})
            struct_attr_test(idl.sdpyn['intensity'], numpy.ndarray, 'uint8', ())
            struct_attr_test(idl.sdpyn['polar'], numpy.ndarray, 'uint8', ())
            struct_attr_test(idl.sdpyn['f_t'], numpy.ndarray, 'uint8', ())
            struct_attr_test(idl.sdpyn['lg_t'], numpy.ndarray, 'uint8', ())
            struct_attr_test(idl.sdpyn['lat_t'], numpy.ndarray, 'uint8', ())
            struct_attr_test(idl.sdpyn['f_r'], numpy.ndarray, 'uint8', ())
            struct_attr_test(idl.sdpyn['lg_r'], numpy.ndarray, 'uint8', ())
            struct_attr_test(idl.sdpyn['lat_r'], numpy.ndarray, 'uint8', ())
            struct_attr_test(idl.sdpyn['f_lg'], numpy.ndarray, 'uint8', ())
            struct_attr_test(idl.sdpyn['lg_lg'], numpy.ndarray, 'uint8', ())
            struct_attr_test(idl.sdpyn['lat_lg'], numpy.ndarray, 'uint8', ())
            struct_attr_test(idl.sdpyn['f_lat'], numpy.ndarray, 'uint8', ())
            struct_attr_test(idl.sdpyn['lg_lat'], numpy.ndarray, 'uint8', ())
            struct_attr_test(idl.sdpyn['lat_lat'], numpy.ndarray, 'uint8', ())
            struct_attr_test(idl.sdpyn['f_lt'], numpy.ndarray, 'uint8', ())
            struct_attr_test(idl.sdpyn['lg_lt'], numpy.ndarray, 'uint8', ())
            struct_attr_test(idl.sdpyn['lat_lt'], numpy.ndarray, 'uint8', ())
            struct_attr_test(idl.sdpyn['khz'], numpy.ndarray, 'uint8', ())
            struct_attr_test(idl.sdpyn['pdf'], numpy.ndarray, 'uint8', ())
            struct_attr_test(idl.sdpyn['log'], numpy.ndarray, 'uint8', ())
            struct_attr_test(idl.sdpyn['xrange'], numpy.ndarray, 'float32', (2,))
            struct_attr_test(idl.sdpyn['lgrange'], numpy.ndarray, 'float32', (2,))
            struct_attr_test(idl.sdpyn['larange'], numpy.ndarray, 'float32', (2,))
            struct_attr_test(idl.sdpyn['ltrange'], numpy.ndarray, 'float32', (2,))
            struct_attr_test(idl.sdpyn['nr'], numpy.ndarray, 'int32', ())
            struct_attr_test(idl.sdpyn['dr'], numpy.ndarray, 'float32', ())
            struct_attr_test(idl.sdpyn['nlg'], numpy.ndarray, 'int32', ())
            struct_attr_test(idl.sdpyn['dlg'], numpy.ndarray, 'float32', ())
            struct_attr_test(idl.sdpyn['nlat'], numpy.ndarray, 'int32', ())
            struct_attr_test(idl.sdpyn['dlat'], numpy.ndarray, 'float32', ())
            struct_attr_test(idl.sdpyn['nlt'], numpy.ndarray, 'int32', ())
            struct_attr_test(idl.sdpyn['dlt'], numpy.ndarray, 'float32', ())
            struct_attr_test(idl.sdpyn['infos'], numpy.ndarray, 'uint8', ())
            idl.close()

        def test_INIT_SERPE_STRUCTURES__cdf(self):
            idl = read_save.init_test()
            idl("init_serpe_structures,time,freq,observer,body,dens,src,spdyn,cdf,mov2d,mov3d")
            self.assertIsInstance(idl.cdf, dict)
            self.assertSetEqual(set(idl.cdf.keys()), {'theta', 'fp', 'fc', 'azimuth', 'obslatitude', 'srclongitude', 
                                                       'srcfreqmax', 'srcfreqmaxcmi', 'obsdistance', 'obslocaltime', 
                                                       'cml', 'srcpos'})
            struct_attr_test(idl.cdf['theta'], numpy.ndarray, 'uint8', ())
            struct_attr_test(idl.cdf['fp'], numpy.ndarray, 'uint8', ())
            struct_attr_test(idl.cdf['fc'], numpy.ndarray, 'uint8', ())
            struct_attr_test(idl.cdf['azimuth'], numpy.ndarray, 'uint8', ())
            struct_attr_test(idl.cdf['obslatitude'], numpy.ndarray, 'uint8', ())
            struct_attr_test(idl.cdf['srclongitude'], numpy.ndarray, 'uint8', ())
            struct_attr_test(idl.cdf['srcfreqmax'], numpy.ndarray, 'uint8', ())
            struct_attr_test(idl.cdf['srcfreqmaxcmi'], numpy.ndarray, 'uint8', ())
            struct_attr_test(idl.cdf['obsdistance'], numpy.ndarray, 'uint8', ())
            struct_attr_test(idl.cdf['obslocaltime'], numpy.ndarray, 'uint8', ())
            struct_attr_test(idl.cdf['cml'], numpy.ndarray, 'uint8', ())
            struct_attr_test(idl.cdf['srcpos'], numpy.ndarray, 'uint8', ())
            idl.close()

        def test_INIT_SERPE_STRUCTURES__mov2d(self):
            idl = read_save.init_test()
            idl("init_serpe_structures,time,freq,observer,body,dens,src,spdyn,cdf,mov2d,mov3d")
            self.assertIsInstance(idl.mov2d, dict)
            self.assertSetEqual(set(idl.mov2d.keys()), {'on', 'sub', 'range'})
            struct_attr_test(idl.mov2d['on'], numpy.ndarray, 'uint8', ())
            struct_attr_test(idl.mov2d['sub'], numpy.ndarray, 'int16', ())
            struct_attr_test(idl.mov2d['range'], numpy.ndarray, 'float32', ())
            idl.close()

        def test_INIT_SERPE_STRUCTURES__mov3d(self):
            idl = read_save.init_test()
            idl("init_serpe_structures,time,freq,observer,body,dens,src,spdyn,cdf,mov2d,mov3d")
            self.assertIsInstance(idl.mov3d, dict)
            self.assertSetEqual(set(idl.mov3d.keys()), {'on', 'sub', 'xrange', 'yrange', 'zrange', 'obs', 'traj'})
            struct_attr_test(idl.mov3d['on'], numpy.ndarray, 'uint8', ())
            struct_attr_test(idl.mov3d['sub'], numpy.ndarray, 'int16', ())
            struct_attr_test(idl.mov3d['xrange'], numpy.ndarray, 'float32', (2,))
            struct_attr_test(idl.mov3d['yrange'], numpy.ndarray, 'float32', (2,))
            struct_attr_test(idl.mov3d['zrange'], numpy.ndarray, 'float32', (2,))
            struct_attr_test(idl.mov3d['obs'], numpy.ndarray, 'uint8', ())
            struct_attr_test(idl.mov3d['traj'], numpy.ndarray, 'uint8', ())
            idl.close()

        test_INIT_SERPE_STRUCTURES__time(self)
        test_INIT_SERPE_STRUCTURES__freq(self)
        test_INIT_SERPE_STRUCTURES__observer(self)
        test_INIT_SERPE_STRUCTURES__body(self)
        test_INIT_SERPE_STRUCTURES__dens(self)
        test_INIT_SERPE_STRUCTURES__src(self)
#        test_INIT_SERPE_STRUCTURES__spdyn(self)
        test_INIT_SERPE_STRUCTURES__cdf(self)
        test_INIT_SERPE_STRUCTURES__mov2d(self)
        test_INIT_SERPE_STRUCTURES__mov3d(self)


    def test_RANK_BODIES(self):
        idl = read_save.init_test()
        idl("init_serpe_structures,time,freq,observer,body,dens,src,spdyn,cdf,mov2d,mov3d")
        fix_empty_string_in_struct(idl, 'body.mfl')
        idl("bodies = [body, body]")
        idl("bodies[0].name = 'Io'")
        idl("bodies[0].parent = 'Jupiter'")
        idl("bodies[0].name = 'Jupiter'")
        idl("rank_bodies,bodies")
        print(idl.bodies[0])
        self.assertIsInstance(idl.bodies, numpy.ndarray)

        idl.close()


    def test_READ_SAVE_JSON(self):
        idl = init_serpe_idl()
        cfg = get_config()

        idl(".r loadpath")
        idl(".r read_save") 
        idl("adresse_mfl = loadpath('adresse_mfl',parameters)")
        idl("read_save_json, adresse_mfl, '{}', parameters".format(str(test_json)))
        self.assertIsInstance(idl.parameters, numpy.ndarray)

        idl.close()


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
        idl("name_r = '{}'".format(str(test_json)))
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

    
