#include <fpga_mgmt.h>
#include <fpga_pci.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>
#include <stdbool.h>
#include <unistd.h>
#include "design_top.h"

// --- MMIO helpers ---

static int ocl_wr32(int bar_handle, uint32_t addr, uint32_t data)
{
    if (fpga_pci_poke(bar_handle, addr, data)) {
        fprintf(stderr, "ERROR: OCL write failed at addr=0x%04x\n", addr);
        return 1;
    }
    return 0;
}

static int ocl_rd32(int bar_handle, uint32_t addr, uint32_t *data)
{
    if (fpga_pci_peek(bar_handle, addr, data)) {
        fprintf(stderr, "ERROR: OCL read failed at addr=0x%04x\n", addr);
        return 1;
    }
    return 0;
}

static int ddr_wr32(int bar_handle, uint64_t addr, uint32_t data)
{
    if (fpga_pci_poke(bar_handle, addr, data)) {
        fprintf(stderr, "ERROR: DDR write failed at addr=0x%016lx\n", addr);
        return 1;
    }
    return 0;
}

static int ddr_rd32(int bar_handle, uint64_t addr, uint32_t *data)
{
    if (fpga_pci_peek(bar_handle, addr, data)) {
        fprintf(stderr, "ERROR: DDR read failed at addr=0x%016lx\n", addr);
        return 1;
    }
    return 0;
}

// --- LSTM dimensions ---
#define T_STEPS   50
#define INPUT_SZ  128
#define HIDDEN    128
#define GATES     4
#define GATE_H    512
#define N_CLASS   10

// --- DRAM layout (each region padded to 4-byte alignment) ---
// input_seq: T_STEPS * INPUT_SZ floats = 6400 floats = 25600 bytes
// wih0:      GATE_H * INPUT_SZ floats  = 65536 floats = 262144 bytes
// whh0:      GATE_H * HIDDEN floats    = 65536 floats = 262144 bytes
// bih0:      GATE_H floats             = 512 floats   = 2048 bytes
// bhh0:      GATE_H floats             = 512 floats   = 2048 bytes
// wih1:      GATE_H * HIDDEN floats    = 65536 floats = 262144 bytes
// whh1:      GATE_H * HIDDEN floats    = 65536 floats = 262144 bytes
// bih1:      GATE_H floats             = 512 floats   = 2048 bytes
// bhh1:      GATE_H floats             = 512 floats   = 2048 bytes
// wfc:       N_CLASS * HIDDEN floats   = 1280 floats  = 5120 bytes
// bfc:       N_CLASS floats            = 10 floats    = 40 bytes
// pred_out:  1 int                     = 4 bytes

#define INPUT_SEQ_SIZE  (T_STEPS  * INPUT_SZ)
#define WIH0_SIZE       (GATE_H   * INPUT_SZ)
#define WHH0_SIZE       (GATE_H   * HIDDEN)
#define BIH0_SIZE       (GATE_H)
#define BHH0_SIZE       (GATE_H)
#define WIH1_SIZE       (GATE_H   * HIDDEN)
#define WHH1_SIZE       (GATE_H   * HIDDEN)
#define BIH1_SIZE       (GATE_H)
#define BHH1_SIZE       (GATE_H)
#define WFC_SIZE        (N_CLASS  * HIDDEN)
#define BFC_SIZE        (N_CLASS)

// DRAM base addresses (in bytes, float = 4 bytes)
#define INPUT_SEQ_PTR   0x0000000000000000ULL
#define WIH0_PTR        (INPUT_SEQ_PTR + INPUT_SEQ_SIZE * 4)
#define WHH0_PTR        (WIH0_PTR      + WIH0_SIZE      * 4)
#define BIH0_PTR        (WHH0_PTR      + WHH0_SIZE      * 4)
#define BHH0_PTR        (BIH0_PTR      + BIH0_SIZE      * 4)
#define WIH1_PTR        (BHH0_PTR      + BHH0_SIZE      * 4)
#define WHH1_PTR        (WIH1_PTR      + WIH1_SIZE      * 4)
#define BIH1_PTR        (WHH1_PTR      + WHH1_SIZE      * 4)
#define BHH1_PTR        (BIH1_PTR      + BIH1_SIZE      * 4)
#define WFC_PTR         (BHH1_PTR      + BHH1_SIZE      * 4)
#define BFC_PTR         (WFC_PTR       + WFC_SIZE        * 4)
#define PRED_OUT_PTR    (BFC_PTR       + BFC_SIZE        * 4)

// Helper: write a float array to DRAM
static int write_float_array(int bar_handle, uint64_t base, float *arr, int n)
{
    for (int i = 0; i < n; i++) {
        uint32_t bits;
        memcpy(&bits, &arr[i], sizeof(float));
        if (ddr_wr32(bar_handle, base + i * 4, bits)) return 1;
    }
    return 0;
}

// Helper: load a binary float file
static int load_float_file(const char *path, float *buf, int n)
{
    FILE *f = fopen(path, "rb");
    if (!f) {
        fprintf(stderr, "ERROR: could not open %s\n", path);
        return 1;
    }
    int read = fread(buf, sizeof(float), n, f);
    fclose(f);
    if (read != n) {
        fprintf(stderr, "ERROR: expected %d floats from %s, got %d\n", n, path, read);
        return 1;
    }
    return 0;
}

int main(int argc, char **argv)
{
    if (argc != 2) {
        printf("Usage: %s <slot_id>\n", argv[0]);
        return 1;
    }

    int slot_id     = atoi(argv[1]);
    int ocl_handle  = -1;
    int pcis_handle = -1;
    int errors      = 0;

    // Allocate weight buffers
    float *input_seq = malloc(INPUT_SEQ_SIZE * sizeof(float));
    float *wih0      = malloc(WIH0_SIZE      * sizeof(float));
    float *whh0      = malloc(WHH0_SIZE      * sizeof(float));
    float *bih0      = malloc(BIH0_SIZE      * sizeof(float));
    float *bhh0      = malloc(BHH0_SIZE      * sizeof(float));
    float *wih1      = malloc(WIH1_SIZE      * sizeof(float));
    float *whh1      = malloc(WHH1_SIZE      * sizeof(float));
    float *bih1      = malloc(BIH1_SIZE      * sizeof(float));
    float *bhh1      = malloc(BHH1_SIZE      * sizeof(float));
    float *wfc       = malloc(WFC_SIZE        * sizeof(float));
    float *bfc       = malloc(BFC_SIZE        * sizeof(float));

    // Load weights from binary files
    // These are exported from PyTorch using numpy's tofile()
    if (load_float_file("input_seq.bin",            input_seq, INPUT_SEQ_SIZE)) goto fail;
    if (load_float_file("weights/weight_ih_l0.bin", wih0,      WIH0_SIZE))      goto fail;
    if (load_float_file("weights/weight_hh_l0.bin", whh0,      WHH0_SIZE))      goto fail;
    if (load_float_file("weights/bias_ih_l0.bin",   bih0,      BIH0_SIZE))      goto fail;
    if (load_float_file("weights/bias_hh_l0.bin",   bhh0,      BHH0_SIZE))      goto fail;
    if (load_float_file("weights/weight_ih_l1.bin", wih1,      WIH1_SIZE))      goto fail;
    if (load_float_file("weights/weight_hh_l1.bin", whh1,      WHH1_SIZE))      goto fail;
    if (load_float_file("weights/bias_ih_l1.bin",   bih1,      BIH1_SIZE))      goto fail;
    if (load_float_file("weights/bias_hh_l1.bin",   bhh1,      BHH1_SIZE))      goto fail;
    if (load_float_file("weights/fc_weight.bin",    wfc,       WFC_SIZE))       goto fail;
    if (load_float_file("weights/fc_bias.bin",      bfc,       BFC_SIZE))       goto fail;
    // Initialize FPGA
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

    printf("---- LSTM Inference Test ----\n");

    // Write all data to DRAM
    if (ocl_wr32(ocl_handle, ADDR_TRANSFER_EN, 1)) goto fail;

    printf("Loading input sequence and weights into DDR...\n");
    if (write_float_array(pcis_handle, INPUT_SEQ_PTR, input_seq, INPUT_SEQ_SIZE)) goto fail;
    if (write_float_array(pcis_handle, WIH0_PTR,      wih0,      WIH0_SIZE))      goto fail;
    if (write_float_array(pcis_handle, WHH0_PTR,      whh0,      WHH0_SIZE))      goto fail;
    if (write_float_array(pcis_handle, BIH0_PTR,      bih0,      BIH0_SIZE))      goto fail;
    if (write_float_array(pcis_handle, BHH0_PTR,      bhh0,      BHH0_SIZE))      goto fail;
    if (write_float_array(pcis_handle, WIH1_PTR,      wih1,      WIH1_SIZE))      goto fail;
    if (write_float_array(pcis_handle, WHH1_PTR,      whh1,      WHH1_SIZE))      goto fail;
    if (write_float_array(pcis_handle, BIH1_PTR,      bih1,      BIH1_SIZE))      goto fail;
    if (write_float_array(pcis_handle, BHH1_PTR,      bhh1,      BHH1_SIZE))      goto fail;
    if (write_float_array(pcis_handle, WFC_PTR,       wfc,       WFC_SIZE))       goto fail;
    if (write_float_array(pcis_handle, BFC_PTR,       bfc,       BFC_SIZE))       goto fail;

    if (ocl_wr32(ocl_handle, ADDR_TRANSFER_EN, 0)) goto fail;

    // Configure kernel pointers
    printf("Configuring LSTM kernel registers...\n");
    if (ocl_wr32(ocl_handle, ADDR_INPUT_SEQ_LO, (uint32_t)(INPUT_SEQ_PTR)))        goto fail;
    if (ocl_wr32(ocl_handle, ADDR_INPUT_SEQ_HI, (uint32_t)(INPUT_SEQ_PTR >> 32)))  goto fail;
    if (ocl_wr32(ocl_handle, ADDR_WIH0_LO,      (uint32_t)(WIH0_PTR)))             goto fail;
    if (ocl_wr32(ocl_handle, ADDR_WIH0_HI,      (uint32_t)(WIH0_PTR >> 32)))       goto fail;
    if (ocl_wr32(ocl_handle, ADDR_WHH0_LO,      (uint32_t)(WHH0_PTR)))             goto fail;
    if (ocl_wr32(ocl_handle, ADDR_WHH0_HI,      (uint32_t)(WHH0_PTR >> 32)))       goto fail;
    if (ocl_wr32(ocl_handle, ADDR_BIH0_LO,      (uint32_t)(BIH0_PTR)))             goto fail;
    if (ocl_wr32(ocl_handle, ADDR_BIH0_HI,      (uint32_t)(BIH0_PTR >> 32)))       goto fail;
    if (ocl_wr32(ocl_handle, ADDR_BHH0_LO,      (uint32_t)(BHH0_PTR)))             goto fail;
    if (ocl_wr32(ocl_handle, ADDR_BHH0_HI,      (uint32_t)(BHH0_PTR >> 32)))       goto fail;
    if (ocl_wr32(ocl_handle, ADDR_WIH1_LO,      (uint32_t)(WIH1_PTR)))             goto fail;
    if (ocl_wr32(ocl_handle, ADDR_WIH1_HI,      (uint32_t)(WIH1_PTR >> 32)))       goto fail;
    if (ocl_wr32(ocl_handle, ADDR_WHH1_LO,      (uint32_t)(WHH1_PTR)))             goto fail;
    if (ocl_wr32(ocl_handle, ADDR_WHH1_HI,      (uint32_t)(WHH1_PTR >> 32)))       goto fail;
    if (ocl_wr32(ocl_handle, ADDR_BIH1_LO,      (uint32_t)(BIH1_PTR)))             goto fail;
    if (ocl_wr32(ocl_handle, ADDR_BIH1_HI,      (uint32_t)(BIH1_PTR >> 32)))       goto fail;
    if (ocl_wr32(ocl_handle, ADDR_BHH1_LO,      (uint32_t)(BHH1_PTR)))             goto fail;
    if (ocl_wr32(ocl_handle, ADDR_BHH1_HI,      (uint32_t)(BHH1_PTR >> 32)))       goto fail;
    if (ocl_wr32(ocl_handle, ADDR_WFC_LO,       (uint32_t)(WFC_PTR)))              goto fail;
    if (ocl_wr32(ocl_handle, ADDR_WFC_HI,       (uint32_t)(WFC_PTR >> 32)))        goto fail;
    if (ocl_wr32(ocl_handle, ADDR_BFC_LO,       (uint32_t)(BFC_PTR)))              goto fail;
    if (ocl_wr32(ocl_handle, ADDR_BFC_HI,       (uint32_t)(BFC_PTR >> 32)))        goto fail;
    if (ocl_wr32(ocl_handle, ADDR_PRED_OUT_LO,  (uint32_t)(PRED_OUT_PTR)))         goto fail;
    if (ocl_wr32(ocl_handle, ADDR_PRED_OUT_HI,  (uint32_t)(PRED_OUT_PTR >> 32)))   goto fail;

    // Start kernel
    printf("Starting LSTM kernel...\n");
    if (ocl_wr32(ocl_handle, ADDR_CTRL, AP_START)) goto fail;

    // Wait for completion
    printf("Waiting for completion...\n");
    usleep(3000000);

    // Read result
    if (ocl_wr32(ocl_handle, ADDR_TRANSFER_EN, 1)) goto fail;
    {
        uint32_t pred = 0;
        if (ddr_rd32(pcis_handle, PRED_OUT_PTR, &pred)) goto fail;

        const char *genres[] = {
            "blues", "classical", "country", "disco", "hiphop",
            "jazz", "metal", "pop", "reggae", "rock"
        };

        printf("Predicted genre index: %u\n", pred);
        if (pred < N_CLASS) {
            printf("Predicted genre: %s\n", genres[pred]);
        } else {
            fprintf(stderr, "ERROR: invalid genre index %u\n", pred);
            errors++;
        }
    }
    if (ocl_wr32(ocl_handle, ADDR_TRANSFER_EN, 0)) goto fail;

    // Read cycle counters
    {
        uint32_t compute_cyc = 0, transfer_cyc = 0;
        if (ocl_rd32(ocl_handle, ADDR_COMPUTE_CYCLES,  &compute_cyc))  goto fail;
        if (ocl_rd32(ocl_handle, ADDR_TRANSFER_CYCLES, &transfer_cyc)) goto fail;
        printf("Compute cycles:  %u\n", compute_cyc);
        printf("Transfer cycles: %u\n", transfer_cyc);
    }

    if (errors == 0)
        printf("---- TEST PASSED ----\n");
    else
        fprintf(stderr, "---- TEST FAILED ----\n");

    fpga_pci_detach(pcis_handle);
    fpga_pci_detach(ocl_handle);
    free(input_seq); free(wih0); free(whh0); free(bih0); free(bhh0);
    free(wih1); free(whh1); free(bih1); free(bhh1); free(wfc); free(bfc);
    return (errors == 0) ? 0 : 1;

fail:
    fprintf(stderr, "TEST FAILED\n");
    if (pcis_handle != -1) fpga_pci_detach(pcis_handle);
    if (ocl_handle  != -1) fpga_pci_detach(ocl_handle);
    return 1;
}
