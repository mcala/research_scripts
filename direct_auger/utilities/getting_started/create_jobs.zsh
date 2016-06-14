#!/bin/zsh
#

start_dir=`pwd`

for i in 20; do

  for j in 1;  do

    run_name=300.${j}E${i}
    rm -rf $run_name
    mkdir $run_name
    cd $run_name

    ../../scripts/make_direct.zsh inn 300 ${j}E${i} 64 64 32

    cd files/pre_direct
    ./pre_direct

    cd ../
#    ./make_nscf.zsh

    cd ${start_dir}

  done

done

