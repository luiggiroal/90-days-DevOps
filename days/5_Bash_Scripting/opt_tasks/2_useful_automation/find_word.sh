#!/bin/bash

# Colors
BLUE="\033[0;34m"
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
FILE=$1
WORD=$2

for i in {1..2}; do
  while [[ -z "${FILE}" || -z "${WORD}" ]]; do
    if [[ "${i}" -eq 1 ]]; then
      read -r -p "Enter the file name: " FILE
      if [[ -f "${FILE}" ]]; then
        print_message $BLUE "'${FILE}' file exists!"
        break
      fi
      print_message $RED "'${FILE}' file doesn't exist!"
      FILE=""
    else
      read -r -p "Enter the word to find: " WORD
      if grep -q "${WORD}" "${FILE}" 2>&1; then
        print_message $GREEN "'${WORD}' word found in '${FILE}' file"
        exit 0
      fi
      print_message $RED "'${WORD}' word NOT found in '${FILE}' file"
      WORD=""
    fi
  done
done

if grep -q "${WORD}" "${FILE}" 2>&1; then
  print_message $GREEN "'${WORD}' word found in '${FILE}' file"
else
  print_message $RED "'${WORD}' word NOT found in '${FILE}' file"
fi
