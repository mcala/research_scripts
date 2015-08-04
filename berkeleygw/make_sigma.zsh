#!/bin/zsh

if [[ -a SCRATCH ]]; then
	SCRATCH=`cat SCRATCH`
else
	echo "NO SCRATCH DIRECTORY FOUND. KILLING SCRIPT."
	exit
fi

if [[ $# -ne 0 ]]; then
  if [[ $# -eq 4 ]]; then
    SCREEN_CUT=$1
    TOT_BANDS=$2
    BARE_CUT=$3
    SUM=$4
  else
    echo "Usage: make_sigma.zsh screened_cutoff total_bands bare_cutoff sigma_sum"
    exit
  fi
elif [[ -a con_parameters.dat && $# -eq 0 ]]; then
	echo "Reading from sigma parameters list..."
	SCREEN_CUT=`awk '{print $2}' con_parameters_sigma.dat | head -n 1`
	TOT_BANDS=`awk '{print $2}' con_parameters_sigma.dat | head -n 2 | tail -n 1`
	BARE_CUT=`awk '{print $2}' con_parameters_sigma.dat | head -n 3 | tail -n 1`
	SUM=`awk '{print $2}' con_parameters_sigma.dat | head -n 4 | tail -n 1`

	echo "I read in the following!"
	echo "SCREENED CUTOFF: " $SCREEN_CUT
	echo "TOTAL BANDS: " $TOT_BANDS
	echo "BARE CUTOFF: " $BARE_CUT
	echo "SIGMA SUM: " $SUM
else
	echo "Screened Coulomb Cutoff?"
	read SCREEN_CUT
	echo "Total bands?"
	read TOT_BANDS
  echo "Bare Coulomb cutoff (can't be larger than in epsilon!)"
	read BARE_CUT
	echo "Bands to sum in Sigma?"
  read SUM

	cat > con_parameters.dat <<- EOF
	SCREEN_CUT: ${SCREEN_CUT}
	TOT_BANDS: ${TOT_BANDS}
	BARE_CUT: ${BARE_CUT}
	SIGMA_SUM: ${SUM}
	EOF
fi

echo "Starting sigma make..."

mkdir 08-sigma 08-sigma/${SCREEN_CUT}_cut 08-sigma/${SCREEN_CUT}_cut/${TOT_BANDS}_bands
mkdir ${SCRATCH}/08-sigma ${SCRATCH}/08-sigma/${SCREEN_CUT}_cut ${SCRATCH}/08-sigma/${SCREEN_CUT}_cut/${TOT_BANDS}_bands

MAIN_DIR=`pwd`
WORKING_DIR=08-sigma/${SCREEN_CUT}_cut/${TOT_BANDS}_bands
SCRATCH_WORKING_DIR=${SCRATCH}/08-sigma/${SCREEN_CUT}_cut/${TOT_BANDS}_bands

mkdir 08-sigma/${SCREEN_CUT}_cut/${TOT_BANDS}_bands/${SUM}_sum
mkdir ${SCRATCH}/08-sigma/${SCREEN_CUT}_cut/${TOT_BANDS}_bands/${SUM}_sum

WORKING_DIR=${MAIN_DIR}/08-sigma/${SCREEN_CUT}_cut/${TOT_BANDS}_bands/${SUM}_sum

# Link necessary files
cp 00-kgrid/WFNco.out ${WORKING_DIR}
ln -sf ${MAIN_DIR}/01-scf/*.upf ${SCRATCH_WORKING_DIR}
ln -sf ${SCRATCH}/04-wfnco/rho ${SCRATCH_WORKING_DIR}/RHO
ln -sf ${SCRATCH}/04-wfnco/vxc.dat ${SCRATCH_WORKING_DIR}
ln -sf ${SCRATCH}/04-wfnco/WFN ${SCRATCH_WORKING_DIR}/WFN_inner
ln -sf ${SCRATCH}/07-epsilon/${SCREEN_CUT}_cut/${TOT_BANDS}_bands/epsmat.h5 ${SCRATCH_WORKING_DIR}
ln -sf ${SCRATCH}/07-epsilon/${SCREEN_CUT}_cut/${TOT_BANDS}_bands/eps0mat.h5 ${SCRATCH_WORKING_DIR}

cd ${WORKING_DIR}

${MAIN_DIR}/make_sigma_inp.zsh ${SCREEN_CUT} ${BARE_CUT} ${SUM} 0

cd ${SCRATCH_WORKING_DIR}/${SUM}_sum

ln -sf ../*.upf ./
ln -sf ../WFN* ./
ln -sf ../RHO ./
ln -sf ../vxc.dat ./
ln -sf ../epsmat.h5 ./
ln -sf ../eps0mat.h5 ./
ln -sf ${WORKING_DIR}/sigma.inp ${SCRATCH_WORKING_DIR}/${SUM}_sum
ln -sf ${WORKING_DIR}/submit ${SCRATCH_WORKING_DIR}/${SUM}_sum
ln -sf ${SCRATCH_WORKING_DIR}/${SUM}_sum/sigma.out ${WORKING_DIR}
ln -sf ${SCRATCH_WORKING_DIR}/${SUM}_sum/sigma.log ${WORKING_DIR}
ln -sf ${SCRATCH_WORKING_DIR}/${SUM}_sum/sigma_hp.log ${WORKING_DIR}
ln -sf ${SCRATCH_WORKING_DIR}/${SUM}_sum/ch_converge.dat ${WORKING_DIR}
cd ${MAIN_DIR}

