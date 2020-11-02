
import json
from jsonschema import validate as validate_schema
from jsonschema.exceptions import ValidationError
from .version import SCHEMA

ExPRES_schema = SCHEMA


class ExPRESConfig:

    def __init__(self, expres_config_data=None):
        self.config = expres_config_data
        self.error = None

    @property
    def config(self):
        return self._config

    @config.setter
    def config(self, config_data):
        json_schema_id = config_data.get('$schema', ExPRES_schema)
        try:
            validate_schema(instance=config_data, schema=json_schema)
        except ValidationError as error:
            self.error = error
        self._config = config_data

    @classmethod
    def from_json(cls, expres_config_file):
        with open(expres_config_file, 'r') as f:
            expres_config_data = json.loads(f.read())
        return cls(expres_config_data)
