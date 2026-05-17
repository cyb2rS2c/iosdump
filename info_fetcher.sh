#!/bin/bash

RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' 

echo -e "${BLUE}===== General iPhone Info =====${NC}"
ideviceinfo | awk '{print "• " $0}'
echo

echo -e "${BLUE}===== Keyed Info (com.*) =====${NC}"


ideviceinfo -h | grep -o 'com\.[a-zA-Z0-9_.]*$' | sort | while IFS= read -r key; do
    
    value=$(ideviceinfo -q "$key" 2>/dev/null)
    
    if [ -n "$value" ]; then
        # Print key in red
        echo -e "${RED}${key}${NC}: $value"
    fi
done
