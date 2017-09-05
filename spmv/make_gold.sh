#!/bin/sh

datasetf=$1
echo "Dataset folder: $datasetf"

spmv=$2
echo "SparseMatrixDenseVector excutable: $spmv"

platform=$3
echo "Platform: $platform"

# mf=~/Development/mdatasets/original/

mkdir -p .gold_results
mkdir -p .gold

# build the kernels first
firstMatrix=$(tail -n 1 $datasetf/datasets.txt)
echo $firstMatrix
$spmv --save-kernels --all -g 32768 -l 128 --platform $platform $datasetf/$firstMatrix/$firstMatrix.mtx

for f in $(cat $datasetf/datasets.txt);
do
    echo "matrix: $f"
  
    echo "$spmv --load-kernels --all -g 32768 -l 128 --check --saveOutput .gold/spmv-$f.gold --platform $platform $datasetf/$f/$f.mtx >> .gold_results/$f-results.txt"
    $spmv --load-kernels --all -g 32768 -l 128 --check --saveOutput .gold/spmv-$f.gold  --platform $platform $datasetf/$f/$f.mtx >> .gold_results/$f-results.txt
done