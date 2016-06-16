#!/bin/zsh
#
FILENAME=$1

POINTS=`wc -l $FILENAME | awk '{print $1}'`
PREFIX=`get_prefix ../../../scf_calculation`

mv ${PREFIX}.eig ${PREFIX}_original.eig

cp ../files/pre_direct/u_matrix* ./
cp ../files/pre_direct/${PREFIX}.eig ./

echo $POINTS > k_points.dat
cat $FILENAME >> k_points.dat

cp ../direct.in interpolate.in
sed -i -e 's/auger/interpolate/g' interpolate.in

wannier_interpolate.x interpolate.in

mv interpolate.eig ${PREFIX}.eig
