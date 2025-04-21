#!/usr/bin/env bash
# Cleanup script for isolated-pymcp environment

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}=====================================${NC}"
echo -e "${BLUE}isolated-pymcp Cleanup${NC}"
echo -e "${BLUE}=====================================${NC}\n"

# Check if Docker or Podman is available
DOCKER_CMD=$(command -v podman || command -v docker)
if [ -z "$DOCKER_CMD" ]; then
    echo -e "${RED}Error: Neither Docker nor Podman is installed.${NC}"
    exit 1
fi

# Stop and remove container if running
echo -e "${BLUE}Stopping container if running...${NC}"
$DOCKER_CMD stop isolated-pymcp 2>/dev/null || true
$DOCKER_CMD rm isolated-pymcp 2>/dev/null || true

# Remove temporary files
echo -e "${BLUE}Removing temporary files...${NC}"
rm -rf data/logs/*

# Ask before removing analysis results
read -p "Remove analysis results? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${BLUE}Removing analysis results...${NC}"
    rm -rf analysis_results/*
fi

# Ask before removing Docker image
read -p "Remove Docker image? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${BLUE}Removing Docker image...${NC}"
    $DOCKER_CMD rmi isolated-pymcp 2>/dev/null || true
fi

echo -e "${GREEN}Cleanup complete!${NC}"
