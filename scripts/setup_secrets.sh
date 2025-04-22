#!/usr/bin/env bash
# Setup secrets for isolated-pymcp environment
# This script fetches required API keys from GitHub Secrets using the GitHub CLI

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}=====================================${NC}"
echo -e "${BLUE}Setting up secrets for isolated-pymcp${NC}"
echo -e "${BLUE}=====================================${NC}\n"

# Check if GitHub CLI is installed and authenticated
if ! command -v gh &> /dev/null; then
    echo -e "${RED}Error: GitHub CLI not installed.${NC}"
    echo "Please install GitHub CLI (gh) and try again."
    exit 1
fi

# Check if authenticated
if ! gh auth status &> /dev/null; then
    echo -e "${RED}Error: GitHub CLI not authenticated.${NC}"
    echo "Please run 'gh auth login' and try again."
    exit 1
fi

echo -e "${BLUE}Fetching secrets from GitHub...${NC}"

# Create .env file
ENV_FILE=".env"
echo "# Auto-generated secrets file for isolated-pymcp" > $ENV_FILE
echo "# Generated on $(date)" >> $ENV_FILE
echo "" >> $ENV_FILE

# Fetch GitHub token
if gh secret list | grep -q "GH_PAT"; then
    echo -e "${BLUE}Fetching GitHub Personal Access Token...${NC}"
    GH_PAT=$(gh secret get GH_PAT 2>/dev/null || echo "")
    if [ -n "$GH_PAT" ]; then
        echo "GITHUB_TOKEN=$GH_PAT" >> $ENV_FILE
        echo -e "${GREEN}GitHub token added to $ENV_FILE${NC}"
    else
        echo -e "${YELLOW}Warning: Could not retrieve GitHub token${NC}"
        echo "# GITHUB_TOKEN=your_github_token_here" >> $ENV_FILE
    fi
fi

# Fetch Anthropic API key
if gh secret list | grep -q "ANTHROPIC_API_KEY"; then
    echo -e "${BLUE}Fetching Anthropic API Key...${NC}"
    ANTHROPIC_KEY=$(gh secret get ANTHROPIC_API_KEY 2>/dev/null || echo "")
    if [ -n "$ANTHROPIC_KEY" ]; then
        echo "ANTHROPIC_API_KEY=$ANTHROPIC_KEY" >> $ENV_FILE
        echo -e "${GREEN}Anthropic API key added to $ENV_FILE${NC}"
    else
        echo -e "${YELLOW}Warning: Could not retrieve Anthropic API key${NC}"
        echo "# ANTHROPIC_API_KEY=your_anthropic_api_key_here" >> $ENV_FILE
    fi
fi

# Add other MCP environment variables
echo "" >> $ENV_FILE
echo "# MCP Server Ports" >> $ENV_FILE
echo "MCP_RUNPYTHON_PORT=3001" >> $ENV_FILE
echo "MCP_MEMORY_PORT=3002" >> $ENV_FILE
echo "MCP_FILESYSTEM_PORT=3003" >> $ENV_FILE
echo "MCP_GITHUB_PORT=3004" >> $ENV_FILE
echo "MCP_MULTILSPY_PORT=3005" >> $ENV_FILE
echo "MCP_PYTHONLSP_PORT=3006" >> $ENV_FILE

echo -e "${GREEN}Secrets setup complete!${NC}"
echo -e "${BLUE}Created environment file: $ENV_FILE${NC}"
echo -e "${YELLOW}Note: If any secrets could not be retrieved, you'll need to edit $ENV_FILE manually.${NC}"