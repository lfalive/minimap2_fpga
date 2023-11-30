# gpu-server-5

source_dir="/home/cluster/Storage4/manymap/micro-benchmark/gpu-server-5/"
data_dir="/home/cluster/Storage4/manymap/micro-benchmark/data/"

input_length=(1 2 4 8 10 16 20 32)
case_nums=(163840 65280 24576 6888 4032 1200 648 96)

echo ""
echo "====================================================================="
echo "gpu: GPU version. Variants: single block / multiple blocks with cooperative groups, global memory / shared memory (applicable to small data), score only / complete path"
echo "====================================================================="
echo ""

for i in {0..7}; do
  echo "=========== ${case_nums[$i]} cases, ${input_length[$i]}k ==========="
  for j in {1..3}; do
    echo -n "RUN $j: "
    ${source_dir}gpu_"${input_length[$i]}"k "${case_nums[$i]}" 1 512 ${data_dir}"${input_length[$i]}"k.in
    sleep 5
  done
  echo ""
done
