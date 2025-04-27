#!/usr/bin/env bash
# Start Pydantic MCP run-python server

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

PYDANTIC_MCP_PORT=${PYDANTIC_MCP_PORT:-3010}
NODE_MODULES_DIR=${NODE_MODULES_DIR:-"./node_modules"}
LOG_DIR="./data/logs"

echo -e "${BLUE}Starting Pydantic MCP run-python server on port ${PYDANTIC_MCP_PORT}...${NC}"

# Create log directory if it doesn't exist
mkdir -p ${LOG_DIR}

# Check if deno is installed
if ! command -v deno &> /dev/null; then
    echo -e "${YELLOW}Deno is not installed. Installing...${NC}"
    curl -fsSL https://deno.land/install.sh | sh
    export PATH="$HOME/.deno/bin:$PATH"
fi

# Create node_modules directory if it doesn't exist
mkdir -p ${NODE_MODULES_DIR}

# Start the server
echo -e "${BLUE}Starting Pydantic MCP run-python server in background...${NC}"
deno run \
  -N -R=${NODE_MODULES_DIR} -W=${NODE_MODULES_DIR} --node-modules-dir=auto \
  --allow-read=. --allow-net \
  jsr:@pydantic/mcp-run-python stdio > ${LOG_DIR}/pydantic-mcp.log 2>&1 &

# Store the PID
PID=$!
echo ${PID} > ${LOG_DIR}/pydantic-mcp.pid
echo -e "${GREEN}Pydantic MCP run-python server started with PID ${PID}${NC}"

# Quick warmup to ensure server is ready
echo -e "${BLUE}Warming up the server...${NC}"
deno run \
  -N -R=${NODE_MODULES_DIR} -W=${NODE_MODULES_DIR} --node-modules-dir=auto \
  --allow-read=. \
  jsr:@pydantic/mcp-run-python warmup

echo -e "${GREEN}Pydantic MCP run-python server ready at http://localhost:${PYDANTIC_MCP_PORT}${NC}"
echo -e "${BLUE}Use 'kill $(cat ${LOG_DIR}/pydantic-mcp.pid)' to stop the server${NC}"