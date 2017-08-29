#!/bin/zsh -l
#
cd ../

PREFIX=`get_prefix ../../scf_calculation`
KPOINTS=`grep "kint" direct.in | awk '{print $3}' | cut -f1 -d","`
NSCF_SCRIPT='../../../scripts'

for i in k_elec k_hole k_irr k4_eeh k4_hhe; do
  mkdir $i
done

cd k_elec
${NSCF_SCRIPT}/make_nscf.zsh $PREFIX 0 kgrid_elec_full.dat
make_pbs_nersc nscf_submit $KPOINTS.e.n.inn \
  1 00:20:00 regular 'espresso/5.1.1/'  'pw.x < nscf.in > nscf.out'
sbatch nscf_submit
cd -

cd k_hole
${NSCF_SCRIPT}/make_nscf.zsh $PREFIX 0 kgrid_hole_full.dat
make_pbs_nersc nscf_submit $KPOINTS.h.n.inn \
  1 00:20:00 regular 'espresso/5.1.1/'  'pw.x < nscf.in > nscf.out'
sbatch nscf_submit
cd -

cd k_irr
${NSCF_SCRIPT}/make_nscf.zsh $PREFIX 1 kgrid_hole_irr_halfholegrid.dat
make_pbs_nersc nscf_submit $KPOINTS.i.n.inn  \
  1 00:20:00 regular 'espresso/5.1.1/'  'pw.x < nscf.in > nscf.out'
sbatch nscf_submit
cd -

cd k4_eeh
${NSCF_SCRIPT}/make_nscf.zsh $PREFIX 0 klist_k4_eeh.dat
make_pbs_nersc nscf_submit $KPOINTS.4e.n.inn \
  2 02:00:00 regular 'espresso/5.1.1/'  'pw.x -nk 2 < nscf.in > nscf.out'
sbatch nscf_submit
cd -

cd k4_hhe
${NSCF_SCRIPT}/make_nscf.zsh $PREFIX 0 klist_k4_hhe.dat
make_pbs_nersc nscf_submit $KPOINTS.4h.n.inn \
  2 02:00:00 regular 'espresso/5.1.1/'  'pw.x -nk 2 < nscf.in > nscf.out'
sbatch nscf_submit
cd -
