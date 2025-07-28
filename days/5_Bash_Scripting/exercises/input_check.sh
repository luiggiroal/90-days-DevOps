#!/bin/bash

if [[ $# -lt 1 ]]; then # '$#' -> number of arguments passed
  echo "Use: $0 <file>" # '$0' -> name of the script
  exit 1
fi
