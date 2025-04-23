#\!/bin/bash
# Script to set up GitHub secrets based on .envrc

# Verify GitHub CLI auth
if \! gh auth status &>/dev/null; then
  echo "GitHub CLI not authenticated. Please run 'gh auth login' first."
  exit 1
fi

# Define required secrets from .envrc.example
REQUIRED_SECRETS=(
  "GH_PAT"  # GitHub Personal Access Token (renamed from GITHUB_TOKEN)
  "ANTHROPIC_API_KEY"
)

# Check for existing secrets
echo "Checking for existing secrets..."
for secret in "${REQUIRED_SECRETS[@]}"; do
  if gh secret list  < /dev/null |  grep -q "$secret"; then
    echo "✓ Secret $secret already exists"
  else
    echo "✗ Secret $secret needs to be created"
    # Create placeholder with instruction to update manually
    gh secret set "$secret" --body "PLACEHOLDER_REPLACE_ME"
    echo "Created placeholder for $secret - please update with actual value"
  fi
done

# Create a script to get secrets for the container
SCRIPT_DIR="$(dirname "$0")"
cat > "${SCRIPT_DIR}/get-secrets.sh" << 'INNER_EOF'
#!/bin/bash
# Script to retrieve secrets for container

# Check if GitHub CLI is authenticated
if ! gh auth status &>/dev/null; then
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
INNER_EOF

chmod +x "${SCRIPT_DIR}/get-secrets.sh"
echo "Created ${SCRIPT_DIR}/get-secrets.sh script to retrieve secrets"

# Update docker-compose.yml to use .env file
echo "Note: docker-compose.yml has already been updated to use .env file"
# No longer need this as we manually edited the file:
# sed -i 's/environment:/env_file: .env\n    environment:/g' docker-compose.yml

echo "Setup complete. Please ensure your secrets are properly set with actual values."
