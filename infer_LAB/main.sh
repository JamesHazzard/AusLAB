#!/bin/bash

copy_config(){

config="./config/jameshome.ini" # choose a config file
cp ${config} scripts/config.ini # copy config file to scripts

}

make_output_dir(){

  python3 make_output_dir.py

}

run_LAB1200_distribution(){

  make_output_dir

    for ((i=0; i<=999; i++)); do
        echo "running viscoelastic parameter model ${i}..."
        python3 make_LAB1200.py -v distribution -i ${i} # run script 
    done

}

run_LAB1200_MAP(){

  make_output_dir

  echo "running maximum a posteriori viscoelastic parameter model.."
  python3 make_LAB1200.py -v MAP # run script

}

calculate_model_summary(){

  python3 make_LAB1200_summary.py

}

plot_model_summary(){

  chmod +x make_LAB1200_plots.sh
  ./make_LAB1200_plots.sh

}

date=$(date '+%Y-%m-%d_%H-%M-%S')
vsmodel="FR12"

copy_config
cd scripts  # change working directory to location of scripts
fold_data_input=$(awk '$1 ~ /^data_input/' config.ini | awk '{print $3}')
input_locs=$(awk '$1 ~ /^input_locs/' config.ini | awk '{print $3}')
fold_data_output=$(awk '$1 ~ /^data_output/' config.ini | awk '{print $3}')
fold_plot_output=$(awk '$1 ~ /^plot_output/' config.ini | awk '{print $3}')
fold_date=$(awk '$1 ~ /^date/' config.ini | awk '{print $3}')
potential_temperature=$(awk '$1 ~ /^potential_temperature/' config.ini | awk '{print $3}')
solidus_50km=$(awk '$1 ~ /^solidus_50km/' config.ini | awk '{print $3}')
fold_data_output=${fold_data_output}/${fold_date}

run_LAB1200_distribution
run_LAB1200_MAP
calculate_model_summary
plot_model_summary

rm -f gmt.* input.dat output.dat geoth.out lacdevs.dat *.cpt
rm -rf __pycache__
