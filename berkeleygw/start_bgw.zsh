#!/bin/zsh
#
#
if [[ -a SCRATCH ]]; then
  SCRATCH=`cat SCRATCH`
else
  echo "Scratch directory?"
  read SCRATCH
fi

echo "Prefix?"
read SYSTEM 
echo "Make sure to fix pseudo potentials in script!"
echo "Make sure to fix number of bands in script!"
echo ${SCRATCH} > SCRATCH

# Make actual folders in both working directory and in the scratch directory.
# Also copy over the required k point lists.
mkdir 02-wfn ${SCRATCH}/02-wfn ${SCRATCH}/02-wfn/${SYSTEM}.save
  cp 00-kgrid/WFN.out 02-wfn
  ln -sf ../01-scf/cs_semi.cpi.upf ./02-wfn
  ln -sf ../01-scf/i.cpi.upf ./02-wfn
  ln -sf ../../01-scf/${SYSTEM}.save/charge-density.dat ${SCRATCH}/02-wfn/${SYSTEM}.save
  cp ${SCRATCH}/01-scf/${SYSTEM}.save/data-file.xml ${SCRATCH}/02-wfn/${SYSTEM}.save

mkdir 03-wfnq ${SCRATCH}/03-wfnq ${SCRATCH}/03-wfnq/${SYSTEM}.save
  cp 00-kgrid/WFNq.out 03-wfnq
  ln -sf ../01-scf/cs_semi.cpi.upf ./03-wfnq
  ln -sf ../01-scf/i.cpi.upf ./03-wfnq
  ln -sf ../../01-scf/${SYSTEM}.save/charge-density.dat ${SCRATCH}/03-wfnq/${SYSTEM}.save
  cp ${SCRATCH}/01-scf/${SYSTEM}.save/data-file.xml ${SCRATCH}/03-wfnq/${SYSTEM}.save

mkdir 04-wfnco ${SCRATCH}/04-wfnco ${SCRATCH}/04-wfnco/${SYSTEM}.save
  cp 00-kgrid/WFNco.out 04-wfnco
  ln -sf ../01-scf/cs_semi.cpi.upf ./04-wfnco
  ln -sf ../01-scf/i.cpi.upf ./04-wfnco
  ln -sf ../../01-scf/${SYSTEM}.save/charge-density.dat ${SCRATCH}/04-wfnco/${SYSTEM}.save
  cp ${SCRATCH}/01-scf/${SYSTEM}.save/data-file.xml ${SCRATCH}/04-wfnco/${SYSTEM}.save

cd 02-wfn
./../make_qe_inp.zsh ${SCRATCH}/02-wfn WFN.out 350
cd -

cd 03-wfnq
./../make_qe_inp.zsh ${SCRATCH}/03-wfnq WFNq.out 8
cd -

cd 04-wfnco
./../make_qe_inp.zsh ${SCRATCH}/04-wfnco WFNco.out 350
cd -
