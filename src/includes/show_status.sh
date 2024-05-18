#!/bin/bash

LOGS_DIR=$1
URL=$2
RECORDS=$3

if [ -z $LOGS_DIR ]; then
  echo "Usage: $0 <logs_dir> <url>"
  exit 1
fi

SAFE_URL=$(echo $URL | sed 's/\///g' | sed 's/\.//g' | sed 's/\://g')
STATUSES=($(awk '{print $4}' "$LOGS_DIR/$SAFE_URL.log"))

clear

function get_color() {
  STATUS=$1

  if [[ $STATUS -ge 200 && $STATUS -lt 300 ]]; then
    COLOR="\e[32m"  # Green
  elif [[ $STATUS -ge 300 && $STATUS -lt 400 ]]; then
    COLOR="\e[33m"  # Yellow
  elif [[ $STATUS -ge 400 ]]; then
    COLOR="\e[31m"  # Red
  else
    COLOR="\e[0m"   # No color
  fi

  echo $COLOR
}

function get_uptime_percentage() {
  URL_PARAM=$1
  SAFE_URL_PARAM=$(echo $URL_PARAM | sed 's/\///g' | sed 's/\.//g' | sed 's/\://g')
  STATUSES_PARAM=($(awk '{print $4}' "$LOGS_DIR/$SAFE_URL_PARAM.log"))

  TOTAL_STATUSES_PARAM=${#STATUSES_PARAM[@]}
  COUNT=$((TOTAL_STATUSES_PARAM - $(grep -o '000' <<< "${STATUSES_PARAM[@]}" | wc -l)))
  PERCENTAGE=$(awk "BEGIN {printf \"%.2f\", ($COUNT / $TOTAL_STATUSES_PARAM) * 100}")

  echo $PERCENTAGE
}

function show_all_services() {
  echo "Uptime Monitoring"
  echo "-----------------"
  echo "Service Name                        | Status | Response Time | Last Checked            | Uptime"
  echo "-----------------------------------------------------------------------------------------------"

  for file in $LOGS_DIR/*; do
    SERVICE_NAME=$(tail -n 1 $file | cut -d ' ' -f3)
    LAST_STATUS=$(tail -n 1 $file | cut -d ' ' -f4)
    LAST_RESPONSE_TIME=$(tail -n 1 $file | cut -d ' ' -f5)
    LAST_CHECKED=$(tail -n 1 $file | cut -d ' ' -f1,2 | sed 's/\[//g' | sed 's/\]//g')

    COLOR=$(get_color $LAST_STATUS)
    UPTIME=$(get_uptime_percentage $SERVICE_NAME)
    printf "%-35s |  ${COLOR}%-5s\e[0m | %-13s | %-23s | %-5s%% \n" "$SERVICE_NAME" "$LAST_STATUS" "$LAST_RESPONSE_TIME" "$LAST_CHECKED" "$UPTIME"
  done

  echo "-----------------------------------------------------------------------------------------------"
}

function show_service_summary() {
  echo "Uptime Monitoring"
  echo "-----------------"
  echo "Service Name                        | Status | Response Time | Last Checked"
  echo "----------------------------------------------------------------------------------"

  SERVICE_NAME=$(tail -n 1 $LOGS_DIR/$SAFE_URL.log | cut -d ' ' -f3)
  LAST_STATUS=$(tail -n 1 $LOGS_DIR/$SAFE_URL.log | cut -d ' ' -f4)
  LAST_RESPONSE_TIME=$(tail -n 1 $LOGS_DIR/$SAFE_URL.log | cut -d ' ' -f5)
  LAST_CHECKED=$(tail -n 1 $LOGS_DIR/$SAFE_URL.log | cut -d ' ' -f1,2 | sed 's/\[//g' | sed 's/\]//g')

  COLOR=$(get_color $LAST_STATUS)

  printf "%-35s |  ${COLOR}%-5s\e[0m | %-13s | %-27s\n" "$SERVICE_NAME" "$LAST_STATUS" "$LAST_RESPONSE_TIME" "$LAST_CHECKED"
  echo "----------------------------------------------------------------------------------"
  printf "\n"
}

function show_uptime_summary() {
  STATUSES_ASCII_COUNT=$(echo ${#STATUSES[@]})

  if [ ${#STATUSES[@]} -gt 40 ]; then
    STATUSES_ASCII_COUNT=40
  fi

  for ((i = 0; i < $STATUSES_ASCII_COUNT; i++)); do
    if [[ ${STATUSES[$i]} -eq 0 ]]; then
      COLOR="\e[31m"  # Red
    else
      COLOR="\e[32m"  # Green
    fi

    printf "${COLOR}█\e[0m "
  done

  PERCENTAGE=$(get_uptime_percentage $URL)
  printf "Uptime: %s%%\n\n\n" "$PERCENTAGE"
}

function show_codes_summary() {
  TOTAL_STATUSES=${#STATUSES[@]}
  UNIQUE_STATUSES=($(printf "%s\n" "${STATUSES[@]}" | sort -n | uniq))

  echo "HTTP Status | Percentage"
  echo "------------------------"

  for STATUS in "${UNIQUE_STATUSES[@]}"; do
      COUNT=$(grep -o "$STATUS" <<< "${STATUSES[@]}" | wc -l)
      PERCENTAGE=$(awk "BEGIN {printf \"%.2f\", ($COUNT / $TOTAL_STATUSES) * 100}")

      COLOR=$(get_color $STATUS)

      printf "${COLOR}    %-3s\e[0m     |   %s%% \n" "$STATUS" "$PERCENTAGE"
  done

  echo "------------------------"
  printf "\n"
}

function show_last_problem_summary() {
  echo "Last Problem"
  echo "-------------------------"

  for ((i = 0; i < ${#STATUSES[@]}; i++)); do
    if [[ ${STATUSES[$i]} -ge 400 ]] || [[ ${STATUSES[$i]} -eq 0 ]]; then
      SERVICE_NAME=$(awk 'NR=='$i+1' {print $3}' "$LOGS_DIR/$SAFE_URL.log")
      LAST_STATUS=$(awk 'NR=='$i+1' {print $4}' "$LOGS_DIR/$SAFE_URL.log")
      LAST_RESPONSE_TIME=$(awk 'NR=='$i+1' {print $5}' "$LOGS_DIR/$SAFE_URL.log")
      LAST_CHECKED=$(awk 'NR=='$i+1' {print $1, $2}' "$LOGS_DIR/$SAFE_URL.log" | sed 's/\[//g' | sed 's/\]//g')
    fi
  done

  COLOR=$(get_color $LAST_STATUS)

  printf "Date: %-27s\n" "$LAST_CHECKED"
  printf "Status: ${COLOR}%-5s\e[0m\n" "$LAST_STATUS"
  printf "Response Time: %-13s\n" "$LAST_RESPONSE_TIME"    

  echo "-------------------------"
  printf '\n'
}

function show_last_reports() {
  echo "Last 10 Records"
  echo "-------------------------"
  echo "Date                 | Status | Response Time"
  echo "---------------------------------------------"
  tail -n 10 "$LOGS_DIR/$SAFE_URL.log" | while read line; do
    DATE=$(echo $line | cut -d ' ' -f1,2 | sed 's/\[//g' | sed 's/\]//g')
    STATUS=$(echo $line | cut -d ' ' -f4)
    RESPONSE_TIME=$(echo $line | cut -d ' ' -f5)

    COLOR=$(get_color $STATUS)

    printf "%-20s |  ${COLOR}%-5s\e[0m | %-13s\n" "$DATE" "$STATUS" "$RESPONSE_TIME"
  done

  echo "---------------------------------------------"
}

function show_last_reports_long() {
  echo "Last 100 Records"
  echo "-------------------------"
  echo "Date                 | Status | Response Time"
  echo "---------------------------------------------"
  tail -n 100 "$LOGS_DIR/$SAFE_URL.log" | while read line; do
    DATE=$(echo $line | cut -d ' ' -f1,2 | sed 's/\[//g' | sed 's/\]//g')
    STATUS=$(echo $line | cut -d ' ' -f4)
    RESPONSE_TIME=$(echo $line | cut -d ' ' -f5)

    COLOR=$(get_color $STATUS)

    printf "%-20s |  ${COLOR}%-5s\e[0m | %-13s\n" "$DATE" "$STATUS" "$RESPONSE_TIME"
  done

  echo "---------------------------------------------"
}


if [ -z $URL ]; then
  show_all_services
else 
  # Check if service exists
  if [ ! -f "$LOGS_DIR/$SAFE_URL.log" ]; then
    echo "Service not found"
    exit 1
  fi

  if [ -z $RECORDS ]; then
    show_service_summary
    show_uptime_summary
    show_codes_summary
    show_last_problem_summary
    show_last_reports
  else
    show_last_reports_long
  fi
fi
