#!/bin/zsh
#
# Makes the direct.in, pre_direct.in and pre_direct scripts for a direct
# auger run
if [[ $# -ne 6 ]]; then
  echo "Usage: make_auger.zsh density temperature kpt1 kpt2 kpt 3 scratch"
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
prefix=
calculation='auger',
density=${DENSITY},
temperature=${TEMP},
nkint(:) = ${KPT1}, ${KPT2}, ${KPT3}, 
scratch_dir='${SCRATCH}'
/
&MATERIAL
alat=
Vcell=
nbnd=
ivbm=
icbm=
vbmdeg=
valence_electrons=
nphonon=
epsilon_infty=
a(:,1) = 
a(:,2) = 
a(:,3) = 
b(:,1) = 
b(:,2) = 
b(:,3) = 
/
&PRE_DIRECT
halfholegrid = 
density_conv_thr = 
/
&WANNIER
nwan=
nwanband=
nkwan1=
nkwan2=
nkwan3=
/
&AUGER
ngap=
Egap_min= 
Egap_step= 
screening_model=
direct_first_run=
/
EOF

cp direct.in pre_direct/pre_direct.in

cat > pre_direct/pre_direct << EOF
#!/bin/zsh

~/soft/auger_/bin/efermi_elec.x pre_direct.in > efermi_elec.out
~/soft/auger_/bin/efermi_hole.x pre_direct.in > efermi_hole.out
~/soft/auger_/bin/trim.x pre_direct.in > trim.out
~/soft/auger_/bin/generate_k4.x pre_direct.in > gen_kgrid.out
EOF
