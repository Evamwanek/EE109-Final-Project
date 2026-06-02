#ifndef DESIGN_TOP_H
#define DESIGN_TOP_H

#include <stdint.h>

// Kernel control register offsets
#define ADDR_CTRL     0x0000
#define AP_START      (1 << 0)
#define AP_DONE       (1 << 1)

// Cycle counter registers
#define ADDR_COMPUTE_CYCLES   0x0100
#define ADDR_TRANSFER_CYCLES  0x0104
#define ADDR_TRANSFER_EN      0x0108

// FFT kernel pointer registers
#define ADDR_INPUT_REAL_LO    0x0010
#define ADDR_INPUT_REAL_HI    0x0014

#define ADDR_INPUT_IMAG_LO    0x001C
#define ADDR_INPUT_IMAG_HI    0x0020

#define ADDR_OUTPUT_REAL_LO   0x0028
#define ADDR_OUTPUT_REAL_HI   0x002C

#define ADDR_OUTPUT_IMAG_LO   0x0034
#define ADDR_OUTPUT_IMAG_HI   0x0038

#endif // DESIGN_TOP_H