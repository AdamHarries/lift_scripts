#/bin/sh

datasetf=$1
echo "Dataset folder: $datasetf"

spmv=$2
echo "SparseMatrixDenseVector excutable: $spmv"

platform=$3
echo "Platform: $platform"

# Get some unique data for the experiment ID
now=$(date -Iminutes)
hsh=$(git rev-parse HEAD)
exID="$hsh-$now"

mkdir -p .gold_results
mkdir -p .gold
mkdir -p "results-$exID"

# build the kernels first
firstMatrix=$(tail -n 1 $datasetf/datasets.txt)
echo $firstMatrix
$spmv --save-kernels --all -g 32768 -l 128 --platform $platform $datasetf/$firstMatrix/$firstMatrix.mtx

# Make gold output for each dataset
for f in $(cat $datasetf/datasets.txt);
do
    echo "matrix: $f"
  
    echo "$spmv --load-kernels -g 32768 -l 128 -i 1 --check --saveOutput .gold/spmv-$f.gold --platform $platform $datasetf/$f/$f.mtx >> .gold_results/$f-results.txt"
    $spmv --load-kernels -g 32768 -l 128 -i 1 --check --saveOutput .gold/spmv-$f.gold  --platform $platform $datasetf/$f/$f.mtx >> .gold_results/$f-results.txt
done

# Run some actual experiments with the stuff we've just prepared
# Declare a range of local sizes to try
declare -a l_sizes=(128 64 256 32 512 16 8)
# declare some multipliers to get global sizes
declare -a mult=(8192 4096 2048 1024 512 256 128 64 32)

for l in ${l_sizes[@]};
do
	echo "Local: $l"
	for m in ${mult[@]}; 
	do
		echo "\t Mult: $m"
		echo "\t $(($l * $m))"
		global=$(($l * $m))
		echo "Global: $global"
		if [ $global -ge 16384 ] && [ $global -le 524288 ];
		then
			for f in $(cat $datasetf/datasets.txt);
			do
				echo "matrix: $f"
				echo "global: $global"
				echo "local: $local"
				echo "Resultfile: result_$f-$global-$l.txt"
				$spmv --experimentId $exID --load-kernels --loadOutput .gold/spmv-$f.gold -g $global -l $l -i 20 -t 25 --all --check $datasetf/$f/$f.mtx &>                  results-$exID/result_$f-$global-$l.txt
			done
		fi
	done
done
