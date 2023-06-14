import numpy as np
import scipy
from glob import glob
from os import sys
from os.path import join
import configparser
import os
import time
from datetime import datetime

model = 'FR12' # update if using a different seismic model
model_data = 'FR12_S_i_abs_crustalgridregion'

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
fold_crustal_grids = os.path.join(fold_data_input, folds["input_crustal_grids"])
fold_seismic_model = os.path.join(fold_data_input, folds["input_seismic_model"], model_data)

fold_data_output = os.path.join(folds["data_output"], now_date_string)
fold_LAB1200 = os.path.join(fold_data_output, folds["output_LAB1200"])

os.makedirs(fold_LAB1200, exist_ok=True)

infold = os.path.join(fold_LAB1200, "distribution", "individual")
outfold = os.path.join(fold_LAB1200, "distribution", "summary")
os.makedirs(outfold, exist_ok=True)
n_files = 1000

###############################################################################################
# 2. LOAD LAB1200 GRIDS INTO SINGLE ARRAY
###############################################################################################

fitfile_index = 0
infile = os.path.join(infold, f'{model}_LAB1200_{fitfile_index}.txt')
grid_i = np.loadtxt(infile)
LAB_arr = np.zeros((n_files, np.shape(grid_i)[0], np.shape(grid_i)[1]))

for fitfile_index in range(0, n_files):

    infile = os.path.join(infold, f'{model}_LAB1200_{fitfile_index}.txt')
    grid_i = np.loadtxt(infile)
    LAB_arr[fitfile_index,:,:] = grid_i

###############################################################################################
# 3. CALCULATE STATISTICAL SUMMARY
###############################################################################################

arr_template = np.zeros(np.shape(grid_i))
arr_template[:,0] = grid_i[:,0]
arr_template[:,1] = grid_i[:,1]

print("finding median..")
arr_median = np.nanmedian(LAB_arr[:,:,2], axis=0)
print("finding 5th percentile..")
arr_pct_5 = np.nanpercentile(LAB_arr[:,:,2], 5, axis=0)
print("finding 95th percentile..")
arr_pct_95 = np.nanpercentile(LAB_arr[:,:,2], 95, axis=0)
print("finding median absolute deviation..")
arr_MAD = scipy.stats.median_abs_deviation(LAB_arr[:,:,2], axis=0, nan_policy='omit')
print("finding mean..")
arr_mean = np.nanmean(LAB_arr[:,:,2], axis=0)
print("finding standard deviation..")
arr_std = np.nanstd(LAB_arr[:,:,2], axis=0)

###############################################################################################
# 4. SAVE STATISTICAL SUMMARY
###############################################################################################

print("saving outputs..")

arr_all_median = arr_template.copy()
arr_all_median[:,2] = arr_median
np.savetxt(os.path.join(outfold, f"LAB1200_median.xyz"), arr_all_median, fmt='%.1f %.1f %.1f')

arr_all_pct_5 = arr_template.copy()
arr_all_pct_5[:,2] = arr_pct_5
np.savetxt(os.path.join(outfold, f"LAB1200_pct_5.xyz"), arr_all_pct_5, fmt='%.1f %.1f %.1f')

arr_all_pct_95 = arr_template.copy()
arr_all_pct_95[:,2] = arr_pct_95
np.savetxt(os.path.join(outfold, f"LAB1200_pct_95.xyz"), arr_all_pct_95, fmt='%.1f %.1f %.1f')

arr_all_MAD = arr_template.copy()
arr_all_MAD[:,2] = arr_MAD
np.savetxt(os.path.join(outfold, f"LAB1200_MAD.xyz"), arr_all_MAD, fmt='%.1f %.1f %.1f')

arr_all_mean = arr_template.copy()
arr_all_mean[:,2] = arr_mean
np.savetxt(os.path.join(outfold, f"LAB1200_mean.xyz"), arr_all_mean, fmt='%.1f %.1f %.1f')

arr_all_std = arr_template.copy()
arr_all_std[:,2] = arr_std
np.savetxt(os.path.join(outfold, f"LAB1200_std.xyz"), arr_all_std, fmt='%.1f %.1f %.1f')

print("done!")