#!/usr/bin/env bash
# Update MCP servers

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}=====================================${NC}"
echo -e "${BLUE}Updating MCP Servers${NC}"
echo -e "${BLUE}=====================================${NC}\n"

# Check if pip is available
if ! command -v pip &> /dev/null; then
    echo -e "${RED}Error: pip not found${NC}"
    echo "Please install pip and try again."
    exit 1
fi

# Update core MCP packages
echo -e "${BLUE}Updating model-context-protocol...${NC}"
pip install --upgrade model-context-protocol

echo -e "${BLUE}Updating python-lsp-server...${NC}"
pip install --upgrade 'python-lsp-server[all]'

echo -e "${BLUE}Updating multilspy...${NC}"
pip install --upgrade multilspy

echo -e "${BLUE}Updating debugpy...${NC}"
pip install --upgrade debugpy

# Check if we're in a container
if [ -f "/.dockerenv" ]; then
    echo -e "${GREEN}MCP servers updated inside container${NC}"
    echo -e "${YELLOW}To apply updates, rebuild the Docker image:${NC}"
    echo -e "  make build"
else
    echo -e "${GREEN}MCP servers updated in local environment${NC}"
    echo -e "${YELLOW}To apply updates to container, rebuild:${NC}"
    echo -e "  make build"
fi

echo -e "${GREEN}Update complete!${NC}"
