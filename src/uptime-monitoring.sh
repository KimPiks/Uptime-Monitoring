#!/bin/bash

# Author           : Kamil Prorok ( kamilxprorok@gmail.com )
# Created On       : 17.05.2024
# Last Modified By : Kamil Prorok ( kamilxprorok@gmail.com )
# Last Modified On : 23.05.2024
# Version          : 0.1.2
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

CONFIGS_DIR="/etc/uptime-monitoring"
SCRIPTS_DIR="/usr/lib/uptime-monitoring"
LOGS_DIR="/var/log/uptime-monitoring"

URLS_CONFIG="$CONFIGS_DIR/urls.config"
EMAIL_CONFIG="$CONFIGS_DIR/email.config"

# Variables
URLS_DATA=$($SCRIPTS_DIR/get_config_urls.sh $URLS_CONFIG)
IFS=' ' read -a URLS_DATA <<< "$URLS_DATA"
URLS=()
INTERVALS=()
FAILS=()
PROXYS=()

# Load functions
. $SCRIPTS_DIR/config_services.sh
. $SCRIPTS_DIR/status.sh
. $SCRIPTS_DIR/email_setup.sh
. $SCRIPTS_DIR/proxy.sh

# Extracting URLs and Intervals
for element in "${URLS_DATA[@]}"; do
  URLS+=($(echo $element | cut -d ';' -f1))
  INTERVALS+=($(echo $element | cut -d ';' -f2))
  FAILS+=($(echo $element | cut -d ';' -f3))
  PROXYS+=($(echo $element | cut -d ';' -f4))
done

# Convert long options to short ones
for arg in "$@"; do
  shift
  case "$arg" in
    '--help')                 set -- "$@" '-h'   ;;
    '--version')              set -- "$@" '-v'   ;;
    '--add-service')          set -- "$@" '-a'   ;;
    '--remove-service')       set -- "$@" '-u'   ;;
    '--background')           set -- "$@" '-d'   ;;
    '--service')              set -- "$@" '-s'   ;;
    '--logs')                 set -- "$@" '-r'   ;;
    '--url')                  set -- "$@" '-n'   ;;
    '--set-email')            set -- "$@" '-e'   ;;
    '--add-proxy')            set -- "$@" '-p'   ;;
    *)                        set -- "$@" "$arg" ;;
  esac
done

# Functions
function show_help() {
  echo "Usage: $0 [OPTION]"
  echo "Options:"
  echo "  --help                          Display help"
  echo "  --version                       Display version"
  echo "  --service                       Show status of services"
  echo "  --url <url> --service           Show status of a specific service"
  echo "  --logs <url>                    Show last 100 logs of a specific service"
  echo "  --background                    Start service in background"
  echo "  --add-service                   Add a new service"
  echo "  --remove-service <url>          Remove service"
  echo "  --set-email                     Set email for notifications"
  echo "  --add-proxy <file>              Add proxy for service"
}

function show_version() {
  VERSION=$(grep -E '^# Version[ ]*:' "$0" | cut -d ':' -f2 | tr -d ' ')
  echo "Uptime Monitoring v$VERSION"
}

while getopts "hvdsaeu:r:n:p:" opt; do
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
    # Set URL parameter
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
    # Add service to monitoring
    a)
      add_service
      exit 0
      ;;
    # Remove service from monitoring
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
    # Set email for notifications
    e)
      set_email
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
    # Add proxy
    p)
      add_proxy $OPTARG
      exit 0
      ;;
    *)
      show_help
      exit 0
      ;;
    esac
done

show_help