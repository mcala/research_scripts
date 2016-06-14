#!/bin/zsh

function reset {
  if ls -l | grep -q "k4_eeh" && ls -l | grep -q "k4_hhe"; then
    echo "No need to reset."
  fi

  if ls -l | grep -q "k4_eeh"; then
    mv k1 k_hole
    mv k2 k_irr
    mv k3 k_elec
    mv k4 k4_hhe
  elif ls -l | grep -q "k4_hhe"; then
    mv k1 k_elec
    mv k3 k_irr
    mv k4 k4_eeh
    rm -r k2
  else
    echo "ERROR."
    exit
  fi
}

RUN=$1

if [[ $# -ne 1 ]]; then
  echo "Must specify run type."
  echo "eeh, hhe or reset"
  exit
fi

echo "RUNTYPE: " $RUN

if [[ $RUN == "eeh" ]]; then

  if [[ -d k1 ]]; then
    reset
  fi
  mv k_elec k1
  mv k_irr k3
  mv k4_eeh k4
  cp -r k1 k2
fi

if [[ $RUN == "hhe" ]]; then

  if [[ -d k1 ]]; then
    reset
  fi

  mv k_hole k1
  mv k_irr k2
  mv k_elec k3
  mv k4_hhe k4
fi

if [[ $RUN == "reset" ]]; then
  reset
fi
