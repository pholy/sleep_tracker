import configparser
from os.path import dirname, abspath, join

SCRIPT_DIR = dirname(abspath(__file__))
GLOBAL_PROPERTIES_PATH = join(dirname(SCRIPT_DIR), "config", "global.properties")


def read_properties(file_path):
    with open(file_path, "r") as f:
        config_string = "[_]\n" + f.read()
    config = configparser.ConfigParser(interpolation=configparser.ExtendedInterpolation())
    config.read_string(config_string)
    options = {}
    for key, value in config["_"].items():
        options[key] = value
    return options


_properties = read_properties(GLOBAL_PROPERTIES_PATH)

REPO_ROOT = _properties["g_repo_root"]
SRC_ROOT = _properties["g_src_root"]

PYTHON_EXE = _properties["g_python_exe"]
PYTHONPATH = _properties["g_pythonpath"]

SYNC_DIR = _properties["g_sync_dir"]
DB_PATH = _properties["g_db_path"]

DB_CONNECTION_STRING = f"sqlite:///{DB_PATH}"
