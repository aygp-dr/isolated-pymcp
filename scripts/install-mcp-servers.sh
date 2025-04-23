#!/bin/bash
# install-mcp-servers.sh - Install MCP servers for use with Claude Code

set -e

echo "Installing MCP servers..."

# Check and install Filesystem MCP server
echo "Checking Filesystem MCP server..."
if ! claude mcp list | grep -q "filesystem"; then
    echo "Installing Filesystem MCP server..."
    claude mcp add filesystem -- npx -y @modelcontextprotocol/server-filesystem ~/projects
else
    echo "Filesystem MCP server already installed."
fi

# Check and install Memory MCP server
echo "Checking Memory MCP server..."
if ! claude mcp list | grep -q "memory"; then
    echo "Installing Memory MCP server..."
    claude mcp add memory -- npx -y @modelcontextprotocol/server-memory
else
    echo "Memory MCP server already installed."
fi

# Install prerequisites for Python Runner
echo "Installing prerequisites..."
npm install

# Check and install Python Runner MCP server
echo "Checking Python Runner MCP server..."
if ! claude mcp list | grep -q "python-runner"; then
    echo "Installing Python Runner MCP server..."
    claude mcp add python-runner -- \
        deno run -N -R=node_modules -W=node_modules --node-modules-dir=auto \
        jsr:@pydantic/mcp-run-python stdio
else
    echo "Python Runner MCP server already installed."
fi

echo "MCP servers installation complete."
echo ""
echo "To verify the installation, run: claude mcp list"
echo "To start servers, run: ./scripts/start-mcp-servers.sh"
