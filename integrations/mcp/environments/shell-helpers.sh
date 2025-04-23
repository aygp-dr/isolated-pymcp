#!/bin/bash
# Shell helpers for MCP servers

# Configuration
MCP_RUNPYTHON_PORT=3001
MCP_MEMORY_PORT=3002
MCP_FILESYSTEM_PORT=3003
MCP_GITHUB_PORT=3004
MCP_BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

# Ensure required commands exist
check_requirements() {
  local missing_cmds=()
  
  for cmd in deno npx jq curl; do
    if ! command -v "$cmd" &> /dev/null; then
      missing_cmds+=("$cmd")
    fi
  done
  
  if [ ${#missing_cmds[@]} -gt 0 ]; then
    echo "Error: The following commands are required but missing: ${missing_cmds[*]}"
    echo "Please install them before using MCP shell helpers."
    return 1
  fi
  
  return 0
}

# Start MCP servers
start_mcp_server() {
  local server_type="$1"
  
  case "$server_type" in
    runpython|python)
      echo "Starting MCP Run Python server on port $MCP_RUNPYTHON_PORT..."
      deno run -N -R=node_modules -W=node_modules --node-modules-dir=auto \
        --allow-read="$MCP_BASE_DIR" jsr:@pydantic/mcp-run-python stdio > /tmp/mcp-runpython.log 2>&1 &
      echo $! > /tmp/mcp-runpython.pid
      ;;
    memory)
      echo "Starting MCP Memory server on port $MCP_MEMORY_PORT..."
      npx -y @modelcontextprotocol/server-memory > /tmp/mcp-memory.log 2>&1 &
      echo $! > /tmp/mcp-memory.pid
      ;;
    filesystem|fs)
      echo "Starting MCP Filesystem server on port $MCP_FILESYSTEM_PORT..."
      npx -y @modelcontextprotocol/server-filesystem > /tmp/mcp-filesystem.log 2>&1 &
      echo $! > /tmp/mcp-filesystem.pid
      ;;
    github|gh)
      echo "Starting MCP GitHub server on port $MCP_GITHUB_PORT..."
      npx -y @modelcontextprotocol/server-github > /tmp/mcp-github.log 2>&1 &
      echo $! > /tmp/mcp-github.pid
      ;;
    all)
      start_mcp_server runpython
      start_mcp_server memory
      start_mcp_server filesystem
      start_mcp_server github
      ;;
    *)
      echo "Unknown server type: $server_type"
      echo "Available types: runpython, memory, filesystem, github, all"
      return 1
      ;;
  esac
  
  return 0
}

# Stop MCP servers
stop_mcp_server() {
  local server_type="$1"
  
  case "$server_type" in
    runpython|python)
      if [ -f /tmp/mcp-runpython.pid ]; then
        echo "Stopping MCP Run Python server..."
        kill "$(cat /tmp/mcp-runpython.pid)" 2>/dev/null
        rm -f /tmp/mcp-runpython.pid
      fi
      ;;
    memory)
      if [ -f /tmp/mcp-memory.pid ]; then
        echo "Stopping MCP Memory server..."
        kill "$(cat /tmp/mcp-memory.pid)" 2>/dev/null
        rm -f /tmp/mcp-memory.pid
      fi
      ;;
    filesystem|fs)
      if [ -f /tmp/mcp-filesystem.pid ]; then
        echo "Stopping MCP Filesystem server..."
        kill "$(cat /tmp/mcp-filesystem.pid)" 2>/dev/null
        rm -f /tmp/mcp-filesystem.pid
      fi
      ;;
    github|gh)
      if [ -f /tmp/mcp-github.pid ]; then
        echo "Stopping MCP GitHub server..."
        kill "$(cat /tmp/mcp-github.pid)" 2>/dev/null
        rm -f /tmp/mcp-github.pid
      fi
      ;;
    all)
      stop_mcp_server runpython
      stop_mcp_server memory
      stop_mcp_server filesystem
      stop_mcp_server github
      ;;
    *)
      echo "Unknown server type: $server_type"
      echo "Available types: runpython, memory, filesystem, github, all"
      return 1
      ;;
  esac
  
  return 0
}

# Run Python code via MCP
run_python() {
  local code="$1"
  local port="${2:-$MCP_RUNPYTHON_PORT}"
  local request='{
    "jsonrpc": "2.0",
    "method": "tools/call",
    "params": {
      "name": "run_python_code",
      "arguments": {
        "python_code": "'"$code"'"
      }
    },
    "id": 1
  }'
  
  curl -s -X POST "http://localhost:$port" \
    -H "Content-Type: application/json" \
    -d "$request" | jq
}

# List available tools on an MCP server
list_mcp_tools() {
  local server_type="$1"
  local port
  
  case "$server_type" in
    runpython|python) port="$MCP_RUNPYTHON_PORT" ;;
    memory) port="$MCP_MEMORY_PORT" ;;
    filesystem|fs) port="$MCP_FILESYSTEM_PORT" ;;
    github|gh) port="$MCP_GITHUB_PORT" ;;
    *)
      echo "Unknown server type: $server_type"
      echo "Available types: runpython, memory, filesystem, github"
      return 1
      ;;
  esac
  
  local request='{
    "jsonrpc": "2.0",
    "method": "tools/list",
    "id": 1
  }'
  
  curl -s -X POST "http://localhost:$port" \
    -H "Content-Type: application/json" \
    -d "$request" | jq '.result.tools[] | {name, description}'
}

# Warmup the MCP Run Python server
warmup_mcp_python() {
  echo "Warming up MCP Run Python server..."
  run_python "print('Hello from MCP Python!')" > /dev/null
  echo "Warmup complete."
}

# Main entry point
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  # Script is being executed directly
  check_requirements || exit 1
  
  case "$1" in
    start)
      start_mcp_server "${2:-all}"
      ;;
    stop)
      stop_mcp_server "${2:-all}"
      ;;
    run)
      shift
      run_python "$*"
      ;;
    list)
      list_mcp_tools "${2:-runpython}"
      ;;
    warmup)
      warmup_mcp_python
      ;;
    *)
      echo "Usage: $0 {start|stop|run|list|warmup} [args...]"
      echo ""
      echo "Commands:"
      echo "  start [server]    Start MCP server(s) (default: all)"
      echo "  stop [server]     Stop MCP server(s) (default: all)"
      echo "  run <code>        Run Python code via MCP"
      echo "  list [server]     List tools on the specified server"
      echo "  warmup            Warm up the MCP Run Python server"
      echo ""
      echo "Server types: runpython, memory, filesystem, github, all"
      exit 1
      ;;
  esac
fi
