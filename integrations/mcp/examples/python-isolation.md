# Python Isolation with MCP

This document demonstrates how to use the Model Context Protocol (MCP) to run Python code in an isolated environment.

## What is Isolation?

When running untrusted or experimental code, isolation provides a layer of security by restricting:
- File system access
- Network access
- Process creation
- System command execution

The MCP Run Python server uses Pyodide, a version of Python that runs in WebAssembly, to provide this isolation.

## Example: Safe Code Execution

```python
# This code runs in an isolated environment
import numpy as np
import matplotlib.pyplot as plt

# Generate some data
x = np.linspace(0, 10, 100)
y = np.sin(x)

# Create a plot
plt.figure(figsize=(8, 4))
plt.plot(x, y)
plt.title('Sine Wave')
plt.xlabel('x')
plt.ylabel('sin(x)')

# Instead of plt.show(), which won't work in isolation, 
# we can return a base64 encoded image
from io import BytesIO
import base64

buf = BytesIO()
plt.savefig(buf, format='png')
buf.seek(0)
img_str = base64.b64encode(buf.read()).decode('utf-8')

# Return the image data
f"data:image/png;base64,{img_str}"
```

## Limitations of Isolation

The isolated environment has some limitations:

1. **No filesystem access** - You can't read or write files on the host system
2. **No network access** - You can't make HTTP requests or open network connections
3. **Limited library support** - Only libraries available in Pyodide can be used
4. **Memory constraints** - The environment has limited memory
5. **Execution time limits** - Long-running calculations may time out

## Running the Example

### Using the Shell Helper

```bash
source integrations/mcp/environments/shell-helpers.sh
start_mcp_server runpython

# Save the example code to a file
cat > example.py << 'EOF'
import numpy as np
import matplotlib.pyplot as plt
# ... rest of the example code ...
EOF

# Run the code
run_python "$(cat example.py)"
```

### Using Emacs

```elisp
;; Load the MCP Emacs integration
(require 'mcp)

;; Start the MCP Run Python server
(mcp-start-server 'run-python)

;; Open a file with the example code and select the region
;; Then run:
M-x mcp-run-python-region
```

### Using Claude Desktop or Claude Code

1. Configure Claude with the appropriate MCP configuration
2. Start a new conversation
3. Ask Claude to run the example code
4. Claude will use the MCP Run Python server to execute the code in isolation
5. Results will be displayed in the conversation
