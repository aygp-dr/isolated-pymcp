#!/bin/bash
# check-mcp-setup.sh - Script to verify MCP setup

set -e

echo "Checking MCP setup..."

# Check if poetry is installed
if ! command -v poetry &> /dev/null; then
    echo "Poetry not found. Installing..."
    curl -sSL https://install.python-poetry.org | python3 -
fi

# Install MCP CLI if not already installed
echo "Ensuring MCP CLI is installed..."
poetry add "mcp[cli]"

# Run MCP setup check
echo "Running MCP setup check..."
poetry run python -m mcp.cli check

# Test run-python MCP server
echo "Testing MCP run-python server..."
poetry run python -m mcp.cli run-python --verify

echo "MCP setup check complete."