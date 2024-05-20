#!/bin/bash

# Create the logs directory and the date-specific directory if they don't exist. And get the folder's ownership.
USERNAME=$(logname)
LOG_DIR="./logs"
DATE_DIR="$LOG_DIR/$DATE"
mkdir -p "$DATE_DIR"
chown -R "$USERNAME":"$USERNAME" "$LOG_DIR"

# ID information is needed while passing from static table data to vector format in QGIS Python. This value increases with each collection. So it is not unique for each line. It is unique for each reading period.
ID=1

# Constructing a dynamic file name (date/hour are included) is essential to avoid overwriting problems. Then we create file.
DATE=$(date +"%Y%m%d")
HOUR=$(date +"%H_%M_%S")
FILENAME="$DATE_DIR/WiFiScanTest_${DATE}_${HOUR}.csv"
touch "$FILENAME"
chown "$USERNAME":"$USERNAME" "$FILENAME"

# Adding column headers
echo "ID,TIMESTAMP,NAME,SSID,SSID-HEX,MODE,CHAN,FREQ,RATE,SIGNAL,SECURITY,WPA-FLAGS,RSN-FLAGS,DEVICE,ACTIVE,IN-USE" > "$FILENAME"


while true; do #endless lopp to collect data until you stop.
  # Prompt the user to continue or q
  echo "Collecting data, you can stop it with ctrl+C "

  # Gathering the date and time is useful for archiving.
  TIMESTAMP=$(date +"%Y_%m_%d_%H_%M_%S")

  # We run "nmcli" to collect WiFiScan. "-t" helps with formatting. "field names" are useful for filtering."
  sudo nmcli -t --fields NAME,SSID,SSID-HEX,MODE,CHAN,FREQ,RATE,SIGNAL,SECURITY,WPA-FLAGS,RSN-FLAGS,DEVICE,ACTIVE,IN-USE dev wifi | awk -v id="$ID" -v timestamp="$TIMESTAMP" '{gsub(":", ","); print id","timestamp","$0}' >> "$FILENAME"

  # Check if the command was successful
  if [ $? -ne 0 ]; then
    echo "Failed to run nmcli command."
    exit 1
  fi

  # We need the "rescan" command below to refresh scanning and not get the same output again.
  sudo nmcli dev wifi rescan
  
  # ID information is needed while passing from static table data to vector format in QGIS Python. This value increases with each collection. So it is not unique for each line. It is unique for each reading period.
  ID=$((ID + 1))

  # a short wait time
  sleep 1
done
