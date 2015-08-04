#!/bin/zsh -l
#
WORKING_DIR=$1
KPOINTS=$2
BANDS=$3
cat > bands.in << EOF
!qe
&control
  calculation = 'bands'
  verbosity = 'high'
  prefix = 'csi'
  restart_mode = 'from_scratch'
  wf_collect = .true.
  tstress = .true.
  tprnfor = .true.
  outdir = '${WORKING_DIR}'
  wfcdir = '${WORKING_DIR}'
  pseudo_dir = './'
  etot_conv_thr=1.0e-4
  forc_conv_thr=1.0e-3
/
&system
  ibrav = 1
  celldm(1) = 8.78288088649
  nat = 2
  ntyp = 2
  nbnd = ${BANDS}
  ecutwfc = 40
  occupations = 'fixed'
/
&electrons
  electron_maxstep = 100
  conv_thr = 1.0e-12
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
  Cs 132.91 cs_semi.cpi.upf
  I  126.90 i.cpi.upf

ATOMIC_POSITIONS crystal
  Cs 0.000000000   0.000000000   0.000000000
  I  0.500000000   0.500000000   0.500000000

EOF

cat bands.in ${KPOINTS} > bands.in2
mv bands.in2 bands.in

if [[ ${KPOINTS} == 'WFN.out' ]]; then
cat > pw2bgw.in << EOF
&INPUT_PW2BGW
  prefix = 'csi'
  outdir = '${WORKING_DIR}'
  real_or_complex = 1
  wfng_flag = .true.
  wfng_file = 'WFN'
  wfng_kgrid = .true.
  wfng_nk1 = 2
  wfng_nk2 = 2
  wfng_nk3 = 2
  wfng_dk1 = 0.5
  wfng_dk2 = 0.5
  wfng_dk3 = 0.5
/
EOF

elif [[ ${KPOINTS} == 'WFNq.out' ]]; then
cat > pw2bgw.in << EOF
&INPUT_PW2BGW
  prefix = 'csi'
  outdir = '${WORKING_DIR}'
  real_or_complex = 1
  wfng_flag = .true.
  wfng_file = 'WFN'
  wfng_kgrid = .true.
  wfng_nk1 = 2
  wfng_nk2 = 2
  wfng_nk3 = 2
  wfng_dk1 = 0.5
  wfng_dk2 = 0.5
  wfng_dk3 = 0.501
/
EOF

elif [[ ${KPOINTS} == 'WFNco.out' ]]; then
cat > pw2bgw.in << EOF
&INPUT_PW2BGW
  prefix = 'csi'
  outdir = '${WORKING_DIR}'
  real_or_complex = 1
  wfng_flag = .true.
  wfng_file = 'WFN' 
  wfng_kgrid = .true.
  wfng_nk1 = 2
  wfng_nk2 = 2
  wfng_nk3 = 2
  wfng_dk1 = 0.0
  wfng_dk2 = 0.0
  wfng_dk3 = 0.0
  rhog_flag = .true.
  rhog_file = 'rho'
  vxcg_flag = .false.
  vxcg_file = 'vxc'
  vxc_flag = .true.
  vxc_file = 'vxc.dat'
  vxc_diag_nmin = 
  vxc_diag_nmax = 
/
EOF
fi

cat > submit << EOF
#!/bin/bash -l
#PBS -q debug
#PBS -N csi_gw_qe
#PBS -l mppwidth=24
#PBS -l walltime=00:30:00
#PBS -j eo
#PBS -A m1380
#PBS -m ae

cd \${PBS_O_WORKDIR}
module load espresso/5.1.1

aprun -n 24 pw.x < bands.in > bands.out
aprun -n 24 pw2bgw.x < pw2bgw.in > pw2bgw.out
EOF
