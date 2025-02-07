#!/bin/bash
# script to send test mail with netcat. 
# expects the following arguments:
# 1. recepient mail server
# 2. port (typically 25 or 465)
# 3. mail from (e.g. from@example.com)
# 4. mail to (e.g. to@example.com)
 
# for mail_input function
from=$3
to=$4
 
# error handling
function err_exit { echo -e 1>&2; exit 1; }
 
# check if proper arguments are supplied
if [ $# -ne 4 ]; then
  echo -e "\n Usage error!"
  echo " This script requires four arguments:"
  echo " 1. recepient mail server"
  echo " 2. port (typically 25 or 465)"
  echo " 3. mail from (e.g. from@example.com)"
  echo " 4. mail to (e.g. to@example.com)"
  exit 1
fi
 
# create message
function mail_input { 
  echo "ehlo $(hostname -f)"
#  echo "helo server.adelerhof.eu"
sleep 1
  echo "MAIL FROM: <$from>"
sleep 1
  echo "RCPT TO: <$to>"
sleep 1
  echo "DATA"
sleep 1  
	echo "From: <$from>"
sleep 1
	echo "To: <$to>"
sleep 1
  echo "Subject: Testing one two three"
sleep 1
  echo "This is only a test. Please do not panic. If this works, then all is well, else all is not well."
  echo "In closing, Lorem ipsum dolor sit amet, consectetur adipiscing elit."
  echo "From: $(hostname -f)"
	echo "$(date)"
  echo "."
sleep 1
  echo "quit"
}
 
# test
#mail_input
 
# send
mail_input | nc $1 $2 || err_exit
