#!/bin/bash

URL="http://10.1.1.100"

while true; do
    STATUS_CODE=$(curl -s -o /dev/null -w "%{http_code}" "$URL")

    if [ "$STATUS_CODE" -eq 200 ]; then
        echo "Server is up (HTTP 200 received). Exiting loop."
        break
    else
        echo "Server not ready (HTTP $STATUS_CODE). Checking again in 5 seconds..."
        sleep 5
    fi
done