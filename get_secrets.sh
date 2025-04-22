#\!/bin/bash
# Script to retrieve secrets for container

# Check if GitHub CLI is authenticated
if \! gh auth status &>/dev/null; then
  echo "GitHub CLI not authenticated. Please run 'gh auth login' first."
  exit 1
fi

# Create .env file from GitHub secrets
echo "# Generated .env file with secrets" > .env
echo "# DO NOT COMMIT THIS FILE" >> .env

# Get secrets from GitHub
echo "GITHUB_TOKEN=$(gh secret get GH_PAT)" >> .env
echo "ANTHROPIC_API_KEY=$(gh secret get ANTHROPIC_API_KEY)" >> .env

# Add other non-secret environment variables from .envrc.example
grep -v -E "(GITHUB_TOKEN|ANTHROPIC_API_KEY)" .envrc.example >> .env

echo "Secrets retrieved and saved to .env file"
