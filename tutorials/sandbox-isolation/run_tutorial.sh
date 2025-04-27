#!/bin/bash
# Main tutorial script

echo "===== MCP Sandbox Isolation Tutorial ====="
echo "This tutorial demonstrates the security boundaries of the Pydantic MCP Run Python server"
echo "by comparing the behavior of Python code when run directly on the host versus through"
echo "the MCP sandbox."
echo

# Setup
chmod +x *.sh
chmod +x *.py
mkdir -p results

# Run direct tests
echo "===== Running Tests Directly on Host System ====="
./run_direct_tests.sh

# Run MCP sandbox tests
echo -e "\n===== Running Tests Through MCP Sandbox ====="
./run_mcp_tests.sh

# Generate report
echo -e "\n===== Generating Comparison Report ====="
./generate_report.sh

echo -e "\n===== Tutorial Complete ====="
echo "The tutorial has demonstrated the security boundaries provided by the MCP sandbox."
echo "View the report at: results/isolation_report.md"
