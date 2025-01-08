#!/bin/bash

# Color definitions
UNDERLINE='\e[4m'
COLOR_BLACK_BOLD='\e[1;30m'
COLOR_RED='\033[0;31m'
COLOR_RED_BACKGROUND='\e[41m'
COLOR_GREEN='\033[0;32m'
COLOR_GREEN_BOLD='\033[4;32m'
COLOR_GREEN_BACKGROUND='\e[42m'
COLOR_YELLOW='\033[0;33m'
COLOR_YELLOW_HIGH_INTENCITY_BACKGROUND='\e[0;103m'
COLOR_BLUE='\033[1;34m'
COLOR_BLUE_BACKGROUND='\e[44m'
COLOR_PURPLE='\033[0;35m'
COLOR_PURPLE_BACKGROUND='\e[45m'
COLOR_LIGHT_GREEN='\033[0;36m'
COLOR_LIGHT_GREEN_BACKGROUND='\e[46m'
COLOR_WHITE_BOLD='\033[1;37m'
COLOR_RESET='\033[0m'

CONF_DIR="$(dirname "$0")/options.conf"


# Function to colorize text
colorize() {
    local color="$1"
    local text="$2"
    echo -e "${color}${text}${COLOR_RESET}"
}

result_colorize(){
    local background_color="$1"
    local text="$2"
    echo -e "${background_color}${COLOR_BLACK_BOLD}${UNDERLINE}${text}${COLOR_RESET}"
}

process_colorize(){
    local background_color="$1"
    local text="$2"
    echo -e "${background_color}${COLOR_BLACK_BOLD}${text}${COLOR_RESET}"
}

# Function to strip colors from text
strip_colors() {
    sed -r "s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[mGK]//g"
}

# Function to set up logging
setup_logging() {
    local log_dir="$1"
    local log_file

    mkdir -p "$log_dir"

    if [ -s "$log_dir/logs.log" ]; then
        local timestamp=$(date +"%Y-%m-%d_%H-%M-%S")
        log_file="$log_dir/logs_$timestamp.log"
    else
        log_file="$log_dir/logs.log"
    fi

    # exec > >(tee >(strip_colors >>"$log_file")) 2>&1

    echo -e "$(colorize $COLOR_BLUE "Created at: $(date +"%Y-%m-%d_%H-%M-%S")")"
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