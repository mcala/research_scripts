#!/bin/zsh
#
#
# 

#for i in 3076 1536; do
#  PROCS=$i
#  aprun -n $PROCS ~/soft/auger_topic/bin/direct_auger_eeh.x direct.in > direct_$PROCS.out
#  ~/scripts/direct_auger/utilities/after_direct run_${PROCS}_old_par
#done

for i in 12 4 2; do
  PROCS=$i
  rm combos.dat
  rm combinations.dat

  sed -i -e 's/direct_first_run=.false./direct_first_run=.true./g' direct.in
  aprun -n 1 ~/soft/auger_dev/bin/direct_auger_eeh.x direct.in > direct_serial.out

  wc -l combinations.dat | awk '{print $1}' > combos.dat
  cat combinations.dat >> combos.dat
  mv combos.dat combinations.dat

  sed -i -e 's/direct_first_run=.true./direct_first_run=.false./g' direct.in
  aprun -n $PROCS ~/soft/auger_dev/bin/direct_auger_eeh.x direct.in > direct_$PROCS.out
  ~/scripts/direct_auger/utilities/after_direct run_${PROCS}_imp_par
done
