from . import *
import unittest
import datetime
import numpy

test_read_ephem_obs_files = {'wgc': ['data/JUICE/StateVectorResults.txt'], 'uiowa':[]}


class amj_aj(unittest.TestCase):
    """
    Test cases for serpe/expres READ_EPHEM_OBS.PRO
    """

    def setUp(self):
        self.idl = init_serpe_idl()
        self.idl.run('.r read_ephem_obs')

    def tearDown(self):
        self.idl.run('.reset_session')

    def test_read_ephem_obs_wgc(self):
        for cur_file in test_read_ephem_obs_files['wgc']:
            self.idl.run('read_ephem_obs, '{}', time, observer, longitude, distance, lat, error'.format(cur_file))
            time = self.idl.time
            observer = self.idl.observer
            longitude = self.idl.longitude
            distance = self.idl.distance
            lat = self.idl.lat
            error = self.idl.error



