# Faizan's Nix configuration

This repository contains my Nix configurations for macOS and WSL.

## Prerequisites

### macOS

1. Install the Xcode Command Line Tools.

```bash
xcode-select --install
```

2. Install Nix via the [Determinate Systems graphical installer](https://determinate.systems/).

### WSL/Linux

Install Nix through your preferred method. I use the Determinate Systems installer CLI:

```bash
curl -fsSL https://install.determinate.systems/nix | sh -s -- install
```

## Installation

### macOS

Inside the config directory, run:

```bash
sudo nix run nix-darwin -- switch --flake .#mac
```

### WSL/Linux

Inside  the config directory, run:

```bash
nix run home-manager/master -- switch --flake .#wsl
```

## Daily Management

To redeploy, you can run this alias from anywhere:

```bash
rebuild
```

You can manually trigger garbage collection:

```bash
nix-collect-garbage
```
