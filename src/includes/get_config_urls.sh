#!/bin/bash

CONFIG=$1

# Check if config file is provided
if [ -z $CONFIG ]; then
  echo "Usage: $0 <config_file>"
  exit 1
fi

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

  DASH_COUNT=$(echo $line | grep -o '-' | wc -l)
  if [ $DASH_COUNT == 1 ]; then
    URL=$(echo $line | cut -d '-' -f2 | sed 's/ //g')
    echo -n "$URL;"
    continue
  else if [ $DASH_COUNT == 2 ]; then
    REFRESH_INTERVAL=$(echo $line | cut -d '-' -f3 | sed 's/ //g')
    echo -n "$REFRESH_INTERVAL "
    continue
  fi
  fi
  
done < $CONFIG