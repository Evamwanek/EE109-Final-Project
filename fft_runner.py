import librosa
import numpy as np
import subprocess
import os

# The following code loads audio .wav files. Then, it runs
# the spatial code as a subprocess on one 1024 block of audio by
# writing it to a csv spatial reads from. Lastly, it uses log
# scale to match software implementation. 
LAB_DIR = '.'
num_frames = 50

import torch
import torch.nn as nn
## need just the proj layer 

class SmallLSTM(nn.Module):
    def __init__(self):
        super().__init__()
        self.proj = nn.Linear(512, 128)
        self.lstm = nn.LSTM(
            input_size=128,
            hidden_size=128,
            num_layers=2,
            batch_first=True,
            dropout=0.2
        )
        self.fc = nn.Linear(128, 10)

    def forward(self, x):
        x = self.proj(x)
        x, _ = self.lstm(x)
        x = x[:, -1, :]
        x = self.fc(x)
        return x


### load model for just the proj layer###
model_export = SmallLSTM()
model_export.load_state_dict(torch.load(f'{LAB_DIR}/model_small.pth', map_location='cpu'))
model_export.eval()
############ Load audio ###############
folder = '/Users/sarakothari/Downloads/EE109 Songs'
for filename in os.listdir(folder):
    if not filename.endswith(".wav"):
        continue
    path = os.path.join(folder, filename)
    audio, sr = librosa.load(path, sr=22050)

############ Take frame of audio ###############

    frame_size = 1024
    jump = 512
    frames = []
    # get audio from middle instead of silence at
    # beginning and end 
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

############ Save array to txt file #############
    frames = np.array(frames)
    print("frames shape:", frames.shape)
    frames_flat = frames.reshape(-1)
    np.savetxt(f'{LAB_DIR}/frames.csv', frames_flat, delimiter=',')
    print("Saved frames.csv")

    # delete old outputs
    for old in ['fft_real.csv', 'fft_imag.csv']:
        if os.path.exists(f'{LAB_DIR}/{old}'):
            os.remove(f'{LAB_DIR}/{old}')

############ Run spatial FFT ###############

    # print("Spatial subprocess running") 
    result = subprocess.run(['sbt', '-Dtest.CS217=true', '; testOnly Butterfly'], capture_output=True, text=True, cwd=LAB_DIR)
    #print(result.stdout[:20])
    # if result.returncode != 0:
    #     print("SBT FAILED:")
    #     exit(1)
    if result.returncode != 0:
        print("SBT FAILED:")
        print(result.stdout[-3000:])  
        print(result.stderr[-1000:])
        exit(1)

############ Get FFT Ootputs ###############

    real = np.genfromtxt(f'{LAB_DIR}/fft_real.csv', delimiter=',')
    imag = np.genfromtxt(f'{LAB_DIR}/fft_imag.csv', delimiter=',')
    # trailing comma 
    real = real[~np.isnan(real)].reshape(num_frames, 1024)
    imag = imag[~np.isnan(imag)].reshape(num_frames, 1024)

# ############ Magnitude/ log ###############
#     num_bins = 128
#     mag = np.sqrt(real**2 + imag**2)
#     log_spec = 20 * np.log10(mag + 1e-10)
#     seq = log_spec[:, :num_bins]
#     seq_flat = seq.reshape(-1)

# ############ Save for LSTM ###############

#     np.savetxt(f'{LAB_DIR}/input_seq_test.csv', seq_flat, delimiter=',')


############ Magnitude/ log ###############
    mag = np.sqrt(real**2 + imag**2)
    log_spec = 20 * np.log10(mag + 1e-10)
    seq = log_spec[:, :512]  # (50, 512) — full 512 bins

############ Normalize ###############
    seq = (seq - seq.mean()) / (seq.std() + 1e-8)

############ we need to project 512->128 using PyTorch proj layer since i havent accelerated that ###############
   

    with torch.no_grad():
        seq_tensor = torch.tensor(seq, dtype=torch.float32)  # (50, 512)
        proj = model_export.proj(seq_tensor).numpy()          # (50, 128)

############ Save for LSTM ###############
    np.savetxt(f'{LAB_DIR}/input_seq.csv', proj.flatten(), delimiter=',')

    result = subprocess.run(
        ['sbt', '-Dtest.CS217=true', '; testOnly LSTMInference'],
        capture_output=True, text=True, cwd=LAB_DIR
    )
    GENRES = [
    "blues", "classical", "country", "disco", "hiphop",
    "jazz", "metal", "pop", "reggae", "rock"]

    for line in result.stdout.split('\n'):
        if 'Predicted genre index:' in line:
            idx = int(line.strip().split()[-1])
            predicted_genre = GENRES[idx]
            print(f"File: {filename}")
            print(f"Predicted genre: {predicted_genre}")
    if result.returncode != 0:
        print("LSTM failed")
    
    ############ Software baseline comparison ###############
    with torch.no_grad():
        seq_tensor2 = torch.tensor(seq, dtype=torch.float32).unsqueeze(0)  # (1, 50, 512)
        logits = model_export(seq_tensor2)
        sw_pred = torch.argmax(logits, dim=1).item()
        print(f"Software prediction: {GENRES[sw_pred]}")