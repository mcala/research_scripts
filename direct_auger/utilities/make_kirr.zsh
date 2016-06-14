#!/bin/zsh

rm -f kirr_coord_weights_halfholegrid.dat

grep "k(" scf.out >> temp
wc -l temp >> line_num
lines=`awk '{print $1}' line_num`
lines=$(($lines/2))

echo "There are " $lines " k points."

tail -${lines} temp >> klist_temp

awk '{print $5 " " $6 " " $7 " " $10}' klist_temp > kirr_coord_weights_halfholegrid.dat


echo $lines >> kirr_coord_weights_halfholegrid.datc
sed s/'),'/''/ kirr_coord_weights_halfholegrid.dat >> kirr_coord_weights_halfholegrid.datc
mv kirr_coord_weights_halfholegrid.datc kirr_coord_weights_halfholegrid.dat

rm -f klist_temp
rm -f temp 
rm -f line_num
