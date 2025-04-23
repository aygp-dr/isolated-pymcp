#!/usr/bin/env bash

# Create symlinks for backward compatibility with user: prefixed commands
echo "Creating symlinks for backward compatibility..."

# Create directory for user: prefixed commands
mkdir -p .claude/commands/user:

# Find all command files
for cmdfile in .claude/commands/*.md; do
  # Skip files that start with "user:"
  if [[ $(basename "$cmdfile") != user:* ]]; then
    base_name=$(basename "$cmdfile")
    symlink_path=".claude/commands/user:/$base_name"
    
    echo "Creating symlink: $symlink_path -> ../$(basename "$cmdfile")"
    ln -sf "../$base_name" "$symlink_path"
  fi
done

echo "Done!"