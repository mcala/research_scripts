#!/bin/zsh
#
# Makes input file for pw2wannier90.in for wave function generation.
if [[ $# -ne 2 ]]; then
  echo "Usage: make_wannier.zsh prefix scratch"
  exit
fi

PREFIX=$1
SCRATCH=$2

cat > ./pw2wannier90.in << EOF
&inputpp
outdir = '${SCRATCH}'
prefix = '${PREFIX}'
seedname = '${PREFIX}'
spin_component = 'none'
write_mmn = .false.
write_amn = .false.
write_unk = .true.
reduce_unk = .true.
/
EOF
