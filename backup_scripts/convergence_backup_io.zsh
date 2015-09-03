#!/bin/zsh
#
# This script copies all input files for a general kpoint/cutoff convergence run. Directory
# structure is parameter_#/parameter_#. Will also save output files, and scripts, but will not save .save files.
#
WORKING_DIR=`pwd`

mkdir convergence_backup
cd convergence_backup

# Make directory structure for backup
for i in `seq 4 6`; do

    mkdir Kpt_${i}
    cd Kpt_${i}

    for j in `seq 15 5 80`; do
        mkdir Cut_${j}
    done

    cd ${WORKING_DIR}/convergence_backup
done

cd ${WORKING_DIR}

cp * convergence_backup

# Actually copy over all files
for i in `seq 4 6`; do

    cd Kpt_${i}
    cp * ${WORKING_DIR}/convergence_backup/Kpt_${i}

    for j in `seq 15 5 80`; do
        
        cd Cut_${j}
        cp * ${WORKING_DIR}/convergence_backup/Kpt_${i}/Cut_${j}
    done
    
    cd ${WORKING_DIR}/convergence_backup
done
