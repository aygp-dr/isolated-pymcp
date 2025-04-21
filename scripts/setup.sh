#!/usr/bin/env bash
# Setup script for isolated-pymcp environment

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}=====================================${NC}"
echo -e "${BLUE}isolated-pymcp Setup${NC}"
echo -e "${BLUE}=====================================${NC}\n"

# Check if Docker or Podman is available
DOCKER_CMD=$(command -v podman || command -v docker)
if [ -z "$DOCKER_CMD" ]; then
    echo -e "${RED}Error: Neither Docker nor Podman is installed.${NC}"
    echo "Please install Docker or Podman and try again."
    exit 1
fi

echo -e "${GREEN}Using container runtime: $DOCKER_CMD${NC}"

# Create necessary directories
echo -e "${BLUE}Creating project directories...${NC}"
mkdir -p algorithms
mkdir -p scripts
mkdir -p tests
mkdir -p data/{memory,filesystem,github}
mkdir -p analysis_results
mkdir -p config
mkdir -p emacs

echo -e "${GREEN}Project directories created${NC}"

# Create .envrc file if it doesn't exist
if [ ! -f ".envrc" ]; then
    echo -e "${BLUE}Creating .envrc file...${NC}"
    cp .envrc.example .envrc
    echo -e "${YELLOW}Please edit .envrc with your API keys${NC}"
else
    echo -e "${GREEN}.envrc file already exists${NC}"
fi

# Build the Docker image
echo -e "${BLUE}Building Docker image...${NC}"
$DOCKER_CMD build -t isolated-pymcp .

echo -e "${GREEN}Setup complete!${NC}"
echo -e "${BLUE}To run the container:${NC}"
echo -e "${YELLOW}make run${NC}"
echo -e "${BLUE}To test the MCP servers:${NC}"
echo -e "${YELLOW}make test${NC}"
