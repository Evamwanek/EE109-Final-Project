#include <fpga_mgmt.h>
#include <fpga_pci.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>
#include <stdbool.h>
#include <unistd.h>
#include <math.h>
#include "design_top.h"

// MMIO helpers
static int ocl_wr32(int bar_handle, uint32_t addr, uint32_t data) {
    if (fpga_pci_poke(bar_handle, addr, data)) {
        fprintf(stderr, "ERROR: OCL write failed at addr=0x%04x\n", addr);
        return 1;
    }
    return 0;
}

static int ocl_rd32(int bar_handle, uint32_t addr, uint32_t *data) {
    if (fpga_pci_peek(bar_handle, addr, data)) {
        fprintf(stderr, "ERROR: OCL read failed at addr=0x%04x\n", addr);
        return 1;
    }
    return 0;
}

static int ddr_wr32(int bar_handle, uint64_t addr, uint32_t data) {
    if (fpga_pci_poke(bar_handle, addr, data)) {
        fprintf(stderr, "ERROR: DDR write failed at addr=0x%016lx\n", addr);
        return 1;
    }
    return 0;
}

static int ddr_rd32(int bar_handle, uint64_t addr, uint32_t *data) {
    if (fpga_pci_peek(bar_handle, addr, data)) {
        fprintf(stderr, "ERROR: DDR read failed at addr=0x%016lx\n", addr);
        return 1;
    }
    return 0;
}

// FFT dimensions
#define N           1024
#define NUM_FRAMES  50
#define TOTAL_SIZE  (N * NUM_FRAMES)

// fixed_t in fft_kernel.h is a signed 32-bit integer
// using Q18.14 fixed-point format.
#define WORD_BYTES 4

#define FRAC_BITS 14
#define FIXED_SCALE (1 << FRAC_BITS)

// DDR layout
#define INPUT_REAL_PTR   0x0000000000000000ULL
#define INPUT_IMAG_PTR   (INPUT_REAL_PTR  + TOTAL_SIZE * WORD_BYTES)
#define OUTPUT_REAL_PTR  (INPUT_IMAG_PTR  + TOTAL_SIZE * WORD_BYTES)
#define OUTPUT_IMAG_PTR  (OUTPUT_REAL_PTR + TOTAL_SIZE * WORD_BYTES)

#define WORD_BYTES 4

#define FRAC_BITS 14
#define FIXED_SCALE (1 << FRAC_BITS)

// DDR layout
#define INPUT_REAL_PTR   0x0000000000000000ULL
#define INPUT_IMAG_PTR   (INPUT_REAL_PTR  + TOTAL_SIZE * WORD_BYTES)
#define OUTPUT_REAL_PTR  (INPUT_IMAG_PTR  + TOTAL_SIZE * WORD_BYTES)
#define OUTPUT_IMAG_PTR  (OUTPUT_REAL_PTR + TOTAL_SIZE * WORD_BYTES)

static uint32_t float_to_fixed_word(float x) {
    int32_t fixed = (int32_t)(x * (float)FIXED_SCALE);

    uint32_t bits;
    memcpy(&bits, &fixed, sizeof(uint32_t));
    return bits;
}

static float fixed_word_to_float(uint32_t bits) {
    int32_t fixed;
    memcpy(&fixed, &bits, sizeof(int32_t));

    return ((float)fixed) / (float)FIXED_SCALE;
}

static int write_test_inputs(int bar_handle) {
    for (int f = 0; f < NUM_FRAMES; f++) {
        for (int i = 0; i < N; i++) {
            // Simple deterministic signal: small sine-like pattern.
            // Avoid needing frames.csv on FPGA runtime.
            float sample = (float)((i % 64) - 32) / 64.0f;
            uint32_t real_bits = float_to_fixed_word(sample);
            uint32_t imag_bits = float_to_fixed_word(0.0f);

            uint64_t idx = f * N + i;

            if (ddr_wr32(bar_handle, INPUT_REAL_PTR + idx * WORD_BYTES, real_bits)) return 1;
            if (ddr_wr32(bar_handle, INPUT_IMAG_PTR + idx * WORD_BYTES, imag_bits)) return 1;
        }
    }
    return 0;
}

int main(int argc, char **argv) {
    if (argc != 2) {
        printf("Usage: %s <slot_id>\n", argv[0]);
        return 1;
    }

    int slot_id = atoi(argv[1]);
    int ocl_handle = -1;
    int pcis_handle = -1;
    int errors = 0;

    if (fpga_mgmt_init() != 0) {
        fprintf(stderr, "Failed to initialize fpga_mgmt\n");
        goto fail;
    }

    if (fpga_pci_attach(slot_id, FPGA_APP_PF, APP_PF_BAR0, 0, &ocl_handle)) {
        fprintf(stderr, "Failed to attach OCL BAR\n");
        goto fail;
    }

    if (fpga_pci_attach(slot_id, FPGA_APP_PF, APP_PF_BAR4, 0, &pcis_handle)) {
        fprintf(stderr, "Failed to attach PCIS BAR\n");
        goto fail;
    }

    printf("---- FFT Inference Test ----\n");

    // Write input data to DDR
    if (ocl_wr32(ocl_handle, ADDR_TRANSFER_EN, 1)) goto fail;

    printf("Loading input frames into DDR...\n");
    if (write_test_inputs(pcis_handle)) goto fail;

    uint32_t check0 = 0, check1 = 0, check2 = 0;

    if (ddr_rd32(pcis_handle, INPUT_REAL_PTR + 0 * WORD_BYTES, &check0)) goto fail;
    if (ddr_rd32(pcis_handle, INPUT_REAL_PTR + 1 * WORD_BYTES, &check1)) goto fail;
    if (ddr_rd32(pcis_handle, INPUT_REAL_PTR + 2 * WORD_BYTES, &check2)) goto fail;

    printf("DEBUG input raw: 0x%08x 0x%08x 0x%08x\n", check0, check1, check2);

    if (ocl_wr32(ocl_handle, ADDR_TRANSFER_EN, 0)) goto fail;

    // Configure FFT kernel pointer registers
    printf("Configuring FFT kernel registers...\n");

    if (ocl_wr32(ocl_handle, ADDR_INPUT_REAL_LO,  (uint32_t)(INPUT_REAL_PTR)))        goto fail;
    if (ocl_wr32(ocl_handle, ADDR_INPUT_REAL_HI,  (uint32_t)(INPUT_REAL_PTR >> 32)))  goto fail;

    if (ocl_wr32(ocl_handle, ADDR_INPUT_IMAG_LO,  (uint32_t)(INPUT_IMAG_PTR)))        goto fail;
    if (ocl_wr32(ocl_handle, ADDR_INPUT_IMAG_HI,  (uint32_t)(INPUT_IMAG_PTR >> 32)))  goto fail;

    if (ocl_wr32(ocl_handle, ADDR_OUTPUT_REAL_LO, (uint32_t)(OUTPUT_REAL_PTR)))       goto fail;
    if (ocl_wr32(ocl_handle, ADDR_OUTPUT_REAL_HI, (uint32_t)(OUTPUT_REAL_PTR >> 32))) goto fail;

    if (ocl_wr32(ocl_handle, ADDR_OUTPUT_IMAG_LO, (uint32_t)(OUTPUT_IMAG_PTR)))       goto fail;
    if (ocl_wr32(ocl_handle, ADDR_OUTPUT_IMAG_HI, (uint32_t)(OUTPUT_IMAG_PTR >> 32))) goto fail;

    // Start kernel
    printf("Starting FFT kernel...\n");
    if (ocl_wr32(ocl_handle, ADDR_CTRL, AP_START)) goto fail;

    // Wait for completion
    printf("Waiting for completion...\n");

    // uint32_t ctrl = 0;
    // int timeout = 1000000;

    // do {
    //     if (ocl_rd32(ocl_handle, ADDR_CTRL, &ctrl)) goto fail;
    //     timeout--;
    // } while (((ctrl & 0x2) == 0) && timeout > 0);

    // printf("DEBUG ctrl after wait = 0x%08x\n", ctrl);

    // if (timeout == 0) {
    //     fprintf(stderr, "ERROR: FFT kernel timeout waiting for ap_done\n");
    //     errors++;
    // }

    printf("Waiting for completion...\n");
 usleep(500000);   // 0.5 seconds

    // Read back a few outputs and sanity-check
    if (ocl_wr32(ocl_handle, ADDR_TRANSFER_EN, 1)) goto fail;

    printf("Reading FFT outputs...\n");

    int nonzero_count = 0;
    for (int i = 0; i < 16; i++) {
        uint32_t real_bits = 0;
        uint32_t imag_bits = 0;

        if (ddr_rd32(pcis_handle, OUTPUT_REAL_PTR + i * WORD_BYTES, &real_bits)) goto fail;
        if (ddr_rd32(pcis_handle, OUTPUT_IMAG_PTR + i * WORD_BYTES, &imag_bits)) goto fail;

        float real_val = fixed_word_to_float(real_bits);
        float imag_val = fixed_word_to_float(imag_bits);

        printf("FFT[%d] = %f + %fi\n", i, real_val, imag_val);

        if (fabsf(real_val) > 0.000001f || fabsf(imag_val) > 0.000001f) {
            nonzero_count++;
        }
    }

    if (nonzero_count == 0) {
        fprintf(stderr, "ERROR: FFT output appears to be all zero.\n");
        errors++;
    }

    if (ocl_wr32(ocl_handle, ADDR_TRANSFER_EN, 0)) goto fail;

    // Read cycle counters
    {
        uint32_t compute_cyc = 0;
        uint32_t transfer_cyc = 0;

        if (ocl_rd32(ocl_handle, ADDR_COMPUTE_CYCLES,  &compute_cyc))  goto fail;
        if (ocl_rd32(ocl_handle, ADDR_TRANSFER_CYCLES, &transfer_cyc)) goto fail;

        printf("Compute cycles:  %u\n", compute_cyc);
        printf("Transfer cycles: %u\n", transfer_cyc);
    }

    if (errors == 0) {
        printf("---- TEST PASSED ----\n");
    } else {
        fprintf(stderr, "---- TEST FAILED ----\n");
    }

    fpga_pci_detach(pcis_handle);
    fpga_pci_detach(ocl_handle);
    return (errors == 0) ? 0 : 1;

fail:
    fprintf(stderr, "TEST FAILED\n");
    if (pcis_handle != -1) fpga_pci_detach(pcis_handle);
    if (ocl_handle != -1) fpga_pci_detach(ocl_handle);
    return 1;
}