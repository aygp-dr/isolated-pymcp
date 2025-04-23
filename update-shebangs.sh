#!/usr/bin/env bash

# Update all shebangs in scripts to use /usr/bin/env
echo "Updating shebangs in script files..."

# Find all shell scripts
find scripts -name "*.sh" -type f | while read script; do
  # Check if the script starts with #!/bin/bash or #!/bin/sh
  if grep -q "^#!/bin/bash" "$script" || grep -q "^#!/bin/sh" "$script"; then
    echo "Updating $script"
    # Replace the shebang with #!/usr/bin/env bash
    sed -i.bak '1s@^#!/bin/bash@#!/usr/bin/env bash@' "$script"
    sed -i.bak '1s@^#!/bin/sh@#!/usr/bin/env bash@' "$script"
    # Remove backup files
    rm -f "$script.bak"
  fi
done

echo "Done!"