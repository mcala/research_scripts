#!/bin/zsh
#
# This script copies all of the necessary input files to a directory called backup. 
# Ideally you would be able to totally rerun a phonon assisted auger calcualtion using
# all of the input files saved from this script.
# For simplicity, it also copies all output files, so if need be you can compare output on
# another run.

# Gets prefix, necessary for dealing with .save files
PREFIX_PATH=`find . -maxdepth 1 -name *.save`
PREFIX=`echo ${PREFIX_PATH:r:t}`
echo "PREFIX is $PREFIX."
WORKING_DIR=`pwd`

# Figure out how many k points were in the run
cd phonon_points/data
wc -l klist_weights.dat >> line_num
KPOINTS=`awk '{print $1}' line_num`
rm line_num
cd ${WORKING_DIR}

echo "I'm making the directory structure..."

# Make backup directory structure
mkdir backup
mkdir backup/phonon_points
mkdir backup/phonon_points/files
mkdir backup/phonon_points/data

for i in `seq 1 ${KPOINTS}`; do
    mkdir backup/phonon_points/phonon_${i}
done

echo "I'm starting my copying..."

# Start in main directory, copying all files (not .save or entire phonon points directory)
cp * backup

# Move to phonon points directory
cd phonon_points

# Copy all loose files (typically Auger input and output) as well as the files and data directories
cp * ${WORKING_DIR}/backup/phonon_points
cp -r files ${WORKING_DIR}/backup/phonon_points/files
cp -r data ${WORKING_DIR}/backup/phonon_points/data

# Move phonon data
for i in `seq 1 ${KPOINTS}`; do
    cd phonon_${i}
    cp *.in ${WORKING_DIR}/backup/phonon_points/phonon_${i}
    cp *.out ${WORKING_DIR}/backup/phonon_points/phonon_${i}
    cp omega ${WORKING_DIR}/backup/phonon_points/phonon_${i}
    cp UNK* ${WORKING_DIR}/backup/phonon_points/phonon_${i}
    cp fort* ${WORKING_DIR}/backup/phonon_points/phonon_${i}
    cp *.nnkp ${WORKING_DIR}/backup/phonon_points/phonon_${i}
    cp *.dvscf01 ${WORKING_DIR}/backup/phonon_points/phonon_${i}
    cp *.dyn ${WORKING_DIR}/backup/phonon_points/phonon_${i}
    cd -
done

cd ${WORKING_DIR}

echo "Phonon assisted run backup complete."

