#!/bin/bash
# Install Python LSP Server

# Create a virtual environment
python -m venv lsp-venv
source lsp-venv/bin/activate

# Install Python LSP Server
pip install python-lsp-server

# Install additional plugins
pip install pylsp-mypy python-lsp-black pylsp-rope pyls-isort

echo "Python LSP Server installed and configured."
