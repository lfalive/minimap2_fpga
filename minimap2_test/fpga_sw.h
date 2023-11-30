//
// Created by cj on 8/1/19.
//

#ifndef MINIMAP_TEST_FPGA_SW_H
#define MINIMAP_TEST_FPGA_SW_H

#ifdef __cplusplus
extern "C"{
#endif

#include <stdint.h>
#include "ksw2.h"


void fpga_ksw2(int qlen, char *query, int tlen, char *target, int8_t *mat, int o, int e, int end_bonus, int zdrop, int h0,
          int flag, ksw_extz_t *ez);
//===================E N D =======================//

#ifdef __cplusplus
}
#endif

#endif //MINIMAP_TEST_FPGA_SW_H
