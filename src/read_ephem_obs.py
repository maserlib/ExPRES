import urllib.request
import json
import datetime
import numpy

wgc_esa_api_url = 'http://spice.esac.esa.int/webgeocalc/api'
wgc_nasa_api_url = 'https://wgc2.jpl.nasa.gov:8443/webgeocalc/api'

wgc_api_observer_mapping = {
    'JUICE': wgc_esa_api_url,
    'MarsExpress': wgc_esa_api_url,
    'Earth': wgc_nasa_api_url,
    'Galileo': wgc_nasa_api_url,
}

wgc_observer_api_config = {
    'id': {
        'JUICE': 11,  # CREMA-3.2 of JUICE @ ESA
        'MarsExpress': 5,  # Mars-Express @ ESA
        'Earth': 1,  # Solar System Kernels @ NASA
        'Galileo': None
    },
    'target': {
        'JUICE': 'JUICE_SC',
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
    time_step = time['MAX']/time['NBR']  # in Minutes

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
        'longitude': longitude,
        'lat': latitude,
        'distance': distance,
    }
