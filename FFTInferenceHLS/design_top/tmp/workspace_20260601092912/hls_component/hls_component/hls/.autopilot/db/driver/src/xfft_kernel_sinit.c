// ==============================================================
// Vitis HLS - High-Level Synthesis from C, C++ and OpenCL v2024.1 (64-bit)
// Tool Version Limit: 2024.05
// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2024 Advanced Micro Devices, Inc. All Rights Reserved.
// 
// ==============================================================
#ifndef __linux__

#include "xstatus.h"
#ifdef SDT
#include "xparameters.h"
#endif
#include "xfft_kernel.h"

extern XFft_kernel_Config XFft_kernel_ConfigTable[];

#ifdef SDT
XFft_kernel_Config *XFft_kernel_LookupConfig(UINTPTR BaseAddress) {
	XFft_kernel_Config *ConfigPtr = NULL;

	int Index;

	for (Index = (u32)0x0; XFft_kernel_ConfigTable[Index].Name != NULL; Index++) {
		if (!BaseAddress || XFft_kernel_ConfigTable[Index].Control_BaseAddress == BaseAddress) {
			ConfigPtr = &XFft_kernel_ConfigTable[Index];
			break;
		}
	}

	return ConfigPtr;
}

int XFft_kernel_Initialize(XFft_kernel *InstancePtr, UINTPTR BaseAddress) {
	XFft_kernel_Config *ConfigPtr;

	Xil_AssertNonvoid(InstancePtr != NULL);

	ConfigPtr = XFft_kernel_LookupConfig(BaseAddress);
	if (ConfigPtr == NULL) {
		InstancePtr->IsReady = 0;
		return (XST_DEVICE_NOT_FOUND);
	}

	return XFft_kernel_CfgInitialize(InstancePtr, ConfigPtr);
}
#else
XFft_kernel_Config *XFft_kernel_LookupConfig(u16 DeviceId) {
	XFft_kernel_Config *ConfigPtr = NULL;

	int Index;

	for (Index = 0; Index < XPAR_XFFT_KERNEL_NUM_INSTANCES; Index++) {
		if (XFft_kernel_ConfigTable[Index].DeviceId == DeviceId) {
			ConfigPtr = &XFft_kernel_ConfigTable[Index];
			break;
		}
	}

	return ConfigPtr;
}

int XFft_kernel_Initialize(XFft_kernel *InstancePtr, u16 DeviceId) {
	XFft_kernel_Config *ConfigPtr;

	Xil_AssertNonvoid(InstancePtr != NULL);

	ConfigPtr = XFft_kernel_LookupConfig(DeviceId);
	if (ConfigPtr == NULL) {
		InstancePtr->IsReady = 0;
		return (XST_DEVICE_NOT_FOUND);
	}

	return XFft_kernel_CfgInitialize(InstancePtr, ConfigPtr);
}
#endif

#endif

