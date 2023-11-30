#include <iostream>
#include <time.h>
#include "ksw2.h"
#include "fpga_sw.h"
#include "ByteBuffer.hpp"
#include "cpu_test.h"
#include "fpga_test.h"
#include "sim_data_in.h"
#include "final_test_data_in.h"

int main() {

    //std::cout << "Calculate start" << std::endl;

    //sim_data();
    //test_data_in();






    //result_package_test();

    for (int i=0; i<1; i++){

      //  cpu_test();
       // sse2_test();
      //  fpga_test();
        // cigar_test();


    }

    int data_length[14] = {5,8,12,20,30,50,80,100,200,400,800,1000,1500,2000};
    int data_num[5] = {1,10,100,1000,10000};
    int PE_NUM = 8;
    for (int i=0; i<14; ++i){

        for(int j=0; j<1; ++j){

            //Test_cpu(PE_NUM, data_length[i], data_num[j]);
            Test_sse2(PE_NUM, data_length[i], data_num[j]);
        }
    }


    //std::cout << "Calculate finish" << std::endl;
    return 0;
}
