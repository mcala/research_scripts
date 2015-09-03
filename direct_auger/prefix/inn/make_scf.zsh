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

# Make the dft scf calculation.
cat > ./files/dft_calc/scf.in << EOF
!qe
&control
   prefix = '${PREFIX}'
   calculation = 'scf'
   restart_mode = 'from_scratch'
   wf_collect = .true.
   tstress = .false.
   tprnfor = .false.
   outdir = '${SCRATCH}/files/dft_calc/'
   wfcdir = '${SCRATCH}/files/dft_calc/'
   pseudo_dir = './'
   verbosity = 'high'
/
&system
   ibrav = 0
   celldm(1) = 6.69237854744e0
   celldm(3) = 1.61137843193
   nat = 4
   ntyp = 2
   nbnd = 26
   ecutwfc = 100.0
   lda_plus_u = .true.
   Hubbard_U(1) = 6.0
   Hubbard_U(2) = 1.5

/
&electrons
   electron_maxstep = 500
   conv_thr = 1.0d-14
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

K_POINTS automatic
${KPT1} ${KPT2} ${KPT3} 1 1 1
EOF

# Make the dft scf calculation to calculate points on the half hole grid
cat > ./files/dft_calc/kirr/scf.in << EOF
!qe
&control
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
   celldm(1) = 6.69237854744e0
   celldm(3) = 1.61137843193
   nat = 4
   ntyp = 2
   nbnd = 32
   ecutwfc = 100.0
   lda_plus_u = .true.
   Hubbard_U(1) = 6.0
   Hubbard_U(2) = 1.5

/
&electrons
   electron_maxstep = 500
   conv_thr = 1.0d-14
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

K_POINTS automatic
${KPT1HH} ${KPT2HH} ${KPT3HH} 0 0 0
EOF
