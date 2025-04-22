# Exercise: Setting Up Claude Code in an Isolated Docker Environment

## Objective

Create an isolated Docker environment for Claude Code to ensure secure and reproducible development.

## Tasks

1. Create a Dockerfile based on the provided template
2. Set up a docker-compose.yml file for your environment
3. Configure environment variables for API keys securely
4. Build and run the container
5. Test Claude Code functionality within the container

## Requirements

- Your setup should isolate Claude Code from your host system
- API keys should be passed via environment variables, not hardcoded
- The container should have necessary tools (git, GitHub CLI)
- The container should preserve history between sessions
- You should be able to analyze code in mounted volumes

## Starting Point

Use the Dockerfile from the course materials as a reference. You can find the official dev container at:
https://github.com/anthropics/claude-code/blob/main/.devcontainer/Dockerfile

## Expected Output

When you successfully complete this exercise, you should be able to:

```
# Build and start the container
$ docker-compose up -d
Creating network "claude-code-env_default" with the default driver
Creating claude-code-env_claude-code_1 ... done

# Connect to the container
$ docker-compose exec claude-code zsh

# Test Claude Code inside the container
node@container:/workspace$ claude --version
Claude Code v1.2.3

node@container:/workspace$ claude "Explain what this Dockerfile does"
[Claude explains the Dockerfile components...]
```

## Bonus Challenge

Add a script to automatically scan your codebase and generate a Mermaid diagram of its structure when the container starts up.