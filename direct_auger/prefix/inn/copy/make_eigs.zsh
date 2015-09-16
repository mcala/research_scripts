#!/bin/zsh
#
# Adjusts eigenvalues after wannier90 run to be the GW eigenvalues using the 
# gw_eigs.zsh script.
cd k1

OUTDIR=`grep "outdir" nscf.in | awk '{print $3}'`
OUTDIR=${(Q)OUTDIR}

./../gw_eigs.zsh kgrid_elec_full.dat
cp inn.eig ${OUTDIR}

cd -

cd k3

OUTDIR=`grep "outdir" nscf.in | awk '{print $3}'`
OUTDIR=${(Q)OUTDIR}

./../gw_eigs.zsh kgrid_hole_irr_halfholegrid.dat
cp inn.eig ${OUTDIR}

cd -

cd k4

OUTDIR=`grep "outdir" nscf.in | awk '{print $3}'`
OUTDIR=${(Q)OUTDIR}

./../gw_eigs.zsh klist_k4_eeh.dat
cp inn.eig ${OUTDIR}

cd -
