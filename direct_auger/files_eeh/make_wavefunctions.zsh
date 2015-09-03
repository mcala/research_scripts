#!/bin/zsh

PREFIX=`get_prefix dft_calc`
SCRIPT_DIR="${HOME}/scripts/direct_auger/utilities"

cd ..
for i in 1 3 4; do
  cd k${i}

  rm -f pw2wannier.in
  rm -f ${PREFIX}.nnkp

  OUTDIR=`grep "outdir" nscf.in | awk '{print $3}'`
  OUTDIR=${(Q)OUTDIR}

  ${SCRIPT_DIR}/make_wannier.zsh ${PREFIX} ${OUTDIR}

  # Do unk script and move and submit PBS script
  ./../files/make_unk.tcsh ${PREFIX}
  make_pbs p2w_submit k${i}_10_direct_wan 24 00:10:00 debug \
    'pw2wannier90.x < pw2wannier90.in > pw2wannier90.out'
  cd -
done
