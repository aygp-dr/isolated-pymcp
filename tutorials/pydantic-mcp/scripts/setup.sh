#!/bin/bash
# Create and activate a virtual environment
python -m venv pydantic-mcp-venv
source pydantic-mcp-venv/bin/activate

# Install Pydantic AI with logfire support
pip install "pydantic-ai[logfire]"

# Verify the installation
python -c "import pydantic_ai; print(f'Pydantic AI version: {pydantic_ai.__version__}')"

# Install MCP
pip install mcp

# Check if Deno is installed
if ! command -v deno &> /dev/null; then
    echo "Deno is not installed. Installing now..."
    curl -fsSL https://deno.land/x/install/install.sh | sh
    
    # Add Deno to PATH
    export DENO_INSTALL="$HOME/.deno"
    export PATH="$DENO_INSTALL/bin:$PATH"
    echo 'export DENO_INSTALL="$HOME/.deno"' >> ~/.bashrc
    echo 'export PATH="$DENO_INSTALL/bin:$PATH"' >> ~/.bashrc
else
    echo "Deno is already installed:"
    deno --version
fi