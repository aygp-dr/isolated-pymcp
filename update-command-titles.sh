#!/usr/bin/env bash

# Update titles in command files to remove user: prefix
echo "Updating command titles in .claude/commands/*.md files..."

# Find all command files
find .claude/commands -name "*.md" -type f | while read cmdfile; do
  # Check if the title contains "user:"
  if grep -q "^# \`/user:" "$cmdfile"; then
    echo "Updating $cmdfile"
    # Replace the user: prefix in titles
    sed -i.bak 's/^# `\/user:\([^`]*\)`/# `\/\1`/' "$cmdfile"
    # Remove backup files
    rm -f "$cmdfile.bak"
  fi
done

echo "Done!"