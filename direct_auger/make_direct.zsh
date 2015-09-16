#!/bin/zsh
# Script to begin a new diret auger calculation.
#
#
#

# Get directory of main_script which allows calling of other scripts in this
# directory. readlink is not exactly standard, so this may not work on all 
# machines
SCRIPT_DIR=$(readlink -f "$0")
SCRIPT_DIR=$(dirname "$SCRIPT_DIR")
echo "Scripts are in: "$SCRIPT_DIR

# Three possible ways for doing input. The first is by calling with command 
# line arguments. Not typically what you'd do, but may be useful in larger 
# convergence setups. The second reads from input.dat, which is simple
# enough to write yourself and is writeen when either of the other methods are
# called. If neither of those are used, it will specifically ask for each
# parameter.
if [[ $# -ne 0 ]]; then
  if [[ $# -eq 7 ]]; then
    PREFIX=$1
    TEMPERATURE=$2
    DENSITY=$3
    KPT1=$4
    KPT2=$5
    KPT3=$6
    SCRATCH=$7
  else
    echo "Usage: make_direct.zsh prefix temperature density kpoints scratchdir"
    exit
  fi

elif [[ -a input.dat && $# -eq 0 ]]; then
  echo "Reading from input.dat"
  PREFIX=`awk '{print $2}' input.dat | head -n 1`
  TEMPERATURE=`awk '{print $2}' input.dat | head -n 2 | tail -n 1`
  DENSITY=`awk '{print $2}' input.dat | head -n 3 | tail -n 1`
  KPT1=`awk '{print $2}' input.dat | head -n 4 | tail -n 1`
  KPT2=`awk '{print $2}' input.dat | head -n 5 | tail -n 1`
  KPT3=`awk '{print $2}' input.dat | head -n 6 | tail -n 1`
  SCRATCH=`awk '{print $2}' input.dat | head -n 7 | tail -n 1`

else
  echo "Prefix?"
  read PREFIX
  echo "Temperature?"
  read TEMPERATURE
  echo "Density?"
  read DENSITY
  echo "K points?"
  read KPOINTS
  echo "Scratch dir?"
  read SCRATCH

  # Split up the kpoints from long string to 3 separate numbers
  KPT1=`echo ${KPOINTS} | awk '{print $1}'`
  KPT2=`echo ${KPOINTS} | awk '{print $2}'`
  KPT3=`echo ${KPOINTS} | awk '{print $3}'`
fi

# Write input data to stdout and to a file for double checking
echo "I'm setting up a calculation with the following!"
echo "PREFIX: " $PREFIX
echo "TEMPERATURE: " $TEMPERATURE
echo "DENSITY: " $DENSITY
echo "KPT1: " $KPT2
echo "KPT1: " $KPT2
echo "KPT1: " $KPT3
echo "SCRATCH: " $SCRATCH

cat > input.dat <<- EOF
PREFIX: ${PREFIX}
TEMPERATURE: ${TEMPERATURE}
DENSITY: ${DENSITY}
KPT1: ${KPT2}
KPT1: ${KPT2}
KPT1: ${KPT3}
SCRATCH: ${SCRATCH}
EOF

echo $SCRATCH > SCRATCH

# Fix points for half hole grid
KPT1HH=`echo ${KPT1} | awk '{print $1/2}'`
KPT2HH=`echo ${KPT2} | awk '{print $1/2}'`
KPT3HH=`echo ${KPT3} | awk '{print $1/2}'`


# Make directory structure in $HOME and $SCRATCH
echo "Making files..."
cp -r ${SCRIPT_DIR}/files ./files
mkdir ./pre_direct
mkdir ${SCRATCH}/files
mkdir ${SCRATCH}/files/dft_calc
mkdir ${SCRATCH}/files/dft_calc/kirr

# The prefix directory allows you to keep different materials separate 
# and create new runs faster. There are different "make" files for scf, nscf,
# wannier, and auger which have the material specific parameters in them.
# Most of this stuff doesn't change between runs, and the stuff that does
# is fed in as input. This copies everything to the correct locations.
#
# IF there is no prefix direcotry. It will make some empty files which you 
# can edits anad make a prefix directory with.
echo "Reading ${PREFIX} directory..."
if [[ -d ${SCRIPT_DIR}/prefix/${PREFIX} ]]; then

  if [[ -a ${SCRIPT_DIR}/prefix/${PREFIX}/NOTES ]]; then
    cat ${SCRIPT_DIR}/prefix/${PREFIX}/NOTES
  fi

  ${SCRIPT_DIR}/prefix/${PREFIX}/make_auger.zsh \
    ${DENSITY} ${TEMPERATURE} ${KPT1} ${KPT2} ${KPT3} ${SCRATCH}

  ${SCRIPT_DIR}/prefix/${PREFIX}/make_scf.zsh \
    ${PREFIX} ${KPT1} ${KPT2} ${KPT3} ${SCRATCH}

  cp -r ${SCRIPT_DIR}/prefix/${PREFIX}/*.dat ./pre_direct
  cp -r ${SCRIPT_DIR}/prefix/${PREFIX}/*.eig ./pre_direct
  cp -r ${SCRIPT_DIR}/prefix/${PREFIX}/*.cpi.* ./files/dft_calc
  cp -r ${SCRIPT_DIR}/prefix/${PREFIX}/*.cpi.* ./files/dft_calc/kirr

  if [[ -a ${SCRIPT_DIR}/prefix/${PREFIX}/make_unk.tcsh ]]; then
    cp ${SCRIPT_DIR}/prefix/${PREFIX}/make_unk.tcsh ./files/
  else
    cp ${SCRIPT_DIR}/prefix/make_unk.tcsh ./files/
    echo "No unk.tcsh file in prefix directory!"
    echo "Default unk.tcsh copied. Make sure to modify it!"
  fi

  if [[ -d copy ]]; then
    cp copy/* ./files
  fi

else
  echo "Didn't find prefix directory!"
  echo "Making some empty files..."
  echo "Make sure to set them up and create prefix directory!"
  echo "Don't forget the Wannier files!"
  echo "Don't foget the pseudos!"

  ${SCRIPT_DIR}/prefix/make_auger.zsh \
    ${DENSITY} ${TEMP} ${KPT1} ${KPT2} ${KPT3} ${SCRATCH}

  ${SCRIPT_DIR}/prefix/make_scf.zsh \
    ${KPT1} ${KPT2} ${KPT3} ${SCRATCH}

  ${SCRIPT_DIR}/prefix/make_wannier.zsh \
    ${PREFIX} 
fi
