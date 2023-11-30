# obsolete
CC=g++
NVCC=nvcc -ccbin g++
ICC=icpc

all: 730-server-5/ksw_sse2 730-server-5/ksw_sse41 730-server-5/ksw_avx2 ksw_avx512 sse2 sse41 avx2 avx512

ksw_sse2:
	$(CC) -O3 -msse2 -lpthread -o ksw_sse2 util.cc mm2.cc micro.cc

ksw_sse41:
	$(CC) -O3 -msse4.1 -lpthread -o ksw_sse41 util.cc mm2.cc micro.cc

ksw_avx2:
	$(CC) -O3 -mavx2 -lpthread -o ksw_avx2 util.cc mm2.cc micro.cc

ksw_avx512:
	$(CC) -O3 -mavx512bw -lpthread -o ksw_avx512 util.cc mm2.cc micro.cc

sse2:
	$(CC) -O3 -msse2 -lpthread -o cpu_sse2 util.cc simple.cc micro.cc

sse41:
	$(CC) -O3 -msse4.1 -lpthread -o cpu_sse41 util.cc simple.cc micro.cc

avx2:
	$(CC) -O3 -mavx2 -lpthread -o cpu_avx2 util.cc simple.cc micro.cc

avx512:
	$(CC) -O3 -mavx512bw -lpthread -o cpu_avx512 util.cc simple.cc micro.cc

# RTX 3090: sm_72; RTX 1080 Ti: sm_61
gpu:
	#$(NVCC) -g -G -arch=sm_61 -Xptxas="-v" -Xptxas -dlcm=ca -o gpu util.cc cigar_glb.cu
	$(NVCC) -O3 -arch=sm_61 -Xptxas="-v" -Xptxas -dlcm=ca -o gpu_1k util.cc cigar_glb.cu

knl:
	$(ICC) -O3 -march=knl -lpthread -o knl micro.cc

clean:
	rm ksw_* cpu_* knl gpu