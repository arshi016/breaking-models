import torch

torch.load("model.pt", weights_only=False)
print("loaded")
