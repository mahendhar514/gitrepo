#!/bin/bash

SERVICES=("pusher" "recorder" "discovery" "onvif" "www" "updater")

for SERVICENAME in "${SERVICES[@]}"; do
    # Check if the process exists
    if ! ps -ef | grep "duranc-gateway --services=$SERVICENAME run" | grep -v grep > /dev/null; then
        echo "Service $SERVICENAME is not running. Starting it now..."
        $HOME/.local/bin/duranc-gateway --services="$SERVICENAME" start
    else
        echo "Service $SERVICENAME is already running."
    fi
done
