#!/bin/zsh

if [[ -a SCRATCH ]]; then
  SCRATCH=`cat SCRATCH`
else
  echo "NO SCRATCH DIRECTORY FOUND. KILLING SCRIPT."
  exit
fi

if [[ $# -ne 0 ]]; then
  if [[ $# -eq 2 ]]; then
    SCREEN_CUT=$1
    TOT_BANDS=$2
  else
    echo "Usage: make_epsilon.zsh screened_cutoff total_bands"
    exit
  fi
elif [[ -a con_parameters.dat && $# -eq 0 ]]; then
  echo "Reading from epsilon parameters list..."
  SCREEN_CUT=`awk '{print $2}' con_parameters.dat | head -n 1`
  TOT_BANDS=`awk '{print $2}' con_parameters.dat | head -n 2 | tail -n 1`

  echo "I read in the following!"
  echo "Screened Coulomb Cutoff: " $SCREEN_CUT
  echo "Total Bands: " $TOT_BANDS
else
  echo "Screened Coulomb Cutoff?"
  read SCREEN_CUT
  echo "Total bands?"
  read TOT_BANDS

  cat > con_parameters.dat <<- EOF
  SCREEN_CUT: ${SCREEN_CUT}
  TOT_BANDS: ${TOT_BANDS}
  EOF
fi

MAIN_DIR=`pwd`
mkdir 07-epsilon 07-epsilon/${SCREEN_CUT}_cut 07-epsilon/${SCREEN_CUT}_cut/${TOT_BANDS}_bands
mkdir ${SCRATCH}/07-epsilon ${SCRATCH}/07-epsilon/${SCREEN_CUT}_cut ${SCRATCH}/07-epsilon/${SCREEN_CUT}_cut/${TOT_BANDS}_bands

# Directories:
# Main is where the whole set of calculations are taking place. So ls would give you the
# folders 00-08 etc.
# Working is the directory where files are being moved to. This changes for epsilon
# and sigma calculations. It's where the input files are stored.
# SCRATCH WORKING DIR is where the run actually takes place.
MAIN_DIR=`pwd`
WORKING_DIR=07-epsilon/${SCREEN_CUT}_cut/${TOT_BANDS}_bands
SCRATCH_WORKING_DIR=${SCRATCH}/07-epsilon/${SCREEN_CUT}_cut/${TOT_BANDS}_bands

echo "Starting epsilon make..."

# Link necessary files
cp 00-kgrid/WFNco.out ${WORKING_DIR}
ln -sf ${MAIN_DIR}/01-scf/*.upf ${SCRATCH_WORKING_DIR}
ln -sf ${SCRATCH}/02-wfn/WFN ${SCRATCH_WORKING_DIR}
ln -sf ${SCRATCH}/03-wfnq/WFN ${SCRATCH_WORKING_DIR}/WFNq

cd ${WORKING_DIR}

QPOINTS=`head -2 WFNco.out | tail -1`

${MAIN_DIR}/make_epsilon_inp.zsh ${SCREEN_CUT} ${TOT_BANDS} 0

for q in `seq 1 $QPOINTS`; do
  mkdir ${SCRATCH_WORKING_DIR}/${q}_qpt
  cd ${SCRATCH_WORKING_DIR}/${q}_qpt

  ln -sf ../*.upf ./
  ln -sf ../WFN* ./
  ln -sf ${MAIN_DIR}/${WORKING_DIR}/${q}_qpt/epsilon.inp ${SCRATCH_WORKING_DIR}/${q}_qpt
  ln -sf ${MAIN_DIR}/${WORKING_DIR}/${q}_qpt/submit ${SCRATCH_WORKING_DIR}/${q}_qpt
  ln -sf ${SCRATCH_WORKING_DIR}/${q}_qpt/epsilon.out ${MAIN_DIR}/${WORKING_DIR}/${q}_qpt/
  ln -sf ${SCRATCH_WORKING_DIR}/${q}_qpt/epsilon.log ${MAIN_DIR}/${WORKING_DIR}/${q}_qpt/
  ln -sf ${SCRATCH_WORKING_DIR}/${q}_qpt/chi_converge.dat ${MAIN_DIR}/${WORKING_DIR}/${q}_qpt/

done

#msub submit
# Try to get job number for dependencies here?
cd ${MAIN_DIR}
