#!/usr/bin/env bash

## e3372.sh v0.01 (9th March 2025)
##  Sends SMS

if [ $# -eq 0 ] || [ $# -gt 3 ]; then
	echo "Usage: $0 <number> <message>"
	echo
	echo "  read                    : Read messages (max 50)."
	echo "  delete <index>          : Delete message."
	echo "  send <number> <message> : Send message."
	echo
	echo "  Number must be in international format, eg. 447700123456."
	echo "  Message must be quoted."
	echo
	exit 1
fi

## Configurable Bits

HILINK_HOST="192.168.8.1"

## Everything Else

SESTOK=$(curl -s --url "http://$HILINK_HOST/api/webserver/SesTokInfo" --header "Host:$HILINK_HOST" | tr -d '\n')
HILINK_COOKIE=$(echo "$SESTOK" | awk -F\o\> {'print $2'} | awk -F\<\/ {'print $1'})
HILINK_TOKEN=$(echo "$SESTOK" | awk -F\o\> {'print $4'} | awk -F\<\/ {'print $1'})
RESPONSE="<response>OK</response>"

if [ "$1" == "read" ]; then 

	RESPONSE=$(
	curl -fSs http://$HILINK_HOST/api/sms/sms-list \
	--header "Cookie:$HILINK_COOKIE" \
	--header "__RequestVerificationToken:$HILINK_TOKEN" \
	--data   "<request><PageIndex>1</PageIndex><ReadCount>50</ReadCount><BoxType>1</BoxType><SortType>0</SortType><Ascending>0</Ascending><UnreadPreferred>0</UnreadPreferred></request>"
	)

	echo "$RESPONSE"
	exit 0

elif [ "$1" == "delete" ]; then 

	RESPONSE=$(
	curl -fSs http://$HILINK_HOST/api/sms/delete-sms \
	--header "Cookie:$HILINK_COOKIE" \
	--header "__RequestVerificationToken:$HILINK_TOKEN" \
	--data   "<request><Index>$2</Index></request>"
	)

	echo
	echo "$RESPONSE"
	echo

elif [ "$1" == "send" ]; then 

	PHONE="$2"
	CONTENT="$3"
	DATE=$(date '+%Y-%m-%d %T')
	LENGTH=${#CONTENT}

	RESPONSE=$(
	curl -fSs http://$HILINK_HOST/api/sms/send-sms \
	--header "Cookie:$HILINK_COOKIE" \
	--header "__RequestVerificationToken:$HILINK_TOKEN" \
	--data   "<request><Index>-1</Index><Phones><Phone>$PHONE</Phone></Phones><Sca/><Content>$CONTENT</Content><Length>$LENGTH</Length><Reserved>1</Reserved><Date>$DATE</Date></request>"
	)
	RESPONSE=$(echo $RESPONSE | tr -d '\n')

elif [ "$1" == "test" ]; then 

	# API paths here! https://github.com/arska/e3372/blob/master/e3372.py

	RESPONSE=$(
	curl -fSs http://$HILINK_HOST/api/device/information \
	--header "Cookie:$HILINK_COOKIE" \
	--header "__RequestVerificationToken:$HILINK_TOKEN"
	)

	echo "$RESPONSE"
	exit 0

else

	RESPONSE="Unknown option: $1"

fi

case "$RESPONSE" in

	*"<response>OK</response>"*)
		exit 0 ;;
	*)
		echo "$RESPONSE"
		exit 1 ;;

esac
