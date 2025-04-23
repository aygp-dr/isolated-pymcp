#!/usr/bin/env bash
# install-commands.sh - Install Claude Code commands to user directory

set -e

CLAUDE_COMMANDS_DIR="$HOME/.claude/commands"
SOURCE_DIR="$(dirname "$0")/commands"

echo "Installing Claude Code commands..."

# Create commands directory if it doesn't exist
mkdir -p "$CLAUDE_COMMANDS_DIR"

# Install all command files
for cmd_file in "$SOURCE_DIR"/*.md; do
  if [ -f "$cmd_file" ]; then
    # Get the base filename
    base_name=$(basename "$cmd_file")
    
    # Skip directories and user: symlinks
    if [[ "$base_name" != "user:"* ]] && [[ ! -d "$cmd_file" ]]; then
      # Copy to user's .claude/commands directory
      echo "Installing: $base_name"
      cp "$cmd_file" "$CLAUDE_COMMANDS_DIR/$base_name"
      
      # Also create a symlink with the user: prefix for backward compatibility
      user_cmd="$CLAUDE_COMMANDS_DIR/user:$base_name"
      mkdir -p "$(dirname "$user_cmd")"
      ln -sf "$base_name" "$user_cmd"
      echo "  Creating compatibility symlink: user:$base_name"
    fi
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