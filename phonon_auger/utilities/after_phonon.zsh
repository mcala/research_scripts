#!/bin/zsh

if [[ $1 = "" ]]; then
  RUN_NAME='last_run'
else
  RUN_NAME=$1
fi

if [ -d ${RUN_NAME} ]; then
  echo "Folder Already Exists."
  exit 1
fi

#After an Auger run, move all the large unwieldy names to their own directory. In addition, move plotting data to it's own directory where it is renamed to something more convienent.
mkdir data/${RUN_NAME}
mkdir data/${RUN_NAME}/plotting
mkdir data/${RUN_NAME}/bymode
mkdir data/${RUN_NAME}/run_info

kpoints=`tail -1 ../nscf_kpt.in | awk '{print $1}'`

for i in `seq 1 8`; do

mv auger_coef_ep_eeh_absorptionemission000${i}.dat data/${RUN_NAME}
mv auger_coef_ep_eeh_absorption_000${i}.dat data/${RUN_NAME}
mv auger_coef_ep_eeh_absorptionemission_bymode000${i}.dat data/${RUN_NAME}
mv auger_coef_ep_eeh_emission_000${i}.dat data/${RUN_NAME}
mv auger_coef_ep_hhe_absorptionemission_000${i}.dat data/${RUN_NAME}
mv auger_coef_ep_hhe_absorption_000${i}.dat data/${RUN_NAME}
mv auger_coef_ep_hhe_absorptionemission_bymode000${i}.dat data/${RUN_NAME}
mv auger_coef_ep_hhe_emission_000${i}.dat data/${RUN_NAME}

cp data/${RUN_NAME}/auger_coef_ep_eeh_absorptionemission000${i}.dat data/${RUN_NAME}/plotting/${kpoints}_0${i}.dat
cp data/${RUN_NAME}/auger_coef_ep_eeh_absorptionemission_bymode000${i}.dat data/${RUN_NAME}/bymode/${kpoints}_0${i}.dat
cp data/${RUN_NAME}/auger_coef_ep_hhe_absorptionemission_000${i}.dat data/${RUN_NAME}/plotting/${kpoints}_0${i}_hhe.dat
cp data/${RUN_NAME}/auger_coef_ep_hhe_absorptionemission_bymode000${i}.dat data/${RUN_NAME}/bymode/${kpoints}_0${i}_hhe.dat

done

cp *.in data/${RUN_NAME}/run_info
cp *.out data/${RUN_NAME}/run_info

