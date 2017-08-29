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
&control
   prefix = '${PREFIX}'
   calculation = 'nscf'
   restart_mode = 'from_scratch'
   wf_collect = .true.
   tstress = .true.
   tprnfor = .true.
   outdir = './'
   wfcdir = './'
   pseudo_dir = './'
   verbosity = 'high'
/
&system
   ibrav = 4
   celldm(1) = 5.8808273
   celldm(3) = 7.892707410
   nat = 20
   ntyp = 3
   nbnd = 85
   ecutwfc = 250.0
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
   Al  26.982   al.cpi.UPF
   Ga  26.982   ga.cpi.UPF
   N  14.007    n.cpi.UPF

ATOMIC_POSITIONS crystal
Al       0.333333333   0.666666667   0.001498776
N        0.333333333   0.666666667   0.077943523
Al       0.666666667   0.333333333   0.100712436
N        0.666666667   0.333333333   0.177126909
Al       0.333333333   0.666666667   0.199894271
N        0.333333333   0.666666667   0.276268342
Al       0.666666667   0.333333333   0.299011680
N        0.666666667   0.333333333   0.375419391
Al       0.333333333   0.666666667   0.398219165
N        0.333333333   0.666666667   0.474636382
Al       0.666666667   0.333333333   0.497382447
N        0.666666667   0.333333333   0.573749559
Al       0.333333333   0.666666667   0.596511199
N        0.333333333   0.666666667   0.672922232
Al       0.666666667   0.333333333   0.695697859
N        0.666666667   0.333333333   0.772088263
Al       0.333333333   0.666666667   0.794738688
N        0.333333333   0.666666667   0.871184640
Ga       0.666666667   0.333333333   0.898524973
N        0.666666667   0.333333333   0.979125967

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
