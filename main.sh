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

touch "$LOG_FILE"

exec > >(tee -a "$LOG_FILE") 2>&1

echo "Created at: $(date +"%Y-%m-%d_%H-%M-%S")"

install_package() {
    local package="$1"
    echo "Installing $package..."
    if ! sudo apt-get install -y "$package"; then
        echo "Failed to install $package"
        exit 1
    fi
    echo "$package installed"
}

# Check if Git is installed
# if command -v git >/dev/null 2>&1; then
#     log_and_show "Git is already installed."
#     log_and_show "Do you want to configure Git? (yes/no)"
#     read -r configure_git </dev/tty

#     if [[ "$configure_git" == "yes" ]]; then
#         log_and_show "Enter your Git user name:"
#         read -r git_user_name </dev/tty
#         log_and_show "Enter your Git user email:"
#         read -r git_user_email </dev/tty

#         git config --global user.name "$git_user_name"
#         git config --global user.email "$git_user_email"

#         log_and_show "Git has been configured with:"
#         log_and_show "User Name: $git_user_name"
#         log_and_show "User Email: $git_user_email"
#     else
#         log_and_show "Git configuration skipped."
#     fi
# else
#     log_and_show "Git is not installed. Would you like to install it? (yes/no)"
#     read -r install_git </dev/tty
#     if [[ "$install_git" == "yes" ]]; then
#         log_and_show "Git has been installed. You can run the script again to configure Git."
#     else
#         log_and_show "Skipping Git installation."
#     fi
# fi

if [ -f "$CONF_DIR" ]; then
    source "$CONF_DIR"
else
    echo "packages.conf file not found!" >&2
    exit 1
fi

echo "Updating system..."
# sudo apt-get update && sudo apt-get upgrade -y

echo "Installing desired packages:"
for package in "${packages[@]}"; do
    echo "- Installing $package"
    install_package "$package"

    # Check if the current package is "git"
    if [[ "$package" == "git" ]]; then
        echo "Do you want to (re)configure Git? (yes/no)"
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
done
