#!/bin/zsh
#
#
PREFIX=`get_prefix ../../scf_calculation`
cd k_hole

OUTDIR=`grep "outdir" nscf.in | awk '{print $3}'`
OUTDIR=${(Q)OUTDIR}

./../gw_eigs.zsh kgrid_hole_full.dat
cp ${PREFIX}.eig ${OUTDIR}

cd -

cd k_irr

OUTDIR=`grep "outdir" nscf.in | awk '{print $3}'`
OUTDIR=${(Q)OUTDIR}

./../gw_eigs.zsh kgrid_hole_irr_halfholegrid.dat
cp ${PREFIX}.eig ${OUTDIR}

cd -

cd k_elec
OUTDIR=`grep "outdir" nscf.in | awk '{print $3}'`
OUTDIR=${(Q)OUTDIR}

./../gw_eigs.zsh kgrid_elec_full.dat
cp ${PREFIX}.eig ${OUTDIR}
cd -

cd k4_hhe

OUTDIR=`grep "outdir" nscf.in | awk '{print $3}'`
OUTDIR=${(Q)OUTDIR}

./../gw_eigs.zsh klist_k4_hhe.dat
cp ${PREFIX}.eig ${OUTDIR}

cd -

cd k4_eeh

OUTDIR=`grep "outdir" nscf.in | awk '{print $3}'`
OUTDIR=${(Q)OUTDIR}

./../gw_eigs.zsh klist_k4_eeh.dat
cp ${PREFIX}.eig ${OUTDIR}

cd -
