#!/bin/bash

echo "=== Testing MCP Run Python Setup ==="
echo

# Check Deno installation
echo "Checking Deno installation:"
if command -v deno &> /dev/null; then
    echo "✅ Deno is installed:"
    deno --version
else
    echo "❌ Deno is not installed. Please install Deno first."
    exit 1
fi

# Check if Node modules directory exists
echo
echo "Checking Node modules directory:"
if [ -d "node_modules" ]; then
    echo "✅ node_modules directory exists"
else
    echo "⚠️ node_modules directory not found. Creating it..."
    mkdir -p node_modules
fi

# Test running a simple command via MCP
echo
echo "Testing MCP Run Python with a simple 'hello world' example:"
echo '{"jsonrpc": "2.0", "method": "tools/call", "params": {"name": "run_python_code", "arguments": {"python_code": "print(\"Hello, MCP Run Python!\")\nprint(\"2 + 2 =\", 2 + 2)"}}, "id": 1}' | \
deno run -N -R=node_modules -W=node_modules --node-modules-dir=auto --allow-read=. jsr:@pydantic/mcp-run-python stdio

echo
echo "Testing complete!"