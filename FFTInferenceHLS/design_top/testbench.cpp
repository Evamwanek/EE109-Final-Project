read frames.csv
set imag input to 0
call fft_kernel()
compare output against numpy/spatial output OR just print first few outputs
print TEST PASSED