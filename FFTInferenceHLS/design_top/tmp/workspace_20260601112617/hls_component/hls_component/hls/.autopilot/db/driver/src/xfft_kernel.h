// ==============================================================
// Vitis HLS - High-Level Synthesis from C, C++ and OpenCL v2024.1 (64-bit)
// Tool Version Limit: 2024.05
// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2024 Advanced Micro Devices, Inc. All Rights Reserved.
// 
// ==============================================================
#ifndef XFFT_KERNEL_H
#define XFFT_KERNEL_H

#ifdef __cplusplus
extern "C" {
#endif

/***************************** Include Files *********************************/
#ifndef __linux__
#include "xil_types.h"
#include "xil_assert.h"
#include "xstatus.h"
#include "xil_io.h"
#else
#include <stdint.h>
#include <assert.h>
#include <dirent.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/mman.h>
#include <unistd.h>
#include <stddef.h>
#endif
#include "xfft_kernel_hw.h"

/**************************** Type Definitions ******************************/
#ifdef __linux__
typedef uint8_t u8;
typedef uint16_t u16;
typedef uint32_t u32;
typedef uint64_t u64;
#else
typedef struct {
#ifdef SDT
    char *Name;
#else
    u16 DeviceId;
#endif
    u64 Control_BaseAddress;
} XFft_kernel_Config;
#endif

typedef struct {
    u64 Control_BaseAddress;
    u32 IsReady;
} XFft_kernel;

typedef u32 word_type;

/***************** Macros (Inline Functions) Definitions *********************/
#ifndef __linux__
#define XFft_kernel_WriteReg(BaseAddress, RegOffset, Data) \
    Xil_Out32((BaseAddress) + (RegOffset), (u32)(Data))
#define XFft_kernel_ReadReg(BaseAddress, RegOffset) \
    Xil_In32((BaseAddress) + (RegOffset))
#else
#define XFft_kernel_WriteReg(BaseAddress, RegOffset, Data) \
    *(volatile u32*)((BaseAddress) + (RegOffset)) = (u32)(Data)
#define XFft_kernel_ReadReg(BaseAddress, RegOffset) \
    *(volatile u32*)((BaseAddress) + (RegOffset))

#define Xil_AssertVoid(expr)    assert(expr)
#define Xil_AssertNonvoid(expr) assert(expr)

#define XST_SUCCESS             0
#define XST_DEVICE_NOT_FOUND    2
#define XST_OPEN_DEVICE_FAILED  3
#define XIL_COMPONENT_IS_READY  1
#endif

/************************** Function Prototypes *****************************/
#ifndef __linux__
#ifdef SDT
int XFft_kernel_Initialize(XFft_kernel *InstancePtr, UINTPTR BaseAddress);
XFft_kernel_Config* XFft_kernel_LookupConfig(UINTPTR BaseAddress);
#else
int XFft_kernel_Initialize(XFft_kernel *InstancePtr, u16 DeviceId);
XFft_kernel_Config* XFft_kernel_LookupConfig(u16 DeviceId);
#endif
int XFft_kernel_CfgInitialize(XFft_kernel *InstancePtr, XFft_kernel_Config *ConfigPtr);
#else
int XFft_kernel_Initialize(XFft_kernel *InstancePtr, const char* InstanceName);
int XFft_kernel_Release(XFft_kernel *InstancePtr);
#endif


void XFft_kernel_Set_input_real(XFft_kernel *InstancePtr, u64 Data);
u64 XFft_kernel_Get_input_real(XFft_kernel *InstancePtr);
void XFft_kernel_Set_input_imag(XFft_kernel *InstancePtr, u64 Data);
u64 XFft_kernel_Get_input_imag(XFft_kernel *InstancePtr);
void XFft_kernel_Set_output_real(XFft_kernel *InstancePtr, u64 Data);
u64 XFft_kernel_Get_output_real(XFft_kernel *InstancePtr);
void XFft_kernel_Set_output_imag(XFft_kernel *InstancePtr, u64 Data);
u64 XFft_kernel_Get_output_imag(XFft_kernel *InstancePtr);

#ifdef __cplusplus
}
#endif

#endif
