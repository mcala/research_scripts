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

kpoints=`tail -1 files/dft_calc/scf.in | awk '{print $1}'`


if [ `ls -l | grep -c eeh` -gt 3 ]; then
  run="eeh"
else
  run="hhe"
fi

echo $run
mv auger* ${RUN_NAME}
cp *.out ${RUN_NAME}/run_info
cp *.dat ${RUN_NAME}/run_info
cp *.in ${RUN_NAME}/run_info

cd ${RUN_NAME}

mkdir plotting

for i in `seq 1 8`; do
  mv auger_coef_${run}_vs_gap_000${i}.dat plotting/${kpoints}_0${i}.dat
done
