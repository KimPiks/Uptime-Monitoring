#!/bin/bash

function check_status() {
  URL_ID=$1
  FAIL=$2

  URL=${URLS[$URL_ID]}
  PROXY=${PROXYS[$URL_ID]}
  MAX_FAILS=${FAILS[$URL_ID]}
  MAX_FAILS=$(($MAX_FAILS+0))

  # Send email if service is not responsing N times (defined in config)
  if [ $FAIL -eq $MAX_FAILS ]; then
    eval $SCRIPTS_DIR/send_email_status.sh $EMAIL_CONFIG $URL
  fi

  # Use proxy depending on config
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

  # Check status again after defined interval
  sleep ${INTERVALS[$URL_ID]}   
  if [ $STATUS_CODE -eq 0 ] || [ $STATUS_CODE -gt 399 ]; then
    check_status $URL_ID $(($FAIL+1))
  else
    check_status $URL_ID 0
  fi
}