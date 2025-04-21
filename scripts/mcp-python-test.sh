#!/usr/bin/env bash
# Test MCP Python servers

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=====================================${NC}"
echo -e "${BLUE}MCP Python Tooling Test${NC}"
echo -e "${BLUE}=====================================${NC}\n"

# Configuration
RUN_PYTHON_URL="http://localhost:${MCP_RUNPYTHON_PORT:-3001}"
LSP_URL="http://localhost:${MCP_MULTILSPY_PORT:-3005}"
TEMP_DIR="/tmp/mcp_python_test"

# Create temporary directory
mkdir -p $TEMP_DIR

# Test Run-Python server
test_run_python() {
    echo -e "\n${BLUE}Testing Run-Python MCP Server...${NC}"
    
    # Create test Python file
    cat > $TEMP_DIR/fibonacci.py << EOF
def fibonacci(n):
    if n <= 1:
        return n
    return fibonacci(n-1) + fibonacci(n-2)

print([fibonacci(i) for i in range(10)])
EOF
    
    echo -e "Sending test code to Run-Python server..."
    
    # Execute the code using the server
    response=$(curl -s -X POST "$RUN_PYTHON_URL/execute" \
        -H "Content-Type: application/json" \
        -d "{
            \"name\": \"run\",
            \"parameters\": {
                \"code\": $(cat $TEMP_DIR/fibonacci.py | jq -Rs .)
            }
        }")
    
    # Check response
    if echo "$response" | jq -e '.result' > /dev/null; then
        echo -e "${GREEN}✓ Run-Python server executed code successfully${NC}"
        echo -e "Output:"
        echo "$response" | jq -r '.result'
        return 0
    else
        echo -e "${RED}✗ Run-Python server failed to execute code${NC}"
        echo -e "Error response:"
        echo "$response" | jq .
        return 1
    fi
}

# Test LSP server
test_lsp() {
    echo -e "\n${BLUE}Testing LSP MCP Server...${NC}"
    
    # Create test Python file with intentional code completion scenario
    cat > $TEMP_DIR/completion_test.py << EOF
def calculate_sum(a, b):
    return a + b

result = calculate_
EOF
    
    echo -e "Requesting code completion from LSP server..."
    
    # Request completions at a specific position
    response=$(curl -s -X POST "$LSP_URL/execute" \
        -H "Content-Type: application/json" \
        -d "{
            \"name\": \"completion\",
            \"parameters\": {
                \"code\": $(cat $TEMP_DIR/completion_test.py | jq -Rs .),
                \"language\": \"python\",
                \"line\": 3,
                \"character\": 17
            }
        }")
    
    # Check response
    if echo "$response" | jq -e '.result' > /dev/null; then
        echo -e "${GREEN}✓ LSP server returned completions${NC}"
        echo -e "Suggestions:"
        echo "$response" | jq '.result.items[].label' 2>/dev/null || echo "No completion items found"
        return 0
    else
        echo -e "${RED}✗ LSP server failed to provide completions${NC}"
        echo -e "Error response:"
        echo "$response" | jq .
        return 1
    fi
}

# Test Python code analysis
test_code_analysis() {
    echo -e "\n${BLUE}Testing Python Code Analysis...${NC}"
    
    # Create test Python file with a bug
    cat > $TEMP_DIR/analysis_test.py << EOF
def factorial(n):
    if n <= 1:
        return 1
    return n * factorial(n-1)

# Bug: Calling with a string instead of an integer
result = factorial("5")
print(result)
EOF
    
    echo -e "Requesting code analysis from LSP server..."
    
    # Request diagnostics
    response=$(curl -s -X POST "$LSP_URL/execute" \
        -H "Content-Type: application/json" \
        -d "{
            \"name\": \"analyze\",
            \"parameters\": {
                \"code\": $(cat $TEMP_DIR/analysis_test.py | jq -Rs .),
                \"language\": \"python\"
            }
        }")
    
    # Check response
    if echo "$response" | jq -e '.result' > /dev/null; then
        echo -e "${GREEN}✓ LSP server analyzed code${NC}"
        echo -e "Diagnostics:"
        echo "$response" | jq '.result.diagnostics[]?.message' 2>/dev/null || echo "No diagnostics found"
        return 0
    else
        echo -e "${RED}✗ LSP server failed to analyze code${NC}"
        echo -e "Error response:"
        echo "$response" | jq .
        return 1
    fi
}

# Run the tests
echo -e "${BLUE}Starting MCP Python tooling tests...${NC}"

# Run tests and track results
PASSED=0
FAILED=0

if test_run_python; then
    PASSED=$((PASSED+1))
else
    FAILED=$((FAILED+1))
fi

if test_lsp; then
    PASSED=$((PASSED+1))
else
    FAILED=$((FAILED+1))
fi

if test_code_analysis; then
    PASSED=$((PASSED+1))
else
    FAILED=$((FAILED+1))
fi

# Summary
echo -e "\n${BLUE}=====================================${NC}"
echo -e "${BLUE}Test Summary${NC}"
echo -e "${BLUE}=====================================${NC}"
echo -e "Tests run: $((PASSED+FAILED))"
echo -e "${GREEN}Passed: $PASSED${NC}"
echo -e "${RED}Failed: $FAILED${NC}"

if [ $FAILED -eq 0 ]; then
    echo -e "\n${GREEN}All MCP Python tooling tests passed successfully!${NC}"
    exit 0
else
    echo -e "\n${RED}Some tests failed.${NC}"
    echo -e "Check the output above for details."
    exit 1
fi
