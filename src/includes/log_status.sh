#!/bin/bash

LOGS_DIR=$1
URL=$2
STATUS=$3
RESPONSE_TIME=$4

if [ -z $LOGS_DIR ] || [ -z $URL ] || [ -z $STATUS ] || [ -z $RESPONSE_TIME ]; then
  echo "Usage: $0 <logs_dir> <url> <status_code> <reponse_time>"
  exit 1
fi

SAFE_URL=$(echo $URL | sed 's/\///g' | sed 's/\.//g' | sed 's/\://g')

# Create log file if it doesn't exist
test -f "$LOGS_DIR/$SAFE_URL.log" || touch "$LOGS_DIR/$SAFE_URL.log"


DATE_TIME_UTC=$(date -u +"%Y-%m-%d %H:%M:%S")
# Log to file
echo "[$DATE_TIME_UTC] $URL $STATUS $RESPONSE_TIME" >> "$LOGS_DIR/$SAFE_URL.log"