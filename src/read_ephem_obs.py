import urllib.request
import json
import datetime
import numpy
import os

os.environ["HTTP_PROXY"] = "http://localhost:3128"

wgc_esa_api_url = 'http://spice.esac.esa.int/webgeocalc/api'
wgc_nasa_api_url = 'https://wgc2.jpl.nasa.gov:8443/webgeocalc/api'
wgc_op_api_url = 'http://voparis-webgeocalc2.obspm.fr:8080/geocalc/api'

wgc_api_observer_mapping = {
    'JUICE': wgc_esa_api_url,
    'MarsExpress': wgc_esa_api_url,
    'Earth': wgc_op_api_url,
    'Galileo': wgc_nasa_api_url,
    'Juno': wgc_nasa_api_url,
}

wgc_observer_api_config = {
    'id': {
        'JUICE': 11,  # CREMA-3.2 of JUICE @ ESA
        'MarsExpress': 5,  # Mars-Express @ ESA
        'Earth': 1,  # Solar System Kernels @ NASA
        'Galileo': None,
        'JUNO': 15,
    },
    'target': {
        'JUICE': 'JUICE_SC',
        'JUNO': 'JUNO',
    },
    'referenceFrame': {
        'JUICE': 'IAU_JUPITER'
    }
}


def get_ephem_from_wgc(observer, time):
    """
    Get ephemeris data from WGC servers through API
    :param observer:
    :type observer: dict
    :param time:
    :type time: dict
    :return:
    :rtype: dict
    """

    time_start = datetime.datetime.strptime(observer['START'], '%Y%m%d%H%M')
    time_end = time_start + datetime.timedelta(minutes=int(time['MAX']))
    time_step = time['MAX']/(time['NBR']-1)  # in Minutes

    # get API url, and defaults to NASA
    wgc_api_url = wgc_api_observer_mapping.get(observer['NAME'], wgc_nasa_api_url)

    wgc_package = {
        "kernels": [
            {
                "type": "KERNEL_SET",
                "id": wgc_observer_api_config['id'].get(observer['NAME'], 1)  # get kernel-set (defaults 1 @ NASA)
            },
        ],
        "timeSystem": "UTC",
        "timeFormat": "CALENDAR",
        "intervals": [
            {
                "startTime": time_start.strftime("%Y-%m-%d %H:%M:%S"),
                "endTime": time_end.strftime("%Y-%m-%d %H:%M:%S"),
            }
        ],
        "timeStep": time_step,
        "timeStepUnits": "MINUTES",
        "calculationType": "STATE_VECTOR",
        "target": wgc_observer_api_config['target'].get(observer['NAME'], observer['NAME']),
        "observer": observer['PARENT'].upper(),
        "referenceFrame": wgc_observer_api_config['referenceFrame'].get(observer['NAME'], 'J2000'),
        "aberrationCorrection": "NONE",
        "stateRepresentation": "LATITUDINAL"
    }

    wgc_post_data = json.dumps(wgc_package).encode('ascii')

    headers = {
        "Content-Type": "application/json",
        "Accept": "application/json",
    }

    try:
        req = urllib.request.Request(f"{wgc_api_url}/calculation/new", wgc_post_data, headers)
        with urllib.request.urlopen(req) as f:
            res = f.read()
        response = json.loads(res.decode())
        print(response)
    except Exception as e:
        print(e)

    if response['status'] == 'OK':
        url = f"{wgc_api_url}/calculation/{response['calculationId']}/results"
        print(url)
        with urllib.request.urlopen(url) as f:
            data = json.loads(f.read().decode())
            print(data['status'])

    longitude = numpy.array([item[1] for item in data['rows']])
    latitude = numpy.array([item[2] for item in data['rows']])
    distance = numpy.array([item[3]/71492 for item in data['rows']])  # TODO: set a variable for the planetary radius

    return {
        'time0': observer['START'],
        'time': {
            'MINI': 0,
            'MAXI': time['MAX'],
            'NBR': time['NBR'],
            'DT': time_step,
        },
        'longitude': list(longitude),
        'latitude': list(latitude),
        'distance': list(distance),
    }


if __name__ == "__main__":
    """
    % python read_ephem_obs obs_start=202001020000 obs_name=Earth obs_parent=Jupiter time_max=1439 time_nbr=1440
    """
    import sys
    args = sys.argv[1:]

    observer = {}
    time = {}
    file_out = "wgc.json"

    kv_mapping = {
        'obs_start': (observer, 'START', str),
        'obs_name': (observer, 'NAME', str),
        'obs_parent': (observer, 'PARENT', str),
        'time_max': (time, 'MAX', int),
        'time_nbr': (time, 'NBR', int),
    }

    for item in args:
        arg_key, arg_val = item.split("=")
        if arg_key == "file":
            file_out = arg_val
        else:
            map_var, map_key, map_typ = kv_mapping[arg_key]
            map_var[map_key] = map_typ(arg_val)

    print(observer)
    print(time)

    data = get_ephem_from_wgc(observer, time)
    with open(file_out, 'w') as f:
        json.dump(data, f)
