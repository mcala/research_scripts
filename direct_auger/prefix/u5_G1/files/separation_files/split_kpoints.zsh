#!/bin/zsh
#

#if [[ $# -ne 1 ]]; then
#  echo "Must specify eeh or hhe"
#  exit
#else
#  RUN=$1
#fi

PREFIX=`get_prefix_file nscf.in`
KPOINTS_FILE='kgrid_elec_full.dat'
KPOINTS=`wc -l ${KPOINTS_FILE} | awk '{print $1}'`
KPOINTS=10

echo "Splitting up a" $KPOINTS "k point job for" $PREFIX"."

for i in `seq 1 $KPOINTS`; do

  mkdir k_${i}
  cd k_${i}

  mkdir ${PREFIX}.save
  cp ../${PREFIX}.save/charge-density.dat ./${PREFIX}.save
  cp ../${PREFIX}.save/data-file.xml ./${PREFIX}.save
  cp ../${PREFIX}.occup ./
  cp ../*.UPF ./
  cp ../${KPOINTS_FILE} ./

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
ATOMIC_SPECIES
In  114.818   in.cpi.UPF
N  14.007   n.cpi.UPF

CELL_PARAMETERS alat
   1.000000000   0.000000000   0.000000000
  -0.500000000   0.866025403   0.000000000
   0.000000000   0.000000000   1.618331691

ATOMIC_POSITIONS crystal
In       0.333333333   0.666666667  -0.001658128
In       0.666666667   0.333333333   0.498341872
N        0.333333333   0.666666667   0.376658128
N        0.666666667   0.333333333  -0.123341872

K_POINTS crystal
1
EOF

cat ${KPOINTS_FILE} | head -${i} | tail -1 >> nscf.in


cat > ./pw2wannier90.in << EOF
&inputpp
outdir = './'
prefix = '${PREFIX}'
seedname = '${PREFIX}'
spin_component = 'none'
write_mmn = .false.
write_amn = .false.
write_unk = .true.
reduce_unk = .true.
/
EOF



cd -

done

cat > job_submit << EOF
#!/bin/bash -l
#SBATCH -p regular
#SBATCH -J 52.e.n.inn
#SBATCH -N 1
#SBATCH -t 00:10:00
#SBATCH -A m1380
#SBATCH --array=1-${KPOINTS}

module load espresso/5.1.1/
EOF

cat >> job_submit << "EOF"
cd ${SLURM_SUBMIT_DIR}/${SLURM_ARRAY_TASK_ID}

echo "I'm running in..."
pwd

srun -n 24 pw.x < nscf.in > nscf.out
../../files/make_unk.tcsh inn
srun -n 24 pw2wannier90.x < pw2wannier90.in > pw2wannier90.out

echo "------------------------------------------------------------------"
sacct -j  --format=JobID,JobName%30,MaxRSS,Elapsed
echo "------------------------------------------------------------------"

EOF
