#!/bin/zsh
#
# Change timing hh:mm:ss to seconds (from stack exchange)
ts_get_sec()
{
  read -r h m s <<< $(echo $1 | tr ':' ' ' )
  echo $(((h*60*60)+(m*60)+s))
}

if [[ -a timing.dat ]]; then
  rm timing.dat
fi

for i in 1 2 4 12 24 48 96; do
  STARTTIME=`grep "starting on" direct_${i}.out | awk '{print $9}'`
  ENDTIME=`grep "ending on" direct_${i}.out | awk '{print $9}'`
  echo $STARTTIME
  echo $ENDTIME
  STARTTIME=`ts_get_sec $STARTTIME`
  ENDTIME=`ts_get_sec $ENDTIME`
  DIFF=$((ENDTIME-$STARTTIME))

  echo $i $DIFF $(($DIFF/60))m $(($DIFF%60))s  >> timing.dat

done
