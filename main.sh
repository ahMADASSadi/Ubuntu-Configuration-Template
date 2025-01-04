#!/bin/zsh

set -e
set -u
set -o pipefail

# Define directories and log files
BASE_DIR="$(pwd)"
LOG_DIR="$BASE_DIR/logs"
mkdir -p "$LOG_DIR"

if [ -s "$LOG_DIR/logs.log" ]; then
    TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
    LOG_FILE="$LOG_DIR/logs_$TIMESTAMP.log"
else
    LOG_FILE="$LOG_DIR/logs.log"
fi

# Create the log file and redirect all outputs to it
touch "$LOG_FILE"

exec > >(tee -a "$LOG_FILE")
exec 2>&1

# Function to log and display messages
log_and_show() {
    local message="$1"
    echo "$message" 
}

log_and_show "Script started at: $(date +'%Y-%m-%d_%H-%M-%S')"

install_package() {
    local package="$1"
    log_and_show "Installing $package..."
    if ! sudo apt-get install -y "$package"; then
        log_and_show "Failed to install $package"
        exit 1
    fi
    log_and_show "$package installed successfully."
}

log_and_show "Updating system..."
# sudo apt-get update && sudo apt-get upgrade -y

# Prompt for packages
log_and_show "Enter the packages you want to install (separated by spaces):"
read -r packages < /dev/tty

# Install the packages
for package in $packages; do
    log_and_show "Processing package: $package"
    install_package "$package"
done

# Check if Git is installed
if command -v git >/dev/null 2>&1; then
    log_and_show "Git is already installed."
    log_and_show "Do you want to configure Git? (yes/no)"
    read -r configure_git < /dev/tty

    if [[ "$configure_git" == "yes" ]]; then
        log_and_show "Enter your Git user name:"
        read -r git_user_name < /dev/tty
        log_and_show "Enter your Git user email:"
        read -r git_user_email < /dev/tty

        git config --global user.name "$git_user_name"
        git config --global user.email "$git_user_email"

        log_and_show "Git has been configured with:"
        log_and_show "User Name: $git_user_name"
        log_and_show "User Email: $git_user_email"
    else
        log_and_show "Git configuration skipped."
    fi
else
    log_and_show "Git is not installed. Would you like to install it? (yes/no)"
    read -r install_git < /dev/tty
    if [[ "$install_git" == "yes" ]]; then
        install_package "git"
        log_and_show "Git has been installed. You can run the script again to configure Git."
    else
        log_and_show "Skipping Git installation."
    fi
fi

log_and_show "Script completed successfully."
