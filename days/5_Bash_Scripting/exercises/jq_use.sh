#!/bin/bash

json='{"name": "Peter", "age": 38}'

# '-r' flag removes quotes and prints the result as raw, plaint text.
name=$(echo "${json}" | jq -r ".name") 
age=$(echo "${json}" | jq -r ".age")

echo -e "Name: ${name}\nAge: ${age}"
# [ OUTPUT ] ->
# Name: Peter
# Age: 38
