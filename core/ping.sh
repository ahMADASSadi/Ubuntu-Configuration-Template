#!/bin/bash

source "$(dirname "$0")/utils.sh"

LOG_DIR="$(pwd)/logs/vpn"
setup_logging "$LOG_DIR"

echo -e "$(colorize $COLOR_BLUE "Starting VPN latency tests...")"

if [ -z "$OPENVPN_PATH" ]; then
    echo -e "$(colorize $COLOR_RED "Error: OPENVPN_PATH is not set in the .conf file!")"
    exit 1
fi

if [ ! -d "$OPENVPN_PATH" ]; then
    echo -e "$(colorize $COLOR_RED "Error: Directory $OPENVPN_PATH not found!")"
    exit 1
fi

if [ -z "$(find "$OPENVPN_PATH" -name '*.ovpn' -print -quit)" ]; then
    echo -e "$(colorize $COLOR_RED "Error: No .ovpn files found in $OPENVPN_PATH!")"
    exit 1
fi

get_remote_server() {
    grep -m 1 "remote " "$1" | awk '{print $2}'
}

test_latency() {
    local server=$(get_remote_server "$1")
    
    if [ -z "$server" ]; then
        echo "ERROR|$1|Could not find remote server in config"
        return
    fi

    if ! ping -c 3 -W 2 "$server" >/dev/null 2>&1; then
        echo "ERROR|$1|Could not ping server (DNS resolution or network issue)"
        return
    fi

    ping_result=$(ping -c 3 -W 1 "$server" 2>/dev/null)
    if [ $? -eq 0 ]; then
        avg_latency=$(echo "$ping_result" | tail -1 | awk -F "/" '{print $5}')
        echo "SUCCESS|$1|$avg_latency"
    else
        echo "ERROR|$1|Ping failed (timeout or other error)"
    fi
}

max_parallel=${1:-1}
current_jobs=0
temp_dir=$(mktemp -d)
trap 'rm -rf "$temp_dir"' EXIT

echo "Testing VPN configs in $OPENVPN_PATH..."
echo "----------------------------------------"

# Use process substitution to avoid subshell issues
while read -r config; do
    if [ "$current_jobs" -ge "$max_parallel" ]; then
        wait -n
        current_jobs=$((current_jobs - 1))
    fi
    test_latency "$config" > "$temp_dir/$(basename "$config").result" &
    current_jobs=$((current_jobs + 1))
done < <(find "$OPENVPN_PATH" -name "*.ovpn" | head -n 1)

wait

echo -e "\nResults (sorted by latency):"
echo "----------------------------------------"

while IFS='|' read -r type conf lat; do
    echo "Config: $(basename "$conf")"
    echo "Latency: ${lat}ms"
    echo "----------------------------------------"
done < <(find "$temp_dir" -name "*.result" -exec cat {} \; | grep "^SUCCESS" | sort -t'|' -k3 -n)

while IFS='|' read -r type conf err; do
    echo "Config: $(basename "$conf")"
    echo "Error: $err"
    echo "----------------------------------------"
done < <(find "$temp_dir" -name "*.result" -exec cat {} \; | grep "^ERROR")

success_count=$(find "$temp_dir" -name "*.result" -exec cat {} \; | grep -c "^SUCCESS")
error_count=$(find "$temp_dir" -name "*.result" -exec cat {} \; | grep -c "^ERROR")

echo -e "\nSummary:"
echo -e "$(colorize $COLOR_GREEN "Successful tests: $success_count")"
echo -e "$(colorize $COLOR_RED "Failed tests: $error_count")"

echo -e "$(colorize $COLOR_GREEN "VPN latency tests completed!")" | tee -a "$LOG_FILE"