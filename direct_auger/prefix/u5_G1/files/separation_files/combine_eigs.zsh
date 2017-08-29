#!/bin/zsh
#

KPOINTS_FILE='kgrid_elec_full.dat'
KPOINTS=`wc -l ${KPOINTS_FILE} | awk '{print $1}'`
KPOINTS=10

for i in `seq 1 $KPOINTS`; do

  cd k_${i}
  awk -v i="${i}" '{ $2=i; print $0 }' inn.eig >> ../inn.eig
  cd -
done
