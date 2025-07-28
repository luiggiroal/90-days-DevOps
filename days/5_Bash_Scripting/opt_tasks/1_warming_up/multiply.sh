#!/bin/bash

# Variables
NUMBERS=()
QUANTITY=$1
FINAL_MSG=""
TOTAL=1

# Asking for the quantity of numbers to multiply
while [[ ! "${QUANTITY}" =~ ^[0-9]+$ ]]; do # If not a number
  read -r -p "Enter the quantity of numbers to multiply: " QUANTITY
done

for i in $(seq 0 $((QUANTITY - 1))); do
  if [[ ! "${NUMBERS[i]}" =~ ^[0-9]+$ ]]; then 
    read -r -p "Enter the number $((i+1)): " NUMBERS[i]
  fi
  while [[ ! "${NUMBERS[i]}" =~ ^[0-9]+$ ]]; do
    echo -e "\nPlease, enter a valid number."
    read -r -p "Enter the number $((i+1)): " NUMBERS[i]
  done

  ((TOTAL *= NUMBERS[i])) # Collecting total multiplication

  # Appending parts to the final message
  if [[ "${i}" -eq $((QUANTITY - 1)) ]]; then
    FINAL_MSG+="${NUMBERS[i]} = ${TOTAL}"
  else
    FINAL_MSG+="${NUMBERS[i]} * "
  fi
done

echo -e "\n##################################\n"

# Printing the result
echo -e "${FINAL_MSG}"

