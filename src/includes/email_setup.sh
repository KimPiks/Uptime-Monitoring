#!/bin/bash

function set_email () {
  echo -n "Enter sender: "
  read SENDER

  echo -n "Enter receiver: "
  read RECEIVER

  echo -n "Enter email password: "
  read PASSWORD

  echo -n "Enter email server: "
  read SERVER

  echo "SENDER=\"$SENDER\"" > $EMAIL_CONFIG
  echo "RECEIVER=\"$RECEIVER\"" >> $EMAIL_CONFIG
  echo "PASSWORD=\"$PASSWORD\"" >> $EMAIL_CONFIG
  echo "SMTP_SERVER=\"$SERVER\"" >> $EMAIL_CONFIG  
}