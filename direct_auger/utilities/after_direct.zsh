#!/bin/zsh

# Moves the long unwieldy post auger names into their own folder with simpler
# names for plotting.
if [[ $1 = "" ]]; then
  RUN_NAME='last_run'
else
  RUN_NAME=$1
fi

if [ -d ${RUN_NAME} ]; then
  echo "Folder Already Exists."
  exit 1
fi

mkdir ${RUN_NAME}
mkdir ${RUN_NAME}/run_info

kpoints=`grep "nkint" direct.in | awk '{print $3}' | rev | cut -c 2- | rev`

echo $run
mv auger* ${RUN_NAME}
cp *.out ${RUN_NAME}/run_info
cp *.in ${RUN_NAME}/run_info
cp files/pre_direct/*.dat ${RUN_NAME}/run_info
cp files/pre_direct/*.in ${RUN_NAME}/run_info

cd ${RUN_NAME}

mkdir plotting_eeh
mkdir plotting_hhe

for i in `seq 1 8`; do
  mv auger_coef_eeh_vs_gap_000${i}.dat plotting_eeh/${kpoints}_0${i}.dat
  mv auger_coef_hhe_vs_gap_000${i}.dat plotting_hhe/${kpoints}_0${i}.dat
done
