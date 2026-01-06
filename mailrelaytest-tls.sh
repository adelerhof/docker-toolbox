#!/bin/bash
# set -x
# script to send test mail with netcat.
# expects the following arguments:
# 1. recepient mail server
# 2. port (typically 25 or 465)
# 3. mail from (e.g. from@example.com)
# 4. mail to (e.g. to@example.com)
# 5. username
# 6. password

# for mail_input function
SMTP_SERVER=$1
PORT=$2
FROM=$3
TO=$4
USERNAME=$5
PASSWORD=$6

# email body
EMAIL="From: ${FROM}\nTo: ${TO}\nSubject: Testing one two three\n\nThis is only a test. Please do not panic. If this works, then all is well, else all is not well.\nIn closing, Lorem ipsum dolor sit amet, consectetur adipiscing elit.\nFrom: $(hostname -f)\n$(date)"

# Encode username and password in base64
ENCODED_USERNAME=$(echo -n $USERNAME | base64)
ENCODED_PASSWORD=$(echo -n $PASSWORD | base64)

# error handling
function err_exit {
	echo -e 1>&2
	exit 1
}

# check if proper arguments are supplied
if [ $# -ne 6 ]; then
	echo -e "\n Usage error!"
	echo " This script requires four arguments:"
	echo " 1. recepient mail server"
	echo " 2. port (typically 25 or 465)"
	echo " 3. mail from (e.g. from@example.com)"
	echo " 4. mail to (e.g. to@example.com)"
	echo " 5. username"
	echo " 6. password"
	exit 1
fi

# create message
function mail_input {
	echo "ehlo $(hostname -f)"
	sleep 1
	echo "AUTH LOGIN"
	echo $ENCODED_USERNAME
	echo $ENCODED_PASSWORD
	sleep 1
	echo "MAIL FROM: <$FROM>"
	sleep 1
	echo "RCPT TO: <$TO>"
	sleep 1
	echo "DATA"
	sleep 1
	echo -e "$EMAIL"
	echo "."
	sleep 1
	echo "quit"
}

# send
mail_input | openssl s_client -starttls smtp -crlf -connect ${SMTP_SERVER}:${PORT} -quiet || err_exit
