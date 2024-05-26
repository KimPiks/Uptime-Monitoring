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

function validate_config() {
  NUM=0
  while IFS= read -r line || [ -n "$line" ];
  do
    # Skip comments
    if [[ $line == \#* ]]; then
      continue
    fi

    # Skip empty lines
    if [ -z "$line" ]; then
      continue
    fi

    NUM=$((NUM+1))
    DASH_COUNT=$(echo $line | grep -o '-' | wc -l)

    if [ $((NUM % 4)) == 1 ]; then
      if [ $DASH_COUNT != 1 ]; then
        exit 1
      fi
    else if [ $((NUM % 4)) == 2 ]; then
      if [ $DASH_COUNT != 2 ]; then
        exit 1
      fi

      REFRESH_INTERVAL=$(echo $line | cut -d '-' -f3 | sed 's/ //g')
      if ! [[ $REFRESH_INTERVAL =~ ^[0-9]+$ ]]; then
        exit 1
      fi
    else if [ $((NUM % 4)) == 3 ]; then
      if [ $DASH_COUNT != 3 ]; then
        exit 1
      fi

      REPORT_AFTER_N_FAILS=$(echo $line | cut -d '-' -f4 | sed 's/ //g')
      if ! [[ $REPORT_AFTER_N_FAILS =~ ^[0-9]+$ ]]; then
        exit 1
      fi
    else if [ $((NUM % 4)) == 0 ]; then
      if [ $DASH_COUNT != 4 ]; then
        exit 1
      fi

      PROXY_USAGE=$(echo $line | cut -d '-' -f5 | sed 's/ //g')
      if ! [[ $PROXY_USAGE =~ ^yes|no$ ]]; then
        exit 1
      fi
    fi
    fi
    fi
    fi
    
    
  done < $CONFIG
}

validate_config

# Read config file
while IFS= read -r line || [ -n "$line" ];
do
  # Skip comments
  if [[ $line == \#* ]]; then
    continue
  fi

  # Skip empty lines
  if [ -z "$line" ]; then
    continue
  fi

  DASH_COUNT=$(echo $line | grep -o '-' | wc -l)
  if [ $DASH_COUNT == 1 ]; then
    URL=$(echo $line | cut -d '-' -f2 | sed 's/ //g')
    echo -n " $URL;"
    continue
  else if [ $DASH_COUNT == 2 ]; then
    REFRESH_INTERVAL=$(echo $line | cut -d '-' -f3 | sed 's/ //g')
    echo -n "$REFRESH_INTERVAL;"
    continue
  else if [ $DASH_COUNT == 3 ]; then
    MAIL_AFTER_FAIL=$(echo $line | cut -d '-' -f4 | sed 's/ //g')
    echo -n "$MAIL_AFTER_FAIL;"
    continue
  else if [ $DASH_COUNT == 4 ]; then
    USE_PROXY=$(echo $line | cut -d '-' -f5 | sed 's/ //g')
    echo -n "$USE_PROXY"
  fi
  fi
  fi
  fi
  
done < $CONFIG