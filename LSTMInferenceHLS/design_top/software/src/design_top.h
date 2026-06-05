#ifndef DESIGN_TOP_H
#define DESIGN_TOP_H
#include <stdint.h>

// HLS vadd kernel control register offsets (AXI-Lite, OCL BAR)
#define ADDR_CTRL     0x0000
#define AP_START      (1 << 0)   // bit 0: write 1 to start kernel
#define AP_DONE       (1 << 1)   // bit 1: set by kernel on completion (clears on read)
#define AP_IDLE       (1 << 2)   // bit 2: high when kernel is idle/ready

// Cycle counter registers (read-only via OCL)
#define ADDR_COMPUTE_CYCLES  0x0100
#define ADDR_TRANSFER_CYCLES 0x0104
#define ADDR_TRANSFER_EN     0x0108

// LSTM kernel pointer registers
// Each pointer is split into LO (lower 32 bits) and HI (upper 32 bits)
#define ADDR_INPUT_SEQ_LO  0x0010
#define ADDR_INPUT_SEQ_HI  0x0014
#define ADDR_WIH0_LO       0x001C
#define ADDR_WIH0_HI       0x0020
#define ADDR_WHH0_LO       0x0028
#define ADDR_WHH0_HI       0x002C
#define ADDR_BIH0_LO       0x0034
#define ADDR_BIH0_HI       0x0038
#define ADDR_BHH0_LO       0x0040
#define ADDR_BHH0_HI       0x0044
#define ADDR_WIH1_LO       0x004C
#define ADDR_WIH1_HI       0x0050
#define ADDR_WHH1_LO       0x0058
#define ADDR_WHH1_HI       0x005C
#define ADDR_BIH1_LO       0x0064
#define ADDR_BIH1_HI       0x0068
#define ADDR_BHH1_LO       0x0070
#define ADDR_BHH1_HI       0x0074
#define ADDR_WFC_LO        0x007C
#define ADDR_WFC_HI        0x0080
#define ADDR_BFC_LO        0x0088
#define ADDR_BFC_HI        0x008C
#define ADDR_PRED_OUT_LO   0x0094
#define ADDR_PRED_OUT_HI   0x0098

#endif // DESIGN_TOP_H