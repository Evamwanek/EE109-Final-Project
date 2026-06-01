import torch
import torch.nn as nn
import numpy as np

class SmallLSTM(nn.Module):
    def __init__(self):
        super().__init__()
        self.proj = nn.Linear(512, 128)
        self.lstm = nn.LSTM(input_size=128, hidden_size=128, num_layers=2, batch_first=True, dropout=0.2)
        self.fc = nn.Linear(128, 10)

model = SmallLSTM()
model.load_state_dict(torch.load('model_small.pth', map_location='cpu'))
model.eval()

np.savetxt('proj_weight.csv', model.proj.weight.detach().numpy().flatten(), delimiter=',')
np.savetxt('proj_bias.csv',   model.proj.bias.detach().numpy().flatten(),   delimiter=',')

np.savetxt('weight_ih_l0.csv', model.lstm.weight_ih_l0.detach().numpy().flatten(), delimiter=',')
np.savetxt('weight_hh_l0.csv', model.lstm.weight_hh_l0.detach().numpy().flatten(), delimiter=',')
np.savetxt('bias_ih_l0.csv',   model.lstm.bias_ih_l0.detach().numpy().flatten(),   delimiter=',')
np.savetxt('bias_hh_l0.csv',   model.lstm.bias_hh_l0.detach().numpy().flatten(),   delimiter=',')
np.savetxt('weight_ih_l1.csv', model.lstm.weight_ih_l1.detach().numpy().flatten(), delimiter=',')
np.savetxt('weight_hh_l1.csv', model.lstm.weight_hh_l1.detach().numpy().flatten(), delimiter=',')
np.savetxt('bias_ih_l1.csv',   model.lstm.bias_ih_l1.detach().numpy().flatten(),   delimiter=',')
np.savetxt('bias_hh_l1.csv',   model.lstm.bias_hh_l1.detach().numpy().flatten(),   delimiter=',')
np.savetxt('fc_weight.csv',    model.fc.weight.detach().numpy().flatten(),          delimiter=',')
np.savetxt('fc_bias.csv',      model.fc.bias.detach().numpy().flatten(),            delimiter=',')

print("all weights exported!")