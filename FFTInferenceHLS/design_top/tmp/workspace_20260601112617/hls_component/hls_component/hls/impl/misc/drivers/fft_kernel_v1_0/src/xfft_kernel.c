// ==============================================================
// Vitis HLS - High-Level Synthesis from C, C++ and OpenCL v2024.1 (64-bit)
// Tool Version Limit: 2024.05
// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2024 Advanced Micro Devices, Inc. All Rights Reserved.
// 
// ==============================================================
/***************************** Include Files *********************************/
#include "xfft_kernel.h"

/************************** Function Implementation *************************/
#ifndef __linux__
int XFft_kernel_CfgInitialize(XFft_kernel *InstancePtr, XFft_kernel_Config *ConfigPtr) {
    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(ConfigPtr != NULL);

    InstancePtr->Control_BaseAddress = ConfigPtr->Control_BaseAddress;
    InstancePtr->IsReady = XIL_COMPONENT_IS_READY;

    return XST_SUCCESS;
}
#endif

void XFft_kernel_Set_input_real(XFft_kernel *InstancePtr, u64 Data) {
    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    XFft_kernel_WriteReg(InstancePtr->Control_BaseAddress, XFFT_KERNEL_CONTROL_ADDR_INPUT_REAL_DATA, (u32)(Data));
    XFft_kernel_WriteReg(InstancePtr->Control_BaseAddress, XFFT_KERNEL_CONTROL_ADDR_INPUT_REAL_DATA + 4, (u32)(Data >> 32));
}

u64 XFft_kernel_Get_input_real(XFft_kernel *InstancePtr) {
    u64 Data;

    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Data = XFft_kernel_ReadReg(InstancePtr->Control_BaseAddress, XFFT_KERNEL_CONTROL_ADDR_INPUT_REAL_DATA);
    Data += (u64)XFft_kernel_ReadReg(InstancePtr->Control_BaseAddress, XFFT_KERNEL_CONTROL_ADDR_INPUT_REAL_DATA + 4) << 32;
    return Data;
}

void XFft_kernel_Set_input_imag(XFft_kernel *InstancePtr, u64 Data) {
    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    XFft_kernel_WriteReg(InstancePtr->Control_BaseAddress, XFFT_KERNEL_CONTROL_ADDR_INPUT_IMAG_DATA, (u32)(Data));
    XFft_kernel_WriteReg(InstancePtr->Control_BaseAddress, XFFT_KERNEL_CONTROL_ADDR_INPUT_IMAG_DATA + 4, (u32)(Data >> 32));
}

u64 XFft_kernel_Get_input_imag(XFft_kernel *InstancePtr) {
    u64 Data;

    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Data = XFft_kernel_ReadReg(InstancePtr->Control_BaseAddress, XFFT_KERNEL_CONTROL_ADDR_INPUT_IMAG_DATA);
    Data += (u64)XFft_kernel_ReadReg(InstancePtr->Control_BaseAddress, XFFT_KERNEL_CONTROL_ADDR_INPUT_IMAG_DATA + 4) << 32;
    return Data;
}

void XFft_kernel_Set_output_real(XFft_kernel *InstancePtr, u64 Data) {
    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    XFft_kernel_WriteReg(InstancePtr->Control_BaseAddress, XFFT_KERNEL_CONTROL_ADDR_OUTPUT_REAL_DATA, (u32)(Data));
    XFft_kernel_WriteReg(InstancePtr->Control_BaseAddress, XFFT_KERNEL_CONTROL_ADDR_OUTPUT_REAL_DATA + 4, (u32)(Data >> 32));
}

u64 XFft_kernel_Get_output_real(XFft_kernel *InstancePtr) {
    u64 Data;

    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Data = XFft_kernel_ReadReg(InstancePtr->Control_BaseAddress, XFFT_KERNEL_CONTROL_ADDR_OUTPUT_REAL_DATA);
    Data += (u64)XFft_kernel_ReadReg(InstancePtr->Control_BaseAddress, XFFT_KERNEL_CONTROL_ADDR_OUTPUT_REAL_DATA + 4) << 32;
    return Data;
}

void XFft_kernel_Set_output_imag(XFft_kernel *InstancePtr, u64 Data) {
    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    XFft_kernel_WriteReg(InstancePtr->Control_BaseAddress, XFFT_KERNEL_CONTROL_ADDR_OUTPUT_IMAG_DATA, (u32)(Data));
    XFft_kernel_WriteReg(InstancePtr->Control_BaseAddress, XFFT_KERNEL_CONTROL_ADDR_OUTPUT_IMAG_DATA + 4, (u32)(Data >> 32));
}

u64 XFft_kernel_Get_output_imag(XFft_kernel *InstancePtr) {
    u64 Data;

    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Data = XFft_kernel_ReadReg(InstancePtr->Control_BaseAddress, XFFT_KERNEL_CONTROL_ADDR_OUTPUT_IMAG_DATA);
    Data += (u64)XFft_kernel_ReadReg(InstancePtr->Control_BaseAddress, XFFT_KERNEL_CONTROL_ADDR_OUTPUT_IMAG_DATA + 4) << 32;
    return Data;
}

