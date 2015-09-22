#!/bin/zsh

PREFIX=`get_prefix dft_calc`
SCRATCH=`cat ../SCRATCH`
SCRIPT_DIR="${HOME}/scripts/direct_auger/utilities"
START_DIR=`pwd`
cd ..
for i in `find . -maxdepth 1 -type d -name "k*"`; do
  cd ${i}

  if [[ -a nscf.out ]]; then

    cp nscf.out ${SCRATCH}/${i}

    cd ${SCRATCH}/${i}

    rm -f pw2wannier.in
    rm -f ${PREFIX}.nnkp

    ${SCRIPT_DIR}/make_wannier.zsh ${PREFIX} ./

    # Do unk script and move and submit PBS script
    ${START_DIR}/make_unk.tcsh ${PREFIX}
    make_pbs_nersc p2w_submit k${i}_10_direct_wan 24 00:10:00 debug \
      'pw2wannier90.x < pw2wannier90.in > pw2wannier90.out'
  fi

  cd ${START_DIR}
  cd ../

done
