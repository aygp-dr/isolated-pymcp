---
title: Secure Environment Variable Usage
category: security
severity: high
language: multiple
---

# Secure Environment Variable Usage

## Rule

Handle environment variables securely:

1. Never hardcode sensitive values (API keys, passwords, tokens)
2. Use environment variables for configuration
3. Apply proper validation for environment variables
4. Do not log or expose sensitive environment variable values
5. Provide clear documentation on required environment variables

## Examples

### ✅ Correct

```python
import os
from dotenv import load_dotenv

# Load environment variables from .env file
load_dotenv()

# Get API key with fallback for development
api_key = os.environ.get("API_KEY")
if not api_key:
    raise ValueError("API_KEY environment variable is required")

# Use the key without printing it
client = APIClient(api_key=api_key)
```

### ❌ Incorrect

```python
# Hardcoded credentials
API_KEY = "sk-1234567890abcdef"

# Exposing sensitive information in logs
print(f"Using API key: {os.environ.get('API_KEY')}")

# No validation for required values
api_key = os.environ.get("API_KEY", "")  # Empty fallback
```

## Rationale

Hardcoded credentials can easily be leaked through version control. Environment variables provide a secure way to configure applications without exposing sensitive information in code.

## References

- [OWASP - Environment Variable Security](https://cheatsheetseries.owasp.org/cheatsheets/Docker_Security_Cheat_Sheet.html#rule-4-use-environment-variables-for-sensitive-information)
- [12 Factor App - Config](https://12factor.net/config)