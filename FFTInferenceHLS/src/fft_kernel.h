#ifndef FFT_KERNEL_H
#define FFT_KERNEL_H

#include <ap_fixed.h>
#include <ap_int.h>

#define N 1024
#define NUM_FRAMES 50
#define NUM_STAGES 10

typedef int fixed_t;

extern "C" {
void fft_kernel(
    fixed_t *input_real,
    fixed_t *input_imag,
    fixed_t *output_real,
    fixed_t *output_imag
);
}

#endif