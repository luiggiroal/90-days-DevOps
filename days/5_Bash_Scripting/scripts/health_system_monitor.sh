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
LOG_FILE="health_system.log"
SECS_1HOUR=3600
END=$(($SECONDS+$SECS_1HOUR))

# Saving the report output to 'health_system.log'
print_message $GREEN "Saving the report output to '${LOG_FILE}'..."
exec &> >(tee -a "${LOG_FILE}")

# Printing the report header
print_message $YELLOW "\nTime\t\t\tMemory\t\tDisk(root)\tCPU"

# Printing report every second 
while [[ ${SECONDS} -lt ${END} ]]; do
  TIME=$(date "+%d-%m-%Y %H:%M:%S")
  MEMORY=$(free -m | awk 'NR==2{printf "%.f%%\t\t", $3*100/$2}')
  DISK=$(df -h | awk '$NF=="/"{printf "%s\t\t", $5}')
  CPU=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{printf "%.f%%\n", 100-$1}')
  print_message $BLUE "${TIME}\t${MEMORY}${DISK}${CPU}"
  sleep 1
done

