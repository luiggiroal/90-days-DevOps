#!/bin/bash

# Variables
NUMBER=$1

# Asking for the number which a multiplication table will be displayed
while [[ ! "${NUMBER}" =~ ^[0-9]+$ ]]; do # If not a number
  read -r -p "Enter a number to show its multiplication table: " NUMBER
done

echo -e "\n##########################\n"

for i in $(seq 0 9); do
  ROW_RESULT=$((i * NUMBER))
  echo -e "${NUMBER} x ${i} = ${ROW_RESULT}"
done


