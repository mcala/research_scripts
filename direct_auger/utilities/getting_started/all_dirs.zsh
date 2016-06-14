#!/bin/zsh
#
#

# PRUNE ONE DIRS
#for i in `find . -maxdepth 1 -type d -name "300.1E14" -o -name "300.*" -print`; do

#PRUNE MULTIPLE DIRS
#for i in `find . -maxdepth 1 -type d -name "300.1E16" -o -name "300.1E17" -prune -o -name "300.1E18" -o -name "300.*" -print`; do
#
# ALL DIRS
for i in `find . -maxdepth 1 -type d -name "300.*" -print`; do
  cd $i
  pwd
  ~/scripts/direct_auger/utilities/after_direct.zsh ${i}_no_screening
  cp -r ${i}_no_screening ~/@action/${i}
  cd ../
done
