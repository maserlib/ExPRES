import configparser
from idlpy import *
import pathlib

cur_dir = pathlib.Path(__file__).parent
src_dir = cur_dir.parent / 'src'


def get_config():
    config = configparser.ConfigParser()
    config.read(str(src_dir / 'config.ini'))
    return config


def init_serpe_idl():
    IDL.run("CD, '{}'".format(str(src_dir)))
    IDL.run('!path = !path + ":" + EXPAND_PATH("+{}") + ":" + EXPAND_PATH("+{}")'.format('/Users/baptiste/Projets/JUNO/Ground-Support/cdf/cdawlib', '/Users/baptiste/Development/idl_lib/coyote'))
    return IDL


def get_test_json_file():
    return cur_dir.parent / 'support' / 'tests' / 'expres_earth_jupiter_io_jrm09_lossc-wid1deg_3kev_20150430_v01.json'
