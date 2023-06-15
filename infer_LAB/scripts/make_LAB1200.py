from libseis_min import load_grd_file, lay_seis_model
from lib_anelasticity import anelasticity_model
import numpy as np
import scipy
from glob import glob
from os import sys
from os.path import join
import configparser
import os
import time
import sys, getopt
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

###############################################################################################
# 2. IMPORT ANELASTICITY PARAMETERS BASED ON USER INPUT
###############################################################################################

# initiate variables
fitfile_type = ''
fitfile_index = -1

# read -v variable for type (specify "MAP" for MAP) and -i variable for index (if using distribution)
opts, args = getopt.getopt(sys.argv[1:], "v:i:")
for opt,arg in opts:
    if opt == '-v':
        fitfile_type = str(arg)
    if opt == '-i':
        fitfile_index = eval(arg)

if fitfile_type.strip().lower() in ['map', 'maximum a posteriori', 'most probable']:

    fitfile = os.path.join(fold_anelastic_params, 'MAP_model.txt')
    outfold = os.path.join(fold_LAB1200, 'MAP')
    os.makedirs(outfold, exist_ok=True)
    outfile = os.path.join(outfold, f'{model}_LAB1200_MAP.txt')
    pars=np.loadtxt(fitfile, usecols=(1))[1:8]
    print('using anelasticity parameters from MAP model..')
    fitfile_type = 'MAP'
    fitfile_index = 'N/A'

elif fitfile_index >= 0:

    fitfile = os.path.join(fold_anelastic_params, 'data_sample.txt')
    outfold = os.path.join(fold_LAB1200, 'distribution')
    os.makedirs(outfold, exist_ok=True)
    outfold = os.path.join(outfold, 'individual')
    os.makedirs(outfold, exist_ok=True)
    outfile = os.path.join(outfold, f'{model}_LAB1200_{fitfile_index}.txt')
    pars=(np.loadtxt(fitfile, skiprows=1).T)[2:9]
    pars=pars[:,fitfile_index]
    print('using anelasticity parameters from sample', fitfile_index, 'of distribution..')
    fitfile_type = 'distribution'
    fitfile_index = str(fitfile_index)

if os.path.exists(outfile):
    exit()

###############################################################################################
# 3. IMPORT SEISMIC MODEL
###############################################################################################

# Initialise conversion
main_inversion  = anelasticity_model(eta_0=float(10**pars[3]), mu0=float(pars[0]*1.e9), dmudT=float(pars[1]*1.e9), dmudp=float(pars[2]),\
                  act_eng=float(pars[4]), act_vol=float(pars[5]), solgrad=float(pars[6]), sol50=solidus_50km, alpha_B=0.38,\
                                    A_B=0.664, delphi=0.0, temps=np.linspace(273.,4473.,4201),dens_flg=1);
# Read in seismic file
seis_pth = fold_seismic_model
# Get the names of all the files
seis_files = glob(join(seis_pth,'*.grd'))

# Make an array consisting of all the depths
seismic_depths = np.zeros(len(seis_files));
# Set maximum depth
maxdep=400.
# Obtain the depths of the seismic models
for i in range(len(seis_files)):
   seismic_depths[i] = float(seis_files[i][seis_files[i].rfind('/')+1:seis_files[i].rfind('km')]);

# Sort the layers and remove slices deeper than maxdep (400 km)
seismic_depths.sort(); seismic_depths = seismic_depths[seismic_depths<=maxdep]*1.e3;

# Define an array for seismic layers
seismic_layers_orig    = [None]*len(seismic_depths);
seismic_layers    = [None]*len(seismic_depths);
seis_object    = [None]*len(seismic_depths);

# Go through all the seismic_depths, and read in the files
for i in range(len(seismic_depths)):
   print(str("Reading in depth %4.0f km" %(seismic_depths[i]/1.e3)))
   seis_object[i] = lay_seis_model(model_path = join(seis_pth,\
               str("%ikm.grd" %(seismic_depths[i]/1.e3))));

   # Write data
   seismic_layers_orig[i] = seis_object[i].data;
   seismic_layers[i] = seis_object[i].data;

   # Check for NaNs and set to layer mean
   seismic_layers[i][seismic_layers_orig[i]!=seismic_layers_orig[i]]=np.nanmean(seismic_layers_orig[i]);

###############################################################################################
# 4. IMPORT CRUSTAL GRIDS
###############################################################################################

# Load moho depth map
moho_map_lat, moho_map_lon, moho_map_data = load_grd_file(os.path.join(fold_crustal_grids, 'AusMoho2023_0.1.grd'))

# Load basement depth map
basement_map_lat, basement_map_lon, basement_map_data = load_grd_file(os.path.join(fold_crustal_grids, 'AusBasement_SEEBASE21_0.1.grd'))

# Load topography map
topography_map_lat, topography_map_lon, topography_map_data = load_grd_file(os.path.join(fold_crustal_grids, 'AusTopo_SRTM_0.1.grd'))

###############################################################################################
# 5. CONVERT SEISMIC VELOCITY INTO TEMPERATURE
###############################################################################################

def T2Tp(z,T):
    alpha=3.e-5
    Cp=1187.
    g=9.81
    Tp=(T+273.15)*np.exp(-(alpha*g*z*1000.)/Cp)-273.15
    return np.array([z,Tp])

# Convert the seismic model to temperature
temp_fld = main_inversion.vs_2_temp(depths=seismic_depths,\
                                    seis_model=seismic_layers);

# Make temperature cube: dimension 1: depths,; 2: lon; 3: lat
temp_cube=np.zeros((len(seismic_depths),np.shape(temp_fld[0])[0],np.shape(temp_fld[0])[1]))
for i in range(len(seismic_depths)):
    temp_cube[i,:,:]=temp_fld[i]

###############################################################################################
# 6. SET UP ARRAYS NEEDED TO STORE INPUTS & OUTPUTS OF LOCATION LOOP
###############################################################################################

# Make location and initial temperature array
ndepths=len(seismic_depths)
locs=np.zeros((np.size(temp_fld[0]),2))
temp_out=np.zeros((np.size(temp_fld[0]),ndepths))
k=0
for i in range(len(topography_map_lat)):
    for j in range(len(topography_map_lon)):
        locs[k,0]=topography_map_lon[j]
        locs[k,1]=topography_map_lat[i]
        for zo in range(ndepths):
            temp_out[k,zo]=temp_fld[zo][i,j]
        k=k+1

# Make crustal thickness array
k=0
nlocs=np.size(temp_fld[0])
moho_arr=np.zeros(nlocs)
basement_arr=np.zeros(nlocs)
topo_arr=np.zeros(nlocs)
for i in range(len(topography_map_lat)):
    for j in range(len(topography_map_lon)):
        moho_arr[k]=moho_map_data[i,j]
        basement_arr[k]=basement_map_data[i,j] * 1e-03  # convert m to km
        topo_arr[k]=topography_map_data[i,j] * 1e-03    # convert m to km
        k=k+1

# Make depth and temperature array
nlocs=np.size(temp_fld[0])
temp_arr=np.zeros((2,ndepths,nlocs))
for t in range(np.shape(locs)[0]):
    temp_arr[0,:,t]=seismic_depths[:]*1e-3
    temp_arr[1,:,t]=temp_out[t,:]-273.15

# Set LAB1200 array
LAB1200 = np.zeros(np.shape(temp_arr)[2])

# Set depth increment for interpolation
zinc=1.

# Set LAB temperature
TLAB=1200.

t_start = time.time()
HF_flag=False

###############################################################################################
# 7. DEFINE CRUSTAL BLEEDING FILTER ALGORITHM
###############################################################################################

def remove_crustalbleed(mantle_arr):

    mantle_arr = mantle_arr[:,np.where(mantle_arr[0,:]>=mantle_arr[0,np.gradient(mantle_arr[:,:])[1][1]>=10][0])][:,0]

    return mantle_arr

###############################################################################################
# 8. LOOP OVER LOCATIONS IN GRID AND CALCULATE LAB1200 AT EACH POINT
###############################################################################################

def main():

    for zl in range(np.shape(temp_arr)[2]):
    #for zl in idx_sample_loc:

        # Interpolate temperature profile
        mantle_arr = temp_arr[:,np.where(temp_arr[0,:,zl]>=moho_arr[zl])[0],zl] # Get rid of any data from the crust
        mantle_arr = remove_crustalbleed(mantle_arr)
        surface_arr_depths = np.array([topo_arr[zl]])
        surface_arr_T = np.array([0.0])
        surface_arr = np.stack((surface_arr_depths, surface_arr_T))
        arr = np.concatenate((surface_arr, mantle_arr), axis = 1)
        minz = arr[0,0]
        maxz = arr[0,-1]
        trial_depths = np.linspace(minz, maxz, int((maxz-minz)/zinc)+1)
        intp=scipy.interpolate.Akima1DInterpolator(arr[0,:],arr[1,:]) # [depth/T ; depth slice] Interpolate remaining profile
        arr=np.stack((trial_depths,intp(trial_depths)))
        arr_LAB = arr.copy().T

        if np.size(arr_LAB[np.where((arr_LAB[:,1]>=TLAB)),:]) > 0:

            LAB1200[zl]=np.interp(TLAB,arr_LAB[:,1],arr_LAB[:,0])

        else:

            LAB1200[zl]=np.nan
        
        print("location:", zl, f'({locs[zl,0]:.1f}, {locs[zl,1]:.1f})', "LAB:", f'{LAB1200[zl]:3.1f}', "km", "completion:", str(f'{np.round(100*(zl/np.shape(temp_arr)[2]),3):.2f}').zfill(5)+"%")

main()

# Mask out NaN regions
test=[None]
mask=[None]

# Read first slice back in
test = lay_seis_model(model_path = join(seis_pth,\
           str("%ikm.grd" %(seismic_depths[0]/1.e3))));
# Write data
mask=np.reshape(test.data,np.size(test.data))
LAB1200[mask!=mask]=np.nan

LABout=np.zeros((np.shape(temp_arr)[2],3))
for i in range(np.shape(temp_arr)[2]):
	LABout[i,0]=locs[i,0]
	LABout[i,1]=locs[i,1]
	LABout[i,2]=LAB1200[i]

np.savetxt(outfile, LABout, fmt='%3.1f %3.1f %3.1f')