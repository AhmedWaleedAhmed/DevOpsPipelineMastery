#!/bin/bash

# Update the package list and install prerequisites
sudo apt update -y
sudo apt install -y wget apt-transport-https gnupg lsb-release

# Import the Trivy GPG key
wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | sudo apt-key add -

# Add the Trivy repository
echo "deb https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main" | sudo tee -a /etc/apt/sources.list.d/trivy.list

# Update the package list again
sudo apt update -y

# Install Trivy
sudo apt install -y trivy

# Confirm the installation
echo "Trivy version:"
trivy --version

echo "Trivy has been installed successfully!"
