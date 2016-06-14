#!/bin/zsh

if [[ $# -ne 3 ]]; then
  echo "Usage: make_nscf.zsh prefix weights(1 or 0) kpoint_list"
  exit
fi

PREFIX=$1
K=$2
KPOINT_LIST=$3

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
   wfcdir = './wfc'
   pseudo_dir = './'
   verbosity = 'high'
/
&system
   ibrav = 0
   celldm(1) = 6.69237854744d0
   celldm(3) = 1.61137843193
   nat = 4
   ntyp = 2
   nbnd = 32
   ecutwfc = 90.0
   lda_plus_u = .true.
   Hubbard_U(1) = 6.0
   Hubbard_U(2) = 1.5
/
&electrons
   electron_maxstep = 500
   conv_thr = 1.0d-10
   mixing_mode = 'plain'
   mixing_beta = 0.7
   mixing_ndim = 8
   diagonalization = 'david'
   diago_david_ndim = 4
   diago_full_acc = .true.
/
&ions
/
&cell
/
ATOMIC_SPECIES
In  114.818   in.cpi.UPF
N  14.007   n.cpi.UPF

CELL_PARAMETERS
   1.000000000   0.000000000   0.000000000
  -0.500000000   0.866025403   0.000000000
   0.000000000   0.000000000   1.618331691

ATOMIC_POSITIONS crystal
In       0.333333333   0.666666667  -0.001658128
In       0.666666667   0.333333333   0.498341872
N        0.333333333   0.666666667   0.376658128
N        0.666666667   0.333333333  -0.123341872

K_POINTS crystal
EOF

POINTS=`wc ../files/pre_direct/${KPOINT_LIST} | awk '{print $1}'`
POINTS=$(($POINTS-1))

get_pseudos ../../../scf_calculation

if [[ -a ../../../scf_calculation/${PREFIX}.occup ]]; then
  cp ../../../scf_calculation/${PREFIX}.occup ./
else
  echo "No .occup file! If running DFT+U double check scf run."
fi

mkdir ${PREFIX}.save
cd ${PREFIX}.save
cp ../../../../scf_calculation/${PREFIX}.save/charge-density.dat .
cp ../../../../scf_calculation/${PREFIX}.save/data-file.xml .
cd -

for i in `seq 1 $POINTS`; do
  echo 1.0 >> weights_temp
done

tail -$POINTS ../files/pre_direct/${KPOINT_LIST} >> ${KPOINT_LIST}
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
