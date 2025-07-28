#!/bin/bash

ANS=""
FILE="users.log"
DATE=$(date "+%d-%m-%Y at %H:%M:%S")

create_user() {
  local USER=$1
  if ! id "${USER}" &>/dev/null; then
    echo "'${USER}' user doesn't exist!"
    while [[ "${ANS}" != "y" && "${ANS}" != "n" ]]; do
      read -r -p "Would you like to create '${USER}' user [y/n]? " ANS
      ANS=$(echo "${ANS}" | tr '[:upper:]' '[:lower:]')
    done
    if [[ "${ANS}" == "y" ]]; then
      sudo adduser "${USER}"
      cat <<EOF >>"${FILE}"
* '${USER}' user created on ${DATE}.
EOF
      echo -e "'${USER}' user created!"
    else
      echo "User creation process cancelled!"
    fi
  else
    echo "'${USER}' user already exists!"
  fi
}
