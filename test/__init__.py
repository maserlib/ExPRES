import configparser
import pidly
import pathlib

cur_dir = pathlib.Path(__file__).parent
src_dir = cur_dir.parent / 'src'


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


def get_test_json_file():
    return cur_dir.parent / 'support' / 'tests' / 'expres_earth_jupiter_io_jrm09_lossc-wid1deg_3kev_20150430_v01.json'


def fix_empty_string_in_struct(idl, struct_attr_string, revert=False):
    """
        pIDLy cannot import an IDL structure into python if the value of a string type attribute is empty, we fix this here.
    """

    if revert:
       idl("{} = ''".format(struct_attr_string))
    else:
       idl("{} = 'test'".format(struct_attr_string))
