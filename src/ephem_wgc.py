import urllib.request
import json
import datetime
import numpy

wgc_esa_api_url = 'http://spice.esac.esa.int/webgeocalc/api'
wgc_nasa_api_url = 'https://wgc2.jpl.nasa.gov:8443/webgeocalc/api'

wgc_api_observer = {
    'JUICE': wgc_esa_api_url,
    'MarsExpress': wgc_esa_api_url,
    'Cassini': wgc_nasa_api_url,
    'Earth': wgc_nasa_api_url,
    'Galileo': wgc_nasa_api_url,
    'Voyager1': wgc_nasa_api_url,
    'Voyager2': wgc_nasa_api_url,
    'Juno': wgc_nasa_api_url,
}

wgc_kernel_observer = {
    'JUICE': [{'type': 'KERNEL_SET', 'id': 11}],  # CREMA-3.2 of JUICE @ ESA
    'MarsExpress': [{'type': 'KERNEL_SET', 'id': 5}],  # Mars-Express @ ESA
    'Cassini': [{'type': 'KERNEL_SET', 'id': 5}],  # Cassini @ NASA
    'Earth': [{'type': 'KERNEL_SET', 'id': 1}],  # Earth @ NASA
    'Galileo': [  # Galileo @ NASA
        {'type': "KERNEL", 'path': "pds/wgc/mk/ground_stations_v0007.tm"},
        {'type': "KERNEL", 'path': "pds/wgc/mk/solar_system_v0027.tm"},
        {'type': "KERNEL", 'path': "pds/wgc/mk/latest_lsk_v0004.tm"},
        {'type': "KERNEL", 'path': "GLL/kernels/spk/gll_951120_021126_raj2007.bsp"},
        {'type': "KERNEL", 'path': "GLL/kernels/sclk/mk00062a.tsc"},
        {'type': "KERNEL", 'path': "GLL/kernels/ck/gll_plt_rec_1995_mav_v00.bc"},
        {'type': "KERNEL", 'path': "GLL/kernels/ck/gll_plt_rec_1996_mav_v00.bc"},
        {'type': "KERNEL", 'path': "GLL/kernels/ck/gll_plt_rec_1997_mav_v00.bc"},
        {'type': "KERNEL", 'path': "GLL/kernels/ck/gll_plt_rec_1998_mav_v00.bc"},
        {'type': "KERNEL", 'path': "GLL/kernels/ck/gll_plt_rec_1999_mav_v00.bc"},
        {'type': "KERNEL", 'path': "GLL/kernels/ck/gll_plt_rec_2000_mav_v00.bc"},
        {'type': "KERNEL", 'path': "GLL/kernels/ck/gll_plt_rec_2001_mav_v00.bc"},
        {'type': "KERNEL", 'path': "GLL/kernels/ck/gll_plt_rec_2002_mav_v00.bc"}
    ],
    'Voyager1': [],  # Voyager1 @ NASA (TODO)
    'Voyager2': [],  # Voyager2 @ NASA (TODO)
    'Juno': [{'type': 'KERNEL_SET', 'id': 15}],  # Juno @ NASA
}

wgc_observer_api_config = {
    'target': {
        'JUICE': 'JUICE_SC',
    },
    'referenceFrame': {
        'JUPITER': 'IAU_JUPITER',
    }
}

body_radius = {
    'JUPITER': 71492
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
    wgc_api_url = wgc_api_observer.get(observer['NAME'], wgc_nasa_api_url)

    wgc_kernels = wgc_kernel_observer[observer['NAME']]
    wgc_target = wgc_observer_api_config['target'].get(observer['NAME'], observer['NAME'])
    wgc_observer = observer['PARENT'].upper()
    wgc_reference_frame = wgc_observer_api_config['referenceFrame'].get(observer['PARENT'], 'J2000')

    wgc_package = {
        "kernels": wgc_kernels,
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
        "target": wgc_target,
        "observer": wgc_observer,
        "referenceFrame": wgc_reference_frame,
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

        if response['status'] == 'OK':
            url = f"{wgc_api_url}/calculation/{response['calculationId']}/results"
            print(url)
            with urllib.request.urlopen(url) as f:
                data = json.loads(f.read().decode())
                print(data['status'])

        longitude = numpy.array([-item[1] for item in data['rows']])  # must be in LongW for ExPRES
        latitude = numpy.array([item[2] for item in data['rows']])
        distance = numpy.array([item[3]/body_radius.get(wgc_observer, 1) for item in data['rows']])

        result_data = {
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

    except Exception as e:
        print(e)
        result_data = None

    return result_data

