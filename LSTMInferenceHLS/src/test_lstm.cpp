#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <cmath>

#include "vadd.cpp"

// -------------------------------------------------------
// Helper: load a raw float32 .bin file into a heap array.
// Returns number of floats read. Exits on error.
// -------------------------------------------------------
static float* load_bin(const char* path, size_t expected_elems) {
    FILE* f = fopen(path, "rb");
    if (!f) {
        fprintf(stderr, "ERROR: could not open %s\n", path);
        exit(EXIT_FAILURE);
    }
    float* buf = (float*)malloc(expected_elems * sizeof(float));
    if (!buf) {
        fprintf(stderr, "ERROR: malloc failed for %s\n", path);
        exit(EXIT_FAILURE);
    }
    size_t n = fread(buf, sizeof(float), expected_elems, f);
    fclose(f);
    if (n != expected_elems) {
        fprintf(stderr, "ERROR: %s — expected %zu floats, got %zu\n",
                path, expected_elems, n);
        exit(EXIT_FAILURE);
    }
    return buf;
}

// -------------------------------------------------------
// Reference LSTM forward pass (plain C++, no pragmas)
// Mirrors the logic in vadd.cpp exactly so we can
// compare outputs without needing PyTorch at test time.
// -------------------------------------------------------
static float ref_sigmoid(float x) {
    return 1.0f / (1.0f + expf(-x));
}
static float ref_tanh(float x) {
    return tanhf(x);
}

static int ref_lstm(
    float* input_seq,
    float* wih0, float* whh0, float* bih0, float* bhh0,
    float* wih1, float* whh1, float* bih1, float* bhh1,
    float* wfc,  float* bfc
) {
    float h0[HIDDEN] = {0}, c0[HIDDEN] = {0};
    float h1[HIDDEN] = {0}, c1[HIDDEN] = {0};
    float gates0[GATE_H], gates1[GATE_H];

    for (int t = 0; t < T_STEPS; t++) {
        float* x = input_seq + t * INPUT_SZ;

        // Layer 0 gate pre-activations
        for (int g = 0; g < GATES; g++) {
            for (int j = 0; j < HIDDEN; j++) {
                int row = g * HIDDEN + j;
                float xC = 0.0f, hC = 0.0f;
                for (int k = 0; k < INPUT_SZ; k++)
                    xC += wih0[row * INPUT_SZ + k] * x[k];
                for (int k = 0; k < HIDDEN; k++)
                    hC += whh0[row * HIDDEN + k] * h0[k];
                gates0[row] = xC + hC + bih0[row] + bhh0[row];
            }
        }
        // Layer 0 state update
        for (int j = 0; j < HIDDEN; j++) {
            float ig = ref_sigmoid(gates0[0 * HIDDEN + j]);
            float fg = ref_sigmoid(gates0[1 * HIDDEN + j]);
            float gg = ref_tanh   (gates0[2 * HIDDEN + j]);
            float og = ref_sigmoid(gates0[3 * HIDDEN + j]);
            c0[j] = fg * c0[j] + ig * gg;
            h0[j] = og * ref_tanh(c0[j]);
        }

        // Layer 1 gate pre-activations
        for (int g = 0; g < GATES; g++) {
            for (int j = 0; j < HIDDEN; j++) {
                int row = g * HIDDEN + j;
                float xC = 0.0f, hC = 0.0f;
                for (int k = 0; k < HIDDEN; k++)
                    xC += wih1[row * HIDDEN + k] * h0[k];
                for (int k = 0; k < HIDDEN; k++)
                    hC += whh1[row * HIDDEN + k] * h1[k];
                gates1[row] = xC + hC + bih1[row] + bhh1[row];
            }
        }
        // Layer 1 state update
        for (int j = 0; j < HIDDEN; j++) {
            float ig = ref_sigmoid(gates1[0 * HIDDEN + j]);
            float fg = ref_sigmoid(gates1[1 * HIDDEN + j]);
            float gg = ref_tanh   (gates1[2 * HIDDEN + j]);
            float og = ref_sigmoid(gates1[3 * HIDDEN + j]);
            c1[j] = fg * c1[j] + ig * gg;
            h1[j] = og * ref_tanh(c1[j]);
        }
    }

    // FC + argmax
    float logits[N_CLASS];
    for (int i = 0; i < N_CLASS; i++) {
        float dot = 0.0f;
        for (int j = 0; j < HIDDEN; j++)
            dot += wfc[i * HIDDEN + j] * h1[j];
        logits[i] = dot + bfc[i];
    }
    int best = 0;
    for (int i = 1; i < N_CLASS; i++)
        if (logits[i] > logits[best]) best = i;
    return best;
}

// -------------------------------------------------------
// Main
// -------------------------------------------------------
int main(int argc, char* argv[]) {
    // Usage: ./test_lstm <weights_dir> <input_seq.bin>
    const char* weights_dir  = (argc > 1) ? argv[1] : "weights";
    const char* input_seq_path = (argc > 2) ? argv[2] : "input_seq.bin";

    char path[512];
    #define BIN(name, elems) \
        (snprintf(path, sizeof(path), "%s/" name ".bin", weights_dir), \
         load_bin(path, (elems)))

    // Load input sequence from its own path
    float* input_seq = load_bin(input_seq_path, T_STEPS * INPUT_SZ);
    float* wih0      = BIN("weight_ih_l0", GATE_H * INPUT_SZ);
    float* whh0      = BIN("weight_hh_l0", GATE_H * HIDDEN);
    float* bih0      = BIN("bias_ih_l0",   GATE_H);
    float* bhh0      = BIN("bias_hh_l0",   GATE_H);
    float* wih1      = BIN("weight_ih_l1", GATE_H * HIDDEN);
    float* whh1      = BIN("weight_hh_l1", GATE_H * HIDDEN);
    float* bih1      = BIN("bias_ih_l1",   GATE_H);
    float* bhh1      = BIN("bias_hh_l1",   GATE_H);
    float* wfc       = BIN("fc_weight",    N_CLASS * HIDDEN);
    float* bfc       = BIN("fc_bias",      N_CLASS);
    #undef BIN

    printf("Loaded all weights from '%s/'\n", weights_dir);

    // --- Reference result (pure C++, exact math) ---
    int expected = ref_lstm(
        input_seq,
        wih0, whh0, bih0, bhh0,
        wih1, whh1, bih1, bhh1,
        wfc, bfc
    );
    printf("Reference predicted class : %d\n", expected);

    // --- HLS kernel result (sigmoid LUT + tanh approx) ---
    int hls_pred = -1;
    vadd(
        input_seq,
        wih0, whh0, bih0, bhh0,
        wih1, whh1, bih1, bhh1,
        wfc, bfc,
        &hls_pred
    );
    printf("HLS kernel predicted class: %d\n", hls_pred);

    // --- Compare ---
    const char* GENRES[] = {
        "blues", "classical", "country", "disco", "hiphop",
        "jazz",  "metal",     "pop",     "reggae", "rock"
    };

    if (hls_pred == expected) {
        printf("---- TEST PASSED — predicted genre: %s ----\n",
               GENRES[hls_pred]);
        return EXIT_SUCCESS;
    } else {
        printf("---- TEST FAILED — reference: %s (%d), HLS: %s (%d) ----\n",
               GENRES[expected], expected, GENRES[hls_pred], hls_pred);
        printf("NOTE: mismatch is likely due to sigmoid LUT quantization.\n");
        printf("      Check if logit gap between top-2 classes is small.\n");
        return EXIT_FAILURE;
    }

    // Cleanup
    free(input_seq); free(wih0); free(whh0); free(bih0); free(bhh0);
    free(wih1); free(whh1); free(bih1); free(bhh1); free(wfc); free(bfc);
}