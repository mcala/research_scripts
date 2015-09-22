#!/bin/zsh

cd ../
SCRATCH=`cat SCRATCH`
SWITCH=$1

if [[ $SWITCH -eq 1 ]]; then
  mv k1 k_hole
  mv k2 k_irr
  mv k3 k_elec
  mv k4 k4_hhe

  mv ${SCRATCH}/k1 ${SCRATCH}/k_hole
  mv ${SCRATCH}/k2 ${SCRATCH}/k_irr
  mv ${SCRATCH}/k3 ${SCRATCH}/k_elec
  mv ${SCRATCH}/k4 ${SCRATCH}/k4_hhe
fi

if [[ -d k1 ]]; then
  echo "ERROR: Must not have already set up a run."
  exit
fi

mv k_elec k1
mv k_irr k3
mv k4_eeh k4
cp -r k1 k2

mv ${SCRATCH}/k_elec ${SCRATCH}/k1
mv ${SCRATCH}/k_irr ${SCRATCH}/k3
mv ${SCRATCH}/k4_eeh ${SCRATCH}/k4
cp -r ${SCRATCH}/k1 ${SCRATCH}/k2
