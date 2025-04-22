#!/bin/bash
# install-commands.sh - Install Claude Code commands to user directory

set -e

CLAUDE_COMMANDS_DIR="$HOME/.claude/commands"
SOURCE_DIR="$(dirname "$0")/commands"

echo "Installing Claude Code commands..."

# Create commands directory if it doesn't exist
mkdir -p "$CLAUDE_COMMANDS_DIR"

# Install all command files, removing the 'user:' prefix
for cmd_file in "$SOURCE_DIR"/user:*.md; do
  if [ -f "$cmd_file" ]; then
    # Extract base filename without the user: prefix
    base_name=$(basename "$cmd_file" | sed 's/^user://')
    
    # Copy to user's .claude/commands directory
    echo "Installing: $base_name"
    cp "$cmd_file" "$CLAUDE_COMMANDS_DIR/$base_name"
  fi
done

# Copy shell scripts if they exist (for supporting scripts)
for script_file in "$SOURCE_DIR"/*.sh; do
  if [ -f "$script_file" ]; then
    # Get the base filename
    base_name=$(basename "$script_file")
    
    # Copy to user's .claude/commands directory
    echo "Installing script: $base_name"
    cp "$script_file" "$CLAUDE_COMMANDS_DIR/$base_name"
    chmod +x "$CLAUDE_COMMANDS_DIR/$base_name"
  fi
done

echo "Installed commands:"
ls -la "$CLAUDE_COMMANDS_DIR"
echo "Installation complete. You can now use these commands with Claude Code."