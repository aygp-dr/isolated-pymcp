#!/usr/bin/env bash
# Tangle SETUP.org to generate all project files
# Author: Claude Code (for Aidan Pace)

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}=====================================${NC}"
echo -e "${BLUE}Tangling SETUP.org${NC}"
echo -e "${BLUE}=====================================${NC}\n"

# Check if Emacs is installed
if ! command -v emacs &> /dev/null; then
    echo -e "${RED}Error: Emacs not found${NC}"
    echo "Please install Emacs or use another method to tangle SETUP.org"
    exit 1
fi

# Ensure we're in the project root
if [ ! -f "SETUP.org" ]; then
    echo -e "${RED}Error: SETUP.org not found${NC}"
    echo "Please run this script from the project root directory"
    exit 1
fi

echo -e "${BLUE}Tangling SETUP.org to generate project files...${NC}"

# Tangle the SETUP.org file
emacs --batch \
      --eval "(require 'org)" \
      --eval '(org-babel-tangle-file "SETUP.org")'

echo -e "${GREEN}Tangling complete!${NC}"

# Make generated scripts executable
echo -e "${BLUE}Making scripts executable...${NC}"
chmod +x scripts/*.sh

echo -e "${GREEN}Setup files generated successfully!${NC}"
echo -e "${YELLOW}Next steps:${NC}"
echo -e "1. Review the generated files"
echo -e "2. Run make setup to initialize the environment"
echo -e "3. Run make run to start the container"
echo -e "4. Run make test to verify MCP server connectivity"