#!/bin/bash

USERNAME=$1
EMAIL=$2

reading_data () {
  local input=$1
  local data_type=$2
  while [[ -z "${input}" ]]; do
    read -r -p "Enter ${data_type}: " input
  done
  echo "${input}"
}

USERNAME=$(reading_data "${USERNAME}" "username")
EMAIL=$(reading_data "${EMAIL}" "email")

TEXT="User: ${USERNAME}, Email: ${EMAIL}"

# '()' in Regex -> Captures part of the match (creates a group)
# '^' inside '[]' in Regex -> Negation of character class
if [[ "${TEXT}" =~ User:\ ([^,]+),\ Email:\ ([^ ]+) ]]; then
  # '$BASH_REMATCH' -> Bash built-in array holding the entire group of matches
  text_match="${BASH_REMATCH[0]}" # Stores the entire match
  user_match="${BASH_REMATCH[1]}" # Stores the first capture group (form left to right)
  email_match="${BASH_REMATCH[2]}" # Stores the second capture group

  echo -e "\n${text_match}"
  echo -e "\n-------------------------\n"
  echo -e "* User: ${user_match}\n* Email: ${email_match}"
fi

