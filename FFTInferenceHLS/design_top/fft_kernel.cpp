#include "fft_kernel.h"
#include <hls_math.h>

static int bit_reverse(int x) {
    int y = 0;
    for (int i = 0; i < NUM_STAGES; i++) {
        y = (y << 1) | (x & 1);
        x >>= 1;
    }
    return y;
}

extern "C" {
void fft_kernel(
    fixed_t *input_real,
    fixed_t *input_imag,
    fixed_t *output_real,
    fixed_t *output_imag
) {
#pragma HLS INTERFACE m_axi port=input_real  offset=slave bundle=gmem0
#pragma HLS INTERFACE m_axi port=input_imag  offset=slave bundle=gmem1
#pragma HLS INTERFACE m_axi port=output_real offset=slave bundle=gmem2
#pragma HLS INTERFACE m_axi port=output_imag offset=slave bundle=gmem3

#pragma HLS INTERFACE s_axilite port=input_real  bundle=control
#pragma HLS INTERFACE s_axilite port=input_imag  bundle=control
#pragma HLS INTERFACE s_axilite port=output_real bundle=control
#pragma HLS INTERFACE s_axilite port=output_imag bundle=control
#pragma HLS INTERFACE s_axilite port=return      bundle=control

    fixed_t real[N];
    fixed_t imag[N];
    fixed_t tmp_real[N];
    fixed_t tmp_imag[N];
    fixed_t out_real[N];
    fixed_t out_imag[N];

#pragma HLS BIND_STORAGE variable=real type=ram_2p impl=bram
#pragma HLS BIND_STORAGE variable=imag type=ram_2p impl=bram
#pragma HLS BIND_STORAGE variable=tmp_real type=ram_2p impl=bram
#pragma HLS BIND_STORAGE variable=tmp_imag type=ram_2p impl=bram

    for (int f = 0; f < NUM_FRAMES; f++) {

        // Load frame from DDR
        for (int i = 0; i < N; i++) {
#pragma HLS PIPELINE II=1
            real[i] = input_real[f * N + i];
            imag[i] = input_imag[f * N + i];
        }

        // Hamming window
        for (int i = 0; i < N; i++) {
#pragma HLS PIPELINE II=1
            fixed_t w = 0.54 - 0.46 * hls::cosf(2.0f * 3.14159265f * i / (N - 1));
            real[i] = real[i] * w;
            imag[i] = imag[i] * w;
        }

        // Bit reversal
        for (int i = 0; i < N; i++) {
#pragma HLS PIPELINE II=1
            int rev = bit_reverse(i);
            tmp_real[rev] = real[i];
            tmp_imag[rev] = imag[i];
        }

        for (int i = 0; i < N; i++) {
#pragma HLS PIPELINE II=1
            real[i] = tmp_real[i];
            imag[i] = tmp_imag[i];
        }

        // FFT butterfly stages
        for (int s = 0; s < NUM_STAGES; s++) {
            int half_stride = 1 << s;
            int stride = 1 << (s + 1);
            int tw_step = (N / 2) / half_stride;

            for (int k = 0; k < N / 2; k++) {
#pragma HLS PIPELINE II=1
                int group = k / half_stride;
                int pos = k % half_stride;
                int top = group * stride + pos;
                int bot = top + half_stride;
                int tw_idx = pos * tw_step;

                fixed_t angle = -2.0f * 3.14159265f * tw_idx / N;
                fixed_t w_real = hls::cosf((float)angle);
                fixed_t w_imag = hls::sinf((float)angle);

                fixed_t a_real = real[top];
                fixed_t a_imag = imag[top];
                fixed_t b_real = real[bot];
                fixed_t b_imag = imag[bot];

                fixed_t bw_real = b_real * w_real - b_imag * w_imag;
                fixed_t bw_imag = b_real * w_imag + b_imag * w_real;

                out_real[top] = a_real + bw_real;
                out_imag[top] = a_imag + bw_imag;
                out_real[bot] = a_real - bw_real;
                out_imag[bot] = a_imag - bw_imag;
            }

            for (int i = 0; i < N; i++) {
#pragma HLS PIPELINE II=1
                real[i] = out_real[i];
                imag[i] = out_imag[i];
            }
        }

        // Store back to DDR
        for (int i = 0; i < N; i++) {
#pragma HLS PIPELINE II=1
            output_real[f * N + i] = real[i];
            output_imag[f * N + i] = imag[i];
        }
    }
}
}