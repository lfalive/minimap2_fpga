# 730-server-5

source_dir="/home/cluster/Storage4/manymap/micro-benchmark/730-server-5/"
data_dir="/home/cluster/Storage4/manymap/micro-benchmark/data/"

input_length=(1 2 4 8 10 16 20 32)
case_nums=(300000 64000 16000 3200 2000 1000 1000 1000)

echo ""
echo "====================================================================="
echo "ksw_{sse2, sse41, avx2, avx512}: The original kernel in minimap2."
echo "cpu_{sse2, sse41, avx2, avx512}: CPU version of the optimized kernel."
echo "====================================================================="
echo ""

for prog in "ksw_sse2" "ksw_sse41" "ksw_avx2" "cpu_sse2" "cpu_sse41" "cpu_avx2"; do
  for i in {0..7}; do
    echo "=========== ${prog}: ${case_nums[$i]} cases, 40 threads, ${input_length[$i]}k ==========="
    for j in {1..3}; do
      echo -n "RUN $j: "
      ${source_dir}${prog} 40 "${case_nums[$i]}" 0 ${data_dir}"${input_length[$i]}"k.in
      sleep 2
    done
    echo ""
  done
done
