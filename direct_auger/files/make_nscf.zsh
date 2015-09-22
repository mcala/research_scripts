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

for i in k_elec k_hole k_irr k4_eeh k4_hhe; do
  mkdir $i
  mkdir ${SCRATCH}/${i}
done

cd k_elec
${NSCF_SCRIPT}/make_nscf.zsh $PREFIX 0 k_elec kgrid_elec_full.dat $SCRATCH
make_pbs_nersc nscf_submit elec_direct_nscf 24 00:10:00 debug 'pw.x < nscf.in > nscf.out'
cd -

#cd k_hole
#${NSCF_SCRIPT}/make_nscf.zsh $PREFIX 0 k_hole kgrid_hole_full.dat $SCRATCH
#make_pbs_nersc nscf_submit hole_direct_nscf 24 00:10:00 debug 'pw.x < nscf.in > nscf.out'
#cd -

cd k_irr
${NSCF_SCRIPT}/make_nscf.zsh $PREFIX 1 k_irr kgrid_hole_irr_halfholegrid.dat $SCRATCH
make_pbs_nersc nscf_submit hole_irr_direct_nscf 24 00:10:00 debug 'pw.x < nscf.in > nscf.out'
cd -

cd k4_eeh
${NSCF_SCRIPT}/make_nscf.zsh $PREFIX 0 k4_eeh klist_k4_eeh.dat $SCRATCH
make_pbs_nersc nscf_submit k4_eeh_direct_nscf 48 00:20:00 debug 'pw.x -nk 2 < nscf.in > nscf.out'
cd -

#cd k4_hhe
#${NSCF_SCRIPT}/make_nscf.zsh $PREFIX 0 k4_hhe klist_k4_hhe.dat $SCRATCH
#make_pbs_nersc nscf_submit k4_hhe_direct_nscf 48 00:20:00 debug 'pw.x -nk 2 < nscf.in > nscf.out'
#cd -
