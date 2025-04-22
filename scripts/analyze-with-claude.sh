#!/usr/bin/env bash
# Analyze algorithm with Claude Code

set -e

# Colors for output
BLUE='\033[0;34m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

ALGORITHM=$1
CODE_FILE="${ALGORITHM:-fibonacci}.py"
RUN_PYTHON_URL="http://localhost:${MCP_RUNPYTHON_PORT:-3001}"
LSP_URL="http://localhost:${MCP_MULTILSPY_PORT:-3005}"
OUTPUT_DIR="analysis_results"

# Input validation functions
validate_algorithm_name() {
    local algo="$1"
    # Only allow alphanumeric and underscore characters
    if ! [[ "$algo" =~ ^[a-zA-Z0-9_]+$ ]]; then
        echo -e "${RED}Error: Algorithm name can only contain letters, numbers, and underscores${NC}"
        return 1
    fi
    return 0
}

# Check if algorithm parameter is provided
if [ -z "$ALGORITHM" ]; then
    echo -e "${RED}Usage: $0 <algorithm>${NC}"
    echo "Example: $0 fibonacci"
    exit 1
fi

# Validate algorithm name
if ! validate_algorithm_name "$ALGORITHM"; then
    echo "Available algorithms:"
    ls -1 algorithms/ | grep -E "\.py$" | sed 's/\.py$//'
    exit 1
fi

# Check if code file exists (using validated input)
if [ ! -f "algorithms/$CODE_FILE" ]; then
    echo -e "${RED}Error: File algorithms/$CODE_FILE not found${NC}"
    echo "Available algorithms:"
    ls -1 algorithms/ | grep -E "\.py$" | sed 's/\.py$//'
    exit 1
fi

# Create output directory
mkdir -p "$OUTPUT_DIR"

echo -e "${BLUE}Analyzing $ALGORITHM implementation...${NC}"

# Step 1: Get LSP analysis
echo -e "${BLUE}Getting LSP analysis...${NC}"
curl -s -X POST "$LSP_URL/execute" \
    -H "Content-Type: application/json" \
    -d "{
        \"name\": \"analyze\",
        \"parameters\": {
            \"code\": $(cat "algorithms/$CODE_FILE" | jq -Rs .),
            \"language\": \"python\"
        }
    }" | jq '.result' > "$OUTPUT_DIR/${ALGORITHM}_lsp.json"

echo -e "${GREEN}LSP analysis saved to $OUTPUT_DIR/${ALGORITHM}_lsp.json${NC}"

# Step 2: Execute code
echo -e "${BLUE}Executing code...${NC}"
curl -s -X POST "$RUN_PYTHON_URL/execute" \
    -H "Content-Type: application/json" \
    -d "{
        \"name\": \"run\",
        \"parameters\": {
            \"code\": $(cat "algorithms/$CODE_FILE" | jq -Rs .)
        }
    }" | jq '.result' > "$OUTPUT_DIR/${ALGORITHM}_execution.json"

echo -e "${GREEN}Execution results saved to $OUTPUT_DIR/${ALGORITHM}_execution.json${NC}"

# Step 3: Create prompt for Claude
echo -e "${BLUE}Creating analysis prompt...${NC}"

cat > "$OUTPUT_DIR/${ALGORITHM}_prompt.md" << EOF
# Code Analysis Request

Please analyze this Python implementation of $ALGORITHM.

## Source Code
\`\`\`python
$(cat "algorithms/$CODE_FILE")
\`\`\`

## LSP Analysis
\`\`\`json
$(cat "$OUTPUT_DIR/${ALGORITHM}_lsp.json")
\`\`\`

## Execution Results
\`\`\`
$(cat "$OUTPUT_DIR/${ALGORITHM}_execution.json")
\`\`\`

## Analysis Questions

1. What is the algorithmic complexity of this implementation?
2. Are there any bugs or inefficiencies in the code?
3. How could this implementation be improved?
4. What are the trade-offs between different approaches to this algorithm?
5. Is there anything interesting or unique about this implementation?
EOF

echo -e "${GREEN}Analysis prompt saved to $OUTPUT_DIR/${ALGORITHM}_prompt.md${NC}"

# Step 4: Run Claude Code CLI (if available)
if command -v claude-code &> /dev/null; then
    echo -e "${BLUE}Running Claude Code CLI...${NC}"
    claude-code analyze \
        --prompt-file "$OUTPUT_DIR/${ALGORITHM}_prompt.md" \
        --output-file "$OUTPUT_DIR/${ALGORITHM}_analysis.md"
    
    echo -e "${GREEN}Analysis complete! Results saved to $OUTPUT_DIR/${ALGORITHM}_analysis.md${NC}"
else
    echo -e "${YELLOW}Claude Code CLI not found.${NC}"
    echo -e "To analyze manually, use the prompt at: $OUTPUT_DIR/${ALGORITHM}_prompt.md"
fi

echo -e "${GREEN}Analysis process complete${NC}"
