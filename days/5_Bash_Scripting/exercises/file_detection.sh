#!/bin/bash

FILE=""
LIST_FILES=$(ls -h)

ask () {
  read -r -p "* Enter a file from the list: " FILE
}

echo -e "* List of files:\n\n${LIST_FILES}\n"

ask

while [[ ! -f "${FILE}" ]]; do
  echo -e "\nFile NOT found."
  ask
done

echo -e "\nFile found: ${FILE}"
