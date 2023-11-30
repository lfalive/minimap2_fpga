//
// Created by fpga-0 on 9/17/19.
//

#ifndef MINIMAP_TEST_FPGA_TEST_H
#define MINIMAP_TEST_FPGA_TEST_H

#include <stdint.h>
#include <zconf.h>
typedef struct {
    int16_t max;
    int8_t max_q;
    int16_t max_t;

    int16_t mqe, mqe_t;

    int16_t mte;
    int8_t mte_q;

    int16_t score;
    uint8_t **bt;
}fpga_score;

typedef struct {
    int16_t max;
    int8_t max_q;
    int16_t max_t;

    int16_t mqe, mqe_t;

    int16_t mte;
    int8_t mte_q;

    int16_t score;
    uint32_t *cigar;
    int32_t n_cigar;
}fpga_cigar;


typedef struct{
    int64_t task_id;
    int8_t seg_id;
    int8_t reg_id;
    int8_t flag[2];//用于表示是否做了拓展，如果有拓展则为1,如果没有则为0,flag[0]表示左边，flag[1]表示右边
    fpga_score result[2];// 0 is the left result ,1 is the right
}fpga_sw_output;


typedef struct{
    int64_t task_id;
    int8_t seg_id;
    int8_t reg_id;
    int8_t flag[2];//用于表示是否做了拓展，如果有拓展则为1,如果没有则为0,flag[0]表示左边，flag[1]表示右边
    fpga_cigar result[2];// 0 is the left result ,1 is the right
}fpga_cigar_output;

void fpga_test();

void resultToFile(Byte *buff);

void buffToBt(int* q_len, int* t_len, uint8_t **L_bt, uint8_t  **R_bt, Byte *buff);
void buffToStruct(Byte *GetBuffer);

/*************CIGAR**********************/
void cigarToFile(fpga_cigar_output *fpgaoutput);
void cigarToStruct(Byte *GetBuffer);
void cigar_test();
/***************END**********************/

#endif //MINIMAP_TEST_FPGA_TEST_H
