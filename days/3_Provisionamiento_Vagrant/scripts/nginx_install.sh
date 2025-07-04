#!/bin/bash

# Installing Nginx
check_install "nginx" "apt install -y nginx" "nginx -v"
print_msg ${YELLOW} "Enabling and activating Nginx..."
# Equivalent to: systemctl enable nginx && systemctl start nginx
systemctl enable --now nginx 2>/dev/null # Hides stderr. Shows stdout.

# Checking services
check_serv "nginx"
