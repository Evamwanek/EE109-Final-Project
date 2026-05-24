import numpy as np


######################################################
N = 1024

x = np.zeros(1024, dtype=complex)
x[3] = 1
#print(np.fft.fft(x)[:8])

# Test 1: Alternating +1/-1
x1 = np.array([1.0 if i % 2 == 0 else -1.0 for i in range(N)], dtype=complex)
#print(np.fft.fft(x1))

# Test 2: Impulse at index 3
x2 = np.zeros(N, dtype=complex)
x2[3] = 1.0
#print(np.fft.fft(x2))

# Test 4: vals pattern
x3 = np.zeros(N, dtype=complex)
vals = [3, -1, 4, 1, 5, -9, 2, 6]
for i, v in enumerate(vals):
    x3[i] = v
print(np.fft.fft(x3))
