import numpy as np
import pandas as pd
import os
import configparser
from datetime import datetime

###############################################################################################
# 1. GET DIRECTORIES FROM CONFIG
###############################################################################################

config_obj = configparser.ConfigParser()
config_obj.read('config.ini')
variables = config_obj["variables"]
potential_temperature = variables["potential_temperature"]
solidus_50km = int(variables["solidus_50km"])
now_date = datetime.strptime(variables["date"], "%Y-%m-%d_%H-%M-%S")
now_date_string = now_date.strftime("%Y-%m-%d_%H-%M-%S")
year = f'year_{now_date.strftime("%Y")}'
month = f'month_{now_date.strftime("%m")}'
day = f'day_{now_date.strftime("%d")}'
folds = config_obj["directories"]
fold_base = folds["base"]
fold_data_input = folds["data_input"]

fold_anelastic_params = os.path.join(fold_data_input, folds["input_anelastic_params"], now_date_string)
fold_data_output = fold_anelastic_params

###############################################################################################
# 2. LOAD BANCAL22 SAMPLES AND GENERATE SUBSET (+ FIND MAP, + FIND MEAN/STD OF IND. PARAMETERS)
###############################################################################################

data_loc = f"{fold_anelastic_params}/samples_postburnin.csv"

def load_data():
    data = pd.read_csv(data_loc, delimiter="\t")
    return data

def find_summary_model():
    if os.path.exists(f"{fold_anelastic_params}/summary_model.txt"):
        print("mean model exists, skipping..")
        data_summary=1
        exists=1
    else:
        print("finding mean model..")
        data=load_data()
        data_mean=data.mean(axis=0)
        data_std=data.std(axis=0)
        exists=0
        data_summary=pd.concat([data_mean, data_std], axis=1).T

    return data_summary, exists

def find_MAP_model():
    if os.path.exists(f"{fold_anelastic_params}/MAP_model.txt"):
        print("MAP model exists, skipping..")
        data_MAP=1
        exists=1
    else:
        print("finding MAP model..")
        data=load_data()
        idx=np.argmax(data['Posterior'])
        data_MAP=data.iloc[idx]
        exists=0
    return data_MAP, exists

def generate_data_sample(sample_size=1000):
    if os.path.exists(f"{fold_anelastic_params}/data_sample.txt"):
        print("subset of models exists, skipping..")
        data_sample=1
        exists=1
    else:
        print("finding subset of models..")
        data=load_data()
        data_sample = data.sample(n = sample_size)
        exists=0
    return data_sample, exists

###############################################################################################
# 3. SAVE OUTPUTS
###############################################################################################

def save_data_sample(data_sample):
    data_sample.to_csv(f"{fold_anelastic_params}/data_sample.txt", sep="\t")

def save_MAP(data_MAP):
    data_MAP.to_csv(f"{fold_anelastic_params}/MAP_model.txt", sep="\t", header=False)

def save_summary(data_summary):
    data_summary.to_csv(f"{fold_anelastic_params}/summary_model.txt", sep="\t", float_format="%20.15f", index=False)

data_sample, exists = generate_data_sample()
if exists < 1:
    save_data_sample(data_sample)

data_MAP, exists = find_MAP_model()
if exists < 1:
    save_MAP(data_MAP)

data_summary, exists = find_summary_model()
if exists < 1:
    save_summary(data_summary)

print("done!")
