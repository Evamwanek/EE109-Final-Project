import librosa
import numpy as np
import subprocess
import os

# The following code loads audio .wav files. Then, it runs
# the spatial code as a subprocess on one 1024 block of audio by
# writing it to a csv spatial reads from. Lastly, it uses log
# scale to match software implementation. 
LAB_DIR = '/Users/evawanek/lab-1-skew'


############ Load audio ###############
folder = '/Users/evawanek/Desktop/EE109 Songs'
for filename in os.listdir(folder):
    if not filename.endswith(".wav"):
        continue
    path = os.path.join(folder, filename)
    audio, sr = librosa.load(path, sr=22050)

############ Take frame of audio ###############

    frame_size = 1024
    # get audio from middle instead of silence at
    # beginning and end 
    min_energy = 0.01 
    frame = None
    for start in range(0, len(audio) - frame_size, frame_size):
        sample = audio[start:start + frame_size]
        if np.sqrt(np.mean(sample**2)) > min_energy:
            frame = sample
            break

############ Save array to txt file #############
    # removes past output file 
    for file in ['fft_real.csv', 'fft_imag.csv']:
        path = f'{LAB_DIR}/{file}'
        if os.path.exists(path):
            os.remove(path)
    np.savetxt(f'{LAB_DIR}/frame.csv', frame, delimiter=',')
    print("Wrote frame.csv")

############ Run spatial FFT ###############

    # print("Spatial subprocess running") 
    result = subprocess.run(['sbt', '-Dtest.CS217=true', '; testOnly Butterfly'], capture_output=True, text=True, cwd=LAB_DIR)
    #print(result.stdout[:20])
    if result.returncode != 0:
        print("SBT FAILED:")
        exit(1)

############ Get FFT Ootputs ###############

    def load_csv(path):
        with open(path, 'r') as f:
            content = f.read().strip()
        vals = [float(x) for x in content.split(',') if x.strip()]
        return np.array(vals)

    real = load_csv(f'{LAB_DIR}/fft_real.csv')
    imag = load_csv(f'{LAB_DIR}/fft_imag.csv')
    window = np.hamming(frame_size)
    x_ref = np.fft.fft(frame * window)

############ Magnitude/ log ###############

    mag = np.sqrt(real**2 + imag**2)
    log_spec = 20 * np.log10(mag + 1e-10)
    log_spec = log_spec[:512]

    #print(f"First 10 bins:\n{log_spec[:10]}")

############ Numpy version ###############

    window = np.hamming(frame_size)
    x_ref = np.fft.fft(frame * window)
    ref_spec = 20 * np.log10(np.abs(x_ref[:512]) + 1e-10)

    max_diff = np.max(np.abs(ref_spec - log_spec))

    diff = np.abs(ref_spec - log_spec)
    mean_diff = diff.mean()

    print("Song:", filename)
    print("Mean diff:", mean_diff)
    print("Max diff:", max_diff)
    print("PASS" if mean_diff < 1.0 else "FAIL")

############ Save for LSTM ###############

    np.save(f'{LAB_DIR}/log_magnitude.npy', log_spec)
    print(f"\nSaved for LSTM. Shape: {log_spec.shape}")
