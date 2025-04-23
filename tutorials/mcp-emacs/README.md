# MCP Emacs Integration

This tutorial provides a comprehensive guide to using the Model Context Protocol (MCP) with Emacs, enabling isolated Python code execution and multi-server communication.

## Overview

MCP enables secure, isolated execution of Python code directly within Emacs, with the following key benefits:

- **Security**: Run untrusted code in an isolated Pyodide environment
- **Persistence**: Store and retrieve data between executions
- **Org-mode integration**: Use with org-babel for literate programming
- **Multiple services**: Python execution, memory storage, filesystem access, and GitHub operations

## Quick Start

1. **Setup environment**:

```bash
# Install dependencies
./check-dependencies.sh

# Setup config files
./setup-mcp.sh
```

2. **Add to Emacs configuration**:

```elisp
;; Add to your init.el or .emacs file
(add-to-list 'load-path "~/.emacs.d/lisp/")
(require 'mcp)

;; Enable for org-babel
(with-eval-after-load 'org
  (add-to-list 'org-babel-load-languages '(mcp-python . t))
  (org-babel-do-load-languages 'org-babel-load-languages org-babel-load-languages))
```

3. **Start using MCP**:

```elisp
;; Start the Python server
(mcp-start-server 'run-python)

;; Run isolated Python code
(mcp-run-python-code "
import numpy as np
result = np.array([1, 2, 3]) ** 2
print(f'Result: {result}')
result.sum()
")
```

## Features

- Isolated Python execution using Pyodide (WebAssembly)
- Key-value store for persistent data with Memory server
- Sandboxed filesystem operations
- GitHub API access
- Org-babel integration for literate programming

## Examples

See the `examples/` directory for:
- Basic usage
- Custom functions
- Org-babel integration
- Cross-server communication

## System Requirements

- Emacs 27.1+
- Deno (for Python execution)
- Node.js and npm (for Memory, Filesystem, GitHub servers)

## License

MIT License

## Author

Jason Walsh <jwalsh@defrecord.com>