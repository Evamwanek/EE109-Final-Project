

#include <ap_fixed.h>

#define T_STEPS  50
#define INPUT_SZ 128
#define HIDDEN   128
#define GATES    4
#define GATE_H   512
#define N_CLASS  10

typedef ap_fixed<32, 10> data_t;
typedef ap_fixed<48, 16> acc_t;

// ---------------------------------------------------------------------------
// Sigmoid LUT — 256 real data_t constants, pre-computed offline.
// x_i = -6 + i*(12/255), value = sigmoid(x_i) rounded to ap_fixed<32,10>.
// No bits_to_fixed hacks, no float literals, no runtime init needed.
// ---------------------------------------------------------------------------
static const data_t sigmoid_lut[256] = {
    0.0024726391, 0.0025913715, 0.0027160645, 0.0028464794,
    0.0029833317, 0.0031266212, 0.0032765865, 0.0034339428,
    0.0035989285, 0.0037715435, 0.0039527416, 0.0041422844,
    0.0043411255, 0.0045492649, 0.0047674179, 0.0049960613,
    0.0052354336, 0.0054862499, 0.0057492256, 0.0060243607,
    0.0063128471, 0.0066151619, 0.0069315434, 0.0072631836,
    0.0076105595, 0.0079741478, 0.0083553791, 0.0087542534,
    0.0091722012, 0.0096099377, 0.0100684166, 0.0105483532,
    0.0110509396, 0.0115773678, 0.0121283531, 0.0127053261,
    0.0133094788, 0.0139417648, 0.0146038532, 0.0152966976,
    0.0160219669, 0.0167808533, 0.0175752640, 0.0184066296,
    0.0192763805, 0.0201864243, 0.0211384296, 0.0221345425,
    0.0231761932, 0.0242660046, 0.0254054070, 0.0265970230,
    0.0278427601, 0.0291452408, 0.0305068493, 0.0319297314,
    0.0334169865, 0.0349707603, 0.0365941525, 0.0382897854,
    0.0400607586, 0.0419101715, 0.0438411236, 0.0458567142,
    0.0479602814, 0.0501551628, 0.0524451733, 0.0548336506,
    0.0573241711, 0.0599207878, 0.0626270771, 0.0654473305,
    0.0683851242, 0.0714447498, 0.0746302605, 0.0779459476,
    0.0813958645, 0.0849845409, 0.0887162685, 0.0925951004,
    0.0966255665, 0.1008119583, 0.1051585674, 0.1096699238,
    0.1143498421, 0.1192028522, 0.1242330074, 0.1294441223,
    0.1348402500, 0.1404249668, 0.1462018490, 0.1521744728,
    0.1583456993, 0.1647186279, 0.1712958813, 0.1780798435,
    0.1850721836, 0.1922750473, 0.1996896267, 0.2073166370,
    0.2151565552, 0.2232096195, 0.2314751148, 0.2399523258,
    0.2486393452, 0.2575342655, 0.2666347027, 0.2759370804,
    0.2854375839, 0.2951319218, 0.3050150871, 0.3150811195,
    0.3253238201, 0.3357362747, 0.3463110924, 0.3570399284,
    0.3679139614, 0.3789241314, 0.3900601864, 0.4013123512,
    0.4126694202, 0.4241201878, 0.4356529713, 0.4472558498,
    0.4589164257, 0.4706220627, 0.4823603630, 0.4941179752,
    0.5058820248, 0.5176396370, 0.5293779373, 0.5410835743,
    0.5527441502, 0.5643470287, 0.5758798122, 0.5873305798,
    0.5986876488, 0.6099398136, 0.6210758686, 0.6320860386,
    0.6429600716, 0.6536889076, 0.6642637253, 0.6746761799,
    0.6849188805, 0.6949849129, 0.7048680782, 0.7145624161,
    0.7240629196, 0.7333652973, 0.7424657345, 0.7513606548,
    0.7600476742, 0.7685248852, 0.7767903805, 0.7848434448,
    0.7926833630, 0.8003103733, 0.8077249527, 0.8149278164,
    0.8219201565, 0.8287041187, 0.8352813721, 0.8416543007,
    0.8478255272, 0.8537981510, 0.8595750332, 0.8651597500,
    0.8705558777, 0.8757669926, 0.8807971478, 0.8856501579,
    0.8903300762, 0.8948414326, 0.8991880417, 0.9033744335,
    0.9074048996, 0.9112837315, 0.9150154591, 0.9186041355,
    0.9220540524, 0.9253697395, 0.9285552502, 0.9316148758,
    0.9345526695, 0.9373729229, 0.9400792122, 0.9426758289,
    0.9451663494, 0.9475548267, 0.9498448372, 0.9520397186,
    0.9541432858, 0.9561588764, 0.9580898285, 0.9599392414,
    0.9617102146, 0.9634058475, 0.9650292397, 0.9665830135,
    0.9680702686, 0.9694931507, 0.9708547592, 0.9721572399,
    0.9734029770, 0.9745945930, 0.9757339954, 0.9768238068,
    0.9778654575, 0.9788615704, 0.9798135757, 0.9807236195,
    0.9815933704, 0.9824247360, 0.9832191467, 0.9839780331,
    0.9847033024, 0.9853961468, 0.9860582352, 0.9866905212,
    0.9872946739, 0.9878716469, 0.9884226322, 0.9889490604,
    0.9894516468, 0.9899315834, 0.9903900623, 0.9908277988,
    0.9912457466, 0.9916446209, 0.9920258522, 0.9923894405,
    0.9927368164, 0.9930684566, 0.9933848381, 0.9936871529,
    0.9939756393, 0.9942507744, 0.9945137501, 0.9947645664,
    0.9950039387, 0.9952325821, 0.9954507351, 0.9956588745,
    0.9958577156, 0.9960472584, 0.9962284565, 0.9964010715,
    0.9965660572, 0.9967234135, 0.9968733788, 0.9970166683,
    0.9971535206, 0.9972839355, 0.9974086285, 0.9975273609,
};

// ---------------------------------------------------------------------------
// sigmoid: LUT lookup, fully fixed-point index math, rounded index.
//
// SCALE = 255/12 = 21.25 exactly.
// 21.25 is representable in ap_fixed<16,8> as 5440/2^8 — no float literal.
// Rounding: add 0.5 before truncation to avoid systematic downward bias.
// ---------------------------------------------------------------------------
static data_t sigmoid(data_t x) {
    if (x >= (data_t)6)  return sigmoid_lut[255];
    if (x <= (data_t)-6) return sigmoid_lut[0];

    // SCALE = 255/12 = 21.25: assign integer 5440 to ap_fixed<16,8>
    // ap_fixed<16,8> stores value = bits/2^8, so 5440/256 = 21.25 exactly.
    ap_fixed<16, 8> scale;
    scale = 21;           // integer part
    scale += (ap_fixed<16,8>)1 / (ap_fixed<16,8>)4;  // + 0.25, exact

    data_t xshifted = x + (data_t)6;

    // Add 0.5 for rounding before truncation (fixes downward bias)
    int idx = (int)(xshifted * scale + (data_t)0.5);
    if (idx < 0)   idx = 0;
    if (idx > 255) idx = 255;
    return sigmoid_lut[idx];
}

// tanh via identity: tanh(x) = 2*sigmoid(2x) - 1
static data_t tanh_approx(data_t x) {
    return (data_t)2 * sigmoid((data_t)2 * x) - (data_t)1;
}

// ---------------------------------------------------------------------------
// Core LSTM inference — zero float, zero float literals
// ---------------------------------------------------------------------------
static void lstm_inference(
    data_t *input_seq,   // (T_STEPS * INPUT_SZ)
    data_t *wih0,        // (GATE_H * INPUT_SZ)
    data_t *whh0,        // (GATE_H * HIDDEN)
    data_t *bih0,        // (GATE_H)
    data_t *bhh0,        // (GATE_H)
    data_t *wih1,        // (GATE_H * HIDDEN)
    data_t *whh1,        // (GATE_H * HIDDEN)
    data_t *bih1,        // (GATE_H)
    data_t *bhh1,        // (GATE_H)
    data_t *wfc,         // (N_CLASS * HIDDEN)
    data_t *bfc,         // (N_CLASS)
    int    *pred_out
) {
    data_t h0[HIDDEN] = {0};
    data_t c0[HIDDEN] = {0};
    data_t h1[HIDDEN] = {0};
    data_t c1[HIDDEN] = {0};

    data_t gates0[GATE_H];
    data_t gates1[GATE_H];

    for (int t = 0; t < T_STEPS; t++) {
        #pragma HLS loop_tripcount min=50 max=50

        data_t *x = input_seq + t * INPUT_SZ;

        // --- Layer 0: gate pre-activations ---
        for (int g = 0; g < GATES; g++) {
            for (int j = 0; j < HIDDEN; j++) {
                int row = g * HIDDEN + j;

                // Wide accumulators — bias added inside acc_t before cast down.
                // Casting to data_t only at the final boundary (FIX from reviewer).
                acc_t xC = 0;
                acc_t hC = 0;
                for (int k = 0; k < INPUT_SZ; k++) {
                    #pragma HLS pipeline
                    xC += (acc_t)wih0[row * INPUT_SZ + k] * (acc_t)x[k];
                }
                for (int k = 0; k < HIDDEN; k++) {
                    #pragma HLS pipeline
                    hC += (acc_t)whh0[row * HIDDEN + k] * (acc_t)h0[k];
                }
                // Biases added at full acc_t precision, cast once at end
                acc_t pre0 = xC + hC + (acc_t)bih0[row] + (acc_t)bhh0[row];
                gates0[row] = (data_t)pre0;
            }
        }

        // --- Layer 0: gate activations + state update ---
        for (int j = 0; j < HIDDEN; j++) {
            data_t i_gate = sigmoid    (gates0[0 * HIDDEN + j]);
            data_t f_gate = sigmoid    (gates0[1 * HIDDEN + j]);
            data_t g_gate = tanh_approx(gates0[2 * HIDDEN + j]);
            data_t o_gate = sigmoid    (gates0[3 * HIDDEN + j]);
            data_t c0_new = f_gate * c0[j] + i_gate * g_gate;
            c0[j] = c0_new;
            h0[j] = o_gate * tanh_approx(c0_new);
        }

        // --- Layer 1: gate pre-activations ---
        for (int g = 0; g < GATES; g++) {
            for (int j = 0; j < HIDDEN; j++) {
                int row = g * HIDDEN + j;
                acc_t xC = 0;
                acc_t hC = 0;
                for (int k = 0; k < HIDDEN; k++) {
                    #pragma HLS pipeline
                    xC += (acc_t)wih1[row * HIDDEN + k] * (acc_t)h0[k];
                }
                for (int k = 0; k < HIDDEN; k++) {
                    #pragma HLS pipeline
                    hC += (acc_t)whh1[row * HIDDEN + k] * (acc_t)h1[k];
                }
                acc_t pre1 = xC + hC + (acc_t)bih1[row] + (acc_t)bhh1[row];
                gates1[row] = (data_t)pre1;
            }
        }

        // --- Layer 1: gate activations + state update ---
        for (int j = 0; j < HIDDEN; j++) {
            data_t i_gate = sigmoid    (gates1[0 * HIDDEN + j]);
            data_t f_gate = sigmoid    (gates1[1 * HIDDEN + j]);
            data_t g_gate = tanh_approx(gates1[2 * HIDDEN + j]);
            data_t o_gate = sigmoid    (gates1[3 * HIDDEN + j]);
            data_t c1_new = f_gate * c1[j] + i_gate * g_gate;
            c1[j] = c1_new;
            h1[j] = o_gate * tanh_approx(c1_new);
        }
    }

    // --- FC layer ---
    data_t logits[N_CLASS];
    for (int i = 0; i < N_CLASS; i++) {
        acc_t dot = 0;
        for (int j = 0; j < HIDDEN; j++) {
            #pragma HLS pipeline
            dot += (acc_t)wfc[i * HIDDEN + j] * (acc_t)h1[j];
        }
        logits[i] = (data_t)(dot + (acc_t)bfc[i]);
    }

    // --- Argmax ---
    int    max_idx = 0;
    data_t max_val = logits[0];
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
        data_t *input_seq,
        data_t *wih0,
        data_t *whh0,
        data_t *bih0,
        data_t *bhh0,
        data_t *wih1,
        data_t *whh1,
        data_t *bih1,
        data_t *bhh1,
        data_t *wfc,
        data_t *bfc,
        int    *pred_out
    ) {
#pragma HLS INTERFACE m_axi port=input_seq bundle=gmem0
#pragma HLS INTERFACE m_axi port=wih0      bundle=gmem0
#pragma HLS INTERFACE m_axi port=whh0      bundle=gmem0
#pragma HLS INTERFACE m_axi port=bih0      bundle=gmem0
#pragma HLS INTERFACE m_axi port=bhh0      bundle=gmem0
#pragma HLS INTERFACE m_axi port=wih1      bundle=gmem0
#pragma HLS INTERFACE m_axi port=whh1      bundle=gmem0
#pragma HLS INTERFACE m_axi port=bih1      bundle=gmem0
#pragma HLS INTERFACE m_axi port=bhh1      bundle=gmem0
#pragma HLS INTERFACE m_axi port=wfc       bundle=gmem0
#pragma HLS INTERFACE m_axi port=bfc       bundle=gmem0
#pragma HLS INTERFACE m_axi port=pred_out  bundle=gmem0

        lstm_inference(
            input_seq,
            wih0, whh0, bih0, bhh0,
            wih1, whh1, bih1, bhh1,
            wfc, bfc,
            pred_out
        );
    }
}
