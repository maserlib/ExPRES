#!python3

import sys
import json
import jsonschema
from jsonschema import validate

EXPRES_SCHEMA_DIR = '../schema'
EXPRES_SCHEMA_VERSION = '1.0.3'

expres_schema_file = f'{EXPRES_SCHEMA_DIR}/expres-v{EXPRES_SCHEMA_VERSION}.json'

def validateJson(json_data, expres_schema):
    try:
        validate(instance=json_data, schema=expres_schema)
    except jsonschema.exceptions.ValidationError as err:
        return False
    return True


if __name__ == '__main__':

    with open(sys.argv[0]) as f:
        json_data = json.load(f)

    isValid = validateJson(json_data, expres_schema_file)
