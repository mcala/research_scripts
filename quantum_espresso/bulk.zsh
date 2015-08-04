#!/bin/zsh -l

# Directory information.
WORK_DIR=`pwd`
echo "Scratch Directory?"
read SCRATCH_DIR

# Make list of pseduo prefixes you need.
echo "pseudopotential prefixes? (each separated by a space)"
read PSEUDO_LIST

# Variables to set up directories and jobs for the multiple lattice constants
#echo "Lattice Constant?"
#read ALAT
ALAT=8.627355028
echo "Minimum +/-?"
read MIN
echo "Maximum +/-?"
read MAX
echo "Spacing?"
read SPACING

cat > delta_parameters.dat << EOF
minimum: ${MIN}
maximum: ${MAX}
spacing: ${SPACING}
EOF

echo "Setting up jobs..."

# Go through the above k point and e cutoffs. Making directories in
# both the working directory and the scratch direction. Make input files
# in working directory and link the correct pseudos.
for cell_change in `seq ${MIN} ${SPACING} ${MAX}`; do
  mkdir delta_${cell_change}
  mkdir ${SCRATCH_DIR}/delta_${cell_change}
  cd delta_${cell_change}

  lattice=`echo "${ALAT}+${cell_change}" | bc`

cat > scf.in << EOF
!qe
&control
  calculation = 'scf'
  verbosity = 'high'
  prefix = 'csi'
  restart_mode = 'from_scratch'
  wf_collect = .true.
  tstress = .true.
  tprnfor = .true.
  outdir = '${SCRATCH_DIR}/delta_${cell_change}'
  wfcdir = '${SCRATCH_DIR}/delta_${cell_change}'
  pseudo_dir = './'
  etot_conv_thr=1.0e-4
  forc_conv_thr=1.0e-3
/
&system
  ibrav = 1
  celldm(1) = ${lattice}
  nat = 2
  ntyp = 2
  nbnd = 8
  ecutwfc = 35.0
/
&electrons
  electron_maxstep = 100
  conv_thr = 1.0e-10
  mixing_mode = 'plain'
  mixing_beta = 0.7
  mixing_ndim = 8
  diagonalization = 'david'
  diago_david_ndim = 4
  diago_full_acc = .true.
/
&ions
/

ATOMIC_SPECIES
  Cs 132.91 cs.cpi.upf
  I  126.90 i.cpi.upf

ATOMIC_POSITIONS crystal
  Cs 0.000000000   0.000000000   0.000000000
  I  0.500000000   0.500000000   0.500000000

K_POINTS automatic
4 4 4 1 1 1
EOF

cat > submit << EOF
#!/bin/bash -l
#MSUB -A pls2

#MSUB -c cab
#MSUB -l procs=32
#MSUB -l walltime=00:10:00
#MSUB -N csi_relax_${cell_change}.%j
#MSUB -o csi_relax_${cell_change}.%j
#MSUB -V
#MSUB -j oe

srun -n 32 pw.x < scf.in > scf.out
EOF


  # Goes through the list of pseudo potential prefixes and lines them.
  # To do this, you need to echo the list which will be as typed by the user.
  # The list is piped to cat, which allows the for loop to process the entries
  # separated by spaces. (If you tried to just do the echo, it would only do the
  # whole space separated string.)
  for pseudo in `echo $PSEUDO_LIST | cat`; do
    pwd
    ln -s ../../../pseudos/${pseudo}.cpi.upf .
  done

  msub submit

cd $WORK_DIR

done




echo "Done."
