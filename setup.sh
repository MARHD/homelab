#!/bin/bash
set -e

echo "==> Updating system"
sudo apt update && sudo apt upgrade -y

echo "==> Installing dependencies"
sudo apt install -y curl ca-certificates

echo "==> Installing Docker"
curl -fsSL https://get.docker.com | sh
sudo usermod -aG docker $USER

echo "==> Enabling WireGuard kernel module"
sudo apt install -y wireguard
echo "wireguard" | sudo tee /etc/modules-load.d/wireguard.conf

echo "==> Hardening SSH (disabling password auth)"
sudo sed -i 's/^#*PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config
sudo systemctl restart ssh

echo "==> Reducing GPU memory"
if ! grep -q "gpu_mem=16" /boot/firmware/config.txt; then
    echo "gpu_mem=16" | sudo tee -a /boot/firmware/config.txt
fi

echo "==> Disabling swap"
sudo dphys-swapfile swapoff
sudo systemctl disable dphys-swapfile

echo "==> Disabling bluetooth"
sudo systemctl disable bluetooth hciuart 2>/dev/null || true

echo ""
echo "==> Done. Next steps:"
echo "  1. cp .env.example .env && nano .env"
echo "  2. Once HDD is mounted: docker compose up -d"
echo ""
echo "Reboot recommended for group changes to take effect."
