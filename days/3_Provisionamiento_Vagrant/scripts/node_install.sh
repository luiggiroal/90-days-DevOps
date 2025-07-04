#!/bin/bash

# Installing Node
check_install "node" "curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash - && apt install -y nodejs" "node -v"

# Installing Npm
check_install "npm" "apt install npm -y" "npm -v"

