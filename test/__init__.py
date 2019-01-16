import configparser
from idlpy import *
import pathlib
import urllib.request
import os

cur_dir = pathlib.Path(__file__).parent
src_dir = cur_dir.parent / 'src'
sup_dir = cur_dir.parent / 'support' / 'tests'
cdawlib_path = '/Users/baptiste/Projets/JUNO/Ground-Support/cdf/cdawlib'
coyote_path = '/Users/baptiste/Development/idl_lib/coyote'

mfl_url = 'http://maser.obspm.fr/support/expres/mfl/'

def get_config():
    config = configparser.ConfigParser()
    config.read(str(src_dir / 'config.ini'))
    return config


def init_serpe_idl():
    IDL.run("CD, '{}'".format(str(src_dir)))
    IDL.run('!path = !path + ":" + EXPAND_PATH("+{}") + ":" + EXPAND_PATH("+{}")'.format(cdawlib_path, coyote_path))
    return IDL


def get_test_json_file():
    return sup_dir / 'expres_earth_jupiter_io_jrm09_lossc-wid1deg_3kev_20150430_v01.json'


def get_test_mfl_dir():
    return sup_dir / 'mfl'


def load_test_mfl(mfl_name):
    mfl_dir = get_test_mfl_dir()
    if (mfl_dir / mfl_name).exists():
        pass
    else:
        # downloading corresponding mfl_name data
        mfl_url_name = '{}{}.tar.gz'.format(mfl_url,mfl_name)
        mfl_tmp_tgz = pathlib.Path('/tmp') / '{}.tar.gz'.format(mfl_name)
        urllib.request.urlretrieve(mfl_url_name, str(mfl_tmp_tgz))
        os.system('cd {} ; tar -xzf {}'.format(str(mfl_dir), str(mfl_tmp_tgz)))
