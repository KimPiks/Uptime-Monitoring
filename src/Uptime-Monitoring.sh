#!/bin/bash

# Author           : Kamil Prorok ( kamilxprorok@gmail.com )
# Created On       : 17.05.2024
# Last Modified By : Kamil Prorok ( kamilxprorok@gmail.com )
# Last Modified On : 17.05.2024
# Version          : 0.1.0
#
# Description      : A tool for monitoring and reporting the status of websites.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <https://www.gnu.org/licenses/>.

# Configs

CONFIGS_DIR="/home/Studia/sys-skrypts/Uptime-Monitoring/src/configs"
SCRIPTS_DIR="/home/Studia/sys-skrypts/Uptime-Monitoring/src/includes"
LOGS_DIR="/home/Studia/sys-skrypts/Uptime-Monitoring/logs"

URLS_CONFIG="$CONFIGS_DIR/urls.config"
EMAIL_CONFIG="$CONFIGS_DIR/email.config"

# Variables
URLS_DATA=$($SCRIPTS_DIR/get_config_urls.sh $URLS_CONFIG)
IFS=' ' read -a URLS_DATA <<< "$URLS_DATA"
URLS=()
INTERVALS=()
FAILS=()
PROXYS=()

# Extracting URLs and Intervals
for element in "${URLS_DATA[@]}"; do
  URLS+=($(echo $element | cut -d ';' -f1))
  INTERVALS+=($(echo $element | cut -d ';' -f2))
  FAILS+=($(echo $element | cut -d ';' -f3))
  PROXYS+=($(echo $element | cut -d ';' -f4))
done

if [ ${#URLS[@]} -eq 0 ]; then
  echo "URL's config file is not properly formatted."
  exit 1
fi

# Convert long options to short ones
for arg in "$@"; do
  shift
  case "$arg" in
    '--help')         set -- "$@" '-h'   ;;
    '--version')      set -- "$@" '-v'   ;;
    '--add')          set -- "$@" '-a'   ;;
    '--remove')       set -- "$@" '-u'   ;;
    '--background')   set -- "$@" '-d'   ;;
    '--service')      set -- "$@" '-s'   ;;
    '--logs')         set -- "$@" '-r'   ;;
    '--url')          set -- "$@" '-n'   ;;
    *)                set -- "$@" "$arg" ;;
  esac
done

# Functions
function check_status() {
  URL_ID=$1
  FAIL=$2

  URL=${URLS[$URL_ID]}
  PROXY=${PROXYS[$URL_ID]}
  MAX_FAILS=${FAILS[$URL_ID]}
  MAX_FAILS=$(($MAX_FAILS+0))

  if [ $FAIL -eq $MAX_FAILS ]; then
    eval $SCRIPTS_DIR/send_email_status.sh $EMAIL_CONFIG $URL
  fi

  if [ $PROXY == "yes" ]; then
    PROXY_LIST="$CONFIGS_DIR/proxy.list"
    REQUEST_DATA=$(eval $SCRIPTS_DIR/get_service_status.sh $URL $PROXY $PROXY_LIST)
  else
    REQUEST_DATA=$(eval $SCRIPTS_DIR/get_service_status.sh $URL $PROXY)
  fi

  STATUS_CODE=$(echo $REQUEST_DATA | cut -d ' ' -f1)
  RESPONSE_TIME=$(echo $REQUEST_DATA | cut -d ' ' -f2)
  
  # Log to file
  eval $SCRIPTS_DIR/log_status.sh $LOGS_DIR $URL $STATUS_CODE $RESPONSE_TIME

  sleep ${INTERVALS[$URL_ID]}   
  if [ $STATUS_CODE -eq 0 ] || [ $STATUS_CODE -gt 399 ]; then
    check_status $URL_ID $(($FAIL+1))
  else
    check_status $URL_ID 0
  fi
}

function show_help() {
  echo "Usage: $0 [OPTION]"
  echo "Options:"
  echo "  --help                  Display help"
  echo "  --version               Display version"
  echo "  --service               Show status of services"
  echo "  --url <url> --service   Show status of a specific service"
  echo "  --logs <url>            Show last 100 logs of a specific service"
  echo "  --background            Start service in background"
  echo "  --add                   Add a new service"
  echo "  --remove <url>          Remove service"
}

function show_version() {
  VERSION=$(grep -E '^# Version[ ]*:' "$0" | cut -d ':' -f2 | tr -d ' ')
  echo "Uptime Monitoring v$VERSION"
}

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

while getopts "hvdsau:r:n:" opt; do
  case $opt in
    # Script help
    h)
      show_help
      exit 0
      ;;
    # Script version
    v)
      show_version
      exit 0
      ;;
    n)
      URL_PARAM=$OPTARG
      ;;
    # Get status of services
    s)
      if [ -z $URL_PARAM ]; then
        eval $SCRIPTS_DIR/show_status.sh $LOGS_DIR
      else
        eval $SCRIPTS_DIR/show_status.sh $LOGS_DIR $URL_PARAM
      fi
      exit 0
      ;;
    a)
      add_service
      exit 0
      ;;
    u)
      remove_service $OPTARG
      exit 0
      ;;
    # Show logs of a specific service
    r)
      URL_PARAM=$OPTARG
      if ! [ -z $URL_PARAM ]; then
        eval $SCRIPTS_DIR/show_status.sh $LOGS_DIR $URL_PARAM 1 
      fi
      exit 0
      ;;
    # Start service in background
    d)
      for ((i = 0; i < ${#URLS[@]}; i++)); do
        check_status $i 0 &
      done

      # Keep the script running; neccessery for systemd service
      while [ true ]; do 
        sleep 1 
      done
      ;;
    *)
      show_help
      exit 0
      ;;
    esac
done

show_help