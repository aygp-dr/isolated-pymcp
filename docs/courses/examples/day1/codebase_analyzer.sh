#!/usr/bin/env bash
# Example script to analyze a codebase with Claude Code in an isolated environment

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== Claude Code Codebase Analyzer ===${NC}"

# Check if ANTHROPIC_API_KEY is set
if [ -z "${ANTHROPIC_API_KEY}" ]; then
  echo -e "${YELLOW}Warning: ANTHROPIC_API_KEY environment variable not set.${NC}"
  echo -e "Using AWS Bedrock instead? [y/N] "
  read -r use_bedrock
  
  if [[ "$use_bedrock" =~ ^[Yy]$ ]]; then
    export CLAUDE_CODE_USE_BEDROCK=1
    echo -e "${GREEN}Using AWS Bedrock for Claude Code.${NC}"
  else
    echo -e "${YELLOW}Please set ANTHROPIC_API_KEY or configure AWS credentials.${NC}"
    exit 1
  fi
fi

# Verify Claude Code installation
if ! command -v claude &> /dev/null; then
  echo -e "${YELLOW}Claude Code not found. Installing...${NC}"
  npm install -g @anthropic-ai/claude-code
fi

# Check version
version=$(claude --version)
echo -e "${GREEN}Using ${version}${NC}"

# Get the repository path
if [ -z "$1" ]; then
  repo_path=$(pwd)
  echo -e "${BLUE}Analyzing current directory: ${repo_path}${NC}"
else
  repo_path=$1
  echo -e "${BLUE}Analyzing repository: ${repo_path}${NC}"
fi

# Change to the repository directory
cd "$repo_path"

# Generate Mermaid diagram of the codebase structure
echo -e "\n${BLUE}Generating Mermaid diagram of codebase structure...${NC}"
echo -e "This may take a moment depending on the size of the codebase.\n"

# Run Claude Code to analyze the codebase
claude "Analyze this codebase and create a Mermaid diagram showing:
1. The main components and their relationships
2. Key file dependencies
3. The overall architecture
Make the diagram concise but informative." | tee codebase-diagram.md

echo -e "\n${GREEN}Analysis complete! Results saved to codebase-diagram.md${NC}"

# Optionally run additional analyses
echo -e "\n${BLUE}Would you like to run additional analyses? [y/N]${NC} "
read -r additional

if [[ "$additional" =~ ^[Yy]$ ]]; then
  echo -e "\n${BLUE}Running code quality analysis...${NC}"
  claude "Analyze this codebase for code quality issues, potential bugs, and security concerns. Provide a concise summary." | tee code-quality-report.md
  
  echo -e "\n${BLUE}Generating documentation improvements...${NC}"
  claude "Review this codebase and suggest documentation improvements. Focus on unclear areas and missing documentation." | tee documentation-suggestions.md
  
  echo -e "\n${GREEN}All analyses complete!${NC}"
  echo -e "Results saved to:"
  echo -e "- codebase-diagram.md"
  echo -e "- code-quality-report.md"
  echo -e "- documentation-suggestions.md"
fi

echo -e "\n${BLUE}=== Analysis Complete ===${NC}"