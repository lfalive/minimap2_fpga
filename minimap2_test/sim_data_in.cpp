//
// Created by fpga-0 on 20-11-20.
//

#include "sim_data_in.h"
#include <stdlib.h>

char seq_nt4_table[256] = {
        0, 1, 2, 3,  4, 4, 4, 4,  4, 4, 4, 4,  4, 4, 4, 4,
        4, 4, 4, 4,  4, 4, 4, 4,  4, 4, 4, 4,  4, 4, 4, 4,
        4, 4, 4, 4,  4, 4, 4, 4,  4, 4, 4, 4,  4, 4, 4, 4,
        4, 4, 4, 4,  4, 4, 4, 4,  4, 4, 4, 4,  4, 4, 4, 4,
        4, 0, 4, 1,  4, 4, 4, 2,  4, 4, 4, 4,  4, 4, 4, 4,
        4, 4, 4, 4,  3, 4, 4, 4,  4, 4, 4, 4,  4, 4, 4, 4,
        4, 0, 4, 1,  4, 4, 4, 2,  4, 4, 4, 4,  4, 4, 4, 4,
        4, 4, 4, 4,  3, 4, 4, 4,  4, 4, 4, 4,  4, 4, 4, 4,
        4, 4, 4, 4,  4, 4, 4, 4,  4, 4, 4, 4,  4, 4, 4, 4,
        4, 4, 4, 4,  4, 4, 4, 4,  4, 4, 4, 4,  4, 4, 4, 4,
        4, 4, 4, 4,  4, 4, 4, 4,  4, 4, 4, 4,  4, 4, 4, 4,
        4, 4, 4, 4,  4, 4, 4, 4,  4, 4, 4, 4,  4, 4, 4, 4,
        4, 4, 4, 4,  4, 4, 4, 4,  4, 4, 4, 4,  4, 4, 4, 4,
        4, 4, 4, 4,  4, 4, 4, 4,  4, 4, 4, 4,  4, 4, 4, 4,
        4, 4, 4, 4,  4, 4, 4, 4,  4, 4, 4, 4,  4, 4, 4, 4,
        4, 4, 4, 4,  4, 4, 4, 4,  4, 4, 4, 4,  4, 4, 4, 4
};

void sim_data(){

    fpga_data_input* data;
    data = (fpga_data_input*)malloc(1*sizeof(fpga_data_input));

    ByteBuffer Buffer(PACKAGE_SIZE);
    Buffer.putLong(0);
    Buffer.putLong(0);

    int data_num = 2;

    for (int i=0; i<data_num; ++i){

        GenerateData(data, i);

        DataToBuffer(data, Buffer);
    }

    free(data);

    BufferTofile(Buffer, data_num);
}


# define LEN_CONST  5;


void GenerateData(fpga_data_input* data, int id_tmp ){

    int PE_NUM = 8;

    data->id.reg_id = id_tmp;
    data->id.seg_id = id_tmp;
    data->task_id = id_tmp;

    char ATCG[4] = {'0', '1', '2', '3'};

    /******************LEFT DATA*****************/
    //int len = (rand()%PE_NUM)*(id_tmp+1);
    int len = LEN_CONST;
   // if (len == 0) len = 1;
    data->sw_cal[0].qs = (char*)malloc(len * sizeof(char));
    for (int i=0; i<len; ++i) {
        data->sw_cal[0].qs[i] = ATCG[rand()%4];
    }

    data->sw_cal[0].q_len = len;
    data->sw_cal[0].r_len = len;
    data->sw_cal[0].rs = (char*)malloc(len * sizeof(char));
    for (int i=0; i<len; ++i) {
        data->sw_cal[0].rs[i] = data->sw_cal[0].qs[i];
    }
    data->sw_cal[0].score_init = 0;
    data->length = 12 + 8 + ((data->sw_cal[0].q_len -1)/8 + 1)*4+((data->sw_cal[0].r_len -1)/8 + 1)*4;

    /******************Right data*****************/
    /*len = (rand()%8)*(id_tmp+1);
    if (len == 0) len = 1;*/
    data->sw_cal[1].qs = (char*)malloc(len * sizeof(char));
    for (int i=0; i<len; ++i) {
        data->sw_cal[1].qs[i] = ATCG[rand()%4];
    }

    data->sw_cal[1].q_len = len;
    data->sw_cal[1].r_len = len;
    data->sw_cal[1].rs = (char*)malloc(len * sizeof(char));
    for (int i=0; i<len; ++i) {
        data->sw_cal[1].rs[i] = data->sw_cal[1].qs[i];
    }
    data->sw_cal[1].score_init = 0;
    data->length = data->length + 8+((data->sw_cal[1].q_len -1)/8 +1)*4+((data->sw_cal[1].r_len -1)/8 + 1)*4;

}

void DataToBuffer(fpga_data_input* Data, ByteBuffer &buffer){
    int i = 0;
    buffer.putLong(0);//second 128bit save the length of next cal unit, its unit is 128bit but the length is 8bit
    int num_zero = ((Data->length) % 16) ? 16 - (Data->length) % 16 : 0;
    buffer.putInt(0);
    buffer.putInt_Little((Data->length -1)/16 + 1);

    buffer.putLong_Little(Data->task_id);//use 8byte to save id, taskID need to be recycled
    buffer.put(Data->id.seg_id);// use 1byte
    buffer.put(Data->id.reg_id); // use 1 byte

    buffer.putShort_Little(0); // total is 12byte fill the zero is to fit the FPGA

    buffer.putShort_Little(Data->sw_cal[0].q_len);//use 2+2Byte sve read_len r_len
    buffer.putShort_Little(Data->sw_cal[0].r_len);

    buffer.putInt_Little(Data->sw_cal[0].score_init); //use 4byte save socre_init

    char *rs = Data->sw_cal[0].rs;
    char *qs = Data->sw_cal[0].qs;
    int r_len = Data->sw_cal[0].r_len;
    int q_len = Data->sw_cal[0].q_len;
    int len_left = 0;

    if (q_len != 0) {
        for (i = 0; i < ((q_len - 1) / 8) + 1; i++) {//4bit save one bp,save qs
            len_left = q_len - 8 * i;
            int q_query = 0;
            int j = 0;
            if (len_left <= 8) {
                for (j = 0; j < len_left; j++) {
                    int shift = 28 - 4 * j;
                    q_query = q_query | (qs[i*8+j] << shift);
                }
                buffer.putInt_Little(q_query);
            } else {
                for (j = 0; j < 8; j++) {
                    int shift = 28 - 4 * j;
                    q_query = q_query | (qs[i*8+j] << shift);
                }
                buffer.putInt_Little(q_query);
            }
        }
        for (i = 0; i < ((r_len - 1) / 8) + 1; i++) {//4bit save one bp save rs
            len_left = r_len - 8 * i;
            int q_query = 0;
            int j = 0;
            if (len_left <= 8) {
                for (j = 0; j < len_left; j++) {
                    int shift = 28 - 4 * j;
                    q_query = q_query | (rs[i*8+j] << shift);
                }
                buffer.putInt_Little(q_query);
            } else {
                for (j = 0; j < 8; j++) {
                    int shift = 28 - 4 * j;
                    q_query = q_query | (rs[i*8+j] << shift);
                }
                buffer.putInt_Little(q_query); //todo maybe wrong
            }
        }
    }

    buffer.putShort_Little(Data->sw_cal[1].q_len);//use 2+2Byte sve q_len r_len
    buffer.putShort_Little(Data->sw_cal[1].r_len);

    buffer.putInt_Little(Data->sw_cal[1].score_init); //use 4byte save socre_init

    rs = Data->sw_cal[1].rs;
    qs = Data->sw_cal[1].qs;
    r_len = Data->sw_cal[1].r_len;
    q_len = Data->sw_cal[1].q_len;
    if (q_len != 0){
        for(i=0; i< ((q_len-1)/8) +1; i++)  {//4bit save one bp,save qs
            len_left = q_len - 8*i;
            int q_query = 0;
            int j=0;
            if (len_left <= 8){
                for (j=0; j<len_left; j++){
                    int shift = 28 - 4*j;
                    q_query = q_query | (qs[i*8+j] << shift);
                }
                buffer.putInt_Little(q_query);
            }
            else{
                for (j=0; j<8; j++){
                    int shift = 28 - 4*j;
                    q_query = q_query | (qs[i*8+j] << shift);
                }
                buffer.putInt_Little(q_query);
            }
        }

        for(i=0; i< ((r_len-1)/8) +1; i++)  {//4bit save one bp save rs
            len_left = r_len - 8*i;
            int q_query = 0;
            int j=0;
            if (len_left <= 8){
                for (j=0; j<len_left; j++){
                    int shift = 28 - 4*j;
                    q_query = q_query | (rs[i*8+j] << shift);
                }
                buffer.putInt_Little(q_query);
            }
            else{
                for (j=0; j<8; j++){
                    int shift = 28 - 4*j;
                    q_query = q_query | (rs[i*8+j] << shift);
                }
                buffer.putInt_Little(q_query);
            }
        }

    }
    for (i=0; i<num_zero; i++) buffer.putChar(0);

    free(Data->sw_cal[0].qs);
    free(Data->sw_cal[0].rs);
    free(Data->sw_cal[1].qs);
    free(Data->sw_cal[1].rs);

}

void BufferTofile(ByteBuffer SendBuffer, int cal_num){

    uint8_t * temp = (uint8_t *)malloc(PACKAGE_SIZE*sizeof(char));
    memset(temp,0, PACKAGE_SIZE);
    SendBuffer.getBytes(temp,SendBuffer.size());
    for (int i=0 ; i<16; i++){ //save the number of cal unit to the SendBuffer
        if (i<12) temp[i] = 0;
        else{
            temp[i] = cal_num >> (8*(15-i));
        }
    }
    FILE * file;
    file = fopen("../../Output/fpga_input_test_8.txt","w+");
    for (int i=0; i<PACKAGE_SIZE; i++){
        putc(temp[i], file);
    }
    fclose(file);
    free(temp);
}