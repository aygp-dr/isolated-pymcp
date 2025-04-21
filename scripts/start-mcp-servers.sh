#!/usr/bin/env bash
# Start MCP servers

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}Starting MCP servers...${NC}"

# Function to start a server
start_server() {
  local name=$1
  local command=$2
  local port=$3
  
  echo -e "${BLUE}Starting $name on port $port...${NC}"
  mkdir -p /home/mcp/data/logs
  $command > "/home/mcp/data/logs/${name}.log" 2>&1 &
  echo $! > "/home/mcp/data/logs/${name}.pid"
  echo -e "${GREEN}Started $name with PID $(cat /home/mcp/data/logs/${name}.pid)${NC}"
  
  # Wait for server to be ready
  local retries=0
  while ! curl -s "http://localhost:$port/health" > /dev/null 2>&1; do
    if (( retries >= 10 )); then
      echo "Warning: Unable to verify $name is healthy after 10 attempts"
      break
    fi
    sleep 1
    ((retries++))
  done
  
  if (( retries < 10 )); then
    echo -e "${GREEN}$name is ready${NC}"
  fi
}

# Start Core MCP servers
echo -e "${BLUE}Starting core MCP servers...${NC}"

# Run Python MCP server
start_server "run-python" "python -m model_context_protocol.run_python_server --port ${MCP_RUNPYTHON_PORT}" "${MCP_RUNPYTHON_PORT}"

# Memory server
start_server "memory" "python -m model_context_protocol.memory_server --port ${MCP_MEMORY_PORT}" "${MCP_MEMORY_PORT}"

# Filesystem server
start_server "filesystem" "python -m model_context_protocol.filesystem_server --port ${MCP_FILESYSTEM_PORT}" "${MCP_FILESYSTEM_PORT}"

# GitHub server (if token is provided)
if [ -n "${GITHUB_TOKEN}" ]; then
  start_server "github" "python -m model_context_protocol.github_server --port ${MCP_GITHUB_PORT}" "${MCP_GITHUB_PORT}"
fi

# MultilspyLSP server
start_server "multilspy" "python -m multilspy_lsp.server --port ${MCP_MULTILSPY_PORT}" "${MCP_MULTILSPY_PORT}"

echo -e "${GREEN}All MCP servers started successfully${NC}"

# Keep container running
echo -e "${BLUE}Servers are running. Use Ctrl+C to stop.${NC}"
tail -f /home/mcp/data/logs/*.log
