#!/usr/bin/env bash
# check-mcp-setup.sh - Script to verify MCP setup

set -e

echo "Checking MCP setup..."

# Check if UV is installed
if ! command -v uv &> /dev/null; then
    echo "UV not found. Installing..."
    curl -fsSL https://astral.sh/uv/install.sh | bash
fi

# Install MCP CLI if not already installed
echo "Ensuring MCP CLI is installed with Python 3.11..."
uv pip install --python=3.11 "mcp[cli]"

# Run MCP setup check
echo "Running MCP setup check..."
uv run --python=3.11 -m mcp.cli check

# Test run-python MCP server
echo "Testing MCP run-python server..."
uv run --python=3.11 -m mcp.cli run-python --verify

echo "MCP setup check complete."