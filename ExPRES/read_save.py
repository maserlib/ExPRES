import json

def check_save_json(json_hash, error):
    pass


class Density:
    def __init__(self, input_data_ds):
        self.name = input_data_ds['name']
        self.type = input_data_ds['type'].lower()
        self.rho0 = input_data_ds['rho0']
        self.height = input_data_ds['height']
        self.perp = input_data_ds['perp']
        self.init = []
        self.callback = []
        self.finalize = []

def rank_bodies(bd):

    ntot = len(bd)
    bd2 = []
    n = 0
    for item in bd:
        if item['parent'] == '':
            bd2.append(item)

    for k=0, ntot-1 do begin
w = where(bd2[0:n - 1].name
eq
bd[k].name)
if w[0] eq -1 then begin
w = where(bd2[0:n - 1].name
eq
bd[k].parent)
if w[0] ne -1 then begin
bd2[n] = bd[k]
bd2[n].ipar = w[0]
n = n + 1
endif
endif
endfor
bd = bd2
return
end


def build_expres_obj(adresse_mfl, file_name, nbody, ndens, nsrc, ticket, time, freq,
    observer, bd, ds, sc, spdyn, cdf, mov2d, mov3d):
    """
    This function defines the main ExpRES dictionary: the simulations parameters.

    :param adresse_mfl: path to the MFL (Magnetic Field Lines) pre-computed data
    :param file_name: input parameters file name
    :type file_name: Path
    :param nbody: number of bodies
    :param ndens: number of density models
    :param nsrc: number of sources
    :param ticket:
    :param time:
    :type time: dict
    :param freq:
    :param observer:
    :param bd:
    :param ds:
    :param sc:
    :param spdyn:
    :param cdf:
    :param mov2d:
    :param mov3d:
    """

    parameters = dict()

# ***** initializing variables *****

    parameters['ticket'] = ticket
    parameters['time'] = {
        'debut': time['mini'],
        'fin': time['maxi'],
        'step': time['dt'],
        'n_step': time['nbr'],
        'time': 0.,
        't0': 0.,
        'istep': 0
    }
    parameters['freq'] = {
        'fmin': freq['mini'],
        'fmax': freq['maxi'],
        'n_freq': freq['nbr'],
        'step': freq['df'],
        'file': freq['name'],
        'log': freq['log'],
        'freq_tab': None
    }
    parameters['name'] = file_name.stem
    parameters['objects'] = []
    parameters['out'] = None

# ***** preparing DENSITY parameters *****

    for item in enumerate(ds[1:]):
        parameters['objects'].append(Density(item))

# ***** preparing BODY parameters *****

    rank_bodies, bd

    return parameters