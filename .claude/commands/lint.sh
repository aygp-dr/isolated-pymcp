#!/bin/bash
# Claude Code command: /user:lint
# Runs linting tools on the codebase

set -e

echo "Running all code quality checks with UV..."
make check-all