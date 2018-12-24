from urllib.request import urlopen, urlretrieve
from lxml import etree
from pathlib import Path
import os

_CUR_DIR = Path(__file__).parent

_URL_MFL_ROOT = 'http://maser.obspm.fr/support/serpe/mfl'
_MFL_NAMES = ['ISaAC', 'JRM09', 'O6', 'VIT4', 'VIP4', 'SPV', 'Z3', 'VIPAL']
_MFL_ROOT_DIR = _CUR_DIR / 'mfl'


def html_ls(url):

    url_fixed = url.strip('/')

    with urlopen(url_fixed) as ufile:
        root = etree.parse(ufile, etree.HTMLParser())

    list_ls = []
    for tr in root.getroot().xpath('body/table/tr'):
        for td in tr.xpath('td'):
            for item in td.iter():
                if item.tag == 'a':
                    if item.text != 'Parent Directory':
                        list_ls.append('{}/{}'.format(url_fixed, item.text))

    return list_ls


def html_cp(url, file):
    urlretrieve(url, file)  


def download_mfl(model_name=None):

    model_name_list = _MFL_NAMES
    if model_name is not None:
        if model_name not in _MFL_NAMES:
            raise ValueError('"{}": this model name is not supported'.format(model_name))
        else:
            model_name_list = [model_name]

    mfl_list = html_ls(_URL_MFL_ROOT)

    if not _MFL_ROOT_DIR.is_dir():
        cur_command = 'mkdir {}'.format(str(_MFL_ROOT_DIR))
        print(cur_command)
        os.system(cur_command)

    for mfl_item_url in mfl_list:
        dir_name = mfl_item_url.strip('/').split('/')[-1]
        if '_' in dir_name:
            if dir_name.split('_')[0] in model_name_list:
                
                cur_dir = _MFL_ROOT_DIR / dir_name
                if not cur_dir.is_dir():
                    cur_command = 'mkdir {}'.format(str(cur_dir))
                    print(cur_command)
                    os.system(cur_command)
                
                cur_mfl_subdir_list = html_ls(mfl_item_url)

                for mfl_subdir_item_url in cur_mfl_subdir_list:
                    subdir_name = mfl_subdir_item_url.strip('/').split('/')[-1]
                    cur_subdir = cur_dir / subdir_name
                    cur_command = 'mkdir {}'.format(str(cur_subdir))
                    print(cur_command)
                    os.system(cur_command)

                    cur_mfl_file_list = html_ls(mfl_subdir_item_url)
                    
                    for mfl_file_list_item_url in cur_mfl_file_list:
                        file_name = mfl_file_list_item_url.split('/')[-1]
                        cur_file = cur_subdir / file_name
                        print('Downloading: {}'.format(mfl_file_list_item_url))
                        print('       into: {}'.format(str(cur_file)))
                        html_cp(mfl_file_list_item_url, str(cur_file))
