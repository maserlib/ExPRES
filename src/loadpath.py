from pathlib import Path
import configparser

_path_mapping = {
    'adresse_cdf': 'cdf_dist_path',
    'adresse_ephem': 'ephem_path',
    'adresse_mfl': 'mfl_path',
    'adresse_save': 'save_path',
    'ffmpeg': 'ffmpeg_path',
    'ps2pdf': 'ps2pdf_path'
}


def loadpath(expres_path_name, parameters, config=None):

    if config is None:
        config_file = Path('config.ini')
    else:
        config_file = Path(config)

    if config_file.exists():
        config_data = configparser.ConfigParser()
        config_data.read(config_file)

    else:
        raise FileNotFoundError(
            'Please configure your config.ini file (check config.ini.template file) in ExPRES distribution directory'
        )

    path_out = Path(config_data['Paths'][_path_mapping[expres_path_name]])

    if expres_path_name == 'adresse_save':
        # special processing for `adresse_save` (data write out path)

        if path_out != Path('./'):

            year = f"{parameters['objects']['SACRED'].date[0]:04d}"
            month = f"{parameters['objects']['SACRED'].date[1]:04d}"
            observer = parameters['objects']['OBSERVER'].name.lower()

            path_out = path_out / observer / year / month
            print(f'mkdir -p {path_out}')
            path_out.mkdir(parents=True, exist_ok=True)

    return path_out
