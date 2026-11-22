import torch

torch.load("model.pt", weights_only=True)  # default from PyTorch 2.6
print("loaded")
