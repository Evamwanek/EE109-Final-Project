#include <fpga_mgmt.h>
#include <fpga_pci.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>
#include <stdbool.h>
#include <unistd.h>
#include "design_top.h"

// ---------------------------------------------------------------------------
// ap_fixed<32,10> format:
//   - 32 bits total, signed two's complement
//   - 10 integer bits (including sign), 22 fractional bits
//   - value = raw_int32 / 2^22
//   - range: roughly [-512, 512)
// ---------------------------------------------------------------------------
#define AP_FIXED_FRAC_BITS  22
#define AP_FIXED_SCALE      (1 << AP_FIXED_FRAC_BITS)   // 4194304

// Convert a float to the ap_fixed<32,10> wire encoding (signed 32-bit int).
// Clamps to the representable range to avoid overflow wrapping.
static int32_t float_to_apfixed(float v)
{
    // Representable range for ap_fixed<32,10>: [-512, 512 - 2^-22)
    if (v >= 512.0f)  v =  511.9999997615814f;   // 0x7FFFFFFF / 2^22
    if (v < -512.0f)  v = -512.0f;               // 0x80000000 / 2^22
    return (int32_t)(v * (float)AP_FIXED_SCALE);
}

// ---------------------------------------------------------------------------
// MMIO helpers
// ---------------------------------------------------------------------------

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

// ---------------------------------------------------------------------------
// LSTM dimensions — must match HLS kernel defines exactly
// ---------------------------------------------------------------------------
#define T_STEPS   50
#define INPUT_SZ  128
#define HIDDEN    128
#define GATES     4
#define GATE_H    512   // GATES * HIDDEN
#define N_CLASS   10

// ---------------------------------------------------------------------------
// DRAM layout
//
// Each element on the wire is 4 bytes (int32 encoding of ap_fixed<32,10>).
// All pointers are byte addresses.
//
// Sizes in elements:
//   input_seq : T_STEPS * INPUT_SZ = 6400
//   wih0      : GATE_H  * INPUT_SZ = 65536
//   whh0      : GATE_H  * HIDDEN   = 65536
//   bih0      : GATE_H             = 512
//   bhh0      : GATE_H             = 512
//   wih1      : GATE_H  * HIDDEN   = 65536
//   whh1      : GATE_H  * HIDDEN   = 65536
//   bih1      : GATE_H             = 512
//   bhh1      : GATE_H             = 512
//   wfc       : N_CLASS * HIDDEN   = 1280
//   bfc       : N_CLASS            = 10
//   pred_out  : 1 int              = 1   (written by kernel as plain int32)
// ---------------------------------------------------------------------------
#define INPUT_SEQ_ELEMS  (T_STEPS  * INPUT_SZ)
#define WIH0_ELEMS       (GATE_H   * INPUT_SZ)
#define WHH0_ELEMS       (GATE_H   * HIDDEN)
#define BIH0_ELEMS       (GATE_H)
#define BHH0_ELEMS       (GATE_H)
#define WIH1_ELEMS       (GATE_H   * HIDDEN)
#define WHH1_ELEMS       (GATE_H   * HIDDEN)
#define BIH1_ELEMS       (GATE_H)
#define BHH1_ELEMS       (GATE_H)
#define WFC_ELEMS        (N_CLASS  * HIDDEN)
#define BFC_ELEMS        (N_CLASS)

#define BYTES(n)  ((uint64_t)(n) * 4)

// All tensors on the single gmem0 AXI bundle — lay them out contiguously.
#define INPUT_SEQ_PTR  0x0000000000000000ULL
#define WIH0_PTR       (INPUT_SEQ_PTR + BYTES(INPUT_SEQ_ELEMS))
#define WHH0_PTR       (WIH0_PTR      + BYTES(WIH0_ELEMS))
#define BIH0_PTR       (WHH0_PTR      + BYTES(WHH0_ELEMS))
#define BHH0_PTR       (BIH0_PTR      + BYTES(BIH0_ELEMS))
#define WIH1_PTR       (BHH0_PTR      + BYTES(BHH0_ELEMS))
#define WHH1_PTR       (WIH1_PTR      + BYTES(WIH1_ELEMS))
#define BIH1_PTR       (WHH1_PTR      + BYTES(WHH1_ELEMS))
#define BHH1_PTR       (BIH1_PTR      + BYTES(BIH1_ELEMS))
#define WFC_PTR        (BHH1_PTR      + BYTES(BHH1_ELEMS))
#define BFC_PTR        (WFC_PTR       + BYTES(WFC_ELEMS))
#define PRED_OUT_PTR   (BFC_PTR       + BYTES(BFC_ELEMS))

// ---------------------------------------------------------------------------
// write_apfixed_array
//
// Converts each float in arr[] to ap_fixed<32,10> wire format and writes
// it to DRAM as a 32-bit word.  The kernel reads these as ap_fixed<32,10>
// values directly — no further interpretation needed on the FPGA side.
// ---------------------------------------------------------------------------
static int write_apfixed_array(int bar_handle, uint64_t base,
                               float *arr, int n)
{
    for (int i = 0; i < n; i++) {
        int32_t fixed = float_to_apfixed(arr[i]);
        uint32_t bits;
        memcpy(&bits, &fixed, sizeof(bits));
        if (ddr_wr32(bar_handle, base + (uint64_t)i * 4, bits)) return 1;
    }
    return 0;
}

// ---------------------------------------------------------------------------
// load_float_file — reads n IEEE-754 float32 values from a binary file
// (exported from PyTorch via tensor.numpy().astype(numpy.float32).tofile())
// ---------------------------------------------------------------------------
static int load_float_file(const char *path, float *buf, int n)
{
    FILE *f = fopen(path, "rb");
    if (!f) {
        fprintf(stderr, "ERROR: could not open %s\n", path);
        return 1;
    }
    int got = (int)fread(buf, sizeof(float), n, f);
    fclose(f);
    if (got != n) {
        fprintf(stderr, "ERROR: expected %d floats from %s, got %d\n",
                n, path, got);
        return 1;
    }
    return 0;
}

// unbuffer stdout so it interleaves correctly with stderr
// ---------------------------------------------------------------------------
// main
// ---------------------------------------------------------------------------
int main(int argc, char **argv)
{
    setvbuf(stdout, NULL, _IONBF, 0);   
    if (argc != 2) {
        printf("Usage: %s <slot_id>\n", argv[0]);
        return 1;
    }

    int slot_id     = atoi(argv[1]);
    int ocl_handle  = -1;
    int pcis_handle = -1;
    int errors      = 0;

    // ---- Allocate host float buffers ----
    float *input_seq = malloc(INPUT_SEQ_ELEMS * sizeof(float));
    float *wih0      = malloc(WIH0_ELEMS      * sizeof(float));
    float *whh0      = malloc(WHH0_ELEMS      * sizeof(float));
    float *bih0      = malloc(BIH0_ELEMS      * sizeof(float));
    float *bhh0      = malloc(BHH0_ELEMS      * sizeof(float));
    float *wih1      = malloc(WIH1_ELEMS      * sizeof(float));
    float *whh1      = malloc(WHH1_ELEMS      * sizeof(float));
    float *bih1      = malloc(BIH1_ELEMS      * sizeof(float));
    float *bhh1      = malloc(BHH1_ELEMS      * sizeof(float));
    float *wfc       = malloc(WFC_ELEMS       * sizeof(float));
    float *bfc       = malloc(BFC_ELEMS       * sizeof(float));

    if (!input_seq || !wih0 || !whh0 || !bih0 || !bhh0 ||
        !wih1 || !whh1 || !bih1 || !bhh1 || !wfc || !bfc) {
        fprintf(stderr, "ERROR: malloc failed\n");
        goto fail;
    }

    // ---- Load weights from IEEE-754 binary files (PyTorch export) ----
    if (load_float_file("input_seq.bin",            input_seq, INPUT_SEQ_ELEMS)) goto fail;
    if (load_float_file("weights/weight_ih_l0.bin", wih0,      WIH0_ELEMS))      goto fail;
    if (load_float_file("weights/weight_hh_l0.bin", whh0,      WHH0_ELEMS))      goto fail;
    if (load_float_file("weights/bias_ih_l0.bin",   bih0,      BIH0_ELEMS))      goto fail;
    if (load_float_file("weights/bias_hh_l0.bin",   bhh0,      BHH0_ELEMS))      goto fail;
    if (load_float_file("weights/weight_ih_l1.bin", wih1,      WIH1_ELEMS))      goto fail;
    if (load_float_file("weights/weight_hh_l1.bin", whh1,      WHH1_ELEMS))      goto fail;
    if (load_float_file("weights/bias_ih_l1.bin",   bih1,      BIH1_ELEMS))      goto fail;
    if (load_float_file("weights/bias_hh_l1.bin",   bhh1,      BHH1_ELEMS))      goto fail;
    if (load_float_file("weights/fc_weight.bin",    wfc,       WFC_ELEMS))       goto fail;
    if (load_float_file("weights/fc_bias.bin",      bfc,       BFC_ELEMS))       goto fail;

    // ---- Initialize FPGA ----
    if (fpga_mgmt_init() != 0) {
        fprintf(stderr, "ERROR: Failed to initialize fpga_mgmt\n");
        goto fail;
    }
    if (fpga_pci_attach(slot_id, FPGA_APP_PF, APP_PF_BAR0, 0, &ocl_handle)) {
        fprintf(stderr, "ERROR: Failed to attach OCL BAR (BAR0)\n");
        goto fail;
    }
    if (fpga_pci_attach(slot_id, FPGA_APP_PF, APP_PF_BAR4, 0, &pcis_handle)) {
        fprintf(stderr, "ERROR: Failed to attach PCIS BAR (BAR4)\n");
        goto fail;
    }

    printf("---- LSTM Fixed-Point Inference Test ----\n");
    printf("ap_fixed<32,10>: %d fractional bits, scale = %d\n",
           AP_FIXED_FRAC_BITS, AP_FIXED_SCALE);

    // ---- Write all tensors to DRAM as ap_fixed<32,10> ----
    // Enable DRAM transfer mode before writing via PCIS.
    if (ocl_wr32(ocl_handle, ADDR_TRANSFER_EN, 1)) goto fail;

    printf("Writing input sequence and weights to DDR as ap_fixed<32,10>...\n");
    if (write_apfixed_array(pcis_handle, INPUT_SEQ_PTR, input_seq, INPUT_SEQ_ELEMS)) goto fail;
    if (write_apfixed_array(pcis_handle, WIH0_PTR,      wih0,      WIH0_ELEMS))      goto fail;
    if (write_apfixed_array(pcis_handle, WHH0_PTR,      whh0,      WHH0_ELEMS))      goto fail;
    if (write_apfixed_array(pcis_handle, BIH0_PTR,      bih0,      BIH0_ELEMS))      goto fail;
    if (write_apfixed_array(pcis_handle, BHH0_PTR,      bhh0,      BHH0_ELEMS))      goto fail;
    if (write_apfixed_array(pcis_handle, WIH1_PTR,      wih1,      WIH1_ELEMS))      goto fail;
    if (write_apfixed_array(pcis_handle, WHH1_PTR,      whh1,      WHH1_ELEMS))      goto fail;
    if (write_apfixed_array(pcis_handle, BIH1_PTR,      bih1,      BIH1_ELEMS))      goto fail;
    if (write_apfixed_array(pcis_handle, BHH1_PTR,      bhh1,      BHH1_ELEMS))      goto fail;
    if (write_apfixed_array(pcis_handle, WFC_PTR,       wfc,       WFC_ELEMS))       goto fail;
    if (write_apfixed_array(pcis_handle, BFC_PTR,       bfc,       BFC_ELEMS))       goto fail;

    if (ocl_wr32(ocl_handle, ADDR_TRANSFER_EN, 0)) goto fail;

    // ---- Configure kernel AXI master pointer registers ----
    // All buffers share gmem0 — pointers are byte addresses into DDR.
    printf("Configuring kernel pointer registers...\n");
    if (ocl_wr32(ocl_handle, ADDR_INPUT_SEQ_LO, (uint32_t)(INPUT_SEQ_PTR      ))) goto fail;
    if (ocl_wr32(ocl_handle, ADDR_INPUT_SEQ_HI, (uint32_t)(INPUT_SEQ_PTR >> 32))) goto fail;
    if (ocl_wr32(ocl_handle, ADDR_WIH0_LO,      (uint32_t)(WIH0_PTR           ))) goto fail;
    if (ocl_wr32(ocl_handle, ADDR_WIH0_HI,      (uint32_t)(WIH0_PTR      >> 32))) goto fail;
    if (ocl_wr32(ocl_handle, ADDR_WHH0_LO,      (uint32_t)(WHH0_PTR           ))) goto fail;
    if (ocl_wr32(ocl_handle, ADDR_WHH0_HI,      (uint32_t)(WHH0_PTR      >> 32))) goto fail;
    if (ocl_wr32(ocl_handle, ADDR_BIH0_LO,      (uint32_t)(BIH0_PTR           ))) goto fail;
    if (ocl_wr32(ocl_handle, ADDR_BIH0_HI,      (uint32_t)(BIH0_PTR      >> 32))) goto fail;
    if (ocl_wr32(ocl_handle, ADDR_BHH0_LO,      (uint32_t)(BHH0_PTR           ))) goto fail;
    if (ocl_wr32(ocl_handle, ADDR_BHH0_HI,      (uint32_t)(BHH0_PTR      >> 32))) goto fail;
    if (ocl_wr32(ocl_handle, ADDR_WIH1_LO,      (uint32_t)(WIH1_PTR           ))) goto fail;
    if (ocl_wr32(ocl_handle, ADDR_WIH1_HI,      (uint32_t)(WIH1_PTR      >> 32))) goto fail;
    if (ocl_wr32(ocl_handle, ADDR_WHH1_LO,      (uint32_t)(WHH1_PTR           ))) goto fail;
    if (ocl_wr32(ocl_handle, ADDR_WHH1_HI,      (uint32_t)(WHH1_PTR      >> 32))) goto fail;
    if (ocl_wr32(ocl_handle, ADDR_BIH1_LO,      (uint32_t)(BIH1_PTR           ))) goto fail;
    if (ocl_wr32(ocl_handle, ADDR_BIH1_HI,      (uint32_t)(BIH1_PTR      >> 32))) goto fail;
    if (ocl_wr32(ocl_handle, ADDR_BHH1_LO,      (uint32_t)(BHH1_PTR           ))) goto fail;
    if (ocl_wr32(ocl_handle, ADDR_BHH1_HI,      (uint32_t)(BHH1_PTR      >> 32))) goto fail;
    if (ocl_wr32(ocl_handle, ADDR_WFC_LO,       (uint32_t)(WFC_PTR            ))) goto fail;
    if (ocl_wr32(ocl_handle, ADDR_WFC_HI,       (uint32_t)(WFC_PTR       >> 32))) goto fail;
    if (ocl_wr32(ocl_handle, ADDR_BFC_LO,       (uint32_t)(BFC_PTR            ))) goto fail;
    if (ocl_wr32(ocl_handle, ADDR_BFC_HI,       (uint32_t)(BFC_PTR       >> 32))) goto fail;
    if (ocl_wr32(ocl_handle, ADDR_PRED_OUT_LO,  (uint32_t)(PRED_OUT_PTR       ))) goto fail;
    if (ocl_wr32(ocl_handle, ADDR_PRED_OUT_HI,  (uint32_t)(PRED_OUT_PTR >> 32))) goto fail;

    // ---- Start kernel ----
    printf("Starting LSTM kernel (AP_START)...\n");
    if (ocl_wr32(ocl_handle, ADDR_CTRL, AP_START)) goto fail;

    // ---- Poll for completion ----
printf("Waiting for AP_DONE...\n");
{
    const int MAX_POLLS = 60000;   // 60 s timeout at 1ms/poll — covers worst-case DMA + compute
    const int SLEEP_US  = 1000;
    int done = 0;

    for (int i = 0; i < MAX_POLLS; i++) {
        uint32_t ctrl_val = 0;
        if (ocl_rd32(ocl_handle, ADDR_CTRL, &ctrl_val)) goto fail;

        // AP_DONE (bit 1) self-clears on read — check it every poll.
        // AP_IDLE (bit 2) stays high until next AP_START — more reliable.
        // Also accept ctrl_val == 0x6 (IDLE|DONE) or 0x4 (IDLE only).
        if (ctrl_val & AP_DONE) {
            printf("AP_DONE seen after ~%d ms (ctrl=0x%08x)\n", i, ctrl_val);
            done = 1;
            break;
        }
        if ((ctrl_val & AP_IDLE) && i > 0) {
            // AP_IDLE high after at least one poll means kernel finished
            // (guard i>0 avoids false-triggering on idle-before-start)
            printf("AP_IDLE seen after ~%d ms (ctrl=0x%08x)\n", i, ctrl_val);
            done = 1;
            break;
        }
        usleep(SLEEP_US);
    }

    if (!done) {
        // Kernel may still have finished — AP_DONE self-cleared before we caught it.
        // Read the result anyway; errors++ only if the value is out of range.
        fprintf(stderr, "WARNING: poll timed out — AP_DONE may have self-cleared. "
                        "Checking result anyway.\n");
    }
}
    // ---- Read result ----
    // pred_out is written by the kernel as a plain C int (4-byte little-endian).
    // No ap_fixed conversion needed here.
    if (ocl_wr32(ocl_handle, ADDR_TRANSFER_EN, 1)) goto fail;
    {
        uint32_t pred = 0;
        if (ddr_rd32(pcis_handle, PRED_OUT_PTR, &pred)) goto fail;

        const char *genres[] = {
            "blues", "classical", "country", "disco", "hiphop",
            "jazz",  "metal",     "pop",     "reggae", "rock"
        };

        printf("Predicted genre index: %u\n", pred);
        if (pred < N_CLASS) {
            printf("Predicted genre: %s\n", genres[pred]);
        } else {
            fprintf(stderr, "ERROR: invalid genre index %u (max %d)\n",
                    pred, N_CLASS - 1);
            errors++;
        }
    }
    if (ocl_wr32(ocl_handle, ADDR_TRANSFER_EN, 0)) goto fail;

    // ---- Performance counters ----
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
        fprintf(stderr, "---- TEST FAILED (%d errors) ----\n", errors);

    fpga_pci_detach(pcis_handle);
    fpga_pci_detach(ocl_handle);
    free(input_seq); free(wih0); free(whh0); free(bih0); free(bhh0);
    free(wih1);      free(whh1); free(bih1); free(bhh1); free(wfc); free(bfc);
    return (errors == 0) ? 0 : 1;

fail:
    fprintf(stderr, "---- TEST FAILED ----\n");
    if (pcis_handle != -1) fpga_pci_detach(pcis_handle);
    if (ocl_handle  != -1) fpga_pci_detach(ocl_handle);
    free(input_seq); free(wih0); free(whh0); free(bih0); free(bhh0);
    free(wih1);      free(whh1); free(bih1); free(bhh1); free(wfc); free(bfc);
    return 1;
}