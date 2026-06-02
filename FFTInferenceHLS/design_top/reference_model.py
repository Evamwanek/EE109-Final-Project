import re
import numpy as np
from pathlib import Path

N = 1024
NUM_STAGES = 10
SHIFT = 14
SCALE = 1 << SHIFT

def parse_lut_array(path, name):
    text = Path(path).read_text()
    m = re.search(rf"{name}\s*\[[^\]]*\]\s*=\s*\{{(.*?)\}};", text, re.S)
    nums = re.findall(r"-?\d+", m.group(1))
    return np.array([int(v) for v in nums], dtype=np.int64)

def bit_reverse(x):
    y = 0
    for _ in range(NUM_STAGES):
        y = (y << 1) | (x & 1)
        x >>= 1
    return y

def wrap32(x):
    x = int(x) & 0xFFFFFFFF
    return x - 0x100000000 if x & 0x80000000 else x

hamming = parse_lut_array("../src/fft_luts.h", "hamming")
twR = parse_lut_array("../src/fft_luts.h", "twR")
twI = parse_lut_array("../src/fft_luts.h", "twI")

# Same input as design_top.c
x_float = np.array([((i % 64) - 32) / 64.0 for i in range(N)])
x_fixed = np.array([int(v * SCALE) for v in x_float], dtype=np.int64)

real = np.zeros(N, dtype=np.int64)
imag = np.zeros(N, dtype=np.int64)
tmp_real = np.zeros(N, dtype=np.int64)
tmp_imag = np.zeros(N, dtype=np.int64)
out_real = np.zeros(N, dtype=np.int64)
out_imag = np.zeros(N, dtype=np.int64)

# Load + hamming
for i in range(N):
    real[i] = wrap32((x_fixed[i] * hamming[i]) >> SHIFT)
    imag[i] = 0

# Bit reversal
for i in range(N):
    rev = bit_reverse(i)
    tmp_real[rev] = real[i]
    tmp_imag[rev] = imag[i]

real[:] = tmp_real
imag[:] = tmp_imag

# Butterfly loop matching C++
for s in range(NUM_STAGES):
    half_stride = 1 << s
    stride = 1 << (s + 1)
    tw_step = 1 << (NUM_STAGES - 1 - s)

    for k in range(512):
        group = k >> s
        pos = k & (half_stride - 1)

        top = group * stride + pos
        bot = top + half_stride
        tw_idx = pos * tw_step

        w_real = twR[tw_idx]
        w_imag = twI[tw_idx]

        a_real = real[top]
        a_imag = imag[top]
        b_real = real[bot]
        b_imag = imag[bot]

        bw_real = wrap32(((b_real * w_real) - (b_imag * w_imag)) >> SHIFT)
        bw_imag = wrap32(((b_real * w_imag) + (b_imag * w_real)) >> SHIFT)

        # Use this for CURRENT unscaled FPGA behavior:
        out_real[top] = wrap32(a_real + bw_real)
        out_imag[top] = wrap32(a_imag + bw_imag)
        out_real[bot] = wrap32(a_real - bw_real)
        out_imag[bot] = wrap32(a_imag - bw_imag)

        # If testing scaled butterfly version, replace above four lines with:
        # out_real[top] = wrap32((a_real + bw_real) >> 1)
        # out_imag[top] = wrap32((a_imag + bw_imag) >> 1)
        # out_real[bot] = wrap32((a_real - bw_real) >> 1)
        # out_imag[bot] = wrap32((a_imag - bw_imag) >> 1)

    real[:] = out_real
    imag[:] = out_imag

model = real / SCALE + 1j * (imag / SCALE)

# NumPy reference
signal = x_float * (hamming / SCALE)
ref = np.fft.fft(signal)

# FPGA parse
fpga = {}
with open("logs/fpga_test.log.txt") as f:
    for line in f:
        m = re.search(r"FFT\[(\d+)\] =\s*([\-0-9.]+)\s*\+\s*([\-0-9.]+)i", line)
        if m:
            fpga[int(m.group(1))] = float(m.group(2)) + 1j * float(m.group(3))

print("idx  fpga/model_err  model/numpy_err  fpga              model             numpy")
bad_model = 0
bad_numpy = 0

for i in sorted(fpga.keys()):
    fm = abs(fpga[i] - model[i])
    mn = abs(model[i] - ref[i])

    if fm > 0.05:
        bad_model += 1
    if mn > 0.25:
        bad_numpy += 1

    if fm > 0.05 or mn > 0.25 or i < 20:
        print(
            f"{i:3d}  {fm:13.6f}  {mn:15.6f}  "
            f"{fpga[i].real:9.4f}{fpga[i].imag:+9.4f}i  "
            f"{model[i].real:9.4f}{model[i].imag:+9.4f}i  "
            f"{ref[i].real:9.4f}{ref[i].imag:+9.4f}i"
        )

print("\nBad FPGA-vs-model bins > 0.05:", bad_model)
print("Bad model-vs-NumPy bins > 0.25:", bad_numpy)

if bad_model == 0:
    print("FPGA matches fixed-point C++ model.")
else:
    print("FPGA does NOT match fixed-point C++ model.")

if bad_numpy == 0:
    print("Fixed-point model matches NumPy well.")
else:
    print("Fixed-point model differs from NumPy; likely fixed-point overflow/scaling/algorithm issue.")