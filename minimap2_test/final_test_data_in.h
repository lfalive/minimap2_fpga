//
// Created by fpga-0 on 20-12-22.
//

#ifndef MINIMAP_TEST_FINAL_TEST_DATA_IN_H
#define MINIMAP_TEST_FINAL_TEST_DATA_IN_H

void TestGenerateData(fpga_data_input* data, int id_tmp, int data_length );
void TestDataToBuffer(fpga_data_input* Data, ByteBuffer &buffer);
void TestTofile(ByteBuffer SendBuffer, int data_length, int data_num, int PE_NUM);
void test_data_in();

#endif //MINIMAP_TEST_FINAL_TEST_DATA_IN_H

