#!/bin/zsh

# This script copies all of the necessary input files to a directory called backup.
# Ideally, you would be able to totally rerun a direct Auger calculation using all of the
# input files saved from this script.
# For simplicity, it also copies all output files, so if need be you can compare output
# on another run.
##
#
echo "Do you want to save wave functions?"
read WAVE_SAVE_INPUT

if [[ $WAVE_SAVE_INPUT == "Y" || $WAVE_SAVE_INPUT == "y" || $WAVE_SAVE_INPUT == "yes" || $WAVE_SAVE_INPUT == "Yes" ]]; then
  echo "Saving wave functions."
  echo "Be careful you aren't saving GB of data!"
  SAVE_WAVE=1
else
  echo "NOT saving wave functions."
  SAVE_WAVE=0
fi


# Gets prefix, necessary for dealing with .save files
PREFIX_PATH=`find . -maxdepth 1 -name *.eig`
PREFIX=`echo ${PREFIX_PATH:r:t}`
echo "PREFIX is $PREFIX."
WORKING_DIR=`pwd`

mkdir backup
$HOME/scripts/direct_auger/utilities/make_run.zsh reset

# Starts in main directory, copies pretty much everything over
cp *.dat backup
cp *.eig backup
cp *.in backup
cp *.out backup

# If for some reason you're usng the old version, back those files up too.
if [[ -a DENSITY ]]; then
  cp DENSITY backup
  cp TEMPERATURE backup
  cp NKINT backup
fi

# If there was a last run folder, copies it
if [[ -d Last_Run ]]; then
    cp -r Last_Run backup
fi

# In the files folder, copies everything but the details of the ${PREFIX}.save files
# Will copy the charge density, and data-file which are the most important parts
mkdir backup/files
mkdir backup/files/dft_calc
mkdir backup/files/dft_calc/${PREFIX}.save
mkdir backup/files/dft_calc/kirr

cd files
cp -r wannier_calc ${WORKING_DIR}/backup/files
cp * ${WORKING_DIR}/backup/files
cd dft_calc
cp *.in ${WORKING_DIR}/backup/files/dft_calc
cp *.out ${WORKING_DIR}/backup/files/dft_calc
cp *_submit ${WORKING_DIR}/backup/files/dft_calc
cp ${PREFIX}.save/charge-density.dat ${WORKING_DIR}/backup/files/dft_calc/${PREFIX}.save
cp ${PREFIX}.save/data-file.xml ${WORKING_DIR}/backup/files/dft_calc/${PREFIX}.save
cd kirr
cp *.in ${WORKING_DIR}/backup/files/dft_calc/kirr
cp *.out ${WORKING_DIR}/backup/files/dft_calc/kirr

cd $WORKING_DIR

# Copies over all of the k files. This is where the most data is lost.
# We don't bother copying over the .save files, those are already saved in the
# dft calculation. We can  save all the wave functions. They aren't too big so
# it's not that bad. This way we can easy redo another auger calculation.
# We also only bother with 1 3 4 since 2 is just a copy of 1.
# BUT FOR fine grids, these add up and you can't actually save all of them.
for i in 1 3 4; do
    mkdir ${WORKING_DIR}/backup/k${i}
    cd k${i}
    if [[ $SAVE_WAVE == 1 ]]; then
      cp -r k_* ${WORKING_DIR}/backup/k${i}
    fi
    cp *.in ${WORKING_DIR}/backup/k${i}
    cp *.out ${WORKING_DIR}/backup/k${i}
    cp *.nnkp ${WORKING_DIR}/backup/k${i}
    cp *.eig ${WORKING_DIR}/backup/k${i}
    cp -r
    cd ${WORKING_DIR}
#    cp ./backup/files/dft_calc/${PREFIX}.save/charge-density.dat ./backup/k${i}/${PREFIX}.save
#    cp ./backup/files/dft_calc/${PREFIX}.save/data-file.xml ./backup/k${i}/${PREFIX}.save
done


echo "Done backing up direct auger run."
