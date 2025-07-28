#!/bin/bash

# set -e

file="data.txt"

# Clearing the file before appending content
> "${file}"

# Filling data into 'data.txt'
for i in $(seq 0 10); do
  cat << EOF | tee -a "${file}" > /dev/null 
Row ${i}
EOF
# FYI: The closing EOF shouldn't be indented
done

if [[ -f "${file}" ]]; then
  echo "Reading ${file}..."
  cat "${file}"
else
  echo "Error: The file doesn't exist"
  exit 1
fi
