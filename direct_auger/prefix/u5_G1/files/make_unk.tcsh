#!/bin/tcsh
alias calc 'awk "BEGIN{ print \!* }" '

set prefix=$1

cat > ${prefix}.nnkp <<EOF
calc_only_A  :
begin real_lattice
   3.112000012   0.000000000   0.000000000
  -1.556000006   2.69507106697 0.000000000
   0.000000000   0.000000000   24.5621042787
end real_lattice
begin recip_lattice
  2.01901840682  1.16568027718  0.000000000
  0.000000000    2.33136257337  0.000000000
  0.000000000    0.000000000    0.25580761312
end recip_lattice
begin kpoints
EOF

  set NQNSCF = `grep "k( " nscf.out | wc -l`
  set NQNSCF_over = `grep "k(1" nscf.out | wc -l`
  set NQNSCF_total = `calc ($NQNSCF[1]+$NQNSCF_over[1])/2`
  set NQNSCF = `calc $NQNSCF[1]/2`
  set NQNSCF_over = `calc $NQNSCF_over[1]/2`
#   set NQNSCF = 2

   echo $NQNSCF_total >> ${prefix}.nnkp
   grep "k( " nscf.out | tail -$NQNSCF | awk '{ print $5,$6,substr($7,1,9)}'   >> ${prefix}.nnkp
   grep "k(1" nscf.out | tail -$NQNSCF_over | awk '{ print $4,$5,substr($6,1,9)}'   >> ${prefix}.nnkp
 #  echo 0.0 0.0 0.0 >> ${prefix}.nnkp
 #  echo $Q1 $Q2 $Q3 >> ${prefix}.nnkp

cat >> ${prefix}.nnkp <<EOF
end kpoints

begin projections
   0
end projections

begin nnkpts
   1
EOF

set J = 0
while ( $J < $NQNSCF_total )
   set J = `calc $J + 1`
   echo $J $J " 0 0 0 " >> ${prefix}.nnkp
end
cat >> ${prefix}.nnkp <<EOF
end nnkpts

begin exclude_bands
  0
end exclude_bands
EOF
