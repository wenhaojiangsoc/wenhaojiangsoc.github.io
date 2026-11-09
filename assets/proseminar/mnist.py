# Train a small convolutional neural network to read handwritten digits (MNIST).
# Download the data once before submitting (see the guide), since this script does not.

import time

import torch
from torch import nn
from torch.utils.data import DataLoader
from torchvision import datasets, transforms

device = "cuda" if torch.cuda.is_available() else "cpu"
print("Running on", torch.cuda.get_device_name(0) if device == "cuda" else "CPU", flush=True)

to_tensor = transforms.ToTensor()
train = datasets.MNIST("data", train=True, transform=to_tensor)
test = datasets.MNIST("data", train=False, transform=to_tensor)
train_dl = DataLoader(train, batch_size=128, shuffle=True)
test_dl = DataLoader(test, batch_size=1000)

model = nn.Sequential(
    nn.Conv2d(1, 32, 3, padding=1), nn.ReLU(), nn.MaxPool2d(2),
    nn.Conv2d(32, 64, 3, padding=1), nn.ReLU(), nn.MaxPool2d(2),
    nn.Flatten(), nn.Linear(64 * 7 * 7, 128), nn.ReLU(), nn.Linear(128, 10),
).to(device)
optimizer = torch.optim.Adam(model.parameters(), lr=1e-3)
loss_fn = nn.CrossEntropyLoss()

for epoch in range(1, 6):
    start = time.time()
    model.train()
    for x, y in train_dl:
        x, y = x.to(device), y.to(device)
        optimizer.zero_grad()
        loss_fn(model(x), y).backward()
        optimizer.step()

    model.eval()
    correct = 0
    with torch.no_grad():
        for x, y in test_dl:
            correct += (model(x.to(device)).argmax(1) == y.to(device)).sum().item()
    print(f"Epoch {epoch}: test accuracy {correct / len(test):.3f} ({time.time() - start:.0f} s)", flush=True)

torch.save(model.state_dict(), "results/mnist_cnn.pt")
