#!/bin/bash

URL=$1
PROXY=$2
PROXY_LIST=$3

# Check if URL is provided
if [ -z "$URL" ] || [ -z "$PROXY" ]; then
  echo "Usage: $0 <URL> <PROXY> <PROXY_LIST (only if proxy is in use)>"
  exit 1
fi

# Check if proxy is 'yes'
if [ "$PROXY" == "yes" ]; then
  if [ -z "$PROXY_LIST" ]; then
    echo "Proxy list not provided."
    exit 1
  fi

  PROXY_URL=$(shuf -n 1 $PROXY_LIST)
  if [ -z "$PROXY_URL" ]; then
    echo "Proxy list is empty."
    exit 1
  fi

  DATA=$(curl -o /dev/null -s -w "%{http_code} %{time_total}" -x $PROXY_URL $URL)
  echo $DATA
  exit 0
elif [ "$PROXY" == "no" ]; then
  DATA=$(curl -o /dev/null -s -w "%{http_code} %{time_total}" $URL)
  echo $DATA
  exit 0
fi