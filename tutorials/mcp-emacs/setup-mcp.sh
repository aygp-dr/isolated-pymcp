#!/bin/bash
# Setup script for MCP Emacs integration

# Detect script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
INTEGRATION_DIR="$REPO_ROOT/integrations/mcp"

# Create required directories
echo "Creating directories..."
mkdir -p ~/.emacs.d/lisp/
mkdir -p ~/mcp/config

# Check if integrations.org has been tangled
if [ ! -d "$INTEGRATION_DIR" ]; then
  echo "Tangling integrations.org..."
  cd "$REPO_ROOT"
  emacs --batch -l org --eval "(progn (find-file \"integrations.org\") (org-babel-tangle))"
fi

# Copy the MCP Emacs package
echo "Copying MCP Emacs package..."
cp "$INTEGRATION_DIR/environments/emacs.el" ~/.emacs.d/lisp/mcp.el

# Copy MCP server configurations
echo "Copying MCP configurations..."
cp "$INTEGRATION_DIR/config.json" ~/mcp/config/
cp "$INTEGRATION_DIR/mcp-servers.json" ~/mcp/config/

# Tangle code from README.org
echo "Tangling code from README.org..."
cd "$SCRIPT_DIR"
emacs --batch -l org --eval "(progn (find-file \"README.org\") (org-babel-tangle))"

# Make scripts executable
chmod +x "$SCRIPT_DIR/check-dependencies.sh"

echo "Setup complete!"
echo ""
echo "Add these lines to your Emacs configuration:"
echo "--------------------------------------------"
echo "(add-to-list 'load-path \"~/.emacs.d/lisp/\")"
echo "(require 'mcp)"
echo ""
echo "To enable org-babel support, add:"
echo "(with-eval-after-load 'org"
echo "  (add-to-list 'org-babel-load-languages '(mcp-python . t))"
echo "  (org-babel-do-load-languages 'org-babel-load-languages org-babel-load-languages))"