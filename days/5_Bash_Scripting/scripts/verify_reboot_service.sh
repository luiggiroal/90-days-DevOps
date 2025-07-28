#!/bin/bash

# Colors
YELLOW="\033[1;33m"
GREEN="\033[0;32m"
RED="\033[0;31m"
NC="\033[0m" # No color

# Print message function
print_message () {
  local color=$1
  local msg=$2
  echo -e "${color}${msg}${NC}"
}

# Variables
SERVICE=$1
USER=$2
ANS=""

# Asking for the recipient's name
while [[ -z "${USER}" ]]; do
  read -r -p "Enter the recipient's username: " USER
done

# Checking whether USER already exists.
if ! id "${USER}" &>/dev/null; then
  print_message $RED "${USER} user does not exist."
  while [[ "${ANS}" != "y" && "${ANS}" != "n" ]]; do
    read -r -p "Do you want to create ${USER} user? [y/n]: " ANS
    ANS=$(echo "${ANS}" | tr '[:upper:]' '[:lower:]') # Transforming from uppercase to lowercase
  done
  if [[ "${ANS}" == "y" ]]; then
    sudo adduser "${USER}"
    print_message $GREEN "${USER} user created!"
  else
    print_message $RED "User creation cancelled!"
    exit 1
  fi
else
  print_message $GREEN "${USER} user already exists!"
fi

while [[ -z "${SERVICE}" ]]; do
  read -r -p "Enter the service name: " SERVICE
done

# Checking whether SERVICE exists.
while ! systemctl list-unit-files | grep -q "^${SERVICE}.service"; do
  print_message $RED "${SERVICE} service does not exist.\nPlease enter a valid service."
  read -r -p "Enter the service name: " SERVICE
done

# Checking whether SERVICE is active.
if ! systemctl is-active --quiet "${SERVICE}" ; then
  print_message $RED "${SERVICE} service inactive!"
  print_message $YELLOW "Starting ${SERVICE} service..."
  sudo systemctl start "${SERVICE}" 
  print_message $GREEN "The ${SERVICE} service was rebooted.\nSending email to ${USER}"
  echo "The ${SERVICE} service was rebooted." | mail -s "${SERVICE} rebooted" "${USER}"
else
  print_message $GREEN "${SERVICE} service is already active!"
fi
