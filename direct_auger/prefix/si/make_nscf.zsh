#!/bin/zsh

if [[ $# -ne 5 ]]; then
  echo "Usage: make_nscf.zsh prefix weights(1 or 0) dir_name kpoint_list scratch"
  exit
fi

PREFIX=$1
K=$2
DIR_NAME=$3
KPOINT_LIST=$4
SCRATCH=$5

rm -f nscf.in
rm -rf $KPOINT_LIST
cat > nscf.in << EOF
!qe
&control
   prefix = '${PREFIX}'
   calculation = 'nscf'
   restart_mode = 'from_scratch'
   wf_collect = .true.
   tstress = .false.
   tprnfor = .false.
   outdir = './'
   wfcdir = './'
   pseudo_dir = './'
   verbosity = 'high'
/
&system
   ibrav = 0
   celldm(1) = 10.3430650234
   nat = 2
   ntyp = 1
   nbnd = 30
   ecutwfc = 40.0
   occupations = 'fixed'
/
&electrons
   conv_thr = 1.0d-10
   mixing_mode = 'plain'
   mixing_beta = 0.5
   diagonalization = 'cg'
   diago_full_acc = .true.
/
&ions
/
&cell
/
ATOMIC_SPECIES
Si 28.086  si.cpi.upf

CELL_PARAMETERS (alat)
  -0.50000   0.00000   0.50000
   0.00000   0.50000   0.50000
  -0.50000   0.50000   0.00000

ATOMIC_POSITIONS (crystal)
Si      -0.125000000  -0.125000000  -0.125000000
Si       0.125000000   0.125000000   0.125000000

K_POINTS crystal
EOF

POINTS=`wc ../pre_direct/${KPOINT_LIST} | awk '{print $1}'`
POINTS=$(($POINTS-1))

get_pseudos ../files/dft_calc

if [[ -a ${SCRATCH}/files/dft_calc/${PREFIX}.occup ]]; then
  cp ${SCRATCH}/files/dft_calc/${PREFIX}.occup ${SCRATCH}/${DIR_NAME}
else
  echo "No .occup file! If running DFT+U double check scf run."
fi

mkdir ${PREFIX}.save
cd ${PREFIX}.save
cp ../../files/dft_calc/${PREFIX}.save/charge-density.dat .
cp ../../files/dft_calc/${PREFIX}.save/data-file.xml .
cd -

for i in `seq 1 $POINTS`; do
  echo 1.0 >> weights_temp
done

tail -$POINTS ../pre_direct/${KPOINT_LIST} >> ${KPOINT_LIST}
if [[ $K -eq 0 ]]; then
  paste ${KPOINT_LIST} weights_temp >> ${KPOINT_LIST}_2
  mv ${KPOINT_LIST}_2 ${KPOINT_LIST}
fi

cat >> nscf.in << EOF
$POINTS
EOF

cat nscf.in ${KPOINT_LIST} >> nscf.in_2
mv nscf.in_2 nscf.in
rm -f weights_temp
