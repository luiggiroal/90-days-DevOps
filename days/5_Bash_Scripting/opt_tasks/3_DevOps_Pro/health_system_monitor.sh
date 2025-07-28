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
DATE=$(date "+%d-%m-%Y__%H-%M")
LOG_FILE="health_sys_${DATE}.log"
SECS_1HOUR=3600
END=$(($SECONDS+$SECS_1HOUR))
COUNT=0
PREV_SEC=0
THRESHOLD=85
# THRESHOLD=15

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
  CPU_NUMBER=$(echo "${CPU}" | sed 's/%//g')
  # MEMORY_NUMBER=$(echo "${MEMORY}" | sed 's/%//g')
  
  print_message $BLUE "${TIME}\t${MEMORY}${DISK}${CPU}"

  # if [[ "${MEMORY_NUMBER}" -gt "${THRESHOLD}" ]]; then
  if [[ "${CPU_NUMBER}" -gt "${THRESHOLD}" ]]; then
    TEMP=$((SECONDS-PREV_SEC))
    if [[ ${TEMP} -eq 1 ]]; then
      ((COUNT++))
    fi
    PREV_SEC=${SECONDS}
  else
    COUNT=0
  fi

  if [[ "${COUNT}" -ge 2 ]]; then
    print_message $YELLOW "\nThe CPU use has exceeded 85% for three consecutive seconds.\nFinishing monitor process..."
    # print_message $YELLOW "\nGoodbye!"
    break
  fi

  sleep 1

  # 85 - 0 - 0 
  # 85 - 1 - 1 
  # 75 - 2 - 0
  # 66 - 3 - 0
  # 90 - 4 - 0
  # 90 - 5 - 1
  # 90 - 6 - 2
done

