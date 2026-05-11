import librosa 
import numpy as np
from pathlib import Path
import random

import time
from sklearn.metrics import confusion_matrix

import torch
import torch.nn as nn
from torch.utils.data import TensorDataset, DataLoader

######################## PERFORMANCE #########################

fft_total_time = 0  # Time to make a spectrogram for each song (10 total songs)
inference_total_time = 0 
e2e_time = 0
correct_predictions = 0 
total_predictions = 0 

########################### FFT ###############################

def my_spectrogram(x, m, fs): 

    # Inputs:
    # x -- data vector
    # m -- block size, must be even
    # fs -- sampling rate

    if (m % 2 != 0):
        raise ValueError("Choose an even block size")

    # Pad x up to a multiple of m
    lx = len(x)
    nt = int(np.ceil(lx/m))
    # plus 1 is so that the overlapping window works
    xp = np.zeros((nt + 1) * m)
    xp[:lx] = x


    # Rectangular windowing
    # use reshape to make it an m by nt matrix
    xm = xp[:nt * m].reshape((nt, m)).T

    # 50% overlapping blocks 
    n1 = m // 2
    n2 = n1+nt*m

    xmi = xp[n1:n2].reshape((nt, m)).T

    xm3 = np.zeros((m,2*nt))
    xm3[:, 0::2] = xm
    xm3[:, 1::2] = xmi
    
    window = np.hamming(m)
    xm3 *= window[:, None]

    xmf3 = np.fft.fft(xm3, axis=0)

    spectrogram = np.abs(xmf3[:m // 2, :])
    spectrogram = 20 * np.log10(
    np.abs(xmf3[:m // 2, :]) + 1e-10
    )
    # Axes
    freqs = np.arange(0, m // 2) * fs / m
    times = np.arange(1, 2 * nt + 1) * m / (2 * fs)

    return spectrogram, freqs, times

####################### SONG LOADING ########################

# 10 songs, 10 seconds each 
songs_folder = Path("/Users/evawanek/Desktop/EE109 Songs")

X = []
Y = []

# Load song in chunks to increase dataset
chunk_size = 20

song_names = []

for label, song_path in enumerate(songs_folder.glob("*.wav")):

    print(f"Loading: {song_path.name}")

    song_names.append(song_path.name)

    # Make sampling rate same for all songs 
    audio, sample_rate = librosa.load(
        song_path,
        sr=44100
    )

    fft_start = time.time() 

    # Generate FFTs 
    spectrogram, freqs, times = my_spectrogram(
        audio,
        m=1024,
        fs=sample_rate
    )

    fft_end = time.time()

    fft_total_time += (fft_end - fft_start)

    # (time_steps, freq_bins)
    spectrogram = spectrogram.T

    # Normalize
    spectrogram = (
        spectrogram - np.mean(spectrogram)
    ) / np.std(spectrogram)

    # Create chunks
    for i in range(0, spectrogram.shape[0] - chunk_size):
        chunk = spectrogram[i:i + chunk_size]

        X.append(chunk)
        Y.append(label)


X = np.array(X, dtype=np.float32)
Y = np.array(Y)

print("Dataset shape:", X.shape)
print("Labels shape:", Y.shape)

################## SETTING UP PYTORCH ###################
X_tensor = torch.tensor(X)
Y_tensor = torch.tensor(Y)

dataset = TensorDataset(X_tensor, Y_tensor)

# Feeds data into network 
loader = DataLoader(dataset, batch_size=16, shuffle=True)

################## LSTM MODEL ###################

class SongLSTM(nn.Module):

    def __init__(self):

        super().__init__()

        # Basic single layer LSTM
        self.lstm = nn.LSTM(
            input_size = 512,   # Number of frequency bins
            hidden_size = 32,
            num_layers = 1,
            batch_first = True
        )

        # Final classifier layer 
        self.fc = nn.Linear(32, len(song_names))

    def forward(self, x):

        # Feeds FFT into LSTM 
        out, (hidden, cell) = self.lstm(x)

        final_hidden = hidden[-1]

        out = self.fc(final_hidden)

        return out


model = SongLSTM()

################## TRAINING ###################

loss_func = nn.CrossEntropyLoss()

optimizer = torch.optim.Adam(
    model.parameters(),
    lr=0.001
)

epochs = 10

for epoch in range(epochs):

    total_loss = 0
    for batch_x, batch_y in loader:
        optimizer.zero_grad()
        predictions = model(batch_x)

        loss = loss_func(predictions, batch_y)

        loss.backward()

        optimizer.step()

        total_loss += loss.item()

    print(f"Epoch {epoch+1}, Loss: {total_loss:.4f}")

################## INFERENCE ###################

model.eval()

predicted_labels = []
actual_labels = []

e2e_start = time.time()

with torch.no_grad():

    # Tests predictions with 100 chunks, 17040 total 
    for z in range(100):

        # Choose random chunk 
        i = random.randint(0, len(X_tensor) - 1)

        # Adds batch dimension for LSTM
        x = X_tensor[i].unsqueeze(0)

        # Number of chunks 
        #print(len(X))

        inference_start = time.time()

        prediction = model(x)

        inference_end = time.time()

        inference_total_time += (inference_end - inference_start)

        predicted_class = torch.argmax(prediction, dim=1).item()

        actual_class = Y_tensor[i].item()

        predicted_labels.append(predicted_class)
        actual_labels.append(actual_class)

        predicted_song = song_names[predicted_class]
        actual_song = song_names[actual_class]

        print("--------------------------------")
        print(f"Random Chunk Index: {i}")
        print(f"Predicted: {predicted_song}")
        print(f"Actual:    {actual_song}")

        if predicted_class == actual_class:
            print("Correct!")
            correct_predictions += 1
        else:
            print("Incorrect")
        total_predictions += 1

e2e_end = time.time() 
e2e_time += (e2e_end - e2e_start)

###################### PERFORMANCE ############################

accuracy = (correct_predictions / total_predictions) * 100
avg_fft_time = fft_total_time / len(song_names)
avg_inference_time = inference_total_time / total_predictions
throughput = total_predictions / e2e_time

print(f"FFT Total Time: {fft_total_time:.2f} sec")
print("--------------------------------")
print(f"Avg FFT Time: {avg_fft_time*1000:.2f} ms")
print("--------------------------------")
print(f"Accuracy: {accuracy:.2f}%")
print("--------------------------------")
print(f"Inference Total Time: {inference_total_time:.2f} sec")
print("--------------------------------")
print(f"Avg Total Time: {avg_inference_time*1000:.2f} ms")
print("--------------------------------")
print(f"End to end latency: {e2e_time:.2f} seconds")
print("--------------------------------")
print(f"Throughput: {throughput:.2f} chunks/sec")
print("--------------------------------")

cm = confusion_matrix(
    actual_labels,
    predicted_labels
)

print("\nConfusion Matrix:")
print(cm)