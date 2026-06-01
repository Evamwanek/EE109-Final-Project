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

void XFft_kernel_Start(XFft_kernel *InstancePtr) {
    u32 Data;

    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Data = XFft_kernel_ReadReg(InstancePtr->Control_BaseAddress, XFFT_KERNEL_CONTROL_ADDR_AP_CTRL) & 0x80;
    XFft_kernel_WriteReg(InstancePtr->Control_BaseAddress, XFFT_KERNEL_CONTROL_ADDR_AP_CTRL, Data | 0x01);
}

u32 XFft_kernel_IsDone(XFft_kernel *InstancePtr) {
    u32 Data;

    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Data = XFft_kernel_ReadReg(InstancePtr->Control_BaseAddress, XFFT_KERNEL_CONTROL_ADDR_AP_CTRL);
    return (Data >> 1) & 0x1;
}

u32 XFft_kernel_IsIdle(XFft_kernel *InstancePtr) {
    u32 Data;

    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Data = XFft_kernel_ReadReg(InstancePtr->Control_BaseAddress, XFFT_KERNEL_CONTROL_ADDR_AP_CTRL);
    return (Data >> 2) & 0x1;
}

u32 XFft_kernel_IsReady(XFft_kernel *InstancePtr) {
    u32 Data;

    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Data = XFft_kernel_ReadReg(InstancePtr->Control_BaseAddress, XFFT_KERNEL_CONTROL_ADDR_AP_CTRL);
    // check ap_start to see if the pcore is ready for next input
    return !(Data & 0x1);
}

void XFft_kernel_EnableAutoRestart(XFft_kernel *InstancePtr) {
    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    XFft_kernel_WriteReg(InstancePtr->Control_BaseAddress, XFFT_KERNEL_CONTROL_ADDR_AP_CTRL, 0x80);
}

void XFft_kernel_DisableAutoRestart(XFft_kernel *InstancePtr) {
    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    XFft_kernel_WriteReg(InstancePtr->Control_BaseAddress, XFFT_KERNEL_CONTROL_ADDR_AP_CTRL, 0);
}

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

void XFft_kernel_InterruptGlobalEnable(XFft_kernel *InstancePtr) {
    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    XFft_kernel_WriteReg(InstancePtr->Control_BaseAddress, XFFT_KERNEL_CONTROL_ADDR_GIE, 1);
}

void XFft_kernel_InterruptGlobalDisable(XFft_kernel *InstancePtr) {
    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    XFft_kernel_WriteReg(InstancePtr->Control_BaseAddress, XFFT_KERNEL_CONTROL_ADDR_GIE, 0);
}

void XFft_kernel_InterruptEnable(XFft_kernel *InstancePtr, u32 Mask) {
    u32 Register;

    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Register =  XFft_kernel_ReadReg(InstancePtr->Control_BaseAddress, XFFT_KERNEL_CONTROL_ADDR_IER);
    XFft_kernel_WriteReg(InstancePtr->Control_BaseAddress, XFFT_KERNEL_CONTROL_ADDR_IER, Register | Mask);
}

void XFft_kernel_InterruptDisable(XFft_kernel *InstancePtr, u32 Mask) {
    u32 Register;

    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Register =  XFft_kernel_ReadReg(InstancePtr->Control_BaseAddress, XFFT_KERNEL_CONTROL_ADDR_IER);
    XFft_kernel_WriteReg(InstancePtr->Control_BaseAddress, XFFT_KERNEL_CONTROL_ADDR_IER, Register & (~Mask));
}

void XFft_kernel_InterruptClear(XFft_kernel *InstancePtr, u32 Mask) {
    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    XFft_kernel_WriteReg(InstancePtr->Control_BaseAddress, XFFT_KERNEL_CONTROL_ADDR_ISR, Mask);
}

u32 XFft_kernel_InterruptGetEnabled(XFft_kernel *InstancePtr) {
    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    return XFft_kernel_ReadReg(InstancePtr->Control_BaseAddress, XFFT_KERNEL_CONTROL_ADDR_IER);
}

u32 XFft_kernel_InterruptGetStatus(XFft_kernel *InstancePtr) {
    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    return XFft_kernel_ReadReg(InstancePtr->Control_BaseAddress, XFFT_KERNEL_CONTROL_ADDR_ISR);
}

