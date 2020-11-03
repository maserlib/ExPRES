from pathlib import Path
import re

__ALL__ = ['SCHEMA']

_here = Path(__file__)
_expres_schema_dir = _here.parent / 'support' / 'schema' / 'expres'
_expres_namespace_uri_root = 'https://voparis-ns.obspm.fr/maser/expres/'


def schema_uri_from_version(version_string):
    if re.match(r'^v\d\.\d\.\d$', version_string):
        expres_schema_uri = f'{_expres_namespace_uri_root}/{version_string}/expres-{version_string}.json'
    elif re.match(r'^v\d\.\d\$', version_string):
        expres_schema_uri = f'{_expres_namespace_uri_root}/{version_string}/schema#'
    else:
        raise ValueError(f'This version does not exist: {version_string}')
    return expres_schema_uri


SCHEMA = {
    schema_uri_from_version('v1.0.0'): _expres_schema_dir / 'v1.0' / 'expres-v1.0.0.json',
    schema_uri_from_version('v1.0.1'): _expres_schema_dir / 'v1.0' / 'expres-v1.0.1.json',
    schema_uri_from_version('v1.0.2'): _expres_schema_dir / 'v1.0' / 'expres-v1.0.2.json',
    schema_uri_from_version('v1.0.3'): _expres_schema_dir / 'v1.0' / 'expres-v1.0.3.json',
    schema_uri_from_version('v1.0'):  _expres_schema_dir / 'v1.0' / 'expres-v1.0.3.json',
    schema_uri_from_version('v1.1.0'):  _expres_schema_dir / 'v1.1' / 'expres-v1.1.0.json',
    schema_uri_from_version('v1.1'): _expres_schema_dir / 'v1.1' / 'expres-v1.1.0.json',
}
