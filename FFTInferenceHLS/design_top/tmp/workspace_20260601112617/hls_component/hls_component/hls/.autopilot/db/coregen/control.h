// 0x00 : reserved
// 0x04 : reserved
// 0x08 : reserved
// 0x0c : reserved
// 0x10 : Data signal of input_real
//        bit 31~0 - input_real[31:0] (Read/Write)
// 0x14 : Data signal of input_real
//        bit 31~0 - input_real[63:32] (Read/Write)
// 0x18 : reserved
// 0x1c : Data signal of input_imag
//        bit 31~0 - input_imag[31:0] (Read/Write)
// 0x20 : Data signal of input_imag
//        bit 31~0 - input_imag[63:32] (Read/Write)
// 0x24 : reserved
// 0x28 : Data signal of output_real
//        bit 31~0 - output_real[31:0] (Read/Write)
// 0x2c : Data signal of output_real
//        bit 31~0 - output_real[63:32] (Read/Write)
// 0x30 : reserved
// 0x34 : Data signal of output_imag
//        bit 31~0 - output_imag[31:0] (Read/Write)
// 0x38 : Data signal of output_imag
//        bit 31~0 - output_imag[63:32] (Read/Write)
// 0x3c : reserved
// (SC = Self Clear, COR = Clear on Read, TOW = Toggle on Write, COH = Clear on Handshake)

#define CONTROL_ADDR_INPUT_REAL_DATA  0x10
#define CONTROL_BITS_INPUT_REAL_DATA  64
#define CONTROL_ADDR_INPUT_IMAG_DATA  0x1c
#define CONTROL_BITS_INPUT_IMAG_DATA  64
#define CONTROL_ADDR_OUTPUT_REAL_DATA 0x28
#define CONTROL_BITS_OUTPUT_REAL_DATA 64
#define CONTROL_ADDR_OUTPUT_IMAG_DATA 0x34
#define CONTROL_BITS_OUTPUT_IMAG_DATA 64
