#!/bin/bash
# Test LSP Connection

# Create a temporary file
echo 'def example_function(param):
    """Example function that does something."""
    return param.upper()
' > /tmp/test.py

# Send LSP initialization request to Python LSP server
echo '{"jsonrpc": "2.0", "id": 1, "method": "initialize", "params": {"processId": null, "rootUri": null, "capabilities": {}}}' | pylsp

echo "If you see a JSON response above, the connection is working!"
