#!/bin/bash

# Installing Docker
check_install "docker" "apt install -y docker.io" "docker --version"
print_msg ${YELLOW} "Enabling and activating Docker..."
# Equivalent to: systemctl enable docker && systemctl start docker
systemctl enable --now docker 2>/dev/null # Hides stderr. Shows stdout.

# Checking services
check_serv "docker"

# Installing kubectl
check_install "kubectl" "curl -LO https://dl.k8s.io/release/$(curl -sL https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl && install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl" "kubectl version --client"
