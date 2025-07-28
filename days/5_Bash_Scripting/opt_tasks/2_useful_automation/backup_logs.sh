#!/bin/bash

# Colors
YELLOW="\033[1;33m"
GREEN="\033[0;32m"
RED="\033[0;31m"
NC="\033[0m" # No color

print_message () {
  local color=$1
  local msg=$2

  echo -e "${color}${msg}${NC}"
}

# Variables
PATH_BACKUPS="${HOME}/backups"
PATH_LOG="/var/log"
TIMESTAMP="logs_$(date +%F)" # Setting up the timestamp name

# Create 'backups' folder if doesn't exist
if [[ ! -d "${PATH_BACKUPS}" ]]; then
  print_message $RED "'${PATH_BACKUPS}' folder doesn't exist!"
  print_message $YELLOW "Creating ${PATH_BACKUPS} folder..."
  mkdir -p "${PATH_BACKUPS}"
fi

# Compressing the content of '/var/log' into a '.tar.gz' file
print_message $YELLOW "Compressing content of ${PATH_LOG} into a .tar.gz file..."
sudo tar -czvf "${PATH_BACKUPS}/${TIMESTAMP}.tar.gz" "${PATH_LOG}"

# Deleting backups older than 7 days
if [[ -n $(find "${PATH_BACKUPS}" -type f -mtime +7) ]]; then
  print_message $YELLOW "Displaying backups older than 7 days..."
  find "${PATH_BACKUPS}" -type f -mtime +7 
  print_message $YELLOW "Deleting backups older than 7 days..."
  find "${PATH_BACKUPS}" -type f -mtime +7 -exec rm -f {} \;
else
  print_message $RED "No backups older than 7 days!"
fi

