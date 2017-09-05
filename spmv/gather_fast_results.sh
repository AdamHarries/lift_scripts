#!/bin/sh

# kernel local sizes
declare -a l_sizes=(128 64 256 32 512)
# multipliers to get global sizes: global = local * mult[i]
declare -a mult=(8192 4096 2048 1024 512 256 128 64 32)
mf=~/mdatasets/original/
start=$(date +"%d-%m-%y-%H-%M-%S")
resultsf="../results_$start/"

if [ ! -d $resultsf ]; then mkdir $resultsf; fi

for l in ${l_sizes[@]};
do
  echo $l
  for m in ${mult[@]};
  do
  echo "\t$m"
  echo "  $(($l * $m))"
  numThreads=$(($l * $m))
  echo "NumThreads: $numThreads"
  if [ $numThreads -ge 16384 ] && [ $numThreads -le 524288 ]; 
  then
    for f in $(cat $mf/datasets.txt);
    do
      echo "matrix: $f"
      echo "./SparseMatrixDenseVector -p 0 -g $(($l * $m)) -l $l -i 10 -t 100 --load-kernels --all --check --loadOutput --saveOutput .gold/spmv-$f.gold $mf/$f/$f.mtx >> $resultsf$f-results.txt"
      # ./SparseMatrixDenseVector -p 0 -g $(($l * $m)) -l $l -i 10 -t 100 --load-kernels --all --check --loadOutput .gold/spmv-$f.gold $mf/$f/$f.mtx >> $resultsf$f-results.txt
    done
  fi
  done
done
