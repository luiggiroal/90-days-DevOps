#!/bin/bash

cat << EOF
* User: $(whoami)

* Current working directory: $(pwd)

* Current date:
  (EN) $(date +"%A, %B %d, %Y")
  (ES) $(LC_TIME=es_ES.UTF-8 date +"%A, %d de %B del %Y")
EOF
