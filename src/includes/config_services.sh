#!/bin/bash

function add_service() {
  echo -n "Enter URL: "
  read URL

  echo -n "Enter refresh interval (in seconds): "
  read INTERVAL

  if ! [[ $INTERVAL =~ ^[0-9]+$ ]]; then
    echo "Refresh interval must be a positive number."
    exit 1
  fi

  echo -n "Enter report after n fails: "
  read REPORT_AFTER_N_FAILS

  if ! [[ $REPORT_AFTER_N_FAILS =~ ^[0-9]+$ ]]; then
    echo "Report after n fails must be a positive number."
    exit 1
  fi

  echo -n "Use proxy? (yes/no): "
  read PROXY_USAGE

  if ! [[ $PROXY_USAGE =~ ^yes|no$ ]]; then
    echo "Proxy usage must be 'yes' or 'no'."
    exit 1
  fi

  printf "\n- %s \n- - %s \n- - - %s \n- - - - %s \n" $URL $INTERVAL $REPORT_AFTER_N_FAILS $PROXY_USAGE >> $URLS_CONFIG 
}

function remove_service() {
  SERVICE_TO_REMOVE=$1

  if ! grep -q "$SERVICE_TO_REMOVE" "$URLS_CONFIG"; then
    echo "Service '$SERVICE_TO_REMOVE' not found in config."
    exit 1
  fi

  LINE_NUMBER=$(grep -n "$SERVICE_TO_REMOVE" "$URLS_CONFIG" | cut -d ':' -f1)
  LINE=$(sed -n "$LINE_NUMBER"p "$URLS_CONFIG")

  DASH_COUNT=$(echo $LINE | grep -o '-' | wc -l)
  if [ $DASH_COUNT != 1 ]; then
    echo "Service '$SERVICE_TO_REMOVE' not found in config."
    exit 1
  fi

  sed -i -e "$LINE_NUMBER","$(($LINE_NUMBER+3))d" "$URLS_CONFIG"
}