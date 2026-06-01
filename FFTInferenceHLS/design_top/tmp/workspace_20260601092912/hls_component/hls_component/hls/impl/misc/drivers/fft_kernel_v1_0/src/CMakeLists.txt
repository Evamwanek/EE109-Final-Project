# ==============================================================
# Vitis HLS - High-Level Synthesis from C, C++ and OpenCL v2024.1 (64-bit)
# Tool Version Limit: 2024.05
# Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
# Copyright 2022-2024 Advanced Micro Devices, Inc. All Rights Reserved.
# 
# ==============================================================
cmake_minimum_required(VERSION 3.15)
project(fft_kernel)
find_package(common)
collector_create (PROJECT_LIB_SOURCES "${CMAKE_CURRENT_SOURCE_DIR}")
collect (PROJECT_LIB_SOURCES xfft_kernel.c)
collect (PROJECT_LIB_SOURCES xfft_kernel_sinit.c)
collect (PROJECT_LIB_SOURCES xfft_kernel_linux.c)
collect (PROJECT_LIB_SOURCES xfft_kernel_g.c)
collector_list (_sources PROJECT_LIB_SOURCES)
collector_create (PROJECT_LIB_HEADERS "${CMAKE_CURRENT_SOURCE_DIR}")
collect (PROJECT_LIB_HEADERS xfft_kernel.h)
collect (PROJECT_LIB_HEADERS xfft_kernel_hw.h)
collector_list (_headers PROJECT_LIB_HEADERS)
file(COPY ${_headers} DESTINATION ${CMAKE_BINARY_DIR}/include)
include_directories(${CMAKE_BINARY_DIR}/include)
add_library(fft_kernel STATIC ${_sources})
set_target_properties(fft_kernel PROPERTIES LINKER_LANGUAGE C)

