#!/bin/bash
set -e

# Set the country code (e.g. "au" for Australia)
COUNTRY_CODE="au"

# Set the product ID (e.g. "B07JYZFCDN" for the Echo Dot)
PRODUCT_ID="B07JYZFCDN"

# Set the URL of the product to monitor
URL="https://${COUNTRY_CODE}.camelcamelcamel.com/product/${PRODUCT_ID}"

# Set the target price
TARGET_PRICE=50

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

# Get the HTML data from CamelCamelCamel
HTML_DATA=$(curl -s "$URL")

if [ -z "$HTML_DATA" ]; then
  # Send a Pushover notification if there was an error retrieving the HTML data
  send_pushover_notification "Error retrieving HTML data" "There was an error retrieving the HTML data from CamelCamelCamel."
  echo "Error retrieving HTML data from CamelCamelCamel" >> "$LOG_FILE"
  exit 1
fi

# Parse the current price from the HTML data
CURRENT_PRICE=$(echo "$HTML_DATA" | grep -A 1 'Current' | tail -n 1 | sed -e 's/<[^>]*>//g' | tr -d '$,')

if [ -z "$CURRENT_PRICE" ]; then
  # Send a Pushover notification if there was an error parsing the current price
  send_pushover_notification "Error parsing current price" "There was an error parsing the current price from the HTML data."
  echo "Error parsing current price from HTML data" >> "$LOG_FILE"
  exit 1
fi

# Compare the current price with the target price
if (( $(echo "$CURRENT_PRICE < $TARGET_PRICE" | bc -l) )); then
  # Send a Pushover notification
  send_pushover_notification "Price drop on CamelCamelCamel" "The price of the product you are monitoring has dropped below the target price."
  echo "Price drop on CamelCamelCamel. (Current Price: $CURRENT_PRICE vs Target Price: $TARGET_PRICE)" >> "$LOG_FILE"
else
  echo "No price drop detected on CamelCamelCamel (Current Price: $CURRENT_PRICE vs Target Price: $TARGET_PRICE)" >> "$LOG_FILE"
fi

# Log the end time to the log file
echo "Script finished at $(date)" >> "$LOG_FILE"
