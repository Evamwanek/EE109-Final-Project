import librosa
import numpy as np
import subprocess

# The following code loads audio .wav files. Then, it runs
# the spatial code as a subprocess on one 1024 block of audio by
# writing it to a csv spatial reads from. Lastly, it uses log
# scale to match software implementation. 
LAB_DIR = '/Users/evawanek/lab-1-skew'

############ Load audio ###############
audio, sr = librosa.load(
    "/Users/evawanek/Desktop/EE109 Songs/Fleetwood Mac - Landslide (Live) (Official Video) [HD] [WM7-PYtXtJM].wav",
    sr=22050
)

############ Take frame of audio ###############

frame_size = 1024
frame = audio[:frame_size]

############ Save array to txt file #############

np.savetxt(f'{LAB_DIR}/frame.csv', frame, delimiter=',')
print("Wrote frame.csv")

############ Run spatial FFT ###############

# print("Spatial subprocess running") 
result = subprocess.run(['sbt', '-Dtest.CS217=true', '; testOnly Butterfly'], capture_output=True, text=True, cwd=LAB_DIR)
#print(result.stdout[:20])

############ Get FFT Ootputs ###############

def load_csv(path):
    with open(path, 'r') as f:
        content = f.read().strip()
    vals = [float(x) for x in content.split(',') if x.strip()]
    return np.array(vals)

real = load_csv(f'{LAB_DIR}/fft_real.csv')
imag = load_csv(f'{LAB_DIR}/fft_imag.csv')

############ Magnitude/ log ###############

mag = np.sqrt(real**2 + imag**2)
log_spec = 20 * np.log10(mag + 1e-10)
log_spec = log_spec[:512]

print(f"First 10 bins:\n{log_spec[:10]}")

############ Numpy version ###############

window = np.hamming(frame_size)
x_ref = np.fft.fft(frame * window)
ref_spec = 20 * np.log10(np.abs(x_ref[:512]) + 1e-10)

max_diff = np.max(np.abs(ref_spec - log_spec))
#print(f"\nMax diff vs numpy: {max_diff:.4f} dB")

diff = np.abs(ref_spec - log_spec)
mean_diff = diff.mean()

#print(f"Mean diff: {mean_diff:.4f} dB")
print("PASS" if mean_diff < 1.0 else "FAIL")

############ Save for LSTM ###############

np.save(f'{LAB_DIR}/log_magnitude.npy', log_spec)
print(f"\nSaved for LSTM. Shape: {log_spec.shape}")