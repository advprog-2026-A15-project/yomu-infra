#!/bin/bash
set -e

echo "=========================================="
echo "Starting EC2 Environment Setup for Yomu App"
echo "=========================================="

# 1. Setup Swap File (4GB) to prevent OOM
if [ ! -f /swapfile ]; then
    echo "[1/3] Configuring 4GB Swap Space..."
    sudo fallocate -l 4G /swapfile || sudo dd if=/dev/zero of=/swapfile bs=1M count=4096
    sudo chmod 600 /swapfile
    sudo mkswap /swapfile
    sudo swapon /swapfile
    echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
    echo "Swap space configured."
else
    echo "[1/3] Swap space already exists."
fi

# 2. Update System Packages
echo "[2/3] Updating system packages..."
sudo apt-get update -y

# 3. Install Docker & Docker Compose Plugin (if not installed)
if ! command -v docker &> /dev/null; then
    echo "[3/3] Installing Docker..."
    sudo apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release
    
    # Add Docker's official GPG key
    sudo mkdir -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    
    # Set up the repository
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
      $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    
    sudo apt-get update -y
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    
    # Allow current user to run Docker commands without sudo (requires logout/login to take effect)
    sudo usermod -aG docker $USER
    echo "Docker & Docker Compose installed successfully."
else
    echo "[3/3] Docker is already installed."
fi

echo "=========================================="
echo "Setup Completed!"
echo "NOTE: If this is your first time running Docker, run: newgrp docker"
echo "To run the application: docker compose -f docker-compose.deploy.yml up --build -d"
echo "=========================================="
