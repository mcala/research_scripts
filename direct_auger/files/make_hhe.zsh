#!/bin/zsh

cd ../
SCRATCH=`cat SCRATCH`
SWITCH=$1

if [[ $SWITCH -eq 1 ]]; then
  mv k1 k_elec
  rm -r k2
  mv k3 k_irr
  mv k4 k4_eeh

  mv ${SCRATCH}/k1 ${SCRATCH}/k_elec
  rm -r ${SCRATCH}/k2
  mv k3 ${SCRATCH}/k_irr
  mv k4 ${SCRATCH}/k4_eeh
fi

if [[ -d k1 ]]; then
  if [[ -d ${SCRATCH}/k1 ]]; then
    echo "ERROR: Must not have already set up a run."
    exit
 fi
fi

mv k_hole k1
mv k_irr k2
mv k_elec k3
mv k4_hhe k4

mv ${SCRATCH}/k_hole ${SCRATCH}/k1
mv ${SCRATCH}/k_irr ${SCRATCH}/k2
mv ${SCRATCH}/k_elec ${SCRATCH}/k3
mv ${SCRATCH}/k4_hhe ${SCRATCH}/k4
