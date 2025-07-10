#!/bin/bash

# Reading answer until it's 'yes' or 'no'. Case insensitive
ANSWER=""
while [[ "${ANSWER}" != "yes" && "${ANSWER}" != "no" ]]; do
  read -r -p "Are you thirsty? (yes/no): " ANSWER
  ANSWER=$(echo "${ANSWER}" | tr '[:upper:]' '[:lower:]')
done

# Response according the given answer
if [[ "${ANSWER}" == "yes" ]]; then
  echo "Go get a coffee ☕"
else
  echo "We keep on DevOps 🚀"
fi

