#!/bin/bash
# Run the bypass test through Claude CLI, which uses MCP

echo "Running bypass test through Claude CLI..."

# Create results directory
mkdir -p results

# Read the content of the Python file
PYTHON_CODE=$(cat bypass_sandbox_attempt.py)

# Run it through Claude
cat bypass_sandbox_attempt.py | claude -p "Run this Python code using the pydantic-run-python MCP server. Only provide the raw output without any additional commentary." > results/bypass_attempt_results_mcp.json

echo "Results saved to results/bypass_attempt_results_mcp.json"