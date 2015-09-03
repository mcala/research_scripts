#!/bin/zsh
#
# This script copies all input files for a bulk modulus run. Directory
# structure is parameter_#/Size_#. Will also save output files, and scripts, but will not save .save files.
#
WORKING_DIR=`pwd`

mkdir bulk_backup
cd bulk_backup

# Make directory structure for backup
for i in `seq 4 6`; do

    mkdir kpt_${i}
    cd kpt_${i}

    for j in `seq -4.0 0.1 4.0`; do
        mkdir Size_${j}
    done

    cd ${WORKING_DIR}/bulk_backup
done

cd ${WORKING_DIR}

cp * bulk_backup

# Actually copy over all files
for i in `seq 4 6`; do

    cd kpt_${i}
    cp * ${WORKING_DIR}/bulk_backup/kpt_${i}

    for j in `seq -4.0 0.1 4.0`; do
        
        cd Size_${j}
        cp * ${WORKING_DIR}/bulk_backup/kpt_${i}/Size_${j}
    done
    
    cd ${WORKING_DIR}/bulk_backup
done
