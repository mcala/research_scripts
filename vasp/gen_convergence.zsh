#!/bin/zsh -l

# Directory information.
WORK_DIR=`pwd`
echo "Scratch Directory?"
read SCRATCH_DIR

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
#	 mkdir ${SCRATCH_DIR}/${k}_grid
	cd ${k}_grid

	for e in `seq ${ECUT_MIN} ${ECUT_SPACE} ${ECUT_MAX}`; do
		mkdir ${e}_cut
#		 mkdir ${SCRATCH_DIR}/${k}_grid/${e}_cut
		cd ${e}_cut

	cat > INCAR <<- EOF
		GENERAL
		# ------------------------------------------------------------------------
		SYSTEM = csi
		PREC = Accurate
		LREAL = Auto
		#ICHARG = 0
		#ISTART = 0
		
		# PARALLELIZATION
		# ------------------------------------------------------------------------
		NPAR = 6
		#KPAR =
		
		# ELECTRONIC
		# ------------------------------------------------------------------------
		ALGO = Normal
		ENCUT = ${e}
		NBANDS = 12
		ISMEAR = 1; SIGMA = 0.1
		EDIFF = 10E-3
		NELMIN = 4
		
		# IONIC
		# ------------------------------------------------------------------------
		#IBRION = 2
		#NSW = 20
		#EDIFFG = 10E-3
		#ADDGRID = .TRUE.
		#POTIM = 0.5
		#SMASS = 0
	EOF

	cat > KPOINTS <<- EOF
		Automatic mesh
		0
		MP
		${k} ${k} ${k}
		0 0 0
	EOF

	cp ${WORK_DIR}/POTCAR ./
	cp ${WORK_DIR}/POSCAR ./

	cat > vasp_submit <<- EOF
		#!/bin/bash -l
		#PBS -q regular
		#PBS -N csi_${k}_${e}
		#PBS -l mppwidth=48
		#PBS -l walltime=00:30:00
		#PBS -j eo
		#PBS -A m1380
		#PBS -m ae
		#PBS -V
	EOF

	cat >> vasp_submit <<- 'EOF'
		cd ${PBS_O_WORKDIR}

		aprun -n 48 vasp
	EOF

#	 qsub vasp_submit

	cd -
done

cd $WORK_DIR
done

echo "Done."
