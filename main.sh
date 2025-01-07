#!/bin/zsh

set -e
set -u
set -o pipefail

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

exec > >(tee -a "$LOG_FILE") 2>&1

echo "Created at: $(date +"%Y-%m-%d_%H-%M-%S")"

install_package() {
    local package="$1"
    local manager="$2"

    if [[ "$manager" == "apt" ]]; then
        echo "Installing $package..."
        if ! sudo apt-get install -y "$package"; then
            echo "Failed to install $package"
            exit 1
        fi
    elif [[ "$manager" == "snap" ]]; then
        echo "Installing $package..."
        if ! sudo snap install "$package"; then
            echo "Failed to install $package"
            exit 1
        fi
    fi
    echo "$package installed"
}

git_config() {
    local package="$1"
    if [[ "$package" == "git" ]]; then
        if [ -t 0 ]; then
            echo "Do you want to (re)configure Git? (yes/no)"
            read -r configure_git </dev/tty
        else
            echo "Not running in an interactive shell. Skipping Git configuration."
            return
        fi
        read -r configure_git </dev/tty

        if [[ "$configure_git" == "yes" ]]; then
            echo "Enter your Git user name:"
            read -r git_user_name </dev/tty
            echo "Enter your Git user email:"
            read -r git_user_email </dev/tty

            git config --global user.name "$git_user_name"
            git config --global user.email "$git_user_email"

            echo "Git has been configured with:"
            echo "User Name: $git_user_name"
            echo "User Email: $git_user_email"
        else
            echo "Git configuration skipped."
        fi
    fi
}

if [ -f "$CONF_DIR" ]; then
    if ! source "$CONF_DIR"; then
        echo "Error: Failed to source $CONF_DIR. Check the file for syntax errors." >&2
        exit 1
    fi
else
    echo "Error: $CONF_DIR file not found!" >&2
    exit 1
fi

echo "Updating system..."
# sudo apt-get update && sudo apt-get upgrade -y

echo "Installing Official packages:"
for package in "${apt_apps[@]}"; do
    echo "- Installing $package"
    install_package "$package" "apt"
    git_config "$package"
done

echo "Installing Snap packages:"
for package in "${snap_apps[@]}"; do
    echo "- Installing $package"
    install_package "$package" "snap"
done

