# Pydantic MCP Tutorial: Practical Applications

## Overview

This tutorial provides practical guidance for using the Pydantic MCP Run Python server in everyday development workflows. It focuses on **positive use cases** and demonstrates how to leverage the isolated Python environment for building secure applications.

## Target Audience

This tutorial is designed for:
- Application developers
- Data scientists
- DevOps engineers
- AI/ML developers working with Pydantic

## Tutorial Contents

1. **Setting up the Environment** (30 min)
   - Installing Pydantic AI
   - Setting up Deno
   - Configuring your environment

2. **Understanding MCP Basics** (30 min)
   - JSON-RPC communication
   - Tools and tool inputs
   - Server transports

3. **Running Python Code with MCP** (1 hour)
   - Simple code execution
   - Working with dependencies
   - Code sandbox benefits

4. **Implementing Custom Solutions** (1 hour)
   - Running algorithms safely
   - Implementing practical examples
   - Best practices for sandbox constraints

5. **Integration with Existing Applications** (1 hour)
   - Flask web application example
   - API integration
   - Production deployment considerations

## Benefits of the Isolated Environment

This tutorial emphasizes the **practical benefits** of running Python code in an isolated environment:

- **Security**: Run untrusted code without risking your system
- **Dependency Management**: Isolated dependency installation
- **Reproducibility**: Consistent execution environment
- **Resource Control**: Limit memory and CPU usage
- **Cross-Platform Compatibility**: Same behavior across different systems

## When to Use This Tutorial

You should use this tutorial when:
- You want to integrate MCP Run Python into your applications
- You need examples of running algorithms safely
- You're building a web application that utilizes MCP
- You want to understand how to work within sandbox constraints
- You need practical guidelines for everyday development workflows

## Security Note

While this tutorial focuses on practical applications, understanding the security boundaries of the MCP sandbox is also important. For in-depth security testing and boundary validation, please refer to the [sandbox-isolation tutorial](../sandbox-isolation/README.org), which provides:

- Detailed security boundary testing
- Validation of isolation mechanisms
- Comparative analysis of direct vs. sandboxed execution
- Technical details of the isolation implementation

## Getting Started

To begin the tutorial:

1. Make sure you have Python 3.10+ and Deno installed
2. Run the setup script: `./scripts/setup.sh`
3. Follow the tutorial sections in order
4. Complete the practical exercises in each section

## Additional Resources

- [Pydantic AI Installation Guide](https://ai.pydantic.dev/install/#__tabbed_2_2)
- [MCP Run Python GitHub Repository](https://github.com/pydantic/pydantic-ai/tree/main/mcp-run-python)
- [MCP Run Python Documentation](https://ai.pydantic.dev/mcp/run-python/)
- [Sandbox Isolation Tutorial](../sandbox-isolation/README.org)