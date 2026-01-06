#!/bin/bash

# Check if the correct number of arguments is provided
if [[ $# -ne 4 ]]; then
	echo "Usage: $0 <smtp_server> <port> <username> <password>"
	exit 1
fi

SMTP_SERVER=$1
PORT=$2
USERNAME=$3
PASSWORD=$4

# Encode username and password in base64
ENCODED_USERNAME=$(echo -n "${USERNAME}" | base64)
ENCODED_PASSWORD=$(echo -n "${PASSWORD}" | base64)

# # Use openssl to test the SMTP server
# echo "QUIT" | openssl s_client -starttls smtp -crlf -connect ${SMTP_SERVER}:${PORT}

# # Check the exit status of the openssl command
# if [ $? -eq 0 ]; then
#   echo "SMTP server test successful"
# else
#   echo "SMTP server test failed"
# fi

# Send a test email with authentication
FROM="erik@adelerhof.eu"
TO="erik.adelerhof@kpn.com"
SUBJECT="Test Email"
BODY="This is a test email."

EMAIL="From: ${FROM}\nTo: ${TO}\nSubject: ${SUBJECT}\n\n${BODY}"

{
	echo "EHLO localhost"
	echo "AUTH LOGIN"
	echo "${ENCODED_USERNAME}"
	echo "${ENCODED_PASSWORD}"
	echo "MAIL FROM:<${FROM}>"
	echo "RCPT TO:<${TO}>"
	echo "DATA"
	echo -e "${EMAIL}"
	echo "."
	echo "QUIT"
} | openssl s_client -starttls smtp -crlf -connect "${SMTP_SERVER}":"${PORT}" -quiet
