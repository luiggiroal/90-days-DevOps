#!/bin/bash

REPO_URL="https://github.com/StartBootstrap/startbootstrap-freelancer.git"
NGINX_ROOT="/var/www/html"
LOCALHOST_URL="http://localhost"
PORT=80

# Changing directory to Home
print_msg ${YELLOW} "Changing directory to Home..."
cd ~

if [[ ! -d  startbootstrap-freelancer ]]; then
  # Cloning repo
  print_msg ${YELLOW} "Cloning repo..."
  git clone $REPO_URL
fi

# Changing directory to startbootstrap-freelancer
print_msg ${YELLOW} "Changing directory to startbootstrap-freelancer..."
cd startbootstrap-freelancer

# Starting and building project
print_msg ${YELLOW} "Starting and building project..."
npm install
npm run build

# Cleaning and overwriting Nginx's default root
print_msg ${YELLOW} "Cleaning and overwriting Nginx's default root..."
rm -rf ${NGINX_ROOT}/*
cp -r dist/* ${NGINX_ROOT}

# Reloading Nginx
print_msg ${YELLOW} "Reloading Nginx..."
sudo systemctl reload nginx

# Changing the header of the site
print_msg ${YELLOW} "Changing the header of the site..."
sed -i 's/<h1 class="masthead-heading text-uppercase mb-0">Start Bootstrap<\/h1>/<h1 class="masthead-heading text-uppercase mb-0">Luiggi Rodríguez<\/h1>/g' ${NGINX_ROOT}/index.html
sed -i 's/<a class="navbar-brand" href="#page-top">Start Bootstrap<\/a>/<a class="navbar-brand" href="#page-top">My Portfolio<\/a>/g' ${NGINX_ROOT}/index.html

# Verifying the site
print_msg ${YELLOW} "Verifying the site through ${LOCALHOST_URL}:${PORT}..."
sleep 5 
curl -s ${LOCALHOST_URL}:${PORT} | head -20
