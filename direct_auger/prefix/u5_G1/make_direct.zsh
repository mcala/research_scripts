#!/bin/zsh
# Script to begin a new diret auger calculation.

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
  if [[ $# -eq 5 ]]; then
    PREFIX=$1
    DENSITY=$2
    KPT1=$3
    KPT2=$4
    KPT3=$5
  else
    echo "Usage: make_direct.zsh prefix density kpoints"
    exit
  fi

elif [[ -a input.dat && $# -eq 0 ]]; then
  echo "Reading from input.dat"
  PREFIX=`awk '{print $2}' input.dat | head -n 1`
  DENSITY=`awk '{print $2}' input.dat | head -n 2 | tail -n 1`
  KPT1=`awk '{print $2}' input.dat | head -n 3 | tail -n 1`
  KPT2=`awk '{print $2}' input.dat | head -n 4 | tail -n 1`
  KPT3=`awk '{print $2}' input.dat | head -n 5 | tail -n 1`

else
  echo "Prefix?"
  read PREFIX
  echo "Density?"
  read DENSITY
  echo "K points?"
  read KPOINTS

  # Split up the kpoints from long string to 3 separate numbers
  KPT1=`echo ${KPOINTS} | awk '{print $1}'`
  KPT2=`echo ${KPOINTS} | awk '{print $2}'`
  KPT3=`echo ${KPOINTS} | awk '{print $3}'`
fi

# Write input data to stdout and to a file for double checking
echo "I'm setting up a calculation with the following!"
echo "PREFIX: " $PREFIX
echo "DENSITY: " $DENSITY
echo "KPT1: " $KPT1
echo "KPT2: " $KPT2
echo "KPT3: " $KPT3

cat > input.dat <<- EOF
PREFIX: ${PREFIX}
DENSITY: ${DENSITY}
KPT1: ${KPT1}
KPT2: ${KPT2}
KPT3: ${KPT3}
EOF

# Set up points for half hole grid
KPT1HH=`echo ${KPT1} | awk '{print $1/2}'`
KPT2HH=`echo ${KPT2} | awk '{print $1/2}'`
KPT3HH=1

# Make directory structure in $HOME and $SCRATCH
echo "Making files..."
cp -r ${SCRIPT_DIR}/files ./files

# Will show NOTES that you might need about certain runs
cat ${SCRIPT_DIR}/NOTES

${SCRIPT_DIR}/make_auger.zsh \
${DENSITY} ${KPT1} ${KPT2} ${KPT3}

#${SCRIPT_DIR}/make_scf.zsh \
#${PREFIX} ${KPT1} ${KPT2} ${KPT3} ${SCRATCH}
