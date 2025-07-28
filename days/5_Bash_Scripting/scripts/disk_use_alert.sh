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
# USER=""
USER=$1
ANS=""
MAX_ROOT_THRESHOLD=5 # Maximum threshold for the percentage of space disk used by ROOT
MAX_HOME_THRESHOLD=0 # Maximum threshold for the size of HOME in gigabytes

# Asking for the recipient's name
while [[ -z "${USER}" ]]; do
  read -r -p "Enter the recipient's username: " USER
done

# Checking whether USER already exists. If so, a confirmation
# of creation is asked.
print_message $YELLOW "Checking whether USER already exists..."
if ! id "${USER}" &>/dev/null; then
  print_message $RED "${USER} does not exist." 
  while [[ "${ANS}" != "y" && "${ANS}" != "n" ]]; do
    read -r -p "Do you want to create ${USER}? [y/n]: " ANS
    ANS=$(echo "${ANS}" | tr '[:upper:]' '[:lower:]') # Tranforming answer from uppercase to lowercase
  done
  if [[ "${ANS}" == "y" ]]; then
    sudo adduser "${USER}" # Adding user
    print_message $GREEN "${USER} created!" 
  else
    print_message $RED "User creation cancelled!"
    exit 1
  fi
else
  print_message $GREEN "${USER} already exists!"
fi

# Getting the percentage of space disk used by the ROOT (/)
print_message $YELLOW "Getting the percentage of space disk used by the ROOT (/)..."
PERCTG_DISK_USE_ROOT=$(df -hT / | grep / | awk '{print $6}' | sed 's/%//g')
# echo "${PERCTG_DISK_USE_ROOT}"

# Getting the size of HOME directory (/home) in gigabytes
print_message $YELLOW "Getting the size of HOME directory (/home) in gigabytes..."
SIZE_HOME=$(sudo du -s /home/ | awk '{printf "%.2f\n", $1/1024/1024}')
# echo "${SIZE_HOME}"

if [[ "${PERCTG_DISK_USE_ROOT}" -ge ${MAX_ROOT_THRESHOLD} ]]; then
  print_message $RED "[ALERT]: Partition / at ${PERCTG_DISK_USE_ROOT}%\nSending email to ${USER}..."
  echo "[ALERT]: Partition / at ${PERCTG_DISK_USE_ROOT}%" | mail -s "Alert Partition /" "${USER}"
fi

if [[ $(echo "${SIZE_HOME} > ${MAX_HOME_THRESHOLD}" | bc -l) -eq 1 ]]; then
  print_message $RED "[ALERT]: /home size is ${SIZE_HOME}GB\nSending email to ${USER}..."
  echo "[ALERT]: /home size is ${SIZE_HOME}GB!" | mail -s "Alert /home size" "${USER}"
fi
