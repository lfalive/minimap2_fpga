//
// Created by fpga-0 on 9/17/19.
//
#include "queue_ctrl.h"
#include "ByteBuffer.hpp"
#include "fpga_test.h"
#include <zconf.h>

#include <mutex>

#define PACKAGE_SIZE 1*128*1024
#define FPGA_OUT_PACKAGE_SIZE 1024*4
typedef bb::ByteBuffer ByteBuffer;
//static ByteBuffer SendBuffer(PACKAGE_SIZE);

std::mutex file_lock;
std::mutex send_lock;

void writeDataToFPGA(Byte* buffer){
    while(true){
        if (IsDsWriteable(1)){
            WriteDsPkg(buffer, 1);
            break;
        }
    }
}

void* SendDataToFpga(void *args){
    // open the file and get the data to the buffer
    Byte *temp = (Byte*)malloc(PACKAGE_SIZE*sizeof(Byte));
    //Byte *buffer = (Byte*)malloc(PACKAGE_SIZE*sizeof(Byte));
    file_lock.lock();
    FILE* file = fopen("../../Output/fpga_input_test_8.txt", "rb");
    if (!file){
        perror("../../Output/fpga_input_test_8.txt");
        exit(1);
    }
    fread(temp,sizeof(char), PACKAGE_SIZE, file);
    fclose(file);
    file_lock.unlock();
    //ByteBuffer SendBuffer(PACKAGE_SIZE);
    for (int i=0; i<1; ++i){
/*        for (int j=0; j<PACKAGE_SIZE; ++j){
            SendBuffer.putChar(temp[j]);
        }
        SendBuffer.getBytes(buffer, PACKAGE_SIZE);*/
        send_lock.lock();
        writeDataToFPGA(temp);
        send_lock.unlock();
        //printf("\nsend pkg %d to fpga\n", i);
        //SendBuffer.clear();
    }
    free(temp);
    //free(buffer);

}

#define THREAD_NUM  2
void* GetDataFromFPGA(void *args) {

    Byte *GetBuffer = (Byte *) calloc(FPGA_OUT_PACKAGE_SIZE, sizeof(Byte));
    int unit_num = 1339 * 1100 * (THREAD_NUM - 1); //1339
    int i = 0;
    int count = 0;
/*    FILE * file2;
    file2 = fopen("../../Output/buf3_fpga_out.txt","wb");
    if (!file2) {
        perror("../../Output/PU8_fpga_out.txt");
        exit(-1);
    }*/
    while (true) {
        while (true) {
            if (IsUsReadable(1)) {
                //printf("\n get pkg %d from fpga\n", ++i);
                ReadUsPkg(GetBuffer, 1);
                resultToFile(GetBuffer);

                break;
            }
        }
        break;
/*        if (i == 169)
            printf("debug\n");
        int num = FPGA_OUT_PACKAGE_SIZE / 64;
        fpga_sw_output fpgaoutput[num];



        if(count == unit_num) break;

        //fclose(file2);

        free(GetBuffer);*/
    }
}


void fpga_test(){
    // open xdma
    int open_status = OpenQueueCtrl();
    if (!open_status){
        cerr << "\nopen xdma device failed\n";
        exit(-1);
    }
    printf("\nOpen xdma device success\n");

    // create thread  send data to fpga
    pthread_t tid[THREAD_NUM];

    for (int i=0; i<THREAD_NUM-1; ++i ){
        pthread_create(&tid[i], NULL, SendDataToFpga, NULL);
    }

    //create thread get data from fpga
    pthread_create(&tid[THREAD_NUM-1], NULL, GetDataFromFPGA, NULL);

    //print debug info
/*    pthread_t debug_tid;
    pthread_create(&debug_tid, NULL, printDebugInfo, NULL);*/

    //wait thread to join
    for (int i=0; i<THREAD_NUM; ++i){
        pthread_join(tid[i], NULL);
    }
    //close xdma
    printf("\nfinished\n");
    CloseQueueCtrl();
}

void resultToFile(Byte *buff){

    FILE *file;
    file = fopen("../../Output/fpga_out_8.txt","wb");
    if (!file) {
        perror("../../Output/fpga_out_8.txt");
        exit(-1);
    }

    fwrite(buff,sizeof(Byte),FPGA_OUT_PACKAGE_SIZE, file);

    fclose(file);
    //cigarToStruct(buff);

}

void cigar_test(){
    FILE *file;
    file = fopen("../../Output/fpga_out_8.txt","rb");
    if (!file) {
        perror("../../Output/fpga_out_8.txt.txt");
        exit(-1);
    }
    Byte *buff = (Byte *) calloc(FPGA_OUT_PACKAGE_SIZE, sizeof(Byte));

    fread(buff,sizeof(Byte),FPGA_OUT_PACKAGE_SIZE, file);

    cigarToStruct(buff);

    fclose(file);
}
void cigarToStruct(Byte *GetBuffer){

    int count = 0;
    //Byte *buff = GetBuffer;
    fpga_cigar_output *fpgaoutput = (fpga_cigar_output*)malloc(1*sizeof(fpga_cigar_output));
    while (count < FPGA_OUT_PACKAGE_SIZE){

        Byte *buff_tmp = &GetBuffer[count];
        Byte *buff = buff_tmp;

        if (buff[0] == 0xff && buff[1] == 0xff) {
            count = count + 8;
            continue;
            //break;
        }
        int q_len[2], t_len[2];

        int data_num =  (buff[4]<<24) + (buff[5]<<16) + (buff[6]<<8) + buff[7]; //64bit for data_num
        q_len[0] = buff[8];
        t_len[0] = (buff[9]<<8) + buff[10];
        q_len[1] = buff[11];
        t_len[1] = (buff[12]<<8) + buff[13];




        int chunk_id = (buff[14]<<24) + (buff[15]<<16) + (buff[16]<<8) + buff[17];

        int read_id = (buff[18]<<24) + (buff[19]<<16) + (buff[20]<<8) + buff[21];

        fpgaoutput->task_id = chunk_id;
        fpgaoutput->task_id = fpgaoutput->task_id << 32 | read_id;
        fpgaoutput->seg_id = buff[22] ;
        fpgaoutput->reg_id = buff[23] ;

        fpgaoutput->flag[0] = buff[24] && 0x03; //stand for whether extend
        fpgaoutput->flag[1] = buff[25] && 0x0c; //stand for whether coordinate need to plus 1

        //buff[11] is the zero
        fpgaoutput->result[0].max   = (buff[26]<<8) + buff[27];//left_result
        fpgaoutput->result[0].max_t = (buff[28]<<8) + buff[29];
        fpgaoutput->result[0].max_q = buff[30];
        fpgaoutput->result[0].mqe   = (buff[31]<<8) + buff[32];
        fpgaoutput->result[0].mqe_t = (buff[33]<<8) + buff[34];

        fpgaoutput->result[0].mte   = (buff[36]<<8) + buff[37];
        fpgaoutput->result[0].mte_q = buff[40] ; //todo maybe the coordinate need to add 1
        fpgaoutput->result[0].score = (buff[41]<<8) + buff[42];

        fpgaoutput->result[1].max   = (buff[43]<<8) + buff[44];//left_result
        fpgaoutput->result[1].max_t = (buff[45]<<8) + buff[46];
        fpgaoutput->result[1].max_q =  buff[47] ;
        fpgaoutput->result[1].mqe   = (buff[48]<<8) + buff[49];
        fpgaoutput->result[1].mqe_t = (buff[50]<<8) + buff[51];

        fpgaoutput->result[1].mte   = (buff[53]<<8) + buff[54];
        fpgaoutput->result[1].mte_q =  buff[57];
        fpgaoutput->result[1].score = (buff[58]<<8) + buff[59]; //buff[64] 后面是32'b0

        //**************CIGAR******************/
        buff = &buff_tmp[(data_num-1)*8];
        int cj = 1;
        int tmp2 = data_num;
        while (cj >= 0){

            int tmp = (buff[4]<<24) + (buff[5]<<16) + (buff[6]<<8) + buff[7];
            if (tmp == -1)
    
                /*fpgaoutput->result[cj].n_cigar = buff[0] * 256 * 256 * 256 + buff[1] * 256 * 256 +
                                                buff[2] * 256 + buff[3];*/
                fpgaoutput->result[cj].n_cigar =  buff[3];
            else
    
                fpgaoutput->result[cj].n_cigar = tmp;
    
            fpgaoutput->result[cj].cigar = (uint32_t*)malloc((fpgaoutput->result[cj].n_cigar)*sizeof(uint32_t));
    
            tmp2 = tmp2 - (fpgaoutput->result[cj].n_cigar >> 1) -1 ;
            buff = &buff_tmp[tmp2*8];
            for (int i=0; i<fpgaoutput->result[cj].n_cigar; ++i){
                fpgaoutput->result[cj].cigar[i] = (buff[4*i+0]<<24) + (buff[4*i+1]<<16) + (buff[4*i+2]<<8) + buff[4*i+3];
                //printf("fpgaoutput->result[%d].cigar[%d]=%0x\n", cj ,i, fpgaoutput->result[cj].cigar[i] );
            }
            buff = &buff_tmp[(tmp2-1)<<3];
            cj -- ;

        }

        count = count + data_num<<3;

        /****************END******************/


        /**********DEBUG***********/
        cigarToFile(fpgaoutput);

        free(fpgaoutput->result[0].cigar);
        free(fpgaoutput->result[1].cigar);

        /***********END***********/


    }

    free(fpgaoutput);

}


void cigarToFile(fpga_cigar_output *fpgaoutput){

    FILE *file2 = fopen("../../Output/cigar_result.txt", "wb");
    if (!file2) perror("../../Output/cigar_result.txt"), exit(1);


    fprintf(file2, "id:%ld-%ld-%d-%d\n", fpgaoutput->task_id>>32, fpgaoutput->task_id, fpgaoutput->seg_id, fpgaoutput->reg_id);
    fprintf(file2, "Left:\n");
    fprintf(file2, "max:%d max_q:%d max_t:%d\n",fpgaoutput->result[0].max, fpgaoutput->result[0].max_q, fpgaoutput->result[0].max_t );
    fprintf(file2, "mqe:%d mqe_t:%d\n", fpgaoutput->result[0].mqe, fpgaoutput->result[0].mqe_t);
    fprintf(file2, "mte:%d mte_q:%d\n", fpgaoutput->result[0].mte, fpgaoutput->result[0].mte_q);
    fprintf(file2,"diagonal:%d\n", fpgaoutput->result[0].score);
    fprintf(file2, "n_cigar:%d\n", fpgaoutput->result[0].n_cigar);
    for (int i=0; i<fpgaoutput->result[0].n_cigar; ++i){
        fprintf(file2, "cigar[%d] = %0x\n", i, fpgaoutput->result[0].cigar[i]);
    }

    fprintf(file2, "Right:\n");
    fprintf(file2, "max:%d max_q:%d max_t:%d\n",fpgaoutput->result[1].max, fpgaoutput->result[1].max_q, fpgaoutput->result[1].max_t );
    fprintf(file2, "mqe:%d mqe_t:%d\n", fpgaoutput->result[1].mqe, fpgaoutput->result[1].mqe_t);
    fprintf(file2, "mte:%d mte_q:%d\n", fpgaoutput->result[1].mte, fpgaoutput->result[1].mte_q);
    fprintf(file2,"diagonal:%d\n", fpgaoutput->result[1].score);
    fprintf(file2, "n_cigar:%d\n", fpgaoutput->result[1].n_cigar);
    for (int i=0; i<fpgaoutput->result[1].n_cigar; ++i){
        fprintf(file2, "cigar[%d] = %0x\n", i, fpgaoutput->result[1].cigar[i]);
    }

    fclose(file2);
}


//function: one-dimension buffer to max and bt array which is two dimension


/**************************BT_OUT*****************************/
void resultMaxTofile(FILE *file2, Byte *GetBuffer){

    int num = FPGA_OUT_PACKAGE_SIZE / 64;
    fpga_sw_output fpgaoutput[num];

    for (int i = 0; i < num; i++) {
        // zero/18B
        int chunk_id = GetBuffer[i * 64 + 45] * 256 * 256 * 256 + GetBuffer[i * 64 + 44] * 256 * 256 +
                       GetBuffer[i * 64 + 43] * 256 + GetBuffer[i * 64 + 42];

        int read_id = GetBuffer[i * 64 + 41] * 256 * 256 * 256 + GetBuffer[i * 64 + 40] * 256 * 256 +
                      GetBuffer[i * 64 + 39] * 256 + GetBuffer[i * 64 + 38];
        fpgaoutput[i].task_id = chunk_id;
        fpgaoutput[i].task_id = fpgaoutput[i].task_id << 32 | read_id;
        fpgaoutput[i].seg_id = GetBuffer[i * 64 + 37] ;
        fpgaoutput[i].reg_id = GetBuffer[i * 64 + 36] ;

        fpgaoutput[i].flag[0] = GetBuffer[i * 64 + 35] && 0x03; //stand for whether extend
        fpgaoutput[i].flag[1] = GetBuffer[i * 64 + 34] && 0x0c; //stand for whether coordinate need to plus 1
        //GetBuffer[11] is the zero
        fpgaoutput[i].result[0].max = GetBuffer[i * 64 + 33] * 256 + GetBuffer[i * 64 + 32];//left_result
        fpgaoutput[i].result[0].max_t = GetBuffer[i * 64 + 31] * 256 + GetBuffer[i * 64 + 30];
        fpgaoutput[i].result[0].max_q = GetBuffer[i * 64 + 29];
        fpgaoutput[i].result[0].mqe = GetBuffer[i * 64 + 28] * 256 + GetBuffer[i * 64 + 27];
        fpgaoutput[i].result[0].mqe_t = GetBuffer[i * 64 + 26] + GetBuffer[i * 64 + 25];
        fpgaoutput[i].result[0].mte = GetBuffer[i * 64 + 23] * 256 + GetBuffer[i * 64 + 22];
        fpgaoutput[i].result[0].mte_q = GetBuffer[i * 64+ 19] ; //todo maybe the coordinate need to add 1
        fpgaoutput[i].result[0].score = GetBuffer[i * 64 + 18]*256 + GetBuffer[i * 64 + 17];

        fpgaoutput[i].result[1].max = GetBuffer[i * 64 + 16] * 256 + GetBuffer[i * 64 + 15];//left_result
        fpgaoutput[i].result[1].max_t = GetBuffer[i * 64 + 14] * 256 + GetBuffer[i * 64 + 13];
        fpgaoutput[i].result[1].max_q = GetBuffer[i * 64 + 12] ;
        fpgaoutput[i].result[1].mqe = GetBuffer[i * 64 + 11] * 256 + GetBuffer[i * 64 + 10];
        fpgaoutput[i].result[1].mqe_t = GetBuffer[i * 64 + 9] + GetBuffer[i * 64 + 8];
        fpgaoutput[i].result[1].mte = GetBuffer[i * 64 + 6] * 256 + GetBuffer[i * 64 + 5];
        fpgaoutput[i].result[1].mte_q = GetBuffer[i * 64 + 2];
        fpgaoutput[i].result[1].score = GetBuffer[i * 64 + 1]*256 + GetBuffer[i * 64 + 0];

        //if ((GetBuffer[i * 64 + 2] == 0xff) && (GetBuffer[i * 64 + 12] == 0xff) && (GetBuffer[i * 64 + 12] == 0xff)) continue; //ddr上会有缓存数据没有清理干净
        if (chunk_id == 0) continue;

        //count++;
        //printf("\ncount=%d\n", count);

        fprintf(file2, "id:%d-%d-%d-%d\n", chunk_id, read_id, fpgaoutput[i].seg_id, fpgaoutput[i].reg_id);
        fprintf(file2, "Left:\n");
        fprintf(file2, "max:%d max_q:%d max_t:%d\n",fpgaoutput[i].result[0].max, fpgaoutput[i].result[0].max_q, fpgaoutput[i].result[0].max_t );
        fprintf(file2, "mqe:%d mqe_t:%d\n", fpgaoutput[i].result[0].mqe, fpgaoutput[i].result[0].mqe_t);
        fprintf(file2, "mte:%d mte_q:%d\n", fpgaoutput[i].result[0].mte, fpgaoutput[i].result[0].mte_q);
        fprintf(file2,"diagonal:%d\n", fpgaoutput[i].result[0].score);

        fprintf(file2, "Right:\n");
        fprintf(file2, "max:%d max_q:%d max_t:%d\n",fpgaoutput[i].result[1].max, fpgaoutput[i].result[1].max_q, fpgaoutput[i].result[1].max_t );
        fprintf(file2, "mqe:%d mqe_t:%d\n", fpgaoutput[i].result[1].mqe, fpgaoutput[i].result[1].mqe_t);
        fprintf(file2, "mte:%d mte_q:%d\n", fpgaoutput[i].result[1].mte, fpgaoutput[i].result[1].mte_q);
        fprintf(file2,"diagonal:%d\n", fpgaoutput[i].result[1].score);
        printf("id:%d-%d-%d-%d\n", chunk_id, read_id, fpgaoutput[i].seg_id, fpgaoutput[i].reg_id);
        printf("result[0]:%d-%d-%d=%d-%d=%d-%d=%d\n", fpgaoutput[i].result[0].max, fpgaoutput[i].result[0].max_t,
               fpgaoutput[i].result[0].max_q, fpgaoutput[i].result[0].mqe, fpgaoutput[i].result[0].mqe_t,
               fpgaoutput[i].result[0].mte,fpgaoutput[i].result[0].mte_q,fpgaoutput[i].result[0].score );

        printf("result[1]:%d-%d-%d=%d-%d=%d-%d=%d\n", fpgaoutput[i].result[1].max, fpgaoutput[i].result[1].max_t,
               fpgaoutput[i].result[1].max_q, fpgaoutput[i].result[1].mqe, fpgaoutput[i].result[1].mqe_t,
               fpgaoutput[i].result[1].mte,fpgaoutput[i].result[1].mte_q,fpgaoutput[i].result[1].score );
    }

    //if(count == unit_num) break;
}

void buffToStruct(Byte *GetBuffer){

    int count = 0;
    //Byte *buff = GetBuffer;
    while (count < FPGA_OUT_PACKAGE_SIZE){

        Byte *buff = &GetBuffer[count];
        if (buff[0] == 0xff && buff[1] == 0xff) {
            count = count + 8;
            continue;
            //break;
        }
        int q_len[2], t_len[2];

        int data_num =  buff[4] * 256 * 256 * 256 + buff[5] * 256 * 256 +
                        buff[6] * 256 + buff[7]; //64bit for data_num
        q_len[0] = buff[8];
        t_len[0] = buff[9]*256 + buff[10];
        q_len[1] = buff[11];
        t_len[1] = buff[12] * 256 + buff[13];

        fpga_sw_output *fpgaoutput = (fpga_sw_output*)malloc(1*sizeof(fpga_sw_output));

        fpgaoutput->result[0].bt = (uint8_t**)malloc(t_len[0]*sizeof(uint8_t*));
        for (int i=0; i<t_len[0]; ++i){

            fpgaoutput->result[0].bt[i] = (uint8_t*)malloc(q_len[0]*sizeof(uint8_t));
        }

        fpgaoutput->result[1].bt = (uint8_t**)malloc(t_len[1]*sizeof(uint8_t*));
        for (int i=0; i<t_len[1]; ++i){

            fpgaoutput->result[1].bt[i] = (uint8_t*)malloc(q_len[1]*sizeof(uint8_t));
        }


        int chunk_id = buff[14] * 256 * 256 * 256 + buff[15] * 256 * 256 +
                       buff[16] * 256 + buff[17];

        int read_id = buff[18] * 256 * 256 * 256 + buff[19] * 256 * 256 +
                      buff[20] * 256 + buff[21];

        fpgaoutput->task_id = chunk_id;
        fpgaoutput->task_id = fpgaoutput->task_id << 32 | read_id;
        fpgaoutput->seg_id = buff[22] ;
        fpgaoutput->reg_id = buff[23] ;

        fpgaoutput->flag[0] = buff[24] && 0x03; //stand for whether extend
        fpgaoutput->flag[1] = buff[25] && 0x0c; //stand for whether coordinate need to plus 1

        //buff[11] is the zero
        fpgaoutput->result[0].max   = buff[26] * 256 + buff[27];//left_result
        fpgaoutput->result[0].max_t = buff[28] * 256 + buff[29];
        fpgaoutput->result[0].max_q = buff[30];
        fpgaoutput->result[0].mqe   = buff[31] * 256 + buff[32];
        fpgaoutput->result[0].mqe_t = buff[33] * 256+ buff[34];

        fpgaoutput->result[0].mte   = buff[36] * 256 + buff[37];
        fpgaoutput->result[0].mte_q = buff[40] ; //todo maybe the coordinate need to add 1
        fpgaoutput->result[0].score = buff[41]*256 + buff[42];

        fpgaoutput->result[1].max   = buff[43] * 256 + buff[44];//left_result
        fpgaoutput->result[1].max_t = buff[45] * 256 + buff[46];
        fpgaoutput->result[1].max_q = buff[47] ;
        fpgaoutput->result[1].mqe   = buff[48] * 256 + buff[49];
        fpgaoutput->result[1].mqe_t = buff[50] * 256 + buff[51];

        fpgaoutput->result[1].mte   = buff[53] * 256 + buff[54];
        fpgaoutput->result[1].mte_q = buff[57];
        fpgaoutput->result[1].score = buff[58]*256 + buff[59];

        // 32bit zero


        buffToBt(q_len, t_len, fpgaoutput->result[0].bt, fpgaoutput->result[1].bt, &buff[64]);
        count = count + data_num<<3;

        /**********DEBUG***********/


        /***********END***********/


    }


}


void buffToBt(int* q_len, int* t_len, uint8_t **L_bt, uint8_t  **R_bt, Byte *buff){


    // int unit_num =  buff[4] * 256 * 256 * 256 + buff[5] * 256 * 256 + buff[6] * 256 + buff[7];

    buff = &buff[8];

    int K = ((q_len[0]-1) >> 3) + 1 ;// the number of matrix
    int Base = 8*K - q_len[0];

    for (int i=0; i<K*t_len[0]*8; ++i)
        printf("buff[%d] = %x\n", i, buff[i]);

    for (int k=0; k<K; ++k){    //LEFT
        //buff = &buff[k*8*t_len[0]];

        int base = (k == K-1) ? Base : 0;

        for (int t=0; t<t_len[0]; ++t){

            for (int j=0; j<8-base; ++j){
                L_bt[t][j+k*8] = buff[j+base];
                printf("L_bt[%d][%d] = %x; buff[%d]\n", t, j+k*8, buff[j+base], j+base);
            }
            buff = &buff[8];

        }
    }

    buff = &buff[8]; // unit num

    K = ((q_len[1]-1) >> 3) + 1 ;// the number of matrix
    Base = 8*K - q_len[1];

    for (int k=0; k<K; ++k){    //RIGHT
        //buff = &buff[k*8*t_len[1]];

        int base = (k == K-1) ? Base : 0;

        for (int t=0; t<t_len[1]; ++t){

            for (int j=0; j<8-base; ++j){
                R_bt[t][j+k*8] = buff[j+base];
                printf("R_bt[%d][%d] = %x; buff[%d]\n", t, j+k*8, buff[j+base], j+base);
            }
            buff = &buff[8];
        }
    }

}


void resultToFile(fpga_sw_output *fpgaoutput){

    FILE *file2 = fopen("../../Output/result.txt", "wb");
    if (!file2) perror("../../Output/result.txt"), exit(1);


    fprintf(file2, "id:%ld-%ld-%d-%d\n", fpgaoutput->task_id>>32, fpgaoutput->task_id, fpgaoutput->seg_id, fpgaoutput->reg_id);
    fprintf(file2, "Left:\n");
    fprintf(file2, "max:%d max_q:%d max_t:%d\n",fpgaoutput->result[0].max, fpgaoutput->result[0].max_q, fpgaoutput->result[0].max_t );
    fprintf(file2, "mqe:%d mqe_t:%d\n", fpgaoutput->result[0].mqe, fpgaoutput->result[0].mqe_t);
    fprintf(file2, "mte:%d mte_q:%d\n", fpgaoutput->result[0].mte, fpgaoutput->result[0].mte_q);
    fprintf(file2,"diagonal:%d\n", fpgaoutput->result[0].score);

    fprintf(file2, "Right:\n");
    fprintf(file2, "max:%d max_q:%d max_t:%d\n",fpgaoutput->result[1].max, fpgaoutput->result[1].max_q, fpgaoutput->result[1].max_t );
    fprintf(file2, "mqe:%d mqe_t:%d\n", fpgaoutput->result[1].mqe, fpgaoutput->result[1].mqe_t);
    fprintf(file2, "mte:%d mte_q:%d\n", fpgaoutput->result[1].mte, fpgaoutput->result[1].mte_q);
    fprintf(file2,"diagonal:%d\n", fpgaoutput->result[1].score);

    fclose(file2);
}


/****************************END******************************/