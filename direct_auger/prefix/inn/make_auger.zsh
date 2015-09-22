#!/bin/zsh
#
if [[ $# -ne 6 ]]; then
  echo "Usage: make_auger.zsh density temperature kpt1 kpt2 kpt3 scratch"
  exit
fi

DENSITY=$1
TEMP=$2
KPT1=$3
KPT2=$4
KPT3=$5
SCRATCH=$6

cat  > direct.in << EOF
&CONTROL
prefix='inn'
calculation='auger',
density=${DENSITY},
temperature=${TEMP},
nkint(:) = ${KPT1}, ${KPT2}, ${KPT3}, 
scratch_dir='${SCRATCH}'
pre_direct_dir='./pre_direct'
/
&MATERIAL
alat=6.6924,
Vcell=420.0874,
nbnd=26,
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

cp direct.in pre_direct/pre_direct.in
sed -i -e 's/auger/pre_direct/' pre_direct/pre_direct.in

cat > pre_direct/pre_direct << EOF
#!/bin/zsh

~/soft/auger_/bin/efermi_elec.x pre_direct.in > efermi_elec.out
~/soft/auger_/bin/efermi_hole.x pre_direct.in > efermi_hole.out
~/soft/auger_/bin/trim.x pre_direct.in > trim.out
~/soft/auger_/bin/generate_k4_eeh.x pre_direct.in > gen_kgrid_eeh.out
~/soft/auger_/bin/generate_k4_hhe.x pre_direct.in > gen_kgrid_hhe.out
EOF
