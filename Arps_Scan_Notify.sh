#!/bin/bash
# device_notify.sh

# Purpose:
# Monitor network for specific MAC addresses and send a Pushover notification
# when one of the devices connects or disconnects. Used to correlate device
# presence (and thus people) connecting to the network.

# Configuration
IMAGE="secure-arp-scan"
INTERFACE="eth0"  # Change to wlan0 if using Wi-Fi
declare -A DEVICES=(
  ["AA:BB:CC:DD:EE:FF"]="John's Phone"
  ["11:22:33:44:55:66"]="Lisa's Laptop"
  ["77:88:99:AA:BB:CC"]="Guest Tablet"
)
PUSHOVER_USER="your_pushover_user_key"   # Your Pushover user key
PUSHOVER_TOKEN="your_pushover_app_token"  # Your Pushover app token
STATE_FILE="/tmp/device_state.txt"
SLEEP_INTERVAL=60  # Seconds between scans

# How to Run:
# Make the script executable and start it manually or as a background service
# chmod +x device_notify.sh
# ./device_notify.sh

# Initialize the state file if it doesn't exist
if [ ! -f "$STATE_FILE" ]; then
    touch "$STATE_FILE"
fi

# Load previous states
declare -A PREV_STATES
while IFS= read -r line; do
    MAC=$(echo "$line" | cut -d':' -f1)
    STATUS=$(echo "$line" | cut -d':' -f2)
    PREV_STATES[$MAC]="$STATUS"
done < "$STATE_FILE"

while true; do
    echo "Running ARP scan using image: $IMAGE"
    OUTPUT=$(docker run --rm --net=host --cap-add=NET_RAW --cap-add=NET_ADMIN "$IMAGE" arp-scan --localnet -I "$INTERFACE")

    UPDATED=false
    NEW_STATE=""

    for MAC in "${!DEVICES[@]}"; do
        NAME=${DEVICES[$MAC]}

        # Check if MAC is present in the scan output
        if echo "$OUTPUT" | grep -qiE "\b$MAC\b"; then
            CURRENT_STATUS="connected"
        else
            CURRENT_STATUS="disconnected"
        fi

        PREV_STATUS="${PREV_STATES[$MAC]:-unknown}"

        if [ "$CURRENT_STATUS" != "$PREV_STATUS" ]; then
            if [ "$CURRENT_STATUS" = "connected" ]; then
                MESSAGE="$NAME ($MAC) is now CONNECTED to the network."
            else
                MESSAGE="$NAME ($MAC) has DISCONNECTED from the network."
            fi

            echo "$MESSAGE"

            curl -s \
              --form-string "token=$PUSHOVER_TOKEN" \
              --form-string "user=$PUSHOVER_USER" \
              --form-string "message=$MESSAGE" \
              https://api.pushover.net/1/messages.json

            UPDATED=true
        fi

        NEW_STATE+="$MAC:$CURRENT_STATUS\n"
    done

    if [ "$UPDATED" = true ]; then
        echo -e "$NEW_STATE" > "$STATE_FILE"
    fi

    sleep "$SLEEP_INTERVAL"
done
