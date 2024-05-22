#!/bin/bash

CONFIG_DIR=$1
SERVICE=$2

# Check if config directory is provided
if [ -z $CONFIG_DIR ]; then
  echo "Usage: $0 <config_dir> <service>"
  exit 1
fi

# Read config variables
. $CONFIG_DIR

if [ -z $SENDER ] || [ -z $SMTP_SERVER ] || [ -z $RECIPIENT ]; then
  echo "Invalid config file."
  exit 1
fi

SUBJECT="[Uptime-Monitoring] Service $SERVICE is down."
MESSAGE="Service $SERVICE is down. Please check it out."

# Format email content
MAIL_CONTENT="From: $SENDER\nTo: $RECIPIENT\nSubject: $SUBJECT\n\n$MESSAGE"

# Send email
curl --url "$SMTP_SERVER" --ssl-reqd \
  --mail-from "$SENDER" --mail-rcpt "$RECIPIENT" \
  --user "$SENDER:$PASSWORD" --insecure \
  -T <(echo -e "$MAIL_CONTENT")