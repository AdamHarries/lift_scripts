#/bin/sh

datasetf=$1
echo "Dataset folder: $datasetf"

comp_scripts=$2
echo "executable folder: $comp_scripts"

platform=$3
echo "Platform: $platform"

# Get some unique data for the experiment ID
now=$(date -Iminutes)
hsh=$(git rev-parse HEAD)
exID="$hsh-$now"

mkdir -p "results-$exID"

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
				$comp_scripts/BFS --experimentId $exID -g $global -l $l -i 5 -t 25 --all --check $datasetf/$f/$f.mtx &>                  results-$exID/result_BFS_$f-$global-$l.txt
				$comp_scripts/SSSP --experimentId $exID -g $global -l $l -i 5 -t 25 --all --check $datasetf/$f/$f.mtx &>                  results-$exID/result_SSSP_$f-$global-$l.txt
				$comp_scripts/PageRank --experimentId $exID -g $global -l $l -i 5 -t 25 --all --check $datasetf/$f/$f.mtx &>                  results-$exID/result_PageRank_$f-$global-$l.txt
			done
		fi
	done
done
