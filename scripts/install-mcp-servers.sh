#!/bin/bash
# install-mcp-servers.sh - Install MCP servers for use with Claude Code

set -e

echo "Installing MCP servers..."

# Install simple MCP servers first
echo "Installing Filesystem MCP server..."
claude mcp add filesystem

echo "Installing Memory MCP server..."
claude mcp add memory

echo "Installing Github MCP server..."
claude mcp add github

# Install LSP servers
echo "Installing Python LSP servers..."
claude mcp add multilspy
claude mcp add python-lsp

# Install prerequisites for Python Runner
echo "Installing prerequisites..."
npm install

# Install Python Runner MCP server
echo "Installing Python Runner MCP server..."
claude mcp add python-runner -- \
    deno run -N -R=node_modules -W=node_modules --node-modules-dir=auto \
    jsr:@pydantic/mcp-run-python stdio

echo "MCP servers installation complete."
echo ""
echo "To test the installation, run: claude mcp list"
echo "To start servers, run: ./scripts/start-mcp-servers.sh"