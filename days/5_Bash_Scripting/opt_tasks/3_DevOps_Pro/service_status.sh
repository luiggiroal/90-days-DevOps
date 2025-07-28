#!/bin/bash

# Colors
YELLOW="\033[1;33m"
BLUE="\033[1;34m"
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
SERVICE=""
USER="testuser"

while true; do
    while [[ -z "${SERVICE}" ]]; do
      read -r -p "Enter service name ['exit' to quit]: " SERVICE
    done
    if [[ "${SERVICE}" == "exit" ]]; then
      print_message $YELLOW "Goodbye!"
      break
    fi
    if ! systemctl list-unit-files | grep -q "^${SERVICE}.service" 2>&1; then
      print_message $BLUE "'${SERVICE}' service doesn't exist!"
    elif ! systemctl is-active "${SERVICE}" &>/dev/null ; then
      print_message $RED "'${SERVICE}' service isn't active!\nSending email to '${USER}'."
      echo "'${SERVICE}' service isn't active!" | mail -s "'${SERVICE}' service is down!" "${USER}"
    else
      print_message $GREEN "'${SERVICE}' service is active!"
    fi
    SERVICE=""
done

