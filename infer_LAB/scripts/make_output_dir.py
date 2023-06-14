import os
import configparser
from datetime import datetime

config_obj = configparser.ConfigParser()
config_obj.read('config.ini')
variables = config_obj["variables"]
folds = config_obj["directories"]

now_date = datetime.strptime(variables["date"], "%Y-%m-%d_%H-%M-%S")
now_date_string = now_date.strftime("%Y-%m-%d_%H-%M-%S")

potential_temperature = variables["potential_temperature"]
solidus_50km = variables["solidus_50km"]

fold_data_output = os.path.join(folds["data_output"], now_date_string)
os.makedirs(fold_data_output, exist_ok=True)