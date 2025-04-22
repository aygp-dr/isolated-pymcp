
# Table of Contents

1.  [Overview](#org71207cd)
2.  [Architecture](#org328cce5)
3.  [Security Model](#org0b3cfc3)
4.  [Core Components](#org93a49ad)
5.  [Integration Points](#org03d6d84)
6.  [Getting Started](#org8bed99c)
7.  [Command Reference](#orgce7ab36)
    1.  [Scripts](#org58f25b4)
8.  [Development Workflow](#orga37124b)
9.  [Project Goals](#org053b0e6)
10. [References](#org94e6855)
11. [License](#org1419c4d)

A secure, isolated environment for exploring Python development with Model Context Protocol (MCP) and Language Server Protocol (LSP).


<a id="org71207cd"></a>

# Overview

This project creates an isolated container environment that combines MCP and LSP capabilities for Python development. By leveraging the complementary strengths of both protocols, we enable LLMs to access powerful code intelligence features while maintaining strict security boundaries.


<a id="org328cce5"></a>

# Architecture

    graph TD
        A[Host System]
        B[API Keys]
        C[Alpine Container]
        D[Run-Python MCP]
        E[MultilspyLSP]
        F[Python LSP Server]
        G[Client Tools]
        H[Python Algorithms]
    
        A --> B
        A --> C
        B --> D
        B --> E
        C --> D
        C --> E
        C --> F
        C --> G
        C --> H
    
        D --> H
        E --> F
        F --> H
    
        G --> D
        G --> E


<a id="org0b3cfc3"></a>

# Security Model

The project implements a principle of least access architecture:

-   Container isolation from host system
-   Non-root user execution within container
-   Restricted port exposure (bound to localhost only)
-   Secure secrets management via GitHub Secrets
-   Resource limits on container (memory, CPU)
-   Input validation and sanitization
-   Clear security domain boundaries between components

See <./SECURITY.md> for comprehensive security guidelines and best practices.


<a id="org93a49ad"></a>

# Core Components

-   **Pydantic Run-Python**: Executes Python code via MCP
-   **MultilspyLSP**: Bridges LSP capabilities to MCP
-   **Python LSP Server**: Provides code intelligence (completion, analysis, diagnostics)
-   **Client Interfaces**: Multiple access methods with the same security model


<a id="org03d6d84"></a>

# Integration Points

<table border="2" cellspacing="0" cellpadding="6" rules="groups" frame="hsides">


<colgroup>
<col  class="org-left" />

<col  class="org-left" />

<col  class="org-left" />
</colgroup>
<thead>
<tr>
<th scope="col" class="org-left">Component</th>
<th scope="col" class="org-left">Protocol</th>
<th scope="col" class="org-left">Function</th>
</tr>
</thead>
<tbody>
<tr>
<td class="org-left">Run-Python</td>
<td class="org-left">MCP</td>
<td class="org-left">Code execution and output capture</td>
</tr>

<tr>
<td class="org-left">MultilspyLSP</td>
<td class="org-left">MCP+LSP</td>
<td class="org-left">Code intelligence bridge</td>
</tr>

<tr>
<td class="org-left">Python LSP</td>
<td class="org-left">LSP</td>
<td class="org-left">Static analysis and completion</td>
</tr>

<tr>
<td class="org-left">Claude Code</td>
<td class="org-left">-</td>
<td class="org-left">AI-assisted analysis and exploration</td>
</tr>
</tbody>
</table>


<a id="org8bed99c"></a>

# Getting Started

1.  Initial setup:

    # Create required directories
    make dirs
    
    # Generate configuration files from org sources
    make tangle
    
    # Set up GitHub CLI authentication for secrets
    gh auth login

1.  Set up secrets management:

    # Run the secrets setup script
    ./scripts/setup_secrets.sh
    
    # Or manually update the GitHub secrets with your actual keys
    gh secret edit GH_PAT
    gh secret edit ANTHROPIC_API_KEY

1.  Build and run the container:

    # Build the Docker/Podman image
    make build
    
    # Run the container (automatically retrieves secrets)
    make run

1.  Test the environment:

    # Verify MCP server connectivity
    make test
    
    # Try analyzing an algorithm (after creating one)
    make analyze ALGO=fibonacci


<a id="orgce7ab36"></a>

# Command Reference

Run `make` or `gmake help` for a full list of available commands. 

Key commands for getting started:

-   `make build` - Build the Docker/Podman image
-   `make run` - Start container with mounted volumes
-   `make test` - Verify MCP server connectivity
-   `make analyze ALGO=fibonacci` - Analyze algorithm via MCP

## Using MCP Run Python Directly

You can interact with the MCP Run Python server directly using Deno. The correct JSON-RPC format for calling Python code is:

```json
{
  "jsonrpc": "2.0",
  "method": "tools/call",
  "params": {
    "name": "run_python_code",
    "arguments": {
      "python_code": "print(\"Hello, MCP!\")"
    }
  },
  "id": 1
}
```

Example usage:

```bash
echo '{"jsonrpc": "2.0", "method": "tools/call", "params": {"name": "run_python_code", "arguments": {"python_code": "result = 40 + 2\nprint(f\"The answer is: {result}\")\nresult"}}, "id": 1}' | \
deno run -N -R=node_modules -W=node_modules --node-modules-dir=auto \
--allow-read=. jsr:@pydantic/mcp-run-python stdio | jq
```

To access the algorithms in this repository, use:

```python
import sys
sys.path.append('.')
from algorithms.factorial import factorial_iterative

result = factorial_iterative(5)
print(f"Factorial of 5 is {result}")
```

Before committing changes, always run:

1.  `gmake help` - Verify all targets are documented
2.  `gmake lint` - Ensure code passes style checks
3.  `gmake test` - Verify functionality works

The project uses literate programming with org-mode. Configuration files are generated from
`env-setup.org` using the tangle process. If you modify generated files directly, use detangle
to propagate changes back to the org source.


<a id="org58f25b4"></a>

## Scripts

Utility scripts are available in the `scripts/` directory. Scripts include setup tools, MCP management, and analysis utilities. Use \`ls -la scripts/\` to see all available scripts.


<a id="orga37124b"></a>

# Development Workflow

This project follows a literate programming approach with org-mode. Key development files:

-   `env-setup.org` - Contains configuration for Emacs, VSCode, and Claude Code
-   `SETUP.org` - Contains general setup instructions and documentation
-   `Makefile` - Provides automation for common development tasks

When making changes:

1.  For configuration: Edit the org files and run `make tangle`
2.  For implementation: Follow standard Git workflow with conventional commits
3.  For testing: Add algorithms to `algorithms/` directory and use `make analyze`


<a id="org053b0e6"></a>

# Project Goals

1.  Demonstrate secure integration between MCP and LSP
2.  Provide a reference architecture for isolated AI code analysis
3.  Enable exploration of Python algorithm implementations
4.  Support multiple client interfaces while maintaining security


<a id="org94e6855"></a>

# References

-   [Anthropic: Introducing the Model Context Protocol](https://www.anthropic.com/news/model-context-protocol) - Official announcement of MCP as an open standard for connecting AI assistants to data sources.

-   [Model Context Protocol Documentation](https://modelcontextprotocol.io/introduction) - Comprehensive documentation explaining MCP concepts, architecture, and implementation details.

-   [Model Context Protocol GitHub](https://github.com/modelcontextprotocol) - Official GitHub organization with protocol specification, SDKs, and reference implementations.

-   [Anthropic MCP Documentation](https://docs.anthropic.com/en/docs/agents-and-tools/mcp) - Integration guides and best practices for using MCP with Claude.

-   [Microsoft MultilspyLSP](https://github.com/microsoft/multilspy) - The Python library for creating language server clients that powers our LSP integration.

-   [Python LSP Server](https://github.com/python-lsp/python-lsp-server) - The Python implementation of the Language Server Protocol used in this project.

-   [Language Server Protocol](https://microsoft.github.io/language-server-protocol/) - Background on the LSP standard that enables editor-agnostic language intelligence.

-   [MultilspyLSP MCP Server](https://playbooks.com/mcp/asimihsan-multilspy-lsp) - Reference implementation of an MCP server that provides LSP capabilities.

-   [Hacker News: Model Context Protocol Discussion](https://news.ycombinator.com/item?id=43691230) - Community discussion about MCP, including perspectives on security considerations and integration approaches.

-   [Simon Willison: MCP Run Python](https://simonwillison.net/2025/Apr/18/mcp-run-python/) - Detailed exploration of the MCP run-python implementation and its practical applications.


<a id="org1419c4d"></a>

# License

MIT License

