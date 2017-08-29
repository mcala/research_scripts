#!/bin/zsh
# script to move and rename the wave function files to the format used in the
# direct auger code (k_WF#/UNK00001.1). Originally just UNK0000#.1.
#
cd ..

PREFIX=`get_prefix ./files/dft_calc`

for j in `find ./ -maxdepth 1 -type d -name "k*"`; do
  cd ${j}

  KPOINTS=`grep "k( " nscf.out | wc -l | awk '{print $1}'`
  KPOINTSOVER=`grep "k([1-9]" nscf.out | wc -l | awk '{print $1}'`
  KPOINTSTOTAL=$(( (KPOINTS + KPOINTSOVER)/2 ))

  for i in `seq 1 $KPOINTSTOTAL`; do

    if [[ (! -d k_$i) ]]; then
      mkdir k_$i
    fi

    if [ "$i" -lt 10 ]; then
      if [[ -a UNK0000$i.1 ]]; then
        mv UNK0000$i.1 k_${i}/UNK00001.1
      fi
    elif [ "$i" -lt 100 ] && [ "$i" -gt 9 ]; then
      if [[ -a UNK000$i.1 ]]; then
        mv UNK000$i.1 k_${i}/UNK00001.1
      fi
    elif [ "$i" -lt 1000  ] && [ "$i" -gt 99 ]; then
      if [[ -a UNK00$i.1 ]]; then
        mv UNK00$i.1 k_${i}/UNK00001.1
      fi
    elif [ "$i" -lt 10000 ] && [ "$i" -gt 999 ]; then
      if [[ -a UNK0$i.1 ]]; then
        mv UNK0$i.1 k_${i}/UNK00001.1
      fi
    elif [ "$i" -lt 100000 ] && [ "$i" -gt 9999 ]; then
      if [[ -a UNK$i.1 ]]; then
        mv UNK$i.1 k_${i}/UNK00001.1
      fi
    fi

  done

  cd -

done
