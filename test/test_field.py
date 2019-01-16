from . import *
import unittest
from pathlib import Path


class field(unittest.TestCase):
    """
    Test cases for serpe/expres FIELD.PRO
    """

    def setUp(self):
        self.idl = init_serpe_idl()
        self.cfg = get_config()

    def tearDown(self):
        self.idl.run('.reset_session')

    def test_field__interrogate_field_0(self):
        self.idl.run("a = interrogate_field('support/test/mfl/Z3_lsh/','1','-')")
        a = self.idl.a
        self.assertIsInstance(p, int8)
        self.assertEqual(a, 1)
