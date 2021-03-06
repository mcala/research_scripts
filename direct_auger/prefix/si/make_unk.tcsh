#!/bin/tcsh
alias calc 'awk "BEGIN{ print \!* }" '

set prefix=$1

cat > ${prefix}.nnkp <<EOF
calc_only_A  :
begin real_lattice
  -2.7366572   0.0000000   2.7366572
   0.0000000   2.7366572   2.7366572
  -2.7366572   2.7366572   0.0000000
end real_lattice

begin recip_lattice
  -1.1479672  -1.1479672   1.1479672
   1.1479672   1.1479672   1.1479672
  -1.1479672   1.1479672  -1.1479672
end recip_lattice
begin kpoints
EOF

  set NQNSCF = `grep "k( " nscf.out | wc -l`
  set NQNSCF = `calc $NQNSCF[1]/2`
#   set NQNSCF = 2

   echo $NQNSCF >> ${prefix}.nnkp
   grep "k( " nscf.out | tail -$NQNSCF | awk '{ print $5,$6,substr($7,1,9)}'   >> ${prefix}.nnkp
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
while ( $J < $NQNSCF )
   set J = `calc $J + 1`
   echo $J $J " 0 0 0 " >> ${prefix}.nnkp
end
cat >> ${prefix}.nnkp <<EOF
end nnkpts

begin exclude_bands
  0
end exclude_bands
EOF
