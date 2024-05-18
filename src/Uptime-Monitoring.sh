#!/bin/bash

# Author           : Kamil Prorok ( kamilxprorok@gmail.com )
# Created On       : 17.05.2024
# Last Modified By : Kamil Prorok ( kamilxprorok@gmail.com )
# Last Modified On : 17.05.2024
# Version          : 0.0.4
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

# Variables
URLS_DATA=$($SCRIPTS_DIR/get_config_urls.sh $URLS_CONFIG)
IFS=' ' read -a URLS_DATA <<< "$URLS_DATA"
URLS=()
INTERVALS=()

# Extracting URLs and Intervals
for element in "${URLS_DATA[@]}"; do
  URLS+=($(echo $element | cut -d ';' -f1))
  INTERVALS+=($(echo $element | cut -d ';' -f2))
done

# Functions
function check_status() {
  URL_ID=$1
  URL=${URLS[$URL_ID]}

  REQUEST_DATA=$($SCRIPTS_DIR/get_service_status.sh "$URL")
  STATUS_CODE=$(echo $REQUEST_DATA | cut -d ' ' -f1)
  RESPONSE_TIME=$(echo $REQUEST_DATA | cut -d ' ' -f2)
  
  # Log to file
  eval $SCRIPTS_DIR/log_status.sh $LOGS_DIR $URL $STATUS_CODE $RESPONSE_TIME

  sleep ${INTERVALS[$URL_ID]}   
  check_status $URL_ID
}

function show_help() {
  echo "Usage: $0 [OPTION]"
  echo "Options:"
  echo "  -h            Display help"
  echo "  -v            Display version"
  echo "  -s            Show status of services"
  echo "  -d            Start service in background"
  echo "  -r <url>      Show last 100 logs of a specific service"
  echo "  -n <url> -s   Show status of a specific service"
}

function show_version() {
  VERSION=$(grep -E '^# Version[ ]*:' "$0" | cut -d ':' -f2 | tr -d ' ')
  echo "Uptime Monitoring v$VERSION"
}

while getopts "hvdsr:n:" opt; do
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
        check_status $i &
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