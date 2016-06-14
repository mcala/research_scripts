#!/bin/zsh -l

# This function checks that an scf file exists to either print the total energy
# or print that something is wrong. It also handles printing the values of whatever
# we're studying - ecut or delta from the lattice parameter.
function grab_energy {
  input=$1
  echo -n ${input:t} >> ${WORKING_DIR}/energies.dat
  echo -n "\t" >> ${WORKING_DIR}/energies.dat
  if [[ -a OSZICAR ]]; then
    grep "DAV" OSZICAR
    # Check to see if grep succeeded. If it doesn't the calculation didn't
    # finish/converge, and it prints this error. Otherwise it greps for the
    # total energy.
    if [[ $? == 1 ]]; then
      echo "Run Error!" >> ${WORKING_DIR}/energies.dat
    else
      tail -n 2 OSZICAR | head -n 1| awk '{print $3}' >> ${WORKING_DIR}/energies.dat
    fi
  else
    echo "No OSZICAR!" >> ${WORKING_DIR}/energies.dat
  fi
}

WORKING_DIR=`pwd`

if [[ -a energies.dat ]]; then
  echo "Remove old energies?"
  rm -i energies.dat
  touch energies.dat
fi

# This script has two ways of grabbing the energies. One is for the parameters.dat
# files that you generate in various scripts. It will read those parameters and
# use that to output the energies in the form that you want. If this is missing or
# never made, it will go through the directory structure and "hopefully" print
# what you want.
#
# Read old parameters if they exist
if [[ -a con_parameters.dat ]]; then
  echo "Reading from parameters list..."
  K_POINT_MIN=`awk '{print $2}' con_parameters.dat | head -n 1`
  K_POINT_MAX=`awk '{print $2}' con_parameters.dat | head -n 2 | tail -n 1`
  K_POINT_SPACE=`awk '{print $2}' con_parameters.dat | head -n 3 | tail -n 1`
  ECUT_MIN=`awk '{print $2}' con_parameters.dat | head -n 4 | tail -n 1`
  ECUT_MAX=`awk '{print $2}' con_parameters.dat | head -n 5 | tail -n 1`
  ECUT_SPACE=`awk '{print $2}' con_parameters.dat | head -n 6 | tail -n 1`

  for k in `seq ${K_POINT_MIN} ${K_POINT_SPACE} ${K_POINT_MAX}`; do
    echo ${k}_grid >> energies.dat

    for e in `seq ${ECUT_MIN} ${ECUT_SPACE} ${ECUT_MAX}`; do
      cd ${k}_grid/${e}_cut
      grab_energy ${e}
      cd -
    done
  done


elif [[ -a delta_parameters.dat ]]; then
  echo "Reading from parameters list..."
  MIN=`awk '{print $2}' delta_parameters.dat | head -n 1`
  MAX=`awk '{print $2}' delta_parameters.dat | head -n 2 | tail -n 1`
  SPACING=`awk '{print $2}' delta_parameters.dat | head -n 3 | tail -n 1`

  for delta in `seq ${MIN} ${SPACING} ${MAX}`; do
    cd delta_${delta}
    grab_energy ${delta}
    cd -
  done


else
  for d in `find . -mindepth 1 -maxdepth 2 -type d`; do
    cd $d
    if [[ ${d} =~ "cut" ]] then
      grab_energy ${d}
    elif [[ ${d} =~ "delta" ]] then
      grab_energy ${d}
    else
      echo ${d:t} >> ${WORKING_DIR}/energies.dat
    fi
    cd -

  done






fi



