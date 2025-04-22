# Security Review

Perform a thorough security review of the provided code, focusing on:

1. **Authentication & Authorization**
   - Evaluate credential management
   - Check for proper access controls
   - Look for insecure authentication methods

2. **Data Validation**
   - Identify missing or inadequate input validation
   - Check for SQL/command injection vulnerabilities
   - Assess handling of untrusted data

3. **Cryptography Issues**
   - Identify weak cryptographic algorithms
   - Check for hardcoded keys/passwords
   - Examine key management procedures

4. **Common Vulnerabilities**
   - Look for path traversal vulnerabilities
   - Identify CSRF/XSS opportunities
   - Check for dangerous imports and function calls

5. **Container/Environment Security**
   - Evaluate Docker/container configuration
   - Check for privilege escalation opportunities
   - Assess environment variable usage

For each issue found:
1. Identify the specific vulnerability
2. Explain the potential impact
3. Provide a concrete fix recommendation
4. Rate the severity (Critical/High/Medium/Low)