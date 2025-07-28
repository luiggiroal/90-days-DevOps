#!/bin/bash

USER=$1
source ./functions.sh

if [[ $# -ne 1 ]]; then
  echo -e "Please, enter a username as an argument.\nUse -> '$0 <username>'"
  exit 1
fi

create_user "${USER}"
