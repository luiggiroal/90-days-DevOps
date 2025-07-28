#!/bin/bash

# Variables
NAME=$1
AGE=$2

if [[ -z "${NAME}" ]]; then
  read -r -p "Enter your name: " NAME
fi

while [[ -z "${NAME}" ]]; do
  echo -e "\nEmpty value. Please, enter a valid value."
  read -r -p "Enter your name: " NAME
done

echo -e "\n----------------------------"
echo -e "----------------------------\n"

if [[ ! "${AGE}" =~ ^[0-9]+$ ]]; then
  read -r -p "Enter your age: " AGE
fi

while [[ ! "${AGE}" =~ ^[0-9]+$ ]]; do
  echo -e "\nPlease, enter a valid number."
  read -r -p "Enter your age: " AGE
done

echo "Hello, ${NAME}, you are ${AGE}. Welcome to the Bash World!"
