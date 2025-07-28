#!/bin/bash

# Associative arrays ~ Key-value pairs

declare -A colors # Defining an associative array

# Setting key-value pairs in the associative array
colors[red]="#FF0000"
colors[green]="#00FF00"

# '${!colors[@]}' -> All the keys
# '${colors[@]}' -> All the values
for key in "${!colors[@]}"; do
  echo "${key}: ${colors[${key}]}"
done

