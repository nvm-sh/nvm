#!/bin/bash

set -e

echo "========================================"
echo "Setting up NVM Development Environment"
echo "========================================"

# Update package manager
echo "[1/5] Updating system packages..."
apt-get update > /dev/null 2>&1
apt-get install -y curl git build-essential python3 make g++ ca-certificates > /dev/null 2>&1

# Install NVM
echo "[2/5] Installing NVM (Node Version Manager)..."
export NVM_DIR="/root/.nvm"
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.6/install.sh | bash > /dev/null 2>&1

# Load NVM
source "$NVM_DIR/nvm.sh"

# Install multiple Node versions
echo "[3/5] Installing Node.js LTS versions..."
echo "  - Installing Node 20 (LTS Iron)..."
nvm install lts/iron > /dev/null 2>&1
echo "  - Installing Node 18 (LTS Hydrogen)..."
nvm install lts/hydrogen > /dev/null 2>&1
echo "  - Installing Node 16 (LTS Gallium)..."
nvm install lts/gallium > /dev/null 2>&1
echo "  - Installing latest Node..."
nvm install node > /dev/null 2>&1

# Set default version
echo "[4/5] Setting default Node version to LTS Iron (v20)..."
nvm alias default lts/iron

# Install global npm packages
echo "[5/5] Installing global npm utilities..."
npm install -g npm@latest pnpm yarn tsx ts-node > /dev/null 2>&1

echo ""
echo "========================================"
echo "✅ Setup Complete!"
echo "========================================"
echo ""
echo "Installed Node versions:"
nvm list
echo ""
echo "Current Node version:"
node --version
echo "Current npm version:"
npm --version
echo ""
echo "Quick Commands:"
echo "  nvm list              - Show installed versions"
echo "  nvm use lts/iron      - Switch to Node 20"
echo "  nvm use lts/hydrogen  - Switch to Node 18"
echo "  nvm use lts/gallium   - Switch to Node 16"
echo "  nvm use node          - Switch to latest"
echo ""
