#!/bin/bash

URL=$1

# Check if URL is provided
if [ -z "$URL" ]; then
  echo "Usage: $0 <URL>"
  exit 1
fi

DATA=$(curl -o /dev/null -s -w "%{http_code} %{time_total}" $URL)
echo $DATA