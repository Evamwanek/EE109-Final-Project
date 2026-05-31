/*
 * LSTM Inference Engine for Genre Classification
 * Architecture: 2-layer LSTM (input=128, hidden=128) + FC (128->10)
 * Input: projected spectrogram sequence, shape (50 * 128) flattened
 * Weights: flattened row-major, loaded from host DRAM
 * Output: predicted genre index (0-9)
 */

#include <math.h>

#define T_STEPS  50
#define INPUT_SZ 128
#define HIDDEN   128
#define GATES    4
#define GATE_H   512   // GATES * HIDDEN
#define N_CLASS  10

// Sigmoid via lookup table: 256 points over [-6, 6]
// Same approach as Spatial implementation
static float sigmoid_lut[256];

static void init_sigmoid_lut() {
    for (int i = 0; i < 256; i++) {
        float x = -6.0f + i * 12.0f / 255.0f;
        sigmoid_lut[i] = 1.0f / (1.0f + expf(-x));
    }
}

static float sigmoid(float x) {
    if (x > 6.0f)  return 1.0f;
    if (x < -6.0f) return 0.0f;
    int idx = (int)((x + 6.0f) * (255.0f / 12.0f));
    if (idx < 0)   idx = 0;
    if (idx > 255) idx = 255;
    return sigmoid_lut[idx];
}

static float tanh_approx(float x) {
    return 2.0f * sigmoid(2.0f * x) - 1.0f;
}

// Core LSTM inference function
// All weight arrays are flattened row-major
static void lstm_inference(
    float *input_seq,   // (T_STEPS * INPUT_SZ)
    float *wih0,        // (GATE_H * INPUT_SZ)
    float *whh0,        // (GATE_H * HIDDEN)
    float *bih0,        // (GATE_H)
    float *bhh0,        // (GATE_H)
    float *wih1,        // (GATE_H * HIDDEN)
    float *whh1,        // (GATE_H * HIDDEN)
    float *bih1,        // (GATE_H)
    float *bhh1,        // (GATE_H)
    float *wfc,         // (N_CLASS * HIDDEN)
    float *bfc,         // (N_CLASS)
    int   *pred_out     // output: predicted class index
) {
    // Hidden and cell states, initialized to zero
    float h0[HIDDEN] = {0};
    float c0[HIDDEN] = {0};
    float h1[HIDDEN] = {0};
    float c1[HIDDEN] = {0};

    float gates0[GATE_H];
    float gates1[GATE_H];

    // Sequential over timesteps
    for (int t = 0; t < T_STEPS; t++) {
        #pragma HLS loop_tripcount min=50 max=50

        float *x = input_seq + t * INPUT_SZ;

        // --- Layer 0: compute gate pre-activations ---
        // gates0[g*HIDDEN + j] = wih0[row] . x + whh0[row] . h0 + bih0[row] + bhh0[row]
        for (int g = 0; g < GATES; g++) {
            for (int j = 0; j < HIDDEN; j++) {
                int row = g * HIDDEN + j;
                float xC = 0.0f;
                float hC = 0.0f;

                for (int k = 0; k < INPUT_SZ; k++) {
                    #pragma HLS pipeline
                    xC += wih0[row * INPUT_SZ + k] * x[k];
                }
                for (int k = 0; k < HIDDEN; k++) {
                    #pragma HLS pipeline
                    hC += whh0[row * HIDDEN + k] * h0[k];
                }
                gates0[row] = xC + hC + bih0[row] + bhh0[row];
            }
        }

        // --- Layer 0: gate activations + state update ---
        for (int j = 0; j < HIDDEN; j++) {
            float i_gate = sigmoid(gates0[0 * HIDDEN + j]);
            float f_gate = sigmoid(gates0[1 * HIDDEN + j]);
            float g_gate = tanh_approx(gates0[2 * HIDDEN + j]);
            float o_gate = sigmoid(gates0[3 * HIDDEN + j]);

            float c0_new = f_gate * c0[j] + i_gate * g_gate;
            c0[j] = c0_new;
            h0[j] = o_gate * tanh_approx(c0_new);
        }

        // --- Layer 1: compute gate pre-activations ---
        // input to layer 1 is h0
        for (int g = 0; g < GATES; g++) {
            for (int j = 0; j < HIDDEN; j++) {
                int row = g * HIDDEN + j;
                float xC = 0.0f;
                float hC = 0.0f;

                for (int k = 0; k < HIDDEN; k++) {
                    #pragma HLS pipeline
                    xC += wih1[row * HIDDEN + k] * h0[k];
                }
                for (int k = 0; k < HIDDEN; k++) {
                    #pragma HLS pipeline
                    hC += whh1[row * HIDDEN + k] * h1[k];
                }
                gates1[row] = xC + hC + bih1[row] + bhh1[row];
            }
        }

        // --- Layer 1: gate activations + state update ---
        for (int j = 0; j < HIDDEN; j++) {
            float i_gate = sigmoid(gates1[0 * HIDDEN + j]);
            float f_gate = sigmoid(gates1[1 * HIDDEN + j]);
            float g_gate = tanh_approx(gates1[2 * HIDDEN + j]);
            float o_gate = sigmoid(gates1[3 * HIDDEN + j]);

            float c1_new = f_gate * c1[j] + i_gate * g_gate;
            c1[j] = c1_new;
            h1[j] = o_gate * tanh_approx(c1_new);
        }
    }

    // --- FC layer: logits = wfc @ h1 + bfc ---
    float logits[N_CLASS];
    for (int i = 0; i < N_CLASS; i++) {
        float dot = 0.0f;
        for (int j = 0; j < HIDDEN; j++) {
            #pragma HLS pipeline
            dot += wfc[i * HIDDEN + j] * h1[j];
        }
        logits[i] = dot + bfc[i];
    }

    // --- Argmax ---
    int max_idx = 0;
    float max_val = logits[0];
    for (int i = 1; i < N_CLASS; i++) {
        if (logits[i] > max_val) {
            max_val = logits[i];
            max_idx = i;
        }
    }
    *pred_out = max_idx;
}

extern "C" {

    void vadd(
        float *input_seq,   // (T_STEPS * INPUT_SZ)
        float *wih0,        // (GATE_H * INPUT_SZ)
        float *whh0,        // (GATE_H * HIDDEN)
        float *bih0,        // (GATE_H)
        float *bhh0,        // (GATE_H)
        float *wih1,        // (GATE_H * HIDDEN)
        float *whh1,        // (GATE_H * HIDDEN)
        float *bih1,        // (GATE_H)
        float *bhh1,        // (GATE_H)
        float *wfc,         // (N_CLASS * HIDDEN)
        float *bfc,         // (N_CLASS)
        int   *pred_out
    ) {
#pragma HLS INTERFACE m_axi port=input_seq bundle=gmem0
#pragma HLS INTERFACE m_axi port=wih0      bundle=gmem0
#pragma HLS INTERFACE m_axi port=whh0      bundle=gmem0
#pragma HLS INTERFACE m_axi port=bih0      bundle=gmem0
#pragma HLS INTERFACE m_axi port=bhh0      bundle=gmem0
#pragma HLS INTERFACE m_axi port=wih1      bundle=gmem1
#pragma HLS INTERFACE m_axi port=whh1      bundle=gmem1
#pragma HLS INTERFACE m_axi port=bih1      bundle=gmem1
#pragma HLS INTERFACE m_axi port=bhh1      bundle=gmem1
#pragma HLS INTERFACE m_axi port=wfc       bundle=gmem1
#pragma HLS INTERFACE m_axi port=bfc       bundle=gmem1
#pragma HLS INTERFACE m_axi port=pred_out  bundle=gmem1

        init_sigmoid_lut();
        lstm_inference(
            input_seq,
            wih0, whh0, bih0, bhh0,
            wih1, whh1, bih1, bhh1,
            wfc, bfc,
            pred_out
        );
    }
}
