cmake_minimum_required(VERSION 3.9)
project(minimap_test)

set(CMAKE_CXX_STANDARD 11)
#set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -pg")

include_directories(include)

aux_source_directory(./ SRC)

add_executable(minimap_test ${SRC} final_test_data_in.cpp final_test_data_in.h)

target_link_libraries(minimap_test pthread)

