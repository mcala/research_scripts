#!/bin/zsh
# script to move and rename the wave function files to the format used in the
# direct auger code (k_WF#/UNK00001.1). Originally just UNK0000#.1.
#
cd ..

PREFIX=`get_prefix ./files/dft_calc`
SCRATCH=`cat SCRATCH`

for j in 1 3 4; do
  cd k$j

  KPOINTS=`grep "k( " nscf.out | wc -l | awk '{print $1}'`
  KPOINTS=$(($KPOINTS/2))

  OUTDIR=`grep "outdir" nscf.in | awk '{print $3}'`
  OUTDIR=${(Q)OUTDIR}

  cp ${PREFIX}.eig ${OUTDIR}

  for i in `seq 1 $KPOINTS`; do
    mkdir ${OUTDIR}/k_$i

    if [ "$i" -lt 10 ]; then
      mv UNK0000$i.1 ${OUTDIR}/k_${i}/UNK00001.1
    elif [ "$i" -lt 100 ] && [ "$i" -gt 9 ]; then
      mv UNK000$i.1 ${OUTDIR}/k_$i/UNK00001.1
    elif [ "$i" -lt 1000  ] && [ "$i" -gt 99 ]; then
      mv UNK00$i.1 ${OUTDIR}/k_$i/UNK00001.1
    elif [ "$i" -lt 10000 ] && [ "$i" -gt 999 ]; then
      mv UNK0$i.1 ${OUTDIR}/k_$i/UNK00001.1
    elif [ "$i" -lt 100000 ] && [ "$i" -gt 9999 ]; then
      mv UNK$i.1 ${OUTDIR}/k_$i/UNK00001.1
    fi

  done

  cd -

done

echo "Copying k1 to k2 directory.."
cp -r k1 k2 &
cp -r ${SCRATCH}/k1 ${SCRATCH}/k2 &


