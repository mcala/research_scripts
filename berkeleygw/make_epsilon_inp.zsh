#!/bin/zsh
#
# Sets up an epsilon calculation for a given screened cutoff and total bands.
# Will either set up one calculation with all the required points or split the
# calculation into one for each point to be merged later.
#
# Note that the q point shift and valence bands are hard coded. If these change
# they must be changed manually in the script.
#

if [[ $# -ne 3 ]]; then
  echo "Usage: make_epsilon_inp.zsh screened_cutoff total_bands full_grid(1/0)"
  exit
fi

SCREEN_CUT=$1
TOT_BANDS=$2
FULL=$3

echo "----------------------------------------------------------------"
echo "Remember! Q point shift and valence bands are hard coded!"
echo "----------------------------------------------------------------"
echo "I'm setting up an epsilon calculation with:"
echo "Screened Coulomb Cutoff: " $SCREEN_CUT
echo "Total Bands: " $TOT_BANDS
echo "Full qlist: " $FULL
echo "----------------------------------------------------------------"

QPOINTS=`head -2 WFNco.out | tail -1`

	# -----------
	# Do all q points in one run
	# -----------
if [[ ${FULL} == 1 ]]; then
	# -----------
	# epsilon.inp
	# -----------
	# header
	cat > epsilon.inp <<- EOF
		epsilon_cutoff ${SCREEN_CUT}
		number_bands ${TOT_BANDS}
		band_occupation 8*1 $(($TOT_BANDS-8))*0

		degeneracy_check_override

		number_qpoints ${QPOINTS}
		begin qpoints
		0.000000000  0.000000000	0.001000000		1.0  1
	EOF

	# Unshifted q points
	for q in `seq 2 $QPOINTS`; do

		P1=`head -$((q+2)) WFNco.out | tail -1 | awk '{print $1}'`
		P2=`head -$((q+2)) WFNco.out | tail -1 | awk '{print $2}'`
		P3=`head -$((q+2)) WFNco.out | tail -1 | awk '{print $3}'`

		cat >> epsilon.inp <<- EOF
			$P1  $P2	$P3		1.0  0
		EOF

	done

	# final end
	cat >> epsilon.inp <<- EOF
		end
	EOF

	# -----------
	# submit
	# -----------

	cat > submit <<- EOF
		#!/bin/bash -l
		#PBS -q regular
		#PBS -N csi_epsilon_${SCREEN_CUT}_${TOT_BANDS}
		#PBS -l mppwidth=96
		#PBS -l walltime=00:15:00
		#PBS -j eo
		#PBS -A m1380
		#PBS -m ae

		cd \${PBS_O_WORKDIR}
		module load espresso/5.1.1
		module load berkeleygw

		aprun -n 96 ~/soft/berkeleygw_6442/bin/epsilon.cplx.x > epsilon.out
	EOF

# -----------
# Separate all q points into directories for merging later
# -----------

else

	# Have to do shifted point on it's own
	mkdir 1_qpt
	cd 1_qpt

	cat > epsilon.inp <<- EOF
		epsilon_cutoff ${SCREEN_CUT}
		number_bands ${TOT_BANDS}
		band_occupation 8*1 $(($TOT_BANDS-8))*0

		degeneracy_check_override

		number_qpoints 1
		begin qpoints
		0.000000000  0.000000000	0.001000000		1.0  1
		end
	EOF

	cat > submit <<- EOF
		#!/bin/bash -l
		#PBS -q regular
		#PBS -N csi_epsilon_${SCREEN_CUT}_${TOT_BANDS}_1_qpt
		#PBS -l mppwidth=96
		#PBS -l walltime=00:15:00
		#PBS -j eo
		#PBS -A m1380
		#PBS -m ae

		cd \${PBS_O_WORKDIR}
		module load espresso/5.1.1
		module load berkeleygw

		aprun -n 96 ~/soft/berkeleygw_6442/bin/epsilon.cplx.x > epsilon.out
	EOF

	cd -

	for q in `seq 2 $QPOINTS`; do
		mkdir ${q}_qpt
		cd ${q}_qpt

		cat > epsilon.inp <<- EOF
			epsilon_cutoff ${SCREEN_CUT}
			number_bands ${TOT_BANDS}
			band_occupation 8*1 $(($TOT_BANDS-8))*0

			degeneracy_check_override

			number_qpoints 1
			begin qpoints
		EOF

	P1=`head -$((q+2)) ../WFNco.out | tail -1 | awk '{print $1}'`
	P2=`head -$((q+2)) ../WFNco.out | tail -1 | awk '{print $2}'`
	P3=`head -$((q+2)) ../WFNco.out | tail -1 | awk '{print $3}'`

	cat >> epsilon.inp <<- EOF
		$P1  $P2	$P3		1.0  0
		end
	EOF

	cat > submit <<- EOF
		#!/bin/bash -l
		#PBS -q regular
		#PBS -N csi_epsilon_${SCREEN_CUT}_${TOT_BANDS}_${q}_qpt
		#PBS -l mppwidth=96
		#PBS -l walltime=00:15:00
		#PBS -j eo
		#PBS -A m1380
		#PBS -m ae

		cd \${PBS_O_WORKDIR}
		module load espresso/5.1.1
		module load berkeleygw

		aprun -n 96 ~/soft/berkeleygw_6442/bin/epsilon.cplx.x > epsilon.out
	EOF

	cd -

	done

fi
