#!/usr/bin/env bash
# Benchmark Python algorithms

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}=====================================${NC}"
echo -e "${BLUE}Algorithm Benchmarks${NC}"
echo -e "${BLUE}=====================================${NC}\n"

# Configuration
RUN_PYTHON_URL="http://localhost:${MCP_RUNPYTHON_PORT:-3001}"
OUTPUT_DIR="benchmark_results"

# Create output directory
mkdir -p "$OUTPUT_DIR"

# Function to benchmark an algorithm
benchmark_algorithm() {
    local algorithm=$1
    local code_file="algorithms/${algorithm}.py"
    
    if [ ! -f "$code_file" ]; then
        echo -e "${RED}Error: File $code_file not found${NC}"
        return 1
    fi
    
    echo -e "${BLUE}Benchmarking $algorithm implementation...${NC}"
    
    # Execute the code using the MCP server
    curl -s -X POST "$RUN_PYTHON_URL/execute" \
        -H "Content-Type: application/json" \
        -d "{
            \"name\": \"run\",
            \"parameters\": {
                \"code\": $(cat "$code_file" | jq -Rs .)
            }
        }" | jq '.result' > "$OUTPUT_DIR/${algorithm}_benchmark.txt"
    
    echo -e "${GREEN}Benchmark results saved to $OUTPUT_DIR/${algorithm}_benchmark.txt${NC}"
    
    # Display the results
    echo -e "${YELLOW}Results:${NC}"
    cat "$OUTPUT_DIR/${algorithm}_benchmark.txt"
    echo
}

# Run benchmarks for all algorithms
echo -e "${BLUE}Running benchmarks for all algorithms...${NC}"

benchmark_algorithm "fibonacci"
benchmark_algorithm "factorial"
benchmark_algorithm "primes"

echo -e "${GREEN}All benchmarks complete!${NC}"
