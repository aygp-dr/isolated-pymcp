# Working with SETUP.org

The `SETUP.org` file contains all the necessary code and configuration to set up a complete isolated Python development environment with MCP and LSP integration. After tangling this file, you'll have a fully functional project ready for exploration and experimentation.

## What is Tangling?

"Tangling" is a concept from literate programming where code blocks within a documentation file are extracted and written to separate source files. This allows us to maintain a single source of truth (the org file) that contains both documentation and implementation.

## How to Tangle SETUP.org

### Option 1: Using the provided script

```bash
# Run the tangle script
./scripts/tangle-setup.sh
```

### Option 2: Manually with Emacs

```bash
# From the command line
emacs --batch --eval "(require 'org)" --eval '(org-babel-tangle-file "SETUP.org")'

# Or within Emacs:
# 1. Open SETUP.org
# 2. Press C-c C-v t (or M-x org-babel-tangle)
```

## Post-Tangling Steps

After tangling, you should:

1. Review the generated files
2. Initialize the environment with `make setup`
3. Run the container with `make run`
4. Test the MCP servers with `make test`

## For Collaborators

When making changes:

1. Prefer editing the `SETUP.org` file directly for components described there
2. Tangle after changes to generate updated implementation files
3. Run tests to ensure everything works correctly
4. Commit both the SETUP.org and the generated files

## Understanding the File Structure

The tangling process will generate:

- Docker configuration (`Dockerfile`, `docker-compose.yml`)
- Python algorithm implementations (`algorithms/*.py`)
- Test files (`tests/test_*.py`)
- Configuration files (`.claude/preferences.json`, `.vscode/settings.json`, etc.)
- Scripts (`scripts/*.sh`)
- Emacs integration (`emacs/isolated-pymcp.el`)

## Troubleshooting

If you encounter issues with the tangling process:

1. Ensure Emacs is installed with org-mode support
2. Check for syntax errors in the org file
3. Verify you have the necessary permissions to write files
4. Some files may require additional dependencies to be installed