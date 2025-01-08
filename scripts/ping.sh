#!/bin/bash

source "$(dirname "$0")/utils.sh"

LOG_DIR="$(pwd)/logs/vpn"

setup_logging "$LOG_DIR"
echo $LOG_DIR

echo -e "$(process_colorize $COLOR_BLUE_BACKGROUND "Starting VPN latency tests...")"
echo

if [ -z "$OPENVPN_PATH" ]; then
    echo -e "$(result_colorize $COLOR_RED_BACKGROUND "Error: OPENVPN_PATH is not set in the .conf file!")"
    exit 1

elif [ ! -d "$OPENVPN_PATH" ]; then
    echo -e "$(result_colorize $COLOR_RED_BACKGROUND "Error: Directory $OPENVPN_PATH not found!")"
    exit 1

elif [ -z "$(find "$OPENVPN_PATH" -name '*.ovpn' -print -quit)" ]; then
    echo -e "$(result_colorize $COLOR_RED_BACKGROUND "Error: No .ovpn files found in $OPENVPN_PATH!")"
    exit 1
fi

for CONFIG_FILE in "$OPENVPN_PATH"/*.ovpn; do
    FILE_NAME=$(basename "$CONFIG_FILE")
    echo -e "$(process_colorize $COLOR_BLUE_BACKGROUND "Processing $FILE_NAME...")"

    # Extract the remote server address from the OpenVPN configuration file
    REMOTE_SERVER=$(grep -E '^remote\s+' "$CONFIG_FILE" | awk '{print $2}')

    # Check if the remote server address was found
    if [ -z "$REMOTE_SERVER" ]; then
        echo "  Remote server address not found in $FILE_NAME."
        continue
    fi

    # Ping the remote server
    echo -e "$(process_colorize $COLOR_PURPLE_BACKGROUND "- Pinging $FILE_NAME...")"
    ping -c 3 "$REMOTE_SERVER"

    # Check the exit status of the ping command
    if [ $? -eq 0 ]; then
        echo -e "$(result_colorize $COLOR_LIGHT_GREEN_BACKGROUND "Ping to $FILE_NAME was successful.")"
    else
        echo -e "$(result_colorize $COLOR_RED_BACKGROUND "Ping to $FILE_NAME failed.")"
    fi

    echo 
done

echo -e "$(result_colorize $COLOR_GREEN_BACKGROUND "VPN latency tests completed!")"
