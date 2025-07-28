#!/bin/bash

# Colors
YELLOW="\033[1;33m"
GREEN="\033[0;32m"
RED="\033[0;31m"
NC="\033[0m"

# Printing message function
printing_msg() {
  local color=$1
  local msg=$2

  echo -e "${color}${msg}${NC}"
}

while [[ -z "${web_site}" ]]; do
  read -r -p "Enter the web site URL: " web_site
done

printing_msg "${YELLOW}" "\nChecking whether ${web_site} is active..."
curl -s "${web_site}" >/dev/null || {
  printing_msg "${RED}" "\nThe '${web_site}' site is not active!"
  printing_msg "${YELLOW}" "\nTry with another web site. Closing program. Bye!"
  exit 1
}
printing_msg "${GREEN}" "\nThe '${web_site}' site is active!"
