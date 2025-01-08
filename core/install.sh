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
        echo -e "$(process_colorize $COLOR_LIGHT_GREEN_BACKGROUND " - Installing $package...")"
        if ! sudo apt-get install -y "$package"; then
            echo -e "$(colorize $COLOR_RED "Failed to install $package")"
            exit 1
        fi
    elif [[ "$manager" == "snap" ]]; then
        echo -e "$(process_colorize $COLOR_LIGHT_GREEN_BACKGROUND " - Installing $package...")"
        if ! sudo snap install "$package"; then
            echo -e "$(colorize $COLOR_RED "Failed to install $package")"
            exit 1
        fi
    fi
    echo -e "$(result_colorize $COLOR_GREEN_BACKGROUND "$package installed")"
    echo
}

git_config() {
    local package="$1"
    if [[ "$package" == "git" ]]; then
        if [ -t 0 ]; then
            echo -e "$(colorize $COLOR_YELLOW "Do you want to (re)configure Git? (y/n)")"
            read -r configure_git </dev/tty
        else
            echo "Not running in an interactive shell. Skipping Git configuration."
            return
        fi

        if [[ "$configure_git" == "y" ]]; then
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
            echo -e "$(result_colorize $COLOR_YELLOW_HIGH_INTENCITY_BACKGROUND "Git configuration skipped.")"
            echo
        fi
    fi
}



echo -e "$(process_colorize $COLOR_BLUE_BACKGROUND 'Updating system...')"
sudo apt-get update && sudo apt-get upgrade -y
echo -e "$(result_colorize $COLOR_GREEN_BACKGROUND 'System updated')"
echo


for package_manager in "apt" "snap"; do
    case $package_manager in
        apt)
            packages=("${APT_APPS[@]}")
            color=$COLOR_PURPLE_BACKGROUND
            ;;
        snap)
            packages=("${SNAP_APPS[@]}")
            color=$COLOR_PURPLE_BACKGROUND
            ;;
    esac

    echo -e "$(result_colorize $COLOR_BLUE_BACKGROUND "Installing $package_manager packages:")"
    echo
    for package in "${packages[@]}"; do
        echo -e "$(process_colorize $color "Installing $package")"
        install_package "$package" "$package_manager"
        
        # Only run git_config for apt packages (assuming git is installed via apt)
        if [[ "$package_manager" == "apt" && "$package" == "git" ]]; then
            git_config "$package"
        fi
    done
done

echo -e "$(result_colorize $COLOR_GREEN_BACKGROUND 'Installation completed successfully!')"
