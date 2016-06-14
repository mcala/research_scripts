#!/bin/zsh -l

START_DIR=`pwd`

cd ../

PREFIX=`get_prefix ../../scf_calculation`
KPOINTS=`grep "kint" direct.in | awk '{print $3}' | cut -f1 -d","`
SCRIPT_DIR="${HOME}/scripts/direct_auger/utilities"


cd k_elec

if [[ -a nscf.out ]]; then

  rm -f pw2wannier.in
  rm -f ${PREFIX}.nnkp

  ${SCRIPT_DIR}/make_wannier.zsh ${PREFIX} ./

  # Do unk script and move and submit PBS script
  ${START_DIR}/make_unk.tcsh ${PREFIX}
  make_pbs_flux p2w_submit $KPOINTS.e.w.inn 12 00:10:00 flux \
     kioup_flux 'pw2wannier90.x < pw2wannier90.in > pw2wannier90.out'
  qsubqe p2w_submit
fi

cd -

cd k_hole

if [[ -a nscf.out ]]; then

  rm -f pw2wannier.in
  rm -f ${PREFIX}.nnkp

  ${SCRIPT_DIR}/make_wannier.zsh ${PREFIX} ./

  # Do unk script and move and submit PBS script
  ${START_DIR}/make_unk.tcsh ${PREFIX}
  make_pbs_flux p2w_submit $KPOINTS.h.w.inn 12 00:10:00 flux \
   kioup_flux 'pw2wannier90.x < pw2wannier90.in > pw2wannier90.out'
  qsubqe p2w_submit
fi

cd -


cd k_irr

if [[ -a nscf.out ]]; then

  rm -f pw2wannier.in
  rm -f ${PREFIX}.nnkp

  ${SCRIPT_DIR}/make_wannier.zsh ${PREFIX} ./

  # Do unk script and move and submit PBS script
  ${START_DIR}/make_unk.tcsh ${PREFIX}
  make_pbs_flux p2w_submit $KPOINTS.i.w.inn 12 00:10:00 flux \
     kioup_flux 'pw2wannier90.x < pw2wannier90.in > pw2wannier90.out'
  qsubqe p2w_submit
fi

cd -

cd k4_hhe

if [[ -a nscf.out ]]; then

  rm -f pw2wannier.in
  rm -f ${PREFIX}.nnkp

  ${SCRIPT_DIR}/make_wannier.zsh ${PREFIX} ./

  # Do unk script and move and submit PBS script
  ${START_DIR}/make_unk.tcsh ${PREFIX}
  make_pbs_flux p2w_submit $KPOINTS.4h.w.inn 24 02:00:00 flux \
     kioup_flux 'pw2wannier90.x < pw2wannier90.in > pw2wannier90.out'
  qsubqe p2w_submit
fi

cd -

cd k4_eeh

if [[ -a nscf.out ]]; then

  rm -f pw2wannier.in
  rm -f ${PREFIX}.nnkp

  ${SCRIPT_DIR}/make_wannier.zsh ${PREFIX} ./

  # Do unk script and move and submit PBS script
  ${START_DIR}/make_unk.tcsh ${PREFIX}
  make_pbs_flux p2w_submit $KPOINTS.4e.w.inn 24 02:00:00 flux \
     kioup_flux 'pw2wannier90.x < pw2wannier90.in > pw2wannier90.out'
  qsubqe p2w_submit
fi

cd -


