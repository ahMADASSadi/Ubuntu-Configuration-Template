#!/bin/zsh

set -e
set -u
set -o pipefail

# Define ANSI color codes
COLOR_RED='\033[0;31m'
COLOR_GREEN='\033[0;32m'
COLOR_YELLOW='\033[0;33m'
COLOR_BLUE='\033[0;34m'
COLOR_RESET='\033[0m'

# Function to colorize text
colorize() {
    local color="$1"
    local text="$2"
    echo -e "${color}${text}${COLOR_RESET}"
}

# Function to strip ANSI color codes
strip_colors() {
    sed -r "s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[mGK]//g"
}

# Define directories and log files
BASE_DIR="$(pwd)"
LOG_DIR="$BASE_DIR/logs"
CONF_DIR="$BASE_DIR/options.conf"

mkdir -p "$LOG_DIR"

if [ -s "$LOG_DIR/logs.log" ]; then
    TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
    LOG_FILE="$LOG_DIR/logs_$TIMESTAMP.log"
else
    LOG_FILE="$LOG_DIR/logs.log"
fi

# Redirect all output to both the terminal and the log file
# Strip colors for the log file
exec > >(tee >(strip_colors >>"$LOG_FILE")) 2>&1

echo -e "$(colorize $COLOR_BLUE "Created at: $(date +"%Y-%m-%d_%H-%M-%S")")"

install_package() {
    local package="$1"
    local manager="$2"

    if [[ "$manager" == "apt" ]]; then
        echo -e "$(colorize $COLOR_BLUE "Installing $package...")"
        if ! sudo apt-get install -y "$package"; then
            echo -e "$(colorize $COLOR_RED "Failed to install $package")"
            exit 1
        fi
    elif [[ "$manager" == "snap" ]]; then
        echo -e "$(colorize $COLOR_BLUE "Installing $package...")"
        if ! sudo snap install "$package"; then
            echo -e "$(colorize $COLOR_RED "Failed to install $package")"
            exit 1
        fi
    fi
    echo -e "$(colorize $COLOR_GREEN "$package installed")"
}

git_config() {
    local package="$1"
    if [[ "$package" == "git" ]]; then
        if [ -t 0 ]; then
            echo -e "$(colorize $COLOR_YELLOW "Do you want to (re)configure Git? (yes/no)")"
            read -r configure_git </dev/tty
        else
            echo "Not running in an interactive shell. Skipping Git configuration."
            return
        fi

        if [[ "$configure_git" == "yes" ]]; then
            echo -e "$(colorize $COLOR_YELLOW "Enter your Git user name:")"
            read -r git_user_name </dev/tty
            echo -e "$(colorize $COLOR_YELLOW "Enter your Git user email:")"
            read -r git_user_email </dev/tty

            git config --global user.name "$git_user_name"
            git config --global user.email "$git_user_email"

            echo -e "$(colorize $COLOR_GREEN "Git has been configured with:")"
            echo -e "$(colorize $COLOR_GREEN "User Name: $git_user_name")"
            echo -e "$(colorize $COLOR_GREEN "User Email: $git_user_email")"
        else
            echo -e "$(colorize $COLOR_YELLOW "Git configuration skipped.")"
        fi
    fi
}

if [ -f "$CONF_DIR" ]; then
    if ! source "$CONF_DIR"; then
        echo -e "$(colorize $COLOR_RED "Error: Failed to source $CONF_DIR. Check the file for syntax errors.")" >&2
        exit 1
    fi
else
    echo -e "$(colorize $COLOR_RED "Error: $CONF_DIR file not found!")" >&2
    exit 1
fi

echo -e "$(colorize $COLOR_BLUE "Updating system...")"
# sudo apt-get update && sudo apt-get upgrade -y

echo -e "$(colorize $COLOR_BLUE "Installing Official packages:")"
for package in "${apt_apps[@]}"; do
    echo -e "$(colorize $COLOR_BLUE "- Installing $package")"
    install_package "$package" "apt"
    git_config "$package"
done

echo -e "$(colorize $COLOR_BLUE "Installing Snap packages:")"
for package in "${snap_apps[@]}"; do
    echo -e "$(colorize $COLOR_BLUE "- Installing $package")"
    install_package "$package" "snap"
done
