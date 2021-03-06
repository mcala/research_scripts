#!/bin/zsh
#
#
FILENAME=$1

POINTS=`wc -l $FILENAME | awk '{print $1}'`

cp ../pre_direct/u_matrix* ./
cp ../pre_direct/si.eig ./

echo $POINTS > k_points.dat
cat $FILENAME >> k_points.dat

cp ../direct.in interpolate.in
sed -i -e 's/auger/interpolate/g' interpolate.in

~/soft/auger_dev/bin/wannier_interpolate.x interpolate.in 

mv interpolate.eig si.eig
