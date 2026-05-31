import librosa
import numpy as np
import subprocess
import os

LAB_DIR = '.'
num_frames = 50
folder = '/Users/mayabridgman/Documents/EE109 Songs'
for filename in os.listdir(folder):
    if not filename.endswith(".wav"):
        continue
    path = os.path.join(folder, filename)
    audio, sr = librosa.load(path, sr=22050)

    frame_size = 1024
    jump = 512
    frames = []
    min_energy = 0.01
    for start in range(0, len(audio) - frame_size, jump):
        frame = audio[start:start + frame_size]
        if np.sqrt(np.mean(frame**2)) > min_energy:
            frames.append(frame)
        if len(frames) == num_frames:
            break
    if len(frames) < num_frames:
        print("Not enough frames")
        continue

    frames = np.array(frames)
    frames_flat = frames.reshape(-1)
    np.savetxt(f'{LAB_DIR}/frames.csv', frames_flat, delimiter=',')

    for old in ['fft_real.csv', 'fft_imag.csv', 'input_seq.csv']:
        if os.path.exists(f'{LAB_DIR}/{old}'):
            os.remove(f'{LAB_DIR}/{old}')

    result = subprocess.run(['sbt', '-Dtest.CS217=true', '; testOnly Butterfly'], capture_output=True, text=True, cwd=LAB_DIR)
    if result.returncode != 0:
        print("Butterfly FAILED:")
        print(result.stdout[-3000:])
        print(result.stderr[-1000:])
        exit(1)

    result = subprocess.run(['sbt', '-Dtest.CS217=true', '; testOnly MelProjection'], capture_output=True, text=True, cwd=LAB_DIR)
    if result.returncode != 0:
        print("MelProjection FAILED:")
        print(result.stdout[-3000:])
        print(result.stderr[-1000:])
        exit(1)

    result = subprocess.run(['sbt', '-Dtest.CS217=true', '; testOnly LSTMInference'], capture_output=True, text=True, cwd=LAB_DIR)

    GENRES = ["blues", "classical", "country", "disco", "hiphop", "jazz", "metal", "pop", "reggae", "rock"]

    for line in result.stdout.split('\n'):
        if 'Predicted genre index:' in line:
            idx = int(line.strip().split()[-1])
            print(f"File: {filename}")
            print(f"Predicted genre: {GENRES[idx]}")
    if result.returncode != 0:
        print("LSTM failed")
