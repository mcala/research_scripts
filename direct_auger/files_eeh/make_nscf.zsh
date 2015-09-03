#!/bin/zsh
#
# Sets up k1, k3 and k4 directories from the k points made in the pre_direct 
# calculation using a prefix specific make_nscf.zsh script.
cd ../

SCRATCH=`cat SCRATCH`
PREFIX=`get_prefix ./files/dft_calc`
if [[ -a ${HOME}/scripts/direct_auger/prefix/${PREFIX} ]]; then
  NSCF_SCRIPT="${HOME}/scripts/direct_auger/prefix/${PREFIX}"
else
  echo "No NSCF script found."
fi

for i in 1 3 4; do
  mkdir k${i}
  mkdir ${SCRATCH}/k${i}
done

cd k1
${NSCF_SCRIPT}/make_nscf.zsh $PREFIX 1 kgrid_elec_full.dat $SCRATCH
make_pbs nscf_submit k1_10_direct_nscf 24 00:10:00 debug 'pw.x < nscf.in > nscf.out'
cd -

cd k3
${NSCF_SCRIPT}/make_nscf.zsh $PREFIX 3 kgrid_hole_irr_halfholegrid.dat $SCRATCH
make_pbs nscf_submit k3_10_direct_nscf 24 00:10:00 debug 'pw.x < nscf.in > nscf.out'
cd -

cd k4
${NSCF_SCRIPT}/make_nscf.zsh $PREFIX 4 klist_k4_eeh.dat $SCRATCH
make_pbs nscf_submit k4_10_direct_nscf 24 00:10:00 debug 'pw.x < nscf.in > nscf.out'
cd -
