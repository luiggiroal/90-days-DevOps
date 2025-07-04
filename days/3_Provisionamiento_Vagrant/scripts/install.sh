#!/bin/bash

# Variables
BLUE="\033[0;34m"
YELLOW="\033[0;33m"
GREEN="\033[0;32m"
RED="\033[0;31m"
NO_COLOR="\033[0m"

# Print message function
print_msg() {
  local newline_flag=$1

  if [[ "$newline_flag" == "--nnl" ]]; then # '--nnl' -> no newline
    shift # Remove the first argument (newline flag), now $1 is the first real argument
  fi

  local color=$1
  local msg=$2

  if [[ "$newline_flag" == "--nnl" ]]; then
    echo -e "${color}${msg}${NO_COLOR}"
  else
    echo -e "${color}\n${msg}${NO_COLOR}"
  fi
}

# Checking installation
check_install() {
  local tool=$1
  local installing_command=$2
  local version_command=$3

  print_msg ${YELLOW} "Verifying if $tool is installed..."

  if ! command -v $tool &>/dev/null; then
    print_msg --nnl ${RED} "$tool is not installed!"
    print_msg --nnl ${YELLOW} "Installing $tool..."
    eval "$installing_command"
    local app_version=$(eval $version_command 2>&1)
    print_msg ${YELLOW} "$tool version installed:\n${app_version}"
  else
    local app_version=$(eval $version_command 2>&1)
    print_msg --nnl ${GREEN} "$tool is already installed!"
    print_msg --nnl ${BLUE} "$tool version installed -->\n${app_version}"
  fi
}

# Checking service
check_serv () {
  local tool=$1
  print_msg ${YELLOW} "Verifying if $tool is working..."
  sleep 3

  if systemctl status $tool &>/dev/null; then
    print_msg --nnl ${GREEN} "$tool is active!"
  else
    print_msg --nnl ${RED} "$tool is inactive!"
  fi
}

# ---------------------------------------------------

# Greeting
print_msg ${YELLOW} "HELLO FROM PROVISIONING!"

# Updating System
print_msg ${YELLOW} "Updating System..."
apt update

source /vagrant/scripts/nginx_install.sh
source /vagrant/scripts/docker_install.sh
source /vagrant/scripts/node_install.sh

# Serving bootstrap site
print_msg ${YELLOW} "Serving bootstrap site..."
source /vagrant/scripts/serve_bootstrap.sh
