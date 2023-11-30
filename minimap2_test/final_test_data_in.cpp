//
// Created by fpga-0 on 20-12-22.
//


//
// Created by fpga-0 on 20-11-20.
//

#include "sim_data_in.h"
#include "final_test_data_in.h"
#include <stdlib.h>

void test_data_in(){

   // int data_length[8] = {5,8,12,20,30,50,80,100};
    int data_length[14] = {5,8,12,20,30,50,80,100,200,400,800,1000,1500,2000};
    int data_num[5] = {1,10,100,1000,10000};
    int PE_num = 8;
    

    for (int a=0; a<14; ++a){ //data_length

        for (int b=0; b<1; ++b){ //data_num
            
            fpga_data_input* data;
            data = (fpga_data_input*)malloc(1*sizeof(fpga_data_input));
        
            ByteBuffer Buffer(PACKAGE_SIZE);
            Buffer.putLong(0);
            Buffer.putLong(0);

            for (int i=0; i<data_num[b]; ++i){
        
                TestGenerateData(data, i, data_length[a]);
                int length = data->length;
                int num_zero = ((data->length) % 16) ? 16 - (data->length) % 16 : 0;

                if (Buffer.size()+length +num_zero <PACKAGE_SIZE){ // < PACKAGE_SIZE

                    TestDataToBuffer(data, Buffer);
                }
                else{
                    printf("data_length = %d, data_num=%d, exit at data[%d]\n", data_length[a], data_num[b], i );
                    break;
                }
                
            }
        
            free(data);
        
            TestTofile(Buffer, data_length[a], data_num[b], PE_num);
        }
    }
}



void TestGenerateData(fpga_data_input* data, int id_tmp, int data_length ){


    data->id.reg_id = id_tmp;
    data->id.seg_id = id_tmp;
    data->task_id = id_tmp;

    char ATCG[4] = {'0', '1', '2', '3'};

    /******************LEFT DATA*****************/

    int len = data_length;

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

void TestDataToBuffer(fpga_data_input* Data, ByteBuffer &buffer){
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

void TestTofile(ByteBuffer SendBuffer, int data_length, int data_num, int PE_NUM){


    uint8_t * temp = (uint8_t *)malloc(PACKAGE_SIZE*sizeof(char));
    memset(temp,0, PACKAGE_SIZE);
    SendBuffer.getBytes(temp,SendBuffer.size());
    for (int i=0 ; i<16; i++){ //save the number of cal unit to the SendBuffer
        if (i<12) temp[i] = 0;
        else{
            temp[i] = data_num >> (8*(15-i));
        }
    }
    

    char file_name[120];
    char PE_num[5];
    char length[5];
    char num[5];
    sprintf(PE_num, "%d", PE_NUM);
    sprintf(length, "%d", data_length);
    sprintf(num, "%d", data_num);

    strcpy(file_name, "../../TestOutput/fpga_input_test_");
    strcat(file_name, PE_num);
    strcat(file_name, "_");
    strcat(file_name, length);
    strcat(file_name, "bp_");
    strcat(file_name, num);
    strcat(file_name, ".txt");
    FILE * file;
    file = fopen(file_name,"w+");
    for (int i=0; i<PACKAGE_SIZE; i++){
        putc(temp[i], file);
    }
    fclose(file);
    free(temp);
    printf("PE=%d, data_length=%d, data_num=%d test_data generate successed\n",  PE_NUM, data_length, data_num);
}