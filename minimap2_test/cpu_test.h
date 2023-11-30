//
// Created by fpga-0 on 9/17/19.
//

#ifndef MINIMAP_TEST_CPU_TEST_H
#define MINIMAP_TEST_CPU_TEST_H
#include "sim_data_in.h"
#ifdef __cplusplus
extern "C"{
#endif

#include <stdint.h>
#include "ksw2.h"



typedef struct{
    int a, b, q, e, q2, e2;
    int sc_ambi;
    int zdrop;
    int end_bonus;
    int bw;

}mm_opt;

void cpu_test();
void sse2_test();

void Test_cpu(int PE_NUM, int data_length, int data_num);
void Test_sse2(int PE_NUM, int data_length, int data_num);

void resultToFile(fpga_data_input data, ksw_extz_t* ez, FILE* file2);
//===================E N D =======================//

#ifdef __cplusplus
}

#endif
#endif //MINIMAP_TEST_CPU_TEST_H
