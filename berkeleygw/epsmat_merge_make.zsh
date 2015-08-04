#!/bin/zsh
#
# module load python h5py
#

if [[ -z $1 ]]; then
	echo "Usage: epsmat_merge_make.zsh (number of unshifted q points)"
	exit
fi

QPOINTS=$1

cat > epsmat_merge.zsh << EOF
#!/bin/zsh
#
ln -sf 1_qpt/eps0mat.h5 ./

~/soft/berkeleygw_6442/bin/epsmat_hdf5_merge.py \
EOF

for i in `seq 2 $(($QPOINTS+1))`; do

  if [[ ${i} -ne $(($QPOINTS+1)) ]]; then
		cat >> epsmat_merge.zsh <<- EOF
			${i}_qpt/epsmat.h5 \
		EOF

		else
		cat >> epsmat_merge.zsh <<- EOF
			${i}_qpt/epsmat.h5 
		EOF
	fi

done

cat >. epsmat_merge.zsh << EOF
cp epsmat_merge.h5 epsmat.h5
EOF

chmod +x epsmat_merge.zsh
