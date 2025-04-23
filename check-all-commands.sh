#!/usr/bin/env bash

# Check all command files for user: prefixes
echo "Checking all command files for user: prefixes..."

# Find all command files
for cmdfile in .claude/commands/*.md; do
  # Display the first line (title) of each file
  echo -n "$cmdfile: "
  head -n 1 "$cmdfile"
done

echo "Done!"