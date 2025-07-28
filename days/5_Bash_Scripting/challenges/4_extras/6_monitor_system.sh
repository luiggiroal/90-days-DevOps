#!/bin/bash

# Colors
BLUE="\033[0;34m"
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

# Global variables
LOG_FILE="logs_monitor.log"
SECS_1HOUR=3600
END=$(($SECONDS + $SECS_1HOUR))

exec > >(tee -a "${LOG_FILE}") 2>&1 # Saving the output in $LOG_FILE

printing_msg "${YELLOW}" "\nTIME\t\t\tCPU\tMemory\tDisk"

while [[ "${SECONDS}" -lt "${END}" ]]; do
  time=$(date "+%d-%m-%Y %H:%M:%S")
  cpu=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{printf "%.f%%\n", 100-$1}')
  memory=$(free -m | awk 'NR==2{printf "%.f%%", $3*100/$2}')
  disk=$(df -h | awk '$NF=="/"{printf "%s", $5}')

  printing_msg "${BLUE}" "${time}\t${cpu}\t${memory}\t${disk}"
  sleep 5
done
