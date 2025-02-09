#!/bin/bash

URL="http://10.1.1.100"

while true; do
    STATUS_CODE=$(curl -s -o /dev/null -w "%{http_code}" "$URL")

    if [ "$STATUS_CODE" -eq 200 ]; then
        echo "Server is up (HTTP 200 received). Exiting loop."
        break
    else
        RANDOM_SLEEP=$((RANDOM % 14 + 2))
        echo "Server not ready (HTTP $STATUS_CODE). Checking again in $RANDOM_SLEEP seconds..."
        sleep $RANDOM_SLEEP
    fi
done