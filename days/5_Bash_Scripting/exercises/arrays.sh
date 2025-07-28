#!/bin/bash

files=("doc1.txt" "doc2.txt" "brief.pdf")

for file in "${files[@]}"; do
  echo "Processing ${file}..."
done
# [ OUTPUT ] ->
# Processing doc1.txt...
# Processing doc2.txt...
# Processing brief.pdf...

echo -e "\n#############################\n"

for file in "${files[*]}"; do
  echo "${file}"
done
# [ OUTPUT ] ->
# doc1.txt doc2.txt brief.pdf
