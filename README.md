# XSS-Testing-Script

Here’s a more polished version of the script with a better design, default payloads, and enhanced user experience.


### **Key Features**
1. **Default Payloads**: Includes a predefined list of XSS payloads.
2. **Custom Payloads**: Allows you to specify a file with custom payloads.
3. **Single or Multiple URL Testing**:
   - Test a single URL with `-u`.
   - Test multiple URLs from a file with `-f`.
4. **Clear Output Design**:
   - Well-structured output with color-coded results in the terminal.
   - Results saved to a timestamped file (`results_<timestamp>.txt`).
5. **User-Friendly Help Menu**:
   - Comprehensive usage guide with examples.
6. **Error Handling**:
   - Checks for missing files or invalid inputs.

---

### **How to Use**
1. **Save the Script**: Save as `xss_test.sh`.
2. **Make Executable**:
   ```bash
   chmod +x xss_test.sh
   ```
3. **Run the Script**:
   - Test a single URL:
     ```bash
     ./xss_test.sh -u "https://example.com/search?q="
     ```
   - Test multiple URLs from a file:
     ```bash
     ./xss_test.sh -f urls.txt
     ```
   - Use custom payloads:
     ```bash
     ./xss_test.sh -u "https://example.com/search?q=" -p payloads.txt
     ```
   - Save results to a custom file:
     ```bash
     ./xss_test.sh -f urls.txt -o custom_results.txt
     ```

---

### **Sample Files**

#### `urls.txt`
```
https://example.com/search?q=
https://example.org/comment?msg=
https://testsite.net/input?value=
```

#### `payloads.txt`
```
<script>alert('XSS')</script>
<img src=x onerror=alert('XSS')>
<svg/onload=alert('XSS')>
<iframe src=javascript:alert('XSS')></iframe>
```

---

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

