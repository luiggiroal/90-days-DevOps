#!/bin/bash

# Colors
BLUE="\033[0;34m"
YELLOW="\033[1;33m"
GREEN="\033[0;32m"
RED="\033[0;31m"
PURPLE="\033[7;35m"
RED_STRONG="\033[7;31m"
NC="\033[0m" # No color

# Print message function
print_message() {
  local color=$1
  local msg=$2
  echo -e "${color}${msg}${NC}"
}

# Variables
LOG_FILE="logs_deploy.log"
DEPENDENCIES=("curl" "ca-certificates" "nginx" "git")
DATE=$(date "+%d/%m/%Y at %H:%M:%S")
URL_APP="https://github.com/roxsross/devops-static-web.git"
URL_NVM="https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh"
NAME_APP="devops-static-web"
SERVICE="nginx"
NGINX_ENABLED_PATH="/etc/nginx/sites-enabled"
NGINX_ECOMMERCE_PATH="/etc/nginx/sites-available/ecommerce"
# BASH_PATH="$HOME/.bashrc" # Use '$HOME' instead of '~' when working in a bash script.

exec > >(tee -a "${LOG_FILE}") 2>&1 # Appending the output to $LOG_FILE

check_install() {
  local package_name=$1
  if ! dpkg -s "${package_name}" &>/dev/null; then
    print_message "${RED}" "\n'${package_name}' is not installed!"
    print_message "${BLUE}" "Installing '${package_name}'..."
    sudo apt install -y "${package_name}"
    return
  fi
  print_message "${GREEN}" "\n'${package_name}' is already installed!"
}

install_dependencies() {
  print_message "$YELLOW" "\nUpdating packages..."
  sudo apt update
  print_message "$YELLOW" "\nInstalling dependencies..."
  for prog in "${DEPENDENCIES[@]}"; do
    check_install "${prog}"
  done

  export NVM_DIR="$HOME/.nvm"
  print_message "${YELLOW}" "\nInstalling NVM..."
  if [[ ! -s "$NVM_DIR/nvm.sh" ]]; then
    print_message "${RED}" "\n'nvm' is not installed!"
    print_message "${BLUE}" "Downloading and running 'nvm' install script..."
    curl -o- "${URL_NVM}" | bash
  else
    print_message "${GREEN}" "\n'nvm' is already installed!"
  fi

  print_message "${BLUE}" "Making 'nvm' available..."
  \. "$NVM_DIR/nvm.sh" # '.\' is the same to 'source'

  print_message "${YELLOW}" "\nInstalling Node and npm..."
  print_message "${BLUE}" "Installing Node v20 and its corresponding version of npm..."
  nvm install 20 || exit 1
  print_message "${BLUE}" "Switching to Node v20..."
  nvm use 20 || exit 1

  print_message "${YELLOW}" "\nInstalling PM2..."
  if ! command -v pm2 >/dev/null; then
    print_message "${RED}" "\nPM2 is not installed!"
    print_message "${BLUE}" "Installing PM2 globally..."
    npm install -g pm2 #  Running 'sudo' as root, doesn't know about 'nvm'. Don't use it with npm
  else
    print_message "${GREEN}" "PM2 is already installed!"
  fi

  print_message "${YELLOW}" "\nActivating 'nginx'..."
  if ! systemctl is-enabled --quiet "${SERVICE}" && ! systemctl is-active --quiet "${SERVICE}"; then
    print_message "${RED}" "\nNginx is not activated nor enabled..."
    print_message "${BLUE}" "Enabling and activating 'nginx'..."
    sleep 2
    sudo systemctl enable --now nginx 2>/dev/null
    return
  fi
  print_message "${GREEN}" "\nThe ${SERVICE} service is already enabled and running!"
}

cloning_app() {
  if [[ -d "${NAME_APP}" && "$(ls -A "${NAME_APP}")" ]]; then # Check if app dir already exists
    print_message "${RED}" "\n'${NAME_APP}' already exists and is not empty!"
    while [[ ! "${answer}" =~ ^[Yy]$ && ! "${answer}" =~ ^[Nn]$ ]]; do
      read -r -p "Do you want to delete it? [y/n]: " answer
    done
    if [[ "${answer}" =~ ^[Yy]$ ]]; then
      print_message "${BLUE}" "Deleting '${NAME_APP}' directory..."
      rm -rf "${NAME_APP}"
    else
      cd "${NAME_APP}" || {
        print_message "${RED}" "Failed to change directory to ${NAME_APP}. Finishing deployment process..."
        exit 1
      }
      return
    fi
  fi

  print_message "$YELLOW" "\nCloning application..."
  git clone -b ecommerce-ms "${URL_APP}"
  cd "${NAME_APP}" || {
    print_message "${RED}" "Failed to change directory to ${NAME_APP}. Finishing deployment process..."
    exit 1
  }
}

install_npm_dependencies() {
  print_message "$YELLOW" "\nInstalling npm dependencies for each subdirectory..."
  for dir in */; do
    if [[ -f "${dir}/package.json" ]]; then
      print_message "${BLUE}" "\nRunning 'npm install' in ${dir}..."
      # '--no-bin-links' flag prevents npm from creating symlinks. Useful when working with Vagrant and synced folders activated.
      (cd "${dir}" && npm install --no-bin-links 2>/dev/null) # What goes inside the '()' only happens inside a subshell, remaining the current shell in its original directory.
      print_message "${GREEN}" "Done with ${dir}."
    else
      print_message "${RED}" "\nSkipping ${dir}. No package.json found!"
    fi
  done
}

deployment_apps() {
  declare -A apps
  print_message "${YELLOW}" "\nDeploying apps using PM2..."

  print_message "${BLUE}" "\nGetting all the available apps to be deployed..."
  for dir in */; do
    if [[ -f "${dir}/server.js" ]]; then
      dir="${dir%/}" # Removing trailing '/'
      apps["${dir}"]="${dir}/server.js"
      print_message "${GREEN}" "Got ${dir} -> ${apps[${dir}]}"
    fi
  done

  for name in "${!apps[@]}"; do
    local script="${apps[${name}]}"
    if [[ -f "${script}" ]]; then
      print_message "${BLUE}" "Starting ${name} with PM2..."
      pm2 start "${script}" --name "${name}" &>/dev/null
    else
      print_message "${RED}" "\n${script} not found. Skipping ${name}..."
    fi
  done

  print_message "${BLUE}" "\nListing the running apps handle by PM2...\n"
  pm2 list

  print_message "${BLUE}" "\nSaving the current process list...\n"
  pm2 save
}

configure_nginx() {
  print_message "${YELLOW}" "\nConfiguring Nginx..."
  if [[ -f "${NGINX_ENABLED_PATH}/default" ]]; then
    print_message "${BLUE}" "\nDeleting Nginx's default configuration..."
    sudo rm -f "${NGINX_ENABLED_PATH}/default"
  fi

  print_message "${BLUE}" "\nSetting up Nginx configuration for ecommerce-ms ..."
  cat <<EOF | sudo tee "${NGINX_ECOMMERCE_PATH}" >/dev/null
server {
    listen 80;
    server_name localhost;

    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
    }

    location /merchandise {
        proxy_pass http://localhost:3003;
        proxy_http_version 1.1;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
    }

    location /products {
        proxy_pass http://localhost:3001;
        proxy_http_version 1.1;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
    }

    location /cart {
        proxy_pass http://localhost:3002;
        proxy_http_version 1.1;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
    }
}
EOF

  print_message "${BLUE}" "\nLinking ecommerce-ms to Nginx's enabled sites..."
  sudo ln -sf "${NGINX_ECOMMERCE_PATH}" "${NGINX_ENABLED_PATH}"
  print_message "${BLUE}" "\nChecking Nginx configuration..."
  sudo nginx -t && {
    print_message "${GREEN}" "\nNginx configuration is OK!"
    print_message "${BLUE}" "\nReloading Nginx..."
    sudo systemctl reload nginx
    return
  }
  print_message "${RED}" "\nNginx configuration test failed!"
  exit 1
}

check_services() {
  print_message "${YELLOW}" "\nChecking services..."

  if systemctl is-active --quiet nginx; then
    print_message "${GREEN}" "\n✓ Nginx is active!"
  else
    print_message "${RED}" "\n✗ Nginx is inactive!"
  fi

  for port in {3000..3003}; do
    if sudo netstat -tlnp | grep -q ":${port}"; then
      print_message "${GREEN}" "\n✓ Port ${port} is in use!"
    else
      print_message "${RED}" "\n✗ Port ${port} is not in use!"
    fi
  done

  if curl -s "http://127.0.0.1:3000" >/dev/null; then
    print_message "${GREEN}" "\n✓ Ecommerce is responding correctly!"
  else
    print_message "${RED}" "\n✗ Ecommerce is not responding!"
  fi
}

main() {
  echo ""
  print_message "${PURPLE}" "Deployment on ${DATE}"
  print_message "${YELLOW}" "\n=== Starting the App deployment with PM2 ==="
  install_dependencies
  cloning_app
  install_npm_dependencies
  deployment_apps
  configure_nginx
  check_services

  print_message "${YELLOW}" "\n=== Deployment completed ==="
  print_message "${YELLOW}" "\nLook '${LOG_FILE}' for details."
  print_message "${YELLOW}" "The app should be available in: http://$(hostname -I | awk '{print $1}'):3000\n"
}

main
