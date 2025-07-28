#!/bin/bash

# Objective -> Create a repo with both remote and local linked.
# Parameters -> [ Name of the Repo ] [ Description of the Repo ]

# Colors
YELLOW="\033[1;33m"
GREEN="\033[0;32m"
RED="\033[0;31m"
NC="\033[0m" # No color

# Print message function
print_message () {
  local color=$1
  local msg=$2
  echo -e "${color}${msg}${NC}"
}

# Variables
REPO_NAME=$1
REPO_DESC=$2

# Make sure there is a repo name provided
while [[ -z "${REPO_NAME}" ]]; do
  echo -e "A repository name MUST be provided."
  read -r -p "Please, enter a repo name: " REPO_NAME
done

# Creating a log file that saves all output
print_message $YELLOW "Creating a log file that saves all output..."
mkdir -p "${REPO_NAME}"
cd "${REPO_NAME}"
LOG_FILE="output.log"
exec > >(tee -a "${LOG_FILE}") 2>&1

# Ask for an optional repo description
if [[ -z "${REPO_DESC}" ]]; then
  read -r -p "Enter a repository description (optional): " REPO_DESC
fi

# # Create remote GH repo 
# print_message $YELLOW "Creating Github repository..."
# gh repo create --public "${REPO_NAME}" --description "${REPO_DESC}"

Setting the URL mode
URL_MODE=""
while [[ "${URL_MODE}" != "https" && "${URL_MODE}" != "ssh" ]]; do
  read -r -p "Enter the URL mode (ssh / https): " URL_MODE
  # Transform every uppercase letter to its lowercase version
  URL_MODE=$(echo "${URL_MODE}" | tr '[:upper:]' '[:lower:]')
done

# Get HTTPS url of the GH repo 
print_message $YELLOW "Getting the HTTPS url of the Github repository..."
HTTPS_URL=$(gh repo view "${REPO_NAME}" --json url -q .url)

# Init a local repo
print_message $YELLOW "Initializing the local repository..."
git init 

# Changing the current branch to 'main'
print_message $YELLOW "Changing the current branch to 'main'..."
git branch -M main

# Adding log file to '.gitignore' 
print_message $YELLOW "Adding ${LOG_FILE} to '.gitignore'"
echo "${LOG_FILE}" >> .gitignore

# Create a README.md with the repo name as a title
print_message $YELLOW "Creating README.md with '${REPO_NAME}' as a title..."
echo "# ${REPO_NAME}" > README.md

# Add and commit README.md
print_message $YELLOW "Adding and committing README.md..."
git add -A
git commit -m "Added README.md"

# Adding URL as origin of the local repo
print_message $YELLOW "Adding the ${URL_MODE} url as origin of the local repo..."
if [[ ${URL_MODE} == "https" ]]; then
  git remote add origin "${HTTPS_URL}"
else
  SSH_URL=$(gh repo view "${REPO_NAME}" --json sshUrl -q .sshUrl)
  git remote add origin "${SSH_URL}"
fi

# Push the commit to the remote repo
print_message $YELLOW "Pushing the commit to the remote repository..."
git push origin main

# Display a msg with basic info about the created repo
print_message $YELLOW "\n--------------------------------------\n"
print_message $GREEN "📦 Repo created: ${REPO_NAME}" 
print_message $YELLOW "🔗 HTTP URL: ${HTTPS_URL}" 
if [[ -n "${SSH_URL}" ]]; then # '-n' behaves the same as '! -z'
  print_message $YELLOW "🔐 SSH URL: ${SSH_URL}" 
fi
