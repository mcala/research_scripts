#!/bin/zsh -l

# Directory information.
WORK_DIR=`pwd`
echo "Scratch Directory?"
read SCRATCH_DIR

# Make list of pseduo prefixes you need.
echo "pseudopotential prefixes? (each separated by a space)"
read PSEUDO_LIST

# Variables to set up directories for k point and energy cutoff convergence.
echo "k point minimum?"
read K_POINT_MIN
echo "k point maximum?"
read K_POINT_MAX
echo "k point spacing?"
read K_POINT_SPACE

echo "ecut minimum?"
read ECUT_MIN
echo "ecut maximum?"
read ECUT_MAX
echo "ecut spacing?"
read ECUT_SPACE

cat > con_parameters.dat << EOF
k-min: ${K_POINT_MIN}
k-max: ${K_POINT_MAX}
k-space: ${K_POINT_SPACE}
ecut_min: ${ECUT_MIN}
ecut_max: ${ECUT_MAX}
ecut_space: ${ECUT_SPACE}
EOF

echo "Setting up jobs..."

# Go through the above k point and e cutoffs. Making directories in
# both the working directory and the scratch direction. Make input files
# in working directory and link the correct pseudos.
for k in `seq ${K_POINT_MIN} ${K_POINT_SPACE} ${K_POINT_MAX}`; do
  mkdir ${k}_grid
  mkdir ${SCRATCH_DIR}/${k}_grid
  cd ${k}_grid

  for e in `seq ${ECUT_MIN} ${ECUT_SPACE} ${ECUT_MAX}`; do
    mkdir ${e}_cut
    mkdir ${SCRATCH_DIR}/${k}_grid/${e}_cut
    cd ${e}_cut

cat > scf.in << EOF
!qe
&control
  calculation = 'scf'
  verbosity = 'high'
  prefix = 'labr3'
  restart_mode = 'from_scratch'
  wf_collect = .true.
  tstress = .true.
  tprnfor = .true.
  outdir = '${SCRATCH_DIR}/${k}_grid/${e}_cut'
  wfcdir = '${SCRATCH_DIR}/${k}_grid/${e}_cut'
  pseudo_dir = './'
  etot_conv_thr=1.0e-4
  forc_conv_thr=1.0e-3
/
&system
  ibrav = 0
  celldm(1) = 15.051289554
  nat = 8
  ntyp = 2
  nbnd = 64
  ecutwfc = ${e}
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
 La 138.90 la_default.cpi.upf
 Br 79.904 br.cpi.upf

CELL_PARAMETERS alat
0.500000000000 -0.866025403784  0.000000000000
0.500000000000  0.866025403784  0.000000000000
0.000000000000  0.000000000000  0.566480012053

ATOMIC_POSITIONS crystal
La 0.3333333333333333  0.6666666666666666  0.2500000000000000
La 0.6666666666666666  0.3333333333333333  0.7500000000000000
Br 0.3850600000000000  0.2987800000000000  0.2500000000000000
Br 0.9137200000000000  0.6149400000000000  0.2500000000000000
Br 0.7012200000000000  0.0862800000000000  0.2500000000000000
Br 0.0862800000000000  0.3850600000000000  0.7500000000000000
Br 0.2987800000000000  0.9137200000000000  0.7500000000000000
Br 0.6149400000000000  0.7012200000000000  0.7500000000000000

K_POINTS automatic
${k} ${k} $((${k}*2)) 1 1 1
EOF

cat > submit << EOF
#!/bin/bash -l
#MSUB -A pls2

#MSUB -c ansel
#MSUB -l procs=48
#MSUB -l walltime=00:30:00
#MSUB -N labr3_${k}_grid_${e}_cut.%j
#MSUB -o labr3_${k}_grid_${e}_cut.%j
#MSUB -V
#MSUB -j oe

srun -n 48 ~/soft/espresso-5.1.1/bin/pw.x < scf.in > scf.out
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

  cd -
  done

  cd $WORK_DIR
done



echo "Done."
