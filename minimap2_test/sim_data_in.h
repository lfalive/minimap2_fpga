//
// Created by fpga-0 on 20-11-20.
//

#ifndef MINIMAP_TEST_SIM_DATA_IN_H
#define MINIMAP_TEST_SIM_DATA_IN_H

//#include <stdint.h>
#include "ByteBuffer.hpp"

#define PACKAGE_SIZE 1*128*1024 //sizeof(char)

typedef bb::ByteBuffer ByteBuffer;

//==================FPGA_INPUT==================//
typedef struct {
    int q_len;
    int r_len;
    char *qs;
    char *rs;
    int score_init;
}sw_cal_struct;

typedef struct{
    uint8_t seg_id;
    uint8_t reg_id;
}id_struct;

typedef struct{
    int64_t task_id; //low 32bit: read id high32bit: chunk id
    id_struct id;
    sw_cal_struct sw_cal[2];
    int length;
}fpga_data_input;

void sim_data();
void GenerateData(fpga_data_input* data, int id_tmp );
void DataToBuffer(fpga_data_input* Data, ByteBuffer &buffer);
void BufferTofile(ByteBuffer SendBuffer, int cal_num);

#endif //MINIMAP_TEST_SIM_DATA_IN_H
