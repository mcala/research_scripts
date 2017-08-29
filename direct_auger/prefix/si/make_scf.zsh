#!/bin/zsh

if [[ $# -ne 5 ]]; then
  echo "Usage: make_scf.zsh prefix KPT1 KPT2 KPT3 scratch"
  exit
fi

PREFIX=$1
KPT1=$2
KPT2=$3
KPT3=$4
SCRATCH=$5

# Half hole grid points
KPT1HH=`echo ${KPT1} | awk '{print $1/2}'`
KPT2HH=`echo ${KPT2} | awk '{print $1/2}'`
KPT3HH=`echo ${KPT3} | awk '{print $1/2}'`

mkdir ${prefix}.save
cd ${prefix}.save
ln -sf ../../../../../charge_density/si.save/charge-density.dat
ln -sf ../../../../../charge_density/si.save/data-file.xml
cd -
ln -sf ../../../../charge_density/scf.in
ln -sf ../../../../charge_density/scf.out


# Make the dft scf calculation to calculate points on the half hole grid
cat > ./files/dft_calc/kirr/scf.in << EOF
!qe
   prefix = '${PREFIX}'
   calculation = 'scf'
   restart_mode = 'from_scratch'
   wf_collect = .true.
   tstress = .false.
   tprnfor = .false.
   outdir = '${SCRATCH}/files/dft_calc/kirr'
   wfcdir = '${SCRATCH}/files/dft_calc/kirr'
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

K_POINTS automatic
${KPT1HH} ${KPT2HH} ${KPT3HH} 0 0 0
EOF
