//
// Created by cj on 5/16/19.
//
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include "fpga_sw.h"
#include "ksw2.h"

#ifdef __GNUC__
#define LIKELY(x) __builtin_expect((x),1)
#define UNLIKELY(x) __builtin_expect((x),0)
#else
#define LIKELY(x) (x)
#define UNLIKELY(x) (x)
#endif

void test();

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

#define MINUS_INF -0x40000000

static inline uint32_t *push_cigar(int *n_cigar, int *m_cigar, uint32_t *cigar, int op, int len)
{
    if (*n_cigar == 0 || op != (cigar[(*n_cigar) - 1]&0xf)) {
        if (*n_cigar == *m_cigar) {
            *m_cigar = *m_cigar? (*m_cigar)<<1 : 4;
            cigar = (uint32_t*)realloc(cigar, (*m_cigar) << 2);
        }

        cigar[(*n_cigar)++] = len<<4 | op;
    } else cigar[(*n_cigar)-1] += len<<4;
    return cigar;
}


typedef struct {
    int32_t h, e;
} eh_t;


void traceback(uint8_t **z, int tracback_qpos, int tracback_rpos, int is_rev,  ksw_extz_t *ez){
    int i= tracback_rpos;
    int j= tracback_qpos;
    int n_cigar = 0, m_cigar = 0, which = 0;
    uint32_t *cigar = 0, tmp;

    while(i>=0 && j>=0){
        which = z[i][j] >> (which<<1) & 3;
        if (which == 0)      cigar = push_cigar(&n_cigar, &m_cigar, cigar, 0, 1), --i, --j; //o match
        else if (which == 1) cigar = push_cigar(&n_cigar, &m_cigar, cigar, 2, 1), --i;      //2 deletion
        else                 cigar = push_cigar(&n_cigar, &m_cigar, cigar, 1, 1), --j;      //insertion

    }
    if (i >= 0) cigar = push_cigar(&n_cigar, &m_cigar, cigar, 2, i + 1);
    if (j >= 0) cigar = push_cigar(&n_cigar, &m_cigar, cigar, 1, j + 1);
/*    for (int cj=0; cj < n_cigar; ++cj){
        printf("cigar[%d] = %0x\n", cj, cigar[cj]);
    }*/
    if (!is_rev){
        for (i = 0; i < n_cigar>>1; ++i) // reverse CIGAR
            tmp = cigar[i], cigar[i] = cigar[n_cigar-1-i], cigar[n_cigar-1-i] = tmp;
    }
    ez->m_cigar = m_cigar;
    ez->n_cigar = n_cigar;
    ez->cigar = cigar;
}


#define KSW_EZ_REV_CIGAR   0x80 // reverse CIGAR in the output

void fpga_ksw(int qlen, char* query, int tlen, char *target, int8_t* mat,int o, int ex, int end_bonus, int zdrop, int h0, int flag, ksw_extz_t* ez){
    ez->mqe = MINUS_INF;

    eh_t *eh;
    int8_t *qp;
    int o_del,o_ins;
    int e_del, e_ins;
    o_del = o_ins = o;
    e_del = e_ins = ex;
    int i, j, k, oe_del = o_del + e_del, oe_ins = o_ins + e_ins, beg, end, max, max_i, max_j, max_ins, max_del, max_ie, gscore, max_off;
    max_i = max_j = -1;
    int m = 5;
    qp = (int8_t*)malloc(qlen*m);
    eh = (eh_t*)calloc(qlen+1, 8);

    for (k=i=0; k<m; ++k){
        const int8_t *p = &mat[k*m];
        for (j=0; j<qlen; ++j) qp[i++] = p[query[j]];
    }

    //eh[0].h = h0; eh[1].h = h0 > oe_ins? h0 - oe_ins : 0;// h0是right extension之前已有的score，相当于该位置之前所有已经匹配的bp的score，eh[0]是最左上角的score，eh[1]是第一个gap open之后的score
    eh[0].h = h0; eh[1].h = h0 - oe_ins ;//cj
    for (j = 1; j <= qlen ; ++j){// 只保留了score大于0的部分
        eh[j].e = MINUS_INF;// 每次gap extend惩罚分为1，这里计算的是从第一个gap open处开始，依次往后extend并将score值递减，直到extension结束或者score为0
        eh[j].h = -(o_ins + (j)* e_ins);
        int temp = -(o_ins*2+(j)*e_ins/2);
        eh[j].h = eh[j].h > temp ? eh[j].h : temp;
    }

    k = m*m;
    max = 0;
    beg=0, end = qlen;
    uint8_t **z;
    z = (uint8_t**)malloc(tlen*sizeof(uint8_t*));
    for (i=0; i<tlen; i++){
        z[i] = (uint8_t*)malloc(qlen*sizeof(uint8_t));
    }

    eh[0].e = MINUS_INF, eh[1].e = MINUS_INF;

    for (i=0; LIKELY(i<tlen); ++i){
        int t, f = MINUS_INF, h1, m = 0, mj = -1, e;
        int8_t *q = &qp[target[i] * qlen];// target[i]是reference中对应位置上的字符，q指向query profile的某一行起始位置，对应的行号是reference中的字符
        if (beg == 0){
            h1 = h0 - (o_del + e_del * (i + 1));
            //if (h1 < 0) h1=0;
        } else h1=0;
        int row_max_socre = 0;
        int max_q = MINUS_INF;
        for (j=0; LIKELY(j<qlen); ++j){
            eh_t *p = &eh[j];
            uint8_t d;
            int h, M=p->h; e= p->e;
            p->h = h1;// set H(i,j-1) for the next row

            M = M+q[j] ;
            h = M > e ? M : e;
            d = M >e ? 0 : 1;
            h = h > f ? h : f;
            d = h > f ? d : 2;
            //printf("%d ", h);
            if (i == tlen-1){
                max_q = row_max_socre > h ? max_q : j;
                row_max_socre = row_max_socre > h ? row_max_socre : h;
            }

            if (i == tlen-1 && j==qlen-1){
                ez->score = h;
            }

            h1 = h;
            // 记录这一hang中最大的score值及其位置信息
            mj = m > h? mj : j; // record the position where max score is achieved，这个mj记录是的整个score matrix中的得分最大的位置序号
            m = m > h? m : h;   // m is stored at eh[mj+1]，m记录的整个score matrix中的最高得分

            // 计算E(i+1,j)
            t = M - oe_del; // M = H(i-1,j-1) + S(i,j); M是假设上面一行是match或者mismatch，所以应该是gap0 + gape oedel = 7
            //t = t > 0? t : 0;//t = H(i,j) - gapo - gape
            e -= e_del;// E(i,j) - gape
            e = e > t? e : t;   // computed E(i+1,j)
            d |= e > t? 1<<2 : 0;
            p->e = e;           // save E(i+1,j) for the next row
            // 计算F(i,j+1)
            t = M - oe_ins;
            //t = t > 0? t : 0;// t = H(i,j) - gapo - gape
            f -= e_ins;// f = F(i,j) - gape
            f = f > t? f : t;   // computed F(i,j+1)
            d |= f > t? 2<<4 : 0;
            z[i][j] = d;

        }
        //printf("\n");
        eh[end].h = h1; eh[end].e = 0;
        if (j == qlen) { //cj: we default query end
            max_ie = gscore > h1? max_ie : i;// h1=H(i,j=end), h1是extend达到read结束位置时的score，max_ie记录extend达到read结束位置且取得最佳score时，对应的reference中的序号
            gscore = gscore > h1? gscore : h1;// gscore记录extend达到read结束位置时的最佳score
            ez->mqe = ez->mqe > h1 ? ez->mqe : h1;
            ez->mqe_t = ez->mqe > h1 ? ez->mqe_t : i;
        }
        if (i == tlen-1){
            ez->mte_q = max_q;
            ez->mte = row_max_socre;
        }

        if (m > max){
            max = m, max_i = i, max_j = mj;
        }
    }

    ez->max = max;
    ez->max_q = max_j;
    ez->max_t = max_i;
    int tracback_rpos = max_i;
    int tracback_qpos = max_j;
    if (ez->mqe + end_bonus > ez->max){
        ez->reach_end = 1;
        tracback_rpos = ez->mqe_t;
        tracback_qpos = qlen -1;
    }
    if (!ez->zdropped && !(flag&KSW_EZ_EXTZ_ONLY)){
        tracback_qpos = qlen-1;
        tracback_rpos = tlen -1;
    }

    int is_rev  = !!(flag & KSW_EZ_REV_CIGAR);

    traceback(z, tracback_qpos, tracback_rpos, is_rev,  ez);
    free(qp);
    free(eh);
    for (i=0; i<tlen; i++){
        free(z[i]);
    }
    free(z);
}

void fpga_ksw2(int qlen, char* query, int tlen, char *target, int8_t* mat,int o, int ex, int end_bonus, int zdrop, int h0, int flag, ksw_extz_t* ez){
    int en = (tlen+15)/16 * 16-1 ;
    ez->mqe = MINUS_INF;
    eh_t *eh;
    eh_t *eh2;
    int8_t *qp;
    int o_del,o_ins,e_del,e_ins;
    int o_del2, o_ins2, e_del2, e_ins2;
    o_del = o_ins = o;
    o_del2 = o_ins2 = 2 * o;
    e_del = e_ins = ex;
    e_del2 = e_ins2 = ex/2;
    int i, j, k, oe_del = o_del + e_del, oe_ins = o_ins + e_ins, max, max_i, max_j, max_ie, gscore;
    int oe_del2 = o_del2 + e_del2;
    int oe_ins2 = o_ins2 + e_ins2;
    max_i = max_j = -1;
    int m = 5;
    qp = (int8_t*)malloc(qlen*m);
    eh = (eh_t*)calloc(qlen+1, 8);
    eh2 = (eh_t*)calloc(qlen+1, 8);

    // initialize the qp
    for (k=i=0; k<m; ++k){
        const int8_t *p = &mat[k*m];
        for (j=0; j<qlen; ++j) qp[i++] = p[query[j]];
    }
    // initialize the first row of H and e
    eh[0].h = h0; //cj
    eh[0].e = MINUS_INF;
    for (j = 1; j <= qlen ; ++j){// 只保留了score大于0的部分
        // 每次gap extend惩罚分为1，这里计算的是从第一个gap open处开始，依次往后extend并将score值递减，直到extension结束或者score为0
        eh[j].h = h0 -(o_ins + (j)* e_ins);
        int temp = h0 -(o_ins*2+(j)*e_ins/2);
        eh[j].h = eh[j].h > temp ? eh[j].h : temp;
        eh[j].e = eh[j].h - oe_ins;
    }
    eh2[0].h = h0;
    eh2[0].e = MINUS_INF;
    for (j = 1; j <= qlen ; ++j){// 只保留了score大于0的部分
        // 每次gap extend惩罚分为1，这里计算的是从第一个gap open处开始，依次往后extend并将score值递减，直到extension结束或者score为0
        eh2[j].h = h0 -(o_ins + (j)* e_ins);
        int temp = h0 -(o_ins*2+(j)*e_ins/2);
        eh2[j].h = eh[j].h > temp ? eh2[j].h : temp;
        eh2[j].e = eh2[j].h - oe_ins2;

    }
    //initialize the traceback martix
    k = m*m;
    max = 0;
    uint8_t **z;
    z = (uint8_t**)malloc(tlen*sizeof(uint8_t*));
    for (i=0; i<tlen; i++){
        z[i] = (uint8_t*)malloc(qlen*sizeof(uint8_t));
    }
    int h = 0;
    //printf("qlen-tlen :%d-%d\n", qlen, tlen);
/*    FILE *file = fopen("tlen.txt","a+");
    if (!file) perror("Error open the qlen.txt");
    fprintf(file, "%d\n", tlen);
    fclose(file);*/

    for (i=0; LIKELY(i<tlen); ++i){
        int t, t2,  m = MINUS_INF, mj = -1, e, e2;
        int8_t *q = &qp[target[i] * qlen]; //qp的大小为qlen*m

        int h1 = h0 - (o_del + e_del * (i+1)); //对-1列H进行初始化
        int h2 = h0 - (o_del2 + e_del2 * (i+1)); // 对第0列的F进行初始化
        int f=h1 - oe_del, f2 = h2 - oe_del2;
        int temp = h0 - (o_del2 + e_del2*(i+1));
        h1 = h1 > temp ? h1 : temp;
        int row_max_score =MINUS_INF, max_q;
        if(i==0){
            f = f2 = MINUS_INF;
        }
/*        printf("num : %d\n", i);
        if (i == 8){
            printf("debug");
        }*/

        for (j=0; LIKELY(j<qlen); ++j){

            eh_t *p = &eh[j];
            eh_t *p2 = &eh2[j];
            uint8_t d;
            int M=p->h; e= p->e, e2= p2->e; //
            p->h = h1, p2->h = h1;// set H(i,j-1) for the next row

            //compute the H(i,j)=max{H(i-1,j-1)+s(i,j), e(i,j),f(i,j),e2(i,j),f2(i,j)}
            //printf("input:M=%d E1=%d E2=%d F1=%d F2=%d\n", M, e, e2,f, f2);
            M = M + q[j];
            e = e > e2 ? e : e2;
            h = M > e ? M : e;
            d = M > e ? 0 : 1;
            f = f > f2 ? f : f2;
            h = h > f ? h : f;
            d = h > f ? d : 2;

            if (i == tlen-1){
                max_q = row_max_score >= h ? max_q : i+j-en;
                row_max_score = row_max_score > h ? row_max_score : h;
            }
            h1 = h;
            mj = m > h ? mj : j;
            m = m > h ? m : h; //

            //compute E(i+1, j) E2(i+1, j)
            t = M - oe_del, t2 = M - oe_del2;
            e = e - e_del, e2 = e2 - e_del2;
            e = e > t ? e : t;
            e2 = e2 > t2 ? e2 : t2;
            d |= e > t ? 1<<2 : 0;
            p->e = e, p2->e = e2;

            //compute F(i, j+1), F2(i, j+1)
            t = M - oe_ins, t2 = M - oe_ins2;
            f = f - e_ins, f2 = f2 - e_ins2;
            f = f > t ? f : t;
            f2 = f2 > t2 ? f2 : t2;
            d |= f > t ? 2<<4 : 0;
            z[i][j] = d;
          //  printf("output:M=%d E1=%d E2=%d F1=%d F2=%d D= %x \n", h, e, e2,f, f2, d);
        }
        eh[qlen].h = h1; eh[qlen].e = 0;
        eh2[qlen].h = h1; eh2[qlen].e = 0;

        if (j == qlen) { //cj: we default query end
            max_ie = gscore > h1? max_ie : i;// h1=H(i,j=end),
            gscore = gscore > h1? gscore : h1;//
            ez->mqe_t = ez->mqe >= h1 ? ez->mqe_t : i;
            ez->mqe = ez->mqe > h1 ? ez->mqe : h1;
        }
        if (i == tlen-1){
            ez->mte_q = max_q;
            ez->mte = row_max_score;
        }
        if (m > max){
            max = m, max_i = i, max_j = mj;
        }else{
            if((max - m > zdrop + abs((abs(i - max_i) - abs(mj - max_j))) * e_del)){
                ez->zdropped = 1;
                ez->score = MINUS_INF;
            }
        }

    }
    if (i == tlen && j==qlen){
        ez->score = h;
    }

    ez->max = max;
    ez->max_q = max_j;
    ez->max_t = max_i;
    int tracback_rpos = max_i;
    int tracback_qpos = max_j;
    if (ez->mqe + end_bonus > ez->max){
        ez->reach_end = 1;
        tracback_rpos = ez->mqe_t;
        tracback_qpos = qlen -1;
    }
    if (!ez->zdropped && !(flag&KSW_EZ_EXTZ_ONLY)){
        tracback_qpos = qlen-1;
        tracback_rpos = tlen -1;
    }
    int is_rev  = !!(flag & KSW_EZ_REV_CIGAR);

    traceback(z, tracback_qpos, tracback_rpos, is_rev,  ez);
    free(qp);
    free(eh);
    for (i=0; i<tlen; i++){
        free(z[i]);
    }
    free(z);

}


typedef struct{
    int32_t qlen;
    int32_t tlen;
    char *qseq;
    char *tseq;
    int32_t flag;
}fpga_input;
void test(){
/*    int qlen = 76;
    int tlen = 76;
    int o = 6;
    int e = 1;
    int end_bonus = 10;
*//*    char query[76]  = {'T','G','C','T','G','C','C','T','G','C','T','A','G','A','G','A','T','C','C','C','G','A',
    'T','G','T','C','C','C','C','C','A','C','T','C','A','G','G','G','T','C','A','C','T','A','A','C',
    'T','G','T','G','G','C','T','C','T','C','T','C','T','C','C','C','C','A','G','G','A','G','G',
    'G','C','T','G','T','C','G'};
    char target[76]  = {'T','G','C','T','G','C','C','T','G','C','T','A','G','A','G','A','T','C','C','C','G','A',
                       'T','G','T','C','C','C','C','C','A','C','T','C','A','G','G','G','T','C','A','C','T','A','A','C',
                       'T','G','T','G','G','C','A','C','T','C','T','C','T','C','C','C','C','A','G','G','A','G','G',
                       'G','C','T','G','T','C','G'};

    DNA2num(76, query);
    DNA2num(76, target);*//*

    matParameter matpara;
    matpara.m = 5;
    matpara.N_penalty = 1;
    matpara.match = 2;
    matpara.mismatch = 8;
    int h0 = 0;
    int zdrop = 100;

    *//*******************Read temp file******************//*
    FILE *file;
    file = fopen("../../Output/fpga_test2.txt","rb");
    if (!file) exit(1);

    while(!feof(file)){
        ksw_extz_t ez;
        memset(&ez, 0, sizeof(ksw_extz_t));
        char qseq[100];
        char tseq[100];

        memset(&ez, 0, sizeof(ksw_extz_t));
        fpga_input input;
        input.tseq = (char*)malloc(100*sizeof(uint8_t));
        input.qseq = (char*)malloc(100*sizeof(uint8_t));
        fscanf(file,"%d %d %d",&input.flag,&(input.qlen),&(input.tlen));
        fgets(input.qseq,77,file); //using putc function maybe put \0
        fgets(input.tseq,input.tlen+1,file);
        strcpy(tseq,input.tseq);
        strcpy(qseq,input.qseq);
        fpga_ksw(input.qlen, input.qseq, input.tlen, input.tseq, &matpara, o, e, zdrop, end_bonus, h0, input.flag, &ez);
        free(input.tseq);
        free(input.qseq);
    }*/
}
