#include <cstdio>
#include <cstdlib>

#include "vadd.cpp"

#define DATA_SIZE (N * N)

int main() {
    int in1[DATA_SIZE], in2[DATA_SIZE], out[DATA_SIZE];
    int expected[DATA_SIZE];

    for (int i = 0; i < DATA_SIZE; i++) {
        in1[i] = i + 1;
        in2[i] = (i + 1) * 2;
        out[i] = 0;
    }

    for (int i = 0; i < N; i++)
        for (int j = 0; j < N; j++) {
            int sum = 0;
            for (int k = 0; k < N; k++)
                sum += in1[i * N + k] * in2[k * N + j];
            expected[i * N + j] = sum;
        }

    vadd(in1, in2, out);

    int errors = 0;
    for (int i = 0; i < DATA_SIZE; i++) {
        if (out[i] != expected[i]) {
            printf("  Mismatch at [%d][%d]: got %d, expected %d\n",
                   i / N, i % N, out[i], expected[i]);
            errors++;
        }
    }

    if (errors == 0)
        printf("---- TEST PASSED (GEMM %dx%d) ----\n", N, N);
    else
        printf("---- TEST FAILED (GEMM %dx%d, %d mismatches) ----\n", N, N, errors);

    return errors ? EXIT_FAILURE : EXIT_SUCCESS;
}
