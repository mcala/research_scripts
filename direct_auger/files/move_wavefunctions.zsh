#!/bin/zsh
# script to move and rename the wave function files to the format used in the
# direct auger code (k_WF#/UNK00001.1). Originally just UNK0000#.1.
#
cd ..

PREFIX=`get_prefix ./files/dft_calc`
SCRATCH=`cat SCRATCH`

for j in `find ./ -maxdepth 1 -type d -name "k*"`; do
  cd ${SCRATCH}/${j}

  KPOINTS=`grep "k( " nscf.out | wc -l | awk '{print $1}'`
  KPOINTS=$(($KPOINTS/2))

  for i in `seq 1 $KPOINTS`; do
    mkdir k_$i

    if [ "$i" -lt 10 ]; then
      mv UNK0000$i.1 k_${i}/UNK00001.1
    elif [ "$i" -lt 100 ] && [ "$i" -gt 9 ]; then
      mv UNK000$i.1 k_$i/UNK00001.1
    elif [ "$i" -lt 1000  ] && [ "$i" -gt 99 ]; then
      mv UNK00$i.1 k_$i/UNK00001.1
    elif [ "$i" -lt 10000 ] && [ "$i" -gt 999 ]; then
      mv UNK0$i.1 k_$i/UNK00001.1
    elif [ "$i" -lt 100000 ] && [ "$i" -gt 9999 ]; then
      mv UNK$i.1 k_$i/UNK00001.1
    fi

  done

  cd -

done
