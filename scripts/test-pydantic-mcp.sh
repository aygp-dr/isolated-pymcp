#!/usr/bin/env bash
# Test Pydantic MCP run-python server

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}Testing Pydantic MCP run-python server...${NC}"

# Simple addition test using the server
echo -e "${BLUE}Running simple addition test...${NC}"
RESULT=$(echo '{"jsonrpc": "2.0", "method": "tools/call", "params": {"name": "run_python_code", "arguments": {"python_code": "result = 40 + 2\nprint(f\"The answer is: {result}\")\nresult"}}, "id": 1}' | \
deno run -N -R=node_modules -W=node_modules --node-modules-dir=auto \
--allow-read=. jsr:@pydantic/mcp-run-python stdio | jq '.result.content[0].text' -r)

# Check if the result is as expected
if [[ "$RESULT" == *"42"* ]]; then
    echo -e "${GREEN}Test successful! Server returned: $RESULT${NC}"
else
    echo -e "${RED}Test failed. Expected 42, got: $RESULT${NC}"
    exit 1
fi

echo -e "${GREEN}Pydantic MCP run-python server is working correctly!${NC}"