#!/bin/bash
set -e

# Set the country code (e.g. "au" for Australia)
COUNTRY_CODE="au"

# Set the product ID (e.g. "B07JYZFCDN" for the Echo Dot with price target of 80, B07965Y43Q is for cardio scale at price target of 170)
# Define the products to monitor and their target prices
declare -A PRODUCTS=(
  ["B07JYZFCDN"]=80 
  ["B07965Y43Q"]=170 
)


# Define the send_pushover_notification function
send_pushover_notification() {
  USER_KEY="YOUR_PUSHOVER_USER_KEY"
  APP_TOKEN="YOUR_PUSHOVER_APP_TOKEN"
  TITLE="$1"
  MESSAGE="$2"
  curl -s --form-string "token=$APP_TOKEN" --form-string "user=$USER_KEY" --form-string "title=$TITLE" --form-string "message=$MESSAGE" https://api.pushover.net/1/messages.json > /dev/null
}

# Set the log file path
SCRIPT_DIRECTORY="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="$SCRIPT_DIRECTORY/$(basename "$0" .sh).log"

# Log the start time to the log file
echo "Script started at $(date)" >> "$LOG_FILE"

for PRODUCT_ID in "${!PRODUCTS[@]}"; do
    # Set the URL of the product to monitor
    URL="https://${COUNTRY_CODE}.camelcamelcamel.com/product/${PRODUCT_ID}"

    # Set the target price for the current product
    TARGET_PRICE="${PRODUCTS[$PRODUCT_ID]}"
    
    # Get the HTML data from CamelCamelCamel
    HTML_DATA=$(curl -s "$URL")

    if [ -z "$HTML_DATA" ]; then
        # Send a Pushover notification if there was an error retrieving the HTML data
        send_pushover_notification "Error retrieving HTML data" "There was an error retrieving the HTML data from CamelCamelCamel."
        echo "[ERROR] retrieving HTML data from CamelCamelCamel" >> "$LOG_FILE"
        exit 1
    fi

    PRODUCT_NAME=$(echo "$HTML_DATA" | grep -m 1 -oP '<meta property="og:title" content="\K[^"]+')

    if [ -z "$PRODUCT_NAME" ]; then
        # Send a Pushover notification if there was an error parsing the product name
        send_pushover_notification "Error parsing product name" "There was an error parsing the product name from the HTML data."
        echo "[ERROR] Error parsing product name from HTML data" >> "$LOG_FILE"
        exit 1
    fi

    # Parse the current price from the HTML data
    CURRENT_PRICE=$(echo "$HTML_DATA" | grep -A 1 'Current' | tail -n 1 | sed -e 's/<[^>]*>//g' | tr -d '$,')


    if [ -z "$CURRENT_PRICE" ]; then
        # Send a Pushover notification if there was an error parsing the current price
        send_pushover_notification "Error parsing current price" "There was an error parsing the current price from the HTML data."
        echo "[ERROR] Parsing current price from HTML data" >> "$LOG_FILE"
        exit 1
    fi



    # Compare the current price with the target price
    if (( $(echo "$CURRENT_PRICE < $TARGET_PRICE" | bc -l) )); then
     # Send a Pushover notification
        send_pushover_notification "[PRICE DROP] - $PRODUCT_NAME" "Current Price: $CURRENT_PRICE vs Target Price: $TARGET_PRICE"
        echo "[PRICE DROP] - $PRODUCT_NAME - Current Price: $CURRENT_PRICE vs Target Price: $TARGET_PRICE" >> "$LOG_FILE"
    else
        echo "[NO DROP] - $PRODUCT_NAME - Current Price: $CURRENT_PRICE vs Target Price: $TARGET_PRICE" >> "$LOG_FILE"
    fi
done 
# Log the end time to the log file
echo "Script finished at $(date)" >> "$LOG_FILE"