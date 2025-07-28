#!/bin/bash

# Colors
BLUE="\033[0;34m"
YELLOW="\033[1;33m"
GREEN="\033[0;32m"
RED="\033[0;31m"
PURPLE="\033[7;35m"
NC="\033[0m" # No color

# Print message function
print_message() {
  local color=$1
  local msg=$2
  echo -e "${color}${msg}${NC}"
}

# Variables
LOG_FILE="logs_deploy.log"
DEPENDENCIES=("python3" "python3-pip" "python3-venv" "nginx" "git")
DATE=$(date "+%d/%m/%Y at %H:%M:%S")
URL_APP="https://github.com/roxsross/devops-static-web.git"
NAME_APP="devops-static-web"
SERVICE="nginx"
VENV_PATH="$HOME/venvs/${NAME_APP}"
NGINX_ENABLED_PATH="/etc/nginx/sites-enabled"
NGINX_BOOKLIBRARY_PATH="/etc/nginx/sites-available/booklibrary"

exec > >(tee -a "${LOG_FILE}") 2>&1 # Appending the output to $LOG_FILE

check_install() {
  local package_name=$1
  # if ! command -v "${prog_name}" &>/dev/null; then
  if ! dpkg -s "${package_name}" &>/dev/null; then
    print_message "${RED}" "\n'${package_name}' is not installed!"
    print_message "${BLUE}" "Installing '${package_name}'..."
    sudo apt install -y "${package_name}"
    return 1
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

  if ! systemctl is-enabled --quiet "${SERVICE}" && ! systemctl is-active --quiet "${SERVICE}"; then
    print_message "${YELLOW}" "\nEnabling and activating 'nginx'..."
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
    # elif [[ "${answer}" =~ ^[Nn]$ ]]; then
    else
      cd "${NAME_APP}" || {
        print_message "${RED}" "Failed to change directory to ${NAME_APP}. Finishing deployment process..."
        exit 1
      }
      return
    fi
  fi

  print_message "$YELLOW" "\nCloning application..."
  git clone -b booklibrary "${URL_APP}"
  cd "${NAME_APP}" || {
    print_message "${RED}" "Failed to change directory to ${NAME_APP}. Finishing deployment process..."
    exit 1
  }
}

configure_environment() {
  print_message "${YELLOW}" "\nConfiguring virtual environment..."
  mkdir -p "${VENV_PATH}"
  # python3 -m venv venv && source venv/bin/activate # For non-vagrant environment
  python3 -m venv "${VENV_PATH}" || { # Setting venv dir outside the Vagrant sync folder
    print_message "${RED}" "\nFailed to created venv!"
    exit 1
  }
  source "${VENV_PATH}/bin/activate"

  print_message "${YELLOW}" "\nInstalling all required packages..."
  pip install -r requirements.txt
  print_message "${YELLOW}" "\nInstalling 'gunicorn'..."
  pip install gunicorn
}

configure_gunicorn() {
  print_message "${YELLOW}" "\nStarting Gunicorn..."
  command -v gunicorn &>/dev/null || {
    print_message "${RED}" "\nGunicorn is not installed!"
    exit 1
  }
  pgrep -fl gunicorn &>/dev/null || {
    nohup "${VENV_PATH}/bin/gunicorn" -w 4 -b 0.0.0.0:8000 --timeout 120 library_site:app & # Starting gunicorn from venv
    sleep 3
    return
  }
  print_message "${GREEN}" "\nGunicorn is already running!"
}

configure_ginx() {
  print_message "${YELLOW}" "\nConfiguring Nginx..."
  if [[ -f "${NGINX_ENABLED_PATH}/default" ]]; then
    print_message "${BLUE}" "\nDeleting Nginx's default configuration..."
    sudo rm -f "${NGINX_ENABLED_PATH}/default"
  fi

  print_message "${BLUE}" "\nCreating booklibrary..."
  cat <<EOF | sudo tee "${NGINX_BOOKLIBRARY_PATH}" >/dev/null
server {
    listen 80;
    server_name _;
    
    location / {
        proxy_pass http://127.0.0.1:8000;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_redirect off;
    }
    
    location /static/ {
        alias $(pwd)/static/;
        expires 30d;
    }
    
    access_log /var/log/nginx/booklibrary_access.log;
    error_log /var/log/nginx/booklibrary_error.log;
}
EOF

  print_message "${BLUE}" "\nLinking booklibrary Nginx's enabled sites..."
  sudo ln -sf "${NGINX_BOOKLIBRARY_PATH}" "${NGINX_ENABLED_PATH}"
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

  if pgrep -f "gunicorn.*library_site*" >/dev/null; then
    print_message "${GREEN}" "\n✓ Gunicorn is running!"
  else
    print_message "${RED}" "\n✗ Gunicorn is not running!"
  fi

  if sudo netstat -tlnp | grep -q ":8000"; then
    print_message "${GREEN}" "\n✓ Port 8000 is in use!"
  else
    print_message "${RED}" "\n✗ Port 8000 is not in use!"
  fi

  if curl -s "http://127.0.0.1:8000" >/dev/null; then
    print_message "${GREEN}" "\n✓ Gunicorn is responding correctly!"
  else
    print_message "${RED}" "\n✗ Gunicorn is not responding!"
  fi
}

main() {
  echo ""
  print_message "${PURPLE}" "Deployment on ${DATE}"
  print_message "${YELLOW}" "\n=== Starting the Book Library deployment ==="
  install_dependencies
  cloning_app
  configure_environment
  configure_gunicorn
  configure_ginx
  check_services

  print_message "${YELLOW}" "\n=== Deployment completed ==="
  print_message "${YELLOW}" "\nLook '${LOG_FILE}' for details."
  print_message "${YELLOW}" "The app should be available in: http://$(hostname -I | awk '{print $1}')\n"
}

main
