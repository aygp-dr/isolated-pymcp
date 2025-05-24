#!/bin/bash
# Run sandbox bypass test through the MCP sandbox

echo "Running sandbox bypass test through the MCP sandbox..."

# Create results directory
mkdir -p results

# Use python to run the test through MCP
python3 -c "
import requests
import json

with open('bypass_sandbox_attempt.py', 'r') as f:
    code = f.read()

response = requests.post(
    'http://localhost:3010/run-python',
    json={
        'code': code,
        'dependencies': []
    }
)

with open('results/bypass_attempt_results_mcp.json', 'w') as f:
    f.write(response.text)

print('Response received:', response.status_code)
"

echo "Results saved to results/bypass_attempt_results_mcp.json"