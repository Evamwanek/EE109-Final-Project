import re
import numpy as np
from pathlib import Path

N = 1024
FRAC_BITS = 14
SCALE = 1 << FRAC_BITS

def parse_lut_array(path, name):
    text = Path(path).read_text()
    m = re.search(rf"{name}\s*\[[^\]]*\]\s*=\s*\{{(.*?)\}};", text, re.S)
    if not m:
        return None
    nums = re.findall(r"-?\d+", m.group(1))
    return np.array([int(v) for v in nums], dtype=np.float64)

# Same input as software/src/design_top.c
x = np.array([((i % 64) - 32) / 64.0 for i in range(N)], dtype=np.float64)

# Use exact Q14 hamming LUT if available
hamming_raw = parse_lut_array("../src/fft_luts.h", "hamming")
if hamming_raw is not None and len(hamming_raw) >= N:
    w = hamming_raw[:N] / SCALE
    print("Using exact hamming LUT from ../src/fft_luts.h")
else:
    w = np.hamming(N)
    print("WARNING: using numpy.hamming fallback")

signal = x * w

refs = {
    "np.fft.fft": np.fft.fft(signal),
    "np.fft.ifft*N": np.fft.ifft(signal) * N,
}

fpga = []
with open("logs/fpga_test.log.txt") as f:
    for line in f:
        m = re.search(r"FFT\[(\d+)\] =\s*([\-0-9.]+)\s*\+\s*([\-0-9.]+)i", line)
        if m:
            fpga.append((int(m.group(1)), float(m.group(2)), float(m.group(3))))

if not fpga:
    raise SystemExit("ERROR: no FPGA FFT outputs found in logs/fpga_test.log.txt")

print(f"Parsed {len(fpga)} FPGA output bins")

for ref_name, ref in refs.items():
    print("\n=== Comparing against", ref_name, "===")
    max_err = 0.0
    bad = 0

    print("idx  fpga_real  ref_real   fpga_imag  ref_imag   abs_err   nearest_ref_bin")
    for idx, real, imag in fpga:
        z = real + 1j * imag
        err = abs(z - ref[idx])
        max_err = max(max_err, err)

        nearest = int(np.argmin(np.abs(ref - z)))
        nearest_err = abs(ref[nearest] - z)

        if err > 0.25:
            bad += 1

        print(
            f"{idx:3d}  {real:9.5f} {ref[idx].real:9.5f}  "
            f"{imag:9.5f} {ref[idx].imag:9.5f}  "
            f"{err:9.5f}   {nearest:4d} err={nearest_err:.5f}"
        )

    print("max_err:", max_err)
    print("bad_bins_err_gt_0.25:", bad)

    if bad == 0:
        print("TEST PASSED against", ref_name)
    else:
        print("TEST NOT FULLY MATCHED against", ref_name)

print("\nNote: current runtime only prints the first bins present in fpga_test.log.txt.")
print("For stronger validation, modify software/src/design_top.c to print/dump all 1024 bins.")