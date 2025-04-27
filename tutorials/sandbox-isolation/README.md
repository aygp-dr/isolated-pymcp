# MCP Sandbox Isolation: Security Boundaries in Practice

## Overview

This tutorial demonstrates the **security boundaries** of the Pydantic MCP Run Python server by comparing the behavior of Python code when run directly on the host system versus through the MCP sandbox. It focuses on **security testing** and provides systematic validation of isolation mechanisms.

## Target Audience

This tutorial is designed for:
- Security engineers
- System administrators
- Security auditors
- Developers concerned with security implications

## Tutorial Contents

1. **File System Access Tests**
   - Access to sensitive system files
   - Directory listing restrictions
   - Write permission boundaries
   - User information access limits

2. **Command Execution Tests**
   - Subprocess execution attempts
   - OS system command restrictions
   - Shell access prevention
   - Command execution library restrictions

3. **Network Access Tests**
   - DNS lookup capabilities
   - Socket connection restrictions
   - Network library access
   - Local port binding limitations

4. **System Resources Tests**
   - System information visibility
   - Process information access
   - Environment variable isolation
   - System module restrictions

5. **Comparative Analysis**
   - Side-by-side results comparison
   - Security boundary visualization
   - Isolation effectiveness metrics
   - Potential vulnerability identification

## Security Testing Approach

This tutorial takes a systematic approach to security testing:

1. Run identical tests in both environments (direct host execution and MCP sandbox)
2. Compare results to identify security boundaries
3. Document which operations are blocked by the sandbox
4. Analyze the technical implementation of isolation mechanisms
5. Generate a comprehensive security report

## When to Use This Tutorial

You should use this tutorial when:
- You want to understand the security model in depth
- You need to validate that the sandbox is secure for your use case
- You're concerned about potential security vulnerabilities
- You want to test the effectiveness of the isolation mechanisms
- You need to explain the security boundaries to stakeholders

## Practical Applications Note

While this tutorial focuses on security testing, understanding how to use the MCP sandbox for practical applications is also important. For everyday development workflows and integration examples, please refer to the [pydantic-mcp tutorial](../pydantic-mcp/README.md), which provides:

- Practical examples of using the isolated environment
- Integration with web applications
- Guidelines for working within constraints
- Examples of legitimate use cases

## Running the Tutorial

To run this tutorial:

1. Make sure you have Python 3.10+ and Deno installed
2. Run `./setup.sh` to create the necessary directories
3. Execute `./run_direct_tests.sh` to run tests directly on your system
4. Execute `./run_mcp_tests.sh` to run tests through the MCP sandbox
5. Generate the comparison report with `./generate_report.sh`
6. Examine the comprehensive results in `results/isolation_report.md`

## Security Implications

Understanding these security boundaries is crucial for:
- Evaluating the safety of running untrusted code
- Implementing proper security controls
- Communicating security posture to stakeholders
- Planning appropriate usage scenarios
- Identifying potential issues before they become problems

## Additional Resources

- [Pyodide Security Model](https://pyodide.org/en/stable/usage/security.html)
- [Sandbox Escape Techniques](https://github.com/pydantic/pydantic-ai/issues?q=is%3Aissue+label%3Asecurity)
- [Pydantic MCP Tutorial](../pydantic-mcp/README.md) for practical applications
- [MCP Security Documentation](https://ai.pydantic.dev/mcp/security/)