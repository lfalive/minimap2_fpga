//
// Created by fpga-0 on 9/17/19.
//

#include <iostream>
#include "ByteBuffer.hpp"
#include "ksw2.h"
#include "cpu_test.h"
#include "fpga_sw.h"
#include "sim_data_in.h"

void optInit(mm_opt* opt){
    opt->a = 2; //match score
    opt->b = 8; //mismatch score -8
    opt->e = 2; //
    opt->e2 = 1;
    opt->q = 12;
    opt->q2 = 24;
    opt->sc_ambi = 1; // N N
    opt->zdrop = 100;
    opt->end_bonus = 10;
    opt->bw =100;
}
static void ksw_gen_simple_mat(int m, int8_t *mat, int8_t a, int8_t b, int8_t sc_ambi)
{
    int i, j;
    a = a < 0? -a : a;
    b = b > 0? -b : b;
    sc_ambi = sc_ambi > 0? -sc_ambi : sc_ambi;
    for (i = 0; i < m - 1; ++i) {
        for (j = 0; j < m - 1; ++j)
            mat[i * m + j] = i == j? a : b;
        mat[i * m + m - 1] = sc_ambi;
    }
    for (j = 0; j < m; ++j)
        mat[(m - 1) * m + j] = sc_ambi;
}

void print_seq(FILE* file2, char* seq, int len){
    fprintf(file2, "%d:",len);
    for (int j=0; j<len; ++j){
        int temp = (int)seq[j];
        switch (temp){
            case 0 :
                fprintf(file2, "A");
                break;
            case 1 :
                fprintf(file2, "C");
                break;
            case 2 :
                fprintf(file2, "G");
                break;
            case 3 :
                fprintf(file2, "T");
                break;
            default :
                fprintf(file2, "N");
                break;

        }
    }
    fprintf(file2, "\n");

}



void cpu_test(){

    /***********READ THE 128K file***************/

    //FILE *file = fopen("/home/cj/Learning/clion/Output/128K.txt","rb");
    FILE *file = fopen("/home/fpga-0/fpga-test/FPGA_Minimap/Output/fpga_input_test_8.txt","rb");
    if (!file) perror("fpga_input_test.txt is not exit"), exit(1);

    FILE *file2 = fopen("/home/fpga-0/fpga-test/FPGA_Minimap/Output/cpu_out_8.txt", "w+");
    if (!file2) perror("cpu_out.txt is not exit"), exit(1);

    fprintf(file2, "CPU_OUT\n");
    fclose(file2);

    char *buf = (char*)malloc(128*1024*sizeof(char));
    fread(buf, sizeof(char), 1024*128, file);

    ByteBuffer buffer;
    for (int i=0; i<1024*128; i++) buffer.put(buf[i]);

    /***************get the pkt_num **********************/
    buffer.getLong();
    int pkg_num = buffer.getLongLittle();
    /****************loop to analysis the calculate the unit***************/

    int data_num_sum = 1;
    mm_opt *opt = (mm_opt*)malloc(sizeof(mm_opt));
    optInit(opt);
    int8_t mat[25];
    ksw_gen_simple_mat(5, mat, opt->a, opt->b, opt->sc_ambi);//cj:生成5x5的罚分矩阵 a=2 b=8 sc_ambi=1

    for (int i=0; i<pkg_num; ++i){

        fpga_data_input data;
        buffer.getLong();
        int data_num = buffer.getLongLittle();

        data.task_id = buffer.getLongLittle();

        data.id.seg_id = buffer.get();
        data.id.reg_id= buffer.get();
        buffer.getShort();

        data.sw_cal[0].q_len = buffer.getShortLittle();
        data.sw_cal[0].r_len = buffer.getShortLittle();
        data.sw_cal[0].score_init = buffer.getIntLittle();
        int r_len = data.sw_cal[0].r_len;
        int q_len = data.sw_cal[0].q_len;
        data.sw_cal[0].rs = (char *)malloc(r_len*sizeof(char));
        char *rs = data.sw_cal[0].rs;
        data.sw_cal[0].qs = (char *)malloc(q_len*sizeof(char));
        char *qs = data.sw_cal[0].qs;

        if (q_len != 0){
            int len_temp = (q_len-1)/8 + 1;
            for (int i=0; i<len_temp; ++i){
                int query = buffer.getIntLittle();
                for (int j=0; j<q_len-i*8 && j<8; ++j){
                    int shift = 28 - 4 * j;
                    qs[8*i+j] = (query >> shift) & 0x0f;
                }

            }
            len_temp = (r_len-1)/8 + 1;
            for (int i=0; i<len_temp; ++i){
                int query = buffer.getIntLittle();
                for (int j=0; j<r_len-i*8 && j<8; ++j){
                    int shift = 28 - 4 * j;
                    rs[8*i+j] = (query >> shift) & 0x0f;
                }
            }
        }
        data.sw_cal[1].q_len = buffer.getShortLittle();
        data.sw_cal[1].r_len = buffer.getShortLittle();
        data.sw_cal[1].score_init = buffer.getInt();
        r_len = data.sw_cal[1].r_len;
        q_len = data.sw_cal[1].q_len;
        data.sw_cal[1].rs = (char *)malloc(r_len*sizeof(uint8_t));
        rs = data.sw_cal[1].rs;
        data.sw_cal[1].qs = (char *)malloc(q_len*sizeof(uint8_t));
        qs = data.sw_cal[1].qs;
        if (q_len != 0){
            int len_temp = (q_len-1)/8 + 1;
            for (int i=0; i<len_temp; ++i){
                int query = buffer.getIntLittle();
                for (int j=0; j<q_len-i*8 && j<8; ++j){
                    int shift = 28 - 4 * j;
                    qs[8*i+j] = (query >> shift) & 0x0f;
                }

            }
            len_temp = (r_len-1)/8 + 1;
            for (int i=0; i<len_temp; ++i){
                int query = buffer.getIntLittle();
                for (int j=0; j<r_len-i*8 && j<8; ++j){
                    int shift = 28 - 4 * j;
                    rs[8*i+j] = (query >> shift) & 0x0f;
                }
            }
        }
        data_num_sum += data_num+1;
        buffer.setReadPos(16*data_num_sum);

        /**************cal the unit****************/
        ksw_extz_t ez[2];
        int flag = 0; //no traceback
        fpga_ksw2(data.sw_cal[0].q_len, data.sw_cal[0].qs, data.sw_cal[0].r_len, data.sw_cal[0].rs, mat, opt->q, opt->e, opt->end_bonus, 100, data.sw_cal[0].score_init, flag, &ez[0]);
        fpga_ksw2(data.sw_cal[1].q_len, data.sw_cal[1].qs, data.sw_cal[1].r_len, data.sw_cal[1].rs, mat, opt->q, opt->e, opt->end_bonus, 100, data.sw_cal[1].score_init, flag, &ez[1]);


        /***************write the result to the file*************************/

        file2 = fopen("/home/fpga-0/fpga-test/FPGA_Minimap/Output/cpu_out_8.txt", "a+");
        if (!file2) perror("file is open failed");

        resultToFile(data, ez, file2);


        free(data.sw_cal[0].rs);
        free(data.sw_cal[0].qs);
        free(data.sw_cal[1].rs);
        free(data.sw_cal[1].qs);
    }

    free(buf);
}

void Test_cpu(int PE_NUM, int data_length, int data_num_tmp){

    /***********READ THE 128K file***************/
    char file_name[120];
    char PE_num[5];
    char length[5];
    char num[5];

    sprintf(PE_num, "%d", PE_NUM);
    sprintf(length, "%d", data_length);
    sprintf(num, "%d", data_num_tmp);

    strcpy(file_name, "../../TestOutput/fpga_input_test_");
    strcat(file_name, PE_num);
    strcat(file_name, "_");
    strcat(file_name, length);
    strcat(file_name, "bp_");
    strcat(file_name, num);
    strcat(file_name, ".txt");

    char file_out_name[120];

    strcpy(file_out_name, "../../TestOutput/cpu_out_");
    strcat(file_out_name, PE_num);
    strcat(file_out_name, "_");
    strcat(file_out_name, length);
    strcat(file_out_name, "bp_");
    strcat(file_out_name, num);
    strcat(file_out_name, ".txt");

    FILE *file = fopen(file_name,"rb");
    if (!file) perror("fpga_input_test.txt is not exit"), exit(1);



    FILE *file2 = fopen(file_out_name, "w+");
    if (!file2) perror("cpu_out.txt is not exit"), exit(1);

    fprintf(file2, "CPU_OUT\n");
    fclose(file2);

    char *buf = (char*)malloc(128*1024*sizeof(char));
    fread(buf, sizeof(char), 1024*128, file);

    ByteBuffer buffer;
    for (int i=0; i<1024*128; i++) buffer.put(buf[i]);

    /***************get the pkt_num **********************/
    buffer.getLong();
    int pkg_num = buffer.getLongLittle();
    /****************loop to analysis the calculate the unit***************/

    int data_num_sum = 1;
    mm_opt *opt = (mm_opt*)malloc(sizeof(mm_opt));
    optInit(opt);
    int8_t mat[25];
    ksw_gen_simple_mat(5, mat, opt->a, opt->b, opt->sc_ambi);//cj:生成5x5的罚分矩阵 a=2 b=8 sc_ambi=1

    for (int i=0; i<pkg_num; ++i){

        fpga_data_input data;
        buffer.getLong();
        int data_num = buffer.getLongLittle();

        data.task_id = buffer.getLongLittle();

        data.id.seg_id = buffer.get();
        data.id.reg_id= buffer.get();
        buffer.getShort();

        data.sw_cal[0].q_len = buffer.getShortLittle();
        data.sw_cal[0].r_len = buffer.getShortLittle();
        data.sw_cal[0].score_init = buffer.getIntLittle();
        int r_len = data.sw_cal[0].r_len;
        int q_len = data.sw_cal[0].q_len;
        data.sw_cal[0].rs = (char *)malloc(r_len*sizeof(char));
        char *rs = data.sw_cal[0].rs;
        data.sw_cal[0].qs = (char *)malloc(q_len*sizeof(char));
        char *qs = data.sw_cal[0].qs;

        if (q_len != 0){
            int len_temp = (q_len-1)/8 + 1;
            for (int i=0; i<len_temp; ++i){
                int query = buffer.getIntLittle();
                for (int j=0; j<q_len-i*8 && j<8; ++j){
                    int shift = 28 - 4 * j;
                    qs[8*i+j] = (query >> shift) & 0x0f;
                }

            }
            len_temp = (r_len-1)/8 + 1;
            for (int i=0; i<len_temp; ++i){
                int query = buffer.getIntLittle();
                for (int j=0; j<r_len-i*8 && j<8; ++j){
                    int shift = 28 - 4 * j;
                    rs[8*i+j] = (query >> shift) & 0x0f;
                }
            }
        }
        data.sw_cal[1].q_len = buffer.getShortLittle();
        data.sw_cal[1].r_len = buffer.getShortLittle();
        data.sw_cal[1].score_init = buffer.getInt();
        r_len = data.sw_cal[1].r_len;
        q_len = data.sw_cal[1].q_len;
        data.sw_cal[1].rs = (char *)malloc(r_len*sizeof(uint8_t));
        rs = data.sw_cal[1].rs;
        data.sw_cal[1].qs = (char *)malloc(q_len*sizeof(uint8_t));
        qs = data.sw_cal[1].qs;
        if (q_len != 0){
            int len_temp = (q_len-1)/8 + 1;
            for (int i=0; i<len_temp; ++i){
                int query = buffer.getIntLittle();
                for (int j=0; j<q_len-i*8 && j<8; ++j){
                    int shift = 28 - 4 * j;
                    qs[8*i+j] = (query >> shift) & 0x0f;
                }

            }
            len_temp = (r_len-1)/8 + 1;
            for (int i=0; i<len_temp; ++i){
                int query = buffer.getIntLittle();
                for (int j=0; j<r_len-i*8 && j<8; ++j){
                    int shift = 28 - 4 * j;
                    rs[8*i+j] = (query >> shift) & 0x0f;
                }
            }
        }
        data_num_sum += data_num+1;
        buffer.setReadPos(16*data_num_sum);

        /**************cal the unit****************/
        ksw_extz_t ez[2];
        int flag = 0; //no traceback

        /**************************CLOCK_START*****************/
        clock_t time_start = clock();
        /***************************E N D**********************/

        fpga_ksw2(data.sw_cal[0].q_len, data.sw_cal[0].qs, data.sw_cal[0].r_len, data.sw_cal[0].rs, mat, opt->q, opt->e, opt->end_bonus, 100, data.sw_cal[0].score_init, flag, &ez[0]);
        fpga_ksw2(data.sw_cal[1].q_len, data.sw_cal[1].qs, data.sw_cal[1].r_len, data.sw_cal[1].rs, mat, opt->q, opt->e, opt->end_bonus, 100, data.sw_cal[1].score_init, flag, &ez[1]);

        clock_t time_end = clock();

        double time_run = ((double)(time_end-time_start) / CLOCKS_PER_SEC);

        printf("PE=%d, data_length=%d, data_num=%d, running time: %lf\n", time_run, PE_NUM, data_length, data_num_tmp);

        /***************write the result to the file*************************/

        file2 = fopen(file_out_name, "a+");
        if (!file2) perror("file is open failed");

        resultToFile(data, ez, file2);



        free(data.sw_cal[0].rs);
        free(data.sw_cal[0].qs);
        free(data.sw_cal[1].rs);
        free(data.sw_cal[1].qs);
    }

    free(buf);
}

void Test_sse2(int PE_NUM, int data_length, int data_num_tmp){
    /***********READ THE 128K file***************/

    char file_name[120];
    char PE_num[5];
    char length[5];
    char num[5];

    sprintf(PE_num, "%d", PE_NUM);
    sprintf(length, "%d", data_length);
    sprintf(num, "%d", data_num_tmp);

    strcpy(file_name, "../../TestOutput/fpga_input_test_");
    strcat(file_name, PE_num);
    strcat(file_name, "_");
    strcat(file_name, length);
    strcat(file_name, "bp_");
    strcat(file_name, num);
    strcat(file_name, ".txt");

    char file_out_name[120];

    strcpy(file_out_name, "../../TestOutput/sse2_out_");
    strcat(file_out_name, PE_num);
    strcat(file_out_name, "_");
    strcat(file_out_name, length);
    strcat(file_out_name, "bp_");
    strcat(file_out_name, num);
    strcat(file_out_name, ".txt");

    FILE *file = fopen(file_name,"rb");
    if (!file) perror("fpga_input_test.txt is not exit"), exit(1);



    FILE *file2 = fopen(file_out_name, "w+");
    if (!file2) perror("cpu_out.txt is not exit"), exit(1);

    fprintf(file2, "SSE2_OUT\n");
    fclose(file2);


    char *buf = (char*)malloc(128*1024*sizeof(char));
    fread(buf, sizeof(char), 1024*128, file);

    ByteBuffer buffer;
    for (int i=0; i<1024*128; i++) buffer.put(buf[i]);

    /***************get the pkt_num **********************/
    buffer.getLong();
    int pkg_num = buffer.getLongLittle();
    /****************loop to analysis the calculate the unit***************/

    int data_num_sum = 1;
    mm_opt *opt = (mm_opt*)malloc(sizeof(mm_opt));
    optInit(opt);
    int8_t mat[25];
    ksw_gen_simple_mat(5, mat, opt->a, opt->b, opt->sc_ambi);//cj:生成5x5的罚分矩阵 a=2 b=8 sc_ambi=1

    for (int i=0; i<pkg_num; ++i){

        fpga_data_input data;
        buffer.getLong();
        int data_num = buffer.getLongLittle();

        data.task_id = buffer.getLongLittle();

        data.id.seg_id = buffer.get();
        data.id.reg_id= buffer.get();
        buffer.getShort();

        data.sw_cal[0].q_len = buffer.getShortLittle();
        data.sw_cal[0].r_len = buffer.getShortLittle();
        data.sw_cal[0].score_init = buffer.getIntLittle();
        int r_len = data.sw_cal[0].r_len;
        int q_len = data.sw_cal[0].q_len;
        data.sw_cal[0].rs = (char *)malloc(r_len*sizeof(char));
        char *rs = data.sw_cal[0].rs;
        data.sw_cal[0].qs = (char *)malloc(q_len*sizeof(char));
        char *qs = data.sw_cal[0].qs;

        if (q_len != 0){
            int len_temp = (q_len-1)/8 + 1;
            for (int i=0; i<len_temp; ++i){
                int query = buffer.getIntLittle();
                for (int j=0; j<q_len-i*8 && j<8; ++j){
                    int shift = 28 - 4 * j;
                    qs[8*i+j] = (query >> shift) & 0x0f;
                }

            }
            len_temp = (r_len-1)/8 + 1;
            for (int i=0; i<len_temp; ++i){
                int query = buffer.getIntLittle();
                for (int j=0; j<q_len-i*8 && j<8; ++j){
                    int shift = 28 - 4 * j;
                    rs[8*i+j] = (query >> shift) & 0x0f;
                }
            }
        }
        data.sw_cal[1].q_len = buffer.getShortLittle();
        data.sw_cal[1].r_len = buffer.getShortLittle();
        data.sw_cal[1].score_init = buffer.getInt();
        r_len = data.sw_cal[1].r_len;
        q_len = data.sw_cal[1].q_len;
        data.sw_cal[1].rs = (char *)malloc(r_len*sizeof(uint8_t));
        rs = data.sw_cal[1].rs;
        data.sw_cal[1].qs = (char *)malloc(q_len*sizeof(uint8_t));
        qs = data.sw_cal[1].qs;
        if (q_len != 0){
            int len_temp = (q_len-1)/8 + 1;
            for (int i=0; i<len_temp; ++i){
                int query = buffer.getIntLittle();
                for (int j=0; j<q_len-i*8 && j<8; ++j){
                    int shift = 28 - 4 * j;
                    qs[8*i+j] = (query >> shift) & 0x0f;
                }

            }
            len_temp = (r_len-1)/8 + 1;
            for (int i=0; i<len_temp; ++i){
                int query = buffer.getIntLittle();
                for (int j=0; j<q_len-i*8 && j<8; ++j){
                    int shift = 28 - 4 * j;
                    rs[8*i+j] = (query >> shift) & 0x0f;
                }
            }
        }
        data_num_sum += data_num+1;
        buffer.setReadPos(16*data_num_sum);

        /**************cal the unit****************/
        ksw_extz_t ez[2];
        int flag = 0; //no traceback
        int w = 151;
        //no traceback
        void *km = (void*)calloc(1 , sizeof(int));
        /**************************CLOCK_START*****************/
        clock_t time_start = clock();
        /***************************E N D**********************/


        ksw_extd2_sse(km, data.sw_cal[0].q_len, data.sw_cal[0].qs, data.sw_cal[0].r_len, data.sw_cal[0].rs, 5, mat, opt->q, opt->e, opt->q2, opt->e2, w, opt->zdrop, opt->end_bonus, flag, &ez[0]);
        ksw_extd2_sse(km, data.sw_cal[1].q_len, data.sw_cal[1].qs, data.sw_cal[1].r_len, data.sw_cal[1].rs, 5, mat, opt->q, opt->e, opt->q2, opt->e2, w, opt->zdrop, opt->end_bonus, flag, &ez[1]);

        clock_t time_end = clock();

        double time_run = ((double)(time_end-time_start) / CLOCKS_PER_SEC);

        printf("PE=%d, data_length=%d, data_num=%d, running time: %lf\n", time_run, PE_NUM, data_length, data_num_tmp);

        /***************write the result to the file*************************/
        file2 = fopen(file_out_name, "a+");
        if (!file2) perror("file is open failed");

        resultToFile(data, ez, file2);


        free(data.sw_cal[0].rs);
        free(data.sw_cal[0].qs);
        free(data.sw_cal[1].rs);
        free(data.sw_cal[1].qs);
    }

    free(buf);
}


void sse2_test(){
    /***********READ THE 128K file***************/

    FILE *file = fopen("/home/fpga-0/fpga-test/FPGA_Minimap/Output/fpga_input_test_8.txt","rb");
    if (!file) perror("fpga_input_test.txt is not exit"), exit(1);

    FILE *file2 = fopen("/home/fpga-0/fpga-test/FPGA_Minimap/Output/sse2_out_8.txt", "w+");
    if (!file2) perror("cpu_out.txt is not exit"), exit(1);

    fprintf(file2, "SSE2_OUT\n");
    fclose(file2);


    char *buf = (char*)malloc(128*1024*sizeof(char));
    fread(buf, sizeof(char), 1024*128, file);

    ByteBuffer buffer;
    for (int i=0; i<1024*128; i++) buffer.put(buf[i]);

    /***************get the pkt_num **********************/
    buffer.getLong();
    int pkg_num = buffer.getLongLittle();
    /****************loop to analysis the calculate the unit***************/

    int data_num_sum = 1;
    mm_opt *opt = (mm_opt*)malloc(sizeof(mm_opt));
    optInit(opt);
    int8_t mat[25];
    ksw_gen_simple_mat(5, mat, opt->a, opt->b, opt->sc_ambi);//cj:生成5x5的罚分矩阵 a=2 b=8 sc_ambi=1

    for (int i=0; i<pkg_num; ++i){

        fpga_data_input data;
        buffer.getLong();
        int data_num = buffer.getLongLittle();

        data.task_id = buffer.getLongLittle();

        data.id.seg_id = buffer.get();
        data.id.reg_id= buffer.get();
        buffer.getShort();

        data.sw_cal[0].q_len = buffer.getShortLittle();
        data.sw_cal[0].r_len = buffer.getShortLittle();
        data.sw_cal[0].score_init = buffer.getIntLittle();
        int r_len = data.sw_cal[0].r_len;
        int q_len = data.sw_cal[0].q_len;
        data.sw_cal[0].rs = (char *)malloc(r_len*sizeof(char));
        char *rs = data.sw_cal[0].rs;
        data.sw_cal[0].qs = (char *)malloc(q_len*sizeof(char));
        char *qs = data.sw_cal[0].qs;

        if (q_len != 0){
            int len_temp = (q_len-1)/8 + 1;
            for (int i=0; i<len_temp; ++i){
                int query = buffer.getIntLittle();
                for (int j=0; j<q_len-i*8 && j<8; ++j){
                    int shift = 28 - 4 * j;
                    qs[4*i+j] = (query >> shift) & 0x0f;
                }

            }
            len_temp = (r_len-1)/8 + 1;
            for (int i=0; i<len_temp; ++i){
                int query = buffer.getIntLittle();
                for (int j=0; j<q_len-i*8 && j<8; ++j){
                    int shift = 28 - 4 * j;
                    rs[4*i+j] = (query >> shift) & 0x0f;
                }
            }
        }
        data.sw_cal[1].q_len = buffer.getShortLittle();
        data.sw_cal[1].r_len = buffer.getShortLittle();
        data.sw_cal[1].score_init = buffer.getInt();
        r_len = data.sw_cal[1].r_len;
        q_len = data.sw_cal[1].q_len;
        data.sw_cal[1].rs = (char *)malloc(r_len*sizeof(uint8_t));
        rs = data.sw_cal[1].rs;
        data.sw_cal[1].qs = (char *)malloc(q_len*sizeof(uint8_t));
        qs = data.sw_cal[1].qs;
        if (q_len != 0){
            int len_temp = (q_len-1)/8 + 1;
            for (int i=0; i<len_temp; ++i){
                int query = buffer.getIntLittle();
                for (int j=0; j<q_len-i*8 && j<8; ++j){
                    int shift = 28 - 4 * j;
                    qs[4*i+j] = (query >> shift) & 0x0f;
                }

            }
            len_temp = (r_len-1)/8 + 1;
            for (int i=0; i<len_temp; ++i){
                int query = buffer.getIntLittle();
                for (int j=0; j<q_len-i*8 && j<8; ++j){
                    int shift = 28 - 4 * j;
                    rs[4*i+j] = (query >> shift) & 0x0f;
                }
            }
        }
        data_num_sum += data_num+1;
        buffer.setReadPos(16*data_num_sum);

        /**************cal the unit****************/
        ksw_extz_t ez[2];
        int flag = 0; //no traceback
        int w = 151;
        //no traceback
        void *km = (void*)calloc(1 , sizeof(int));
        ksw_extd2_sse(km, data.sw_cal[0].q_len, data.sw_cal[0].qs, data.sw_cal[0].r_len, data.sw_cal[0].rs, 5, mat, opt->q, opt->e, opt->q2, opt->e2, w, opt->zdrop, opt->end_bonus, flag, &ez[0]);
        ksw_extd2_sse(km, data.sw_cal[1].q_len, data.sw_cal[1].qs, data.sw_cal[1].r_len, data.sw_cal[1].rs, 5, mat, opt->q, opt->e, opt->q2, opt->e2, w, opt->zdrop, opt->end_bonus, flag, &ez[1]);

        /***************write the result to the file*************************/
        file2 = fopen("/home/fpga-0/fpga-test/FPGA_Minimap/Output/sse2_out_8.txt", "a+");
        if (!file2) perror("file is open failed");

        resultToFile(data, ez, file2);


        free(data.sw_cal[0].rs);
        free(data.sw_cal[0].qs);
        free(data.sw_cal[1].rs);
        free(data.sw_cal[1].qs);
    }

    free(buf);
}

void resultToFile(fpga_data_input data, ksw_extz_t* ez, FILE* file2){

    int en = (data.sw_cal[0].r_len+15)/16 * 16-1 ;
    int temp = ez[0].mte_q +1 +en - data.sw_cal[0].r_len;
    //fprintf(file2, "Left qlen:%d tlen:%d\n", data.sw_cal[0].q_len, data.sw_cal[0].r_len);
    int chunk_id = data.task_id >> 32;
    int read_id = data.task_id;

    fprintf(file2, "id:%d-%d-%d-%d\n", chunk_id, read_id, data.id.seg_id, data.id.reg_id);
    fprintf(file2, "Left:\n");
    print_seq(file2, data.sw_cal[0].qs, data.sw_cal[0].q_len );
    print_seq(file2, data.sw_cal[0].rs, data.sw_cal[0].r_len );
    fprintf(file2, "max:%d max_q:%d max_t:%d\n", ez[0].max, ez[0].max_q, ez[0].max_t );
    fprintf(file2, "mqe:%d mqe_t:%d\n", ez[0].mqe, ez[0].mqe_t);
    fprintf(file2, "mte:%d mte_q:%d\n", ez[0].mte, temp);
    fprintf(file2,"diagonal:%d\n", ez[0].score);
    for (int i=0; i<ez[0].n_cigar; ++i){
        fprintf(file2, "cigar[%d]=%0x\n", i, ez[0].cigar[i] );
    }
    en = (data.sw_cal[1].r_len+15)/16 * 16-1 ;
    temp = ez[1].mte_q +1 +en - data.sw_cal[1].r_len;
    //fprintf(file2, "Right qlen:%d tlen:%d\n", data.sw_cal[1].q_len, data.sw_cal[1].r_len);
    fprintf(file2, "Right:\n");
    print_seq(file2, data.sw_cal[1].qs, data.sw_cal[1].q_len );
    print_seq(file2, data.sw_cal[1].rs, data.sw_cal[1].r_len );
    fprintf(file2, "max:%d max_q:%d max_t:%d\n", ez[1].max, ez[1].max_q, ez[1].max_t );
    fprintf(file2, "mqe:%d mqe_t:%d\n", ez[1].mqe, ez[1].mqe_t);
    fprintf(file2, "mte:%d mte_q:%d\n", ez[1].mte, temp);
    fprintf(file2,"diagonal:%d\n", ez[1].score);
    for (int i=0; i<ez[1].n_cigar; ++i){
        fprintf(file2, "cigar[%d]=%0x\n", i, ez[1].cigar[i] );
    }
    fclose(file2);

}