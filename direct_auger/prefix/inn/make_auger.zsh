#!/bin/zsh
#
if [[ $# -ne 5 ]]; then
  echo "Usage: make_auger.zsh density temperature kpt1 kpt2 kpt3"
  exit
fi

DENSITY=$1
TEMP=$2
KPT1=$3
KPT2=$4
KPT3=$5

cat  > direct.in << EOF
&CONTROL
prefix='inn'
calculation='auger',
density=${DENSITY},
temperature=${TEMP},
nkint(:) = ${KPT1}, ${KPT2}, ${KPT3},
scratch_dir='.'
pre_direct_dir='./files/pre_direct'
/
&MATERIAL
alat=6.6924,
Vcell=420.0874,
nbnd=26,
icbm_ref=16,
ivbm_ref=18
ivbm=18,
icbm=19,
vbmdeg=2,
valence_electrons=16,
nphonon=0,
epsilon_infty=8.4,
a(:,1) =  1.000000,   0.000000,   0.000000,
a(:,2) = -0.500000,   0.866025,   0.000000,
a(:,3) =  0.000000,   0.000000,   1.618332,
b(:,1) = 1.000000,  0.577350,  0.000000,
b(:,2) = 0.000000,  1.154701,  0.000000,
b(:,3) = 0.000000,  0.000000,  0.617920
/
&PRE_DIRECT
halfholegrid = .true.
density_conv_thr = 1.0E-2
/
&WANNIER
nwan=26,
nwanband=32,
nkwan1=8,
nkwan2=8,
nkwan3=4
/
&AUGER
ngap=4000,
Egap_min= 0.01,
Egap_step= 0.001,
screening_model='combined'
direct_first_run=.false.
/
EOF

cp direct.in files/pre_direct/pre_direct.in
sed -i -e 's/auger/pre_direct/' files/pre_direct/pre_direct.in

cat > files/pre_direct/pre_direct << EOF
#!/bin/zsh

echo "Make sure correct module is loaded."

~/soft/auger/bin/efermi_elec.x pre_direct.in > efermi_elec.out
~/soft/auger/bin/efermi_hole.x pre_direct.in > efermi_hole.out
~/soft/auger/bin/trim.x pre_direct.in > trim.out
~/soft/auger/bin/generate_k4_eeh.x pre_direct.in > gen_kgrid_eeh.out
~/soft/auger/bin/generate_k4_hhe.x pre_direct.in > gen_kgrid_hhe.out
EOF

chmod +x files/pre_direct/pre_direct

mkdir -p files/pre_direct/interpolations
cd files/pre_direct/interpolations
ln -sf ../../../../interpolations/*.dat ./
ln -sf ../../../interpolations/run/kirr_coord_weights_halfholegrid.dat ../
cd -

cat > files/direct_submit << EOF
#!/bin/bash

#PBS -V
#PBS -M mcala@umich.edu
#PBS -m ae
#PBS -j eo
#PBS -q flux
#PBS -A kioup_flux
#PBS -l qos=flux
#PBS -N da.${KPT1}.${DENSITY}
EOF

cat >> files/direct_submit << "EOF"
#PBS -l walltime=00:30:00
#PBS -l nodes=2:ppn=12

#  Include the next three lines always
if [ "x${PBS_NODEFILE}" != "x" ] ; then
   cat $PBS_NODEFILE   # contains a list of the CPUs you were using
fi

cd $PBS_O_WORKDIR

cd ../

/home/mcala/scripts/direct_auger/utilities/make_run.zsh hhe

rm combinations.dat

sed -i -e 's/direct_first_run=.false./direct_first_run=.true./g' direct.in
mpirun -n 1 ~/soft/auger/bin/direct_auger_hhe.x direct.in > direct_serial.out

wc -l combinations.dat | awk '{print $1}' > combos.dat
cat combinations.dat >> combos.dat
mv combos.dat combinations.dat
cp combinations.dat combinations_hhe.dat

sed -i -e 's/direct_first_run=.true./direct_first_run=.false./g' direct.in
mpirun -n 12 ~/soft/auger/bin/direct_auger_hhe.x direct.in > direct_hhe.out

rm combinations.dat
/home/mcala/scripts/direct_auger/utilities/make_run.zsh eeh

sed -i -e 's/direct_first_run=.false./direct_first_run=.true./g' direct.in
mpirun -n 1 ~/soft/auger/bin/direct_auger_eeh.x direct.in > direct_serial.out

wc -l combinations.dat | awk '{print $1}' > combos.dat
cat combinations.dat >> combos.dat
mv combos.dat combinations.dat
cp combinations.dat combinations_eeh.dat

sed -i -e 's/direct_first_run=.true./direct_first_run=.false./g' direct.in
mpirun -n 12 ~/soft/auger/bin/direct_auger_eeh.x direct.in > direct_eeh.out
EOF

