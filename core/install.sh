#!/bin/bash

set -e
set -u
set -o pipefail


source "$(dirname "$0")/utils.sh"

LOG_DIR="$(pwd)/logs/installation"
setup_logging "$LOG_DIR"

install_package() {
    local package="$1"
    local manager="$2"

    if [[ "$manager" == "apt" ]]; then
        echo -e "$(colorize $COLOR_LIGHT_GREEN " - Installing $package...")"
        if ! sudo apt-get install -y "$package"; then
            echo -e "$(colorize $COLOR_RED "Failed to install $package")"
            exit 1
        fi
    elif [[ "$manager" == "snap" ]]; then
        echo -e "$(colorize $COLOR_LIGHT_GREEN " - Installing $package...")"
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



echo -e "$(colorize $COLOR_BLUE "Updating system...")"
# sudo apt-get update && sudo apt-get upgrade -y


for package_manager in "apt" "snap"; do
    case $package_manager in
        apt)
            packages=("${APT_APPS[@]}")
            color=$COLOR_PURPLE
            ;;
        snap)
            packages=("${SNAP_APPS[@]}")
            color=$COLOR_PURPLE
            ;;
    esac

    echo -e "$(colorize $COLOR_BLUE "Installing $package_manager packages:")"
    for package in "${packages[@]}"; do
        echo -e "$(colorize $color "Installing $package")"
        install_package "$package" "$package_manager"
        
        # Only run git_config for apt packages (assuming git is installed via apt)
        if [[ "$package_manager" == "apt" && "$package" == "git" ]]; then
            git_config "$package"
        fi
    done
done


echo -e "$(colorize $COLOR_GREEN_BACKGROUND "\nInstallation completed successfully!")"