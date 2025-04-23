#!/bin/bash
# Check and install dependencies for MCP Emacs integration

# Function to check if a command exists
check_command() {
    if command -v "$1" >/dev/null 2>&1; then
        echo "✅ $1 is installed"
        return 0
    else
        echo "❌ $1 is not installed"
        return 1
    fi
}

echo "Checking dependencies for MCP Emacs integration..."
echo "------------------------------------------------"

# Check for required commands
MISSING_COMMANDS=0

# Check Emacs
check_command emacs || MISSING_COMMANDS=$((MISSING_COMMANDS + 1))

# Check Deno (required for Python execution)
check_command deno
if [ $? -ne 0 ]; then
    MISSING_COMMANDS=$((MISSING_COMMANDS + 1))
    echo "   Deno is required for MCP Python execution."
    echo "   To install Deno, run:"
    echo "   curl -fsSL https://deno.land/install.sh | sh"
    echo "   Then add to your PATH: export PATH=\"\$HOME/.deno/bin:\$PATH\""
fi

# Check Node.js and npm (required for other MCP servers)
check_command node
if [ $? -ne 0 ]; then
    MISSING_COMMANDS=$((MISSING_COMMANDS + 1))
    echo "   Node.js is required for MCP servers."
fi

check_command npm
if [ $? -ne 0 ]; then
    MISSING_COMMANDS=$((MISSING_COMMANDS + 1))
    echo "   npm is required for MCP servers."
    echo "   To install Node.js and npm, visit: https://nodejs.org/"
fi

# Check for required Emacs packages
echo ""
echo "Checking Emacs packages..."
emacs --batch --eval "(progn
  (require 'package)
  (setq missing-packages '())
  
  (dolist (pkg '(json request))
    (condition-case nil
        (require pkg)
      (error 
        (message \"❌ Emacs package '%s' is not installed\" pkg)
        (setq missing-packages (cons pkg missing-packages)))))
        
  (if missing-packages
      (message \"\nMissing Emacs packages: %s\nInstall them with M-x package-install\" 
               (mapconcat 'symbol-name missing-packages \" \"))
    (message \"✅ All required Emacs packages are installed\")))" 2>&1

echo ""
if [ $MISSING_COMMANDS -eq 0 ]; then
    echo "✅ All required dependencies are installed!"
else
    echo "❌ $MISSING_COMMANDS dependency/dependencies missing. Please install them to use MCP Emacs integration."
    exit 1
fi