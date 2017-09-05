#!/bin/sh

mf=/disk/scratch/s1467120/spmvexecutor/matrices/
for f in $(ls $mf); 
do
	echo "Matrix: $f"
	./SparseMatrixDenseVector -p 0 -g 128 -l 32 --all --check $mf/$f/$f.mtx	
done
