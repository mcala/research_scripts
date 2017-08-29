#!/bin/zsh

# Sets up sigma calculation with required number of bands to sum over,
# and screened cutoff (which should match the corresponding epsilon
# calculation).
# The "not full" calculation" is slightly different from epsilon. Here, you
# won't bother calculating any other q points aside from gamma.
#
# Note that the valence bands and which bands to calcualte for are hard coded.
#

if [[ $# -ne 4 ]]; then
  echo "Usage: make_sigma_inp.zsh screened_cutoff bare_cutoff total_bands full_grid(1/0)"
  exit
fi

SCREEN_CUT=$1
BARE_CUT=$2
TOT_BANDS=$3
FULL=$4

echo "----------------------------------------------------------------"
echo "Remember! Valence band number and calcualted bands are hard coded!"
echo "----------------------------------------------------------------"
echo "I'm setting up a sigma calculation with:"
echo "Screened Coulomb Cutoff: " $SCREEN_CUT
echo "Bare Coulomb Cutoff: " $BARE_CUT
echo "Total Bands: " $TOT_BANDS
echo "Full qlist: " $FULL
echo "----------------------------------------------------------------"


QPOINTS=`head -2 WFNco.out | tail -1`

  # -----------
  # Do all q points in one run
  # -----------
if [[ ${FULL} == 1 ]]; then
  # -----------
  # sigma.inp
  # -----------
  # header
  cat > sigma.inp <<- EOF
    screened_coulomb_cutoff ${SCREEN_CUT}
    bare_coulomb_cutoff ${BARE_CUT}

    number_bands ${TOT_BANDS}
    band_occupation 8*1 $(($TOT_BANDS-8))*0

    band_index_min 1
    band_index_max 32

    degeneracy_check_override
    frequency_dependence 1
    exact_static_ch 1

    screening_semiconductor

    number_kpoints ${QPOINTS}
    begin kpoints
    0.000000000  0.000000000  0.000000000   1.0
  EOF

  for q in `seq 2 $QPOINTS`; do

    P1=`head -$((q+2)) WFNco.out | tail -1 | awk '{print $1}'`
    P2=`head -$((q+2)) WFNco.out | tail -1 | awk '{print $2}'`
    P3=`head -$((q+2)) WFNco.out | tail -1 | awk '{print $3}'`

    cat >> sigma.inp <<- EOF
      $P1  $P2  $P3   1.0  0
    EOF

  done

  # final end
  cat >> sigma.inp <<- EOF
    end
  EOF

  cat > submit <<- EOF
    #!/bin/bash -l
    #PBS -q low
    #PBS -N csi_sigma_${SCREEN_CUT}_${TOT_BANDS}
    #PBS -l mppwidth=
    #PBS -l walltime=01:00:00
    #PBS -j eo
    #PBS -A m1380
    #PBS -m ae

    cd \${PBS_O_WORKDIR}
    module load espresso/5.1.1
    module load berkeleygw

    aprun -n 48 ~/soft/berkeleygw_6442/bin/sigma.cplx.x > sigma.out
  EOF

else

  cat > sigma.inp <<- EOF
    screened_coulomb_cutoff ${SCREEN_CUT}
    bare_coulomb_cutoff ${BARE_CUT}

    number_bands ${TOT_BANDS}
    band_occupation 8*1 $(($TOT_BANDS-8))*0

    band_index_min 1
    band_index_max 32

    degeneracy_check_override
    frequency_dependence 1
    exact_static_ch 1

    screening_semiconductor

    number_kpoints 1
    begin kpoints
    0.000000000  0.000000000  0.000000000   1.0
    end
  EOF

  cat > submit <<- EOF
    #!/bin/bash -l
    #PBS -q regular
    #PBS -N csi_sigma_${SCREEN_CUT}_${TOT_BANDS}
    #PBS -l mppwidth=96
    #PBS -l walltime=00:10:00
    #PBS -j eo
    #PBS -A m1380
    #PBS -m ae

    cd \${PBS_O_WORKDIR}
    module load espresso/5.1.1
    module load berkeleygw

    aprun -n 96 ~/soft/berkeleygw_6442/bin/sigma.cplx.x > sigma.out
  EOF

fi
