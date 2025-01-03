#!/bin/bash

set -e
set -u
set -o pipefail

BASE_DIR="$(pwd)"
LOG_DIR="$BASE_DIR/logs"
mkdir -p "$LOG_DIR"

if [ -s "$LOG_DIR/logs.log" ]; then
    TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
    LOG_FILE="$LOG_DIR/logs_$TIMESTAMP.log"
else
    echo "Initial Log" >&2
    LOG_FILE="$LOG_DIR/logs.log"
fi

# Redirect both stdout and stderr to the log file
touch "$LOG_FILE"

exec > "$LOG_FILE" 2>&1

echo "Created at: $(date +"%Y-%m-%d_%H-%M-%S")"

install_package(){
    local package="$1"
    echo "Installing $package..."
    if ! sudo apt-get install -y "$package"; then
        echo "Failed to install $package"
        exit 1
    fi
    echo "$package installed"
}

echo "Updating system..."
sudo apt-get update && sudo apt-get update -y

install_package "git"