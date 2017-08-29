#!/bin/zsh
#
if [[ $# -ne 4 ]]; then
  echo "Usage: make_auger.zsh edensity kpt1 kpt2 kpt3"
  exit
fi

DENSITY=$1
KPT1=$2
KPT2=$3
KPT3=$4

cat  > direct.in << EOF
&CONTROL
prefix='u5_G1'
calculation='auger',
density_e=${DENSITY},
density_h=${DENSITY},
temperature=300,
nkint(:) = ${KPT1}, ${KPT2}, ${KPT3},
scratch_dir='.'
pre_direct_dir='./files/pre_direct'
/

&MATERIAL
alat=5.8808273,
Vcell=1390.1828,
nbnd=85,
icbm_ref=45,
ivbm_ref=46,
ivbm=45,
icbm=46,
vbmdeg=2,
valence_electrons=90,
nphonon=0,
epsilon_infty=4.77,
a(:,1) =  1.000000,   0.000000,   0.000000,
a(:,2) = -0.500000,   0.866025,   0.000000,
a(:,3) =  0.000000,   0.000000,   7.892707,
b(:,1) =  1.000000,  0.577350,  0.000000,
b(:,2) =  0.000000,  1.154701,  0.000000,
b(:,3) =  0.000000,  0.000000,  0.126699,
/
&PRE_DIRECT
halfholegrid = .true.
density_conv_thr = 1.0E-2
/
&WANNIER
nwan=85,
nwanband=88,
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

module load auger/develop
echo "Make sure correct module is loaded."

efermi_elec.x pre_direct.in > efermi_elec.out
efermi_hole.x pre_direct.in > efermi_hole.out
trim.x pre_direct.in > trim.out
generate_k4_eeh.x pre_direct.in > gen_kgrid_eeh.out
generate_k4_hhe.x pre_direct.in > gen_kgrid_hhe.out
EOF

chmod +x files/pre_direct/pre_direct

mkdir -p files/pre_direct/interpolations
cd files/pre_direct/interpolations
ln -sf ../../../../interpolations/*.dat ./
ln -sf ../../../interpolations/run/kirr_coord_weights_halfholegrid.dat ../
cd -

cat > files/combinations_submit << EOF
#!/bin/bash -l
#SBATCH -p regular
#SBATCH -J da.1E${DENSITY}.${PREFIX}
#SBATCH -N 1
#SBATCH -t 01:00:00
#SBATCH -A m1380
EOF

cat >> files/combinations_submit << "EOF"
cd $SLURM_SUBMIT_DIR

module load auger/develop

cd ../

/global/homes/m/mcala/scripts/direct_auger/utilities/make_run.zsh hhe

rm combinations.dat

sed -i -e 's/direct_first_run=.false./direct_first_run=.true./g' direct.in
srun -n 1 direct_auger_hhe.x direct.in > direct_serial.out

wc -l combinations.dat | awk '{print $1}' > combos.dat
cat combinations.dat >> combos.dat
mv combos.dat combinations.dat
cp combinations.dat combinations_hhe.dat

rm combinations.dat
/global/homes/m/mcala/scripts/direct_auger/utilities/make_run.zsh eeh

sed -i -e 's/direct_first_run=.false./direct_first_run=.true./g' direct.in
srun -n 1 direct_auger_eeh.x direct.in > direct_serial.out

wc -l combinations.dat | awk '{print $1}' > combos.dat
cat combinations.dat >> combos.dat
mv combos.dat combinations.dat
cp combinations.dat combinations_eeh.dat
EOF

cat > files/direct_submit << EOF
#!/bin/bash -l
#SBATCH -p regular
#SBATCH -J da.1E${DENSITY}.${PREFIX}
#SBATCH -N 8
#SBATCH -t 03:00:00
#SBATCH -A m1380
EOF

cat >> files/direct_submit << "EOF"
cd $SLURM_SUBMIT_DIR

module load auger/develop

cd ../

/global/homes/m/mcala/scripts/direct_auger/utilities/make_run.zsh hhe

rm combinations.dat

cp combinations_hhe.dat combinations.dat
sed -i -e 's/direct_first_run=.true./direct_first_run=.false./g' direct.in
srun -n 192 direct_auger_hhe.x direct.in > direct_hhe.out

rm combinations.dat
/global/homes/m/mcala/scripts/direct_auger/utilities/make_run.zsh eeh

cp combinations_eeh.dat combinations.dat
sed -i -e 's/direct_first_run=.true./direct_first_run=.false./g' direct.in
srun -n 192 direct_auger_eeh.x direct.in > direct_eeh.out
EOF
