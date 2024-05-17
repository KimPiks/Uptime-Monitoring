#!/bin/bash

CONFIG="../configs/urls.config"

# Check if config file exists
if [ ! -f $CONFIG ]; then
  echo "Config file not found: $CONFIG"
  exit 1
fi

# Read config file
while IFS= read -r line || [ -n "$line" ];
do
  # Skip comments
  if [[ $line == \#* ]]; then
    continue
  fi

  URL=$(echo $line | cut -d '-' -f2 | sed 's/ //g')
  echo "$URL"
done < $CONFIG