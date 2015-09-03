#!/bin/zsh
#
# Makes the scf runs for a direct auger calculation. Includes the kirr 
# scf run which makes the irreducible wedge of points for the half hole grid
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
   ibrav = 
   celldm(1) = 
   nat = 
   ntyp = 
   nbnd =
   ecutwfc = 
   lda_plus_u = 
   Hubbard_U(1) = 
   Hubbard_U(2) = 

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
XX  000.000   XX.cpi.UPF

CELL_PARAMETERS 
   1.000000000   0.000000000   0.000000000

ATOMIC_POSITIONS crystal
XX       0.000000000   0.000000000  -0.000000000

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
   celldm(1) =
   nat = 
   ntyp = 
   nbnd = 
   ecutwfc = 
   lda_plus_u = 
   Hubbard_U(1) = 
   Hubbard_U(2) = 

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
XX  000.000   XX.cpi.UPF

CELL_PARAMETERS 
   1.000000000   0.000000000   0.000000000

ATOMIC_POSITIONS crystal
XX       0.000000000   0.000000000  -0.000000000

K_POINTS automatic
${KPT1HH} ${KPT2HH} ${KPT3HH} 0 0 0
EOF
