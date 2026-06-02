#include "fft_kernel.h"
#include "fft_luts.h"

#define FIXED_SHIFT 14

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
#pragma HLS INTERFACE m_axi port=input_imag  offset=slave bundle=gmem0
#pragma HLS INTERFACE m_axi port=output_real offset=slave bundle=gmem0
#pragma HLS INTERFACE m_axi port=output_imag offset=slave bundle=gmem0

#pragma HLS INTERFACE s_axilite port=input_real  bundle=control
#pragma HLS INTERFACE s_axilite port=input_imag  bundle=control
#pragma HLS INTERFACE s_axilite port=output_real bundle=control
#pragma HLS INTERFACE s_axilite port=output_imag bundle=control
#pragma HLS INTERFACE ap_ctrl_hs port=return


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
#pragma HLS BIND_STORAGE variable=out_real type=ram_2p impl=bram
#pragma HLS BIND_STORAGE variable=out_imag type=ram_2p impl=bram

    for (int f = 0; f < NUM_FRAMES; f++) {

        for (int i = 0; i < N; i++) {
#pragma HLS PIPELINE II=1
            real[i] = input_real[f * N + i];
            imag[i] = input_imag[f * N + i];
        }

        for (int i = 0; i < N; i++) {
#pragma HLS PIPELINE II=1
            fixed_t w = hamming[i];
            real[i] = (real[i] * w) >> FIXED_SHIFT;
            imag[i] = (imag[i] * w) >> FIXED_SHIFT;
        }

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

        for (int s = 0; s < NUM_STAGES; s++) {
            int half_stride = 1 << s;
            int stride = 1 << (s + 1);
            int tw_step = 1 << (NUM_STAGES - 1 - s);

            for (int k = 0; k < 512; k++) {
#pragma HLS PIPELINE II=1
                int group = k >> s;
                int pos = k & (half_stride - 1);

                int top = group * stride + pos;
                int bot = top + half_stride;
                int tw_idx = pos * tw_step;

                fixed_t w_real = twR[tw_idx];
                fixed_t w_imag = twI[tw_idx];

                fixed_t a_real = real[top];
                fixed_t a_imag = imag[top];
                fixed_t b_real = real[bot];
                fixed_t b_imag = imag[bot];

                fixed_t bw_real =
                    ((b_real * w_real) - (b_imag * w_imag)) >> FIXED_SHIFT;

                fixed_t bw_imag =
                    ((b_real * w_imag) + (b_imag * w_real)) >> FIXED_SHIFT;

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

        for (int i = 0; i < N; i++) {
#pragma HLS PIPELINE II=1
            output_real[f * N + i] = real[i];
            output_imag[f * N + i] = imag[i];
        }
    }
}
}