#!/bin/bash 

remove_existing_data(){
    cd ${BANCALfold}
    for data_set in xenolith plate adiabat attenuation viscosity; do
        cd ${data_set}
        rm -f *.VseTz *.QeVsz *.neVsz *.zTVslln
        cd ${BANCALfold}
    done
}

transfer_australia_data(){

    tomo=FR12
    transfer_adiabat=true
    kmod=10
    model=tomo_${tomo}_kmod_${kmod}

    cp ${scriptfold}/${model}/nodule_obs_all.zTVslln ${BANCALfold}/xenolith/nodule_obs_all.zTVslln

    if [ $transfer_adiabat = true ]; then
        awk '{print $1, $4, $3, $2}' ${scriptfold}/${model}/adiabat_${tomo}.txt > ${BANCALfold}/adiabat/adiabat.VseTz
    fi
    echo "1333" > ${scriptfold}/${model}/Tp_${model}.txt
    echo "1326" > ${scriptfold}/${model}/sol50_${model}.txt
    cp ${scriptfold}/${model}/Tp_${model}.txt ${BANCALfold}/potential_temperature/potential_temperature.T
    cp ${scriptfold}/${model}/sol50_${model}.txt ${BANCALfold}/potential_temperature/solidus_50km_temperature.T

}

scriptfold="/home/jah220/phd/AusLAB/BANCAL22_inputdata" # set your directory
BANCALfold="/home/jah220/phd/BANCAL22/data" # set your directory

remove_existing_data
transfer_australia_data

echo done!
