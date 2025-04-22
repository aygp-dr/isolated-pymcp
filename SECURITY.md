# Security Guidelines

This document outlines security best practices for using the isolated-pymcp environment.

## Authentication & Authorization

### GitHub and API Keys

The project has been updated to use GitHub Secrets for sensitive API keys:

1. **Setup GitHub Secrets**
   - Run the script: `./setup_secrets.sh`
   - This will create placeholders for required secrets
   - Update secrets with real values: `gh secret edit SECRET_NAME`

2. **Local Development**
   - Run `make check-secrets` before starting containers
   - This automatically fetches secrets from GitHub and creates a local .env file

### Secret Management

- **DO NOT** commit `.env` files to the repository
- **DO NOT** hardcode API keys in scripts or code
- **DO NOT** expose API keys in logs or output

## Container Security

### Port Binding

All container ports are now bound to localhost only (127.0.0.1) to prevent external access:
- Services are available only from the local machine
- No external network exposure

### Resource Limits

Container resource limits have been added:
- Memory: 1GB
- CPU: 2 cores

### Running as Non-Root

- All processes in the container run as the non-root user 'mcp'
- Mount points and file permissions are properly secured

## Input Validation

Scripts now implement proper input validation:
- Algorithm names must match the pattern `^[a-zA-Z0-9_]+$`
- Path traversal protection in file access
- Command injection protection for user inputs

## Communication Security

While HTTP is used for local MCP servers, consider these additional security measures:
- Minimize sensitive data transmission
- Treat all inputs as untrusted
- Apply appropriate access controls

## Script Security

When installing new components, avoid these insecure patterns:
- Do not use `curl | bash` patterns
- Always download scripts first, then verify before executing
- Use checksums to verify downloaded files

## Reporting Security Issues

If you discover a security vulnerability, please report it to:
- Email: security@defrecord.com
- Or create a GitHub issue with the label "security"

## Security Updates

Keep your environment secure:
- Regularly update base images
- Check for dependency updates
- Subscribe to security advisories for key components