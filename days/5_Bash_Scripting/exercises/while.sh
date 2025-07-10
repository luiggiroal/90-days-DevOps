#!/bin/bash

set -e

count=1
while [[ count -le 3 ]]; do
  echo "Count: ${count}"
  ((count++)) # || true
done
