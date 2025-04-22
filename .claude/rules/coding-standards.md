# Coding Standards

## Git Guidelines

### Commit Guidelines

- Use [Conventional Commits](https://www.conventionalcommits.org/)
- Follow the format: `<type>[optional scope]: <description>`
- Keep the first line under 72 characters
- Use the imperative mood ("add" not "adds" or "added")
- Do not include collaborator information in commit message body
- Use `--trailer` for attribution and signing

### Branch Naming Guidelines

- Always create branches from GitHub issues
- Follow the format: `<type>/<issue-number>-<short-description>`
- Types should match conventional commits (feat, fix, docs, etc.)
- Include the issue number for traceability
- Use kebab-case for the description portion
- Examples:
  - `feat/33-claude-md-algo-guidance`
  - `security/21-container-resource-limits`
  - `docs/29-claude-org-mode-tutorial`
  - `fix/18-curl-bash-pattern`

## Script Development

- All scripts must start with `#!/usr/bin/env <interpreter>` for FreeBSD compatibility
- Place complex Makefile logic in dedicated scripts
- Scripts should be executable: `chmod +x scripts/script-name.sh`
- Include error handling and proper exit codes
- Use shellcheck for shell script validation

## FreeBSD Considerations

- Do not assume Linux-specific paths or tools
- Test compatibility with both Docker and Podman
- Use `uname` to detect operating system when needed
- Default to POSIX-compliant shell constructs
- Verify all system commands exist before using them

## Python Standards

- Follow PEP 8 style guide
- Use type hints where appropriate
- Include docstrings for all functions and classes
- Write unit tests for all significant functionality
