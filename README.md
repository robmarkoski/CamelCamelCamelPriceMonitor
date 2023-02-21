# CamelCamelCamel Price Monitor

The CamelCamelCamel Price Monitor is a Bash script that monitors the price of a product on the CamelCamelCamel website and sends a [Pushover](https://pushover.net/) notification if the price drops below a specified target price. The script retrieves the current price of the product from the website, compares it to the target price, and sends a notification if the current price is lower than the target price.

## How to use

1. Clone or download the script to your local machine.
2. Open the script in a text editor and set the country code, product ID, target price, and [Pushover API key and user key](https://pushover.net/api#registration).
3. Schedule the script to run automatically using `crontab` or a similar tool.
4. The script will log the start and end time of each run, as well as any errors or notifications, to a log file in the same directory as the script.

## Revision History

- 0.1 (2023-02-22): Initial submission.
