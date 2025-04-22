#!/usr/bin/env bash
# review-pr.sh - PR review and merge utility with role-based reviewers
# Usage: ./scripts/review-pr.sh PR_NUMBER [--auto-merge] [--reviewer=ROLE]
#
# Reviewer roles:
# - manager: Project management focus
# - engineer: Code quality and implementation
# - sre: Operations and reliability
# - director: Strategic alignment

set -e

if [ -z "$1" ]; then
  echo "Error: Missing PR number"
  echo "Usage: ./scripts/review-pr.sh PR_NUMBER [--auto-merge] [--reviewer=ROLE]"
  echo "       Reviewer roles: manager, engineer, sre, director"
  exit 1
fi

PR_NUMBER=$1
AUTO_MERGE=""
REVIEWER_ROLE=""

# Parse arguments
for arg in "$@"; do
  case $arg in
    --auto-merge)
      AUTO_MERGE="--auto-merge"
      ;;
    --reviewer=*)
      REVIEWER_ROLE="${arg#*=}"
      ;;
  esac
done

# Config file path
CONFIG_FILE=".claude/pr-review-config.json"

# Check if config file exists
if [ -f "$CONFIG_FILE" ]; then
  echo "Loading PR review configuration from $CONFIG_FILE"
  
  # Check if jq is available
  if ! command -v jq &> /dev/null; then
    echo "Warning: jq is not installed. Role validation will be limited."
    
    # Fallback validation without jq
    if [ -n "$REVIEWER_ROLE" ]; then
      case $REVIEWER_ROLE in
        manager|engineer|sre|director)
          echo "Reviewing as role: $REVIEWER_ROLE"
          ;;
        *)
          echo "Error: Invalid reviewer role '$REVIEWER_ROLE'"
          echo "Valid roles: manager, engineer, sre, director"
          exit 1
          ;;
      esac
    else
      echo "Warning: No reviewer role specified. Using default review process."
    fi
  else
    # Get valid roles from config
    VALID_ROLES=$(jq -r '.roles | keys | join("|")' "$CONFIG_FILE")
    
    # Validate reviewer role if provided
    if [ -n "$REVIEWER_ROLE" ]; then
      if echo "$VALID_ROLES" | grep -q "\b$REVIEWER_ROLE\b"; then
        ROLE_DESCRIPTION=$(jq -r ".roles.\"$REVIEWER_ROLE\".description" "$CONFIG_FILE")
        echo "Reviewing as role: $REVIEWER_ROLE - $ROLE_DESCRIPTION"
        
        # Display responsibilities
        echo "Responsibilities:"
        jq -r ".roles.\"$REVIEWER_ROLE\".responsibilities[] | \"- \" + ." "$CONFIG_FILE"
      else
        echo "Error: Invalid reviewer role '$REVIEWER_ROLE'"
        echo "Valid roles: $(echo $VALID_ROLES | tr '|' ', ')"
        exit 1
      fi
    else
      echo "Warning: No reviewer role specified. Using default review process."
      echo "Available roles: $(echo $VALID_ROLES | tr '|' ', ')"
    fi
  fi
else
  # Fallback if config file doesn't exist
  echo "Warning: PR review config file not found. Using built-in role definitions."
  
  # Validate reviewer role if provided
  if [ -n "$REVIEWER_ROLE" ]; then
    case $REVIEWER_ROLE in
      manager|engineer|sre|director)
        echo "Reviewing as role: $REVIEWER_ROLE"
        ;;
      *)
        echo "Error: Invalid reviewer role '$REVIEWER_ROLE'"
        echo "Valid roles: manager, engineer, sre, director"
        exit 1
        ;;
    esac
  else
    echo "Warning: No reviewer role specified. Using default review process."
  fi
fi

echo "Reviewing PR #$PR_NUMBER..."

# Get PR information
gh pr view $PR_NUMBER

# Check for existing reviews
echo -e "\nChecking existing reviews..."
REVIEWS=$(gh pr view $PR_NUMBER --json reviews -q '.reviews' 2>/dev/null || echo "[]")
if [ "$REVIEWS" != "[]" ]; then
  echo "This PR has existing reviews."
  echo "$REVIEWS" | jq -r '.[] | "- " + .author.login + " (" + .state + ")"' 2>/dev/null || echo "Could not parse reviews."
fi

# Check CI status
echo -e "\nChecking CI status..."
CI_STATUS=$(gh pr checks $PR_NUMBER --watch)

# Show diff with role-specific focus
echo -e "\nReviewing changes..."
gh pr diff $PR_NUMBER

# Get PR file changes
echo -e "\nAnalyzing PR changes..."
PR_FILES=$(gh pr view $PR_NUMBER --json files -q '.files[].path')

# Role-specific checks
if [ -n "$REVIEWER_ROLE" ]; then
  echo -e "\nPerforming $REVIEWER_ROLE-focused review..."
  
  # Check if we have jq and config file for advanced checks
  if command -v jq &> /dev/null && [ -f "$CONFIG_FILE" ]; then
    # Get file patterns for this role
    PATTERNS=$(jq -r ".roles.\"$REVIEWER_ROLE\".filePatterns[]" "$CONFIG_FILE" 2>/dev/null)
    
    # Check files matching the patterns
    echo "Files relevant to $REVIEWER_ROLE role:"
    FOUND_RELEVANT_FILES=false
    
    for file in $PR_FILES; do
      for pattern in $PATTERNS; do
        # Convert glob pattern to regex
        regex=$(echo "$pattern" | sed 's/\*\*/.*/' | sed 's/\*/[^\/]*/' | sed 's/\//\\\//g')
        if echo "$file" | grep -q -E "$regex"; then
          echo "- $file (matches pattern: $pattern)"
          FOUND_RELEVANT_FILES=true
          break
        fi
      done
    done
    
    if [ "$FOUND_RELEVANT_FILES" = false ]; then
      echo "No files directly relevant to $REVIEWER_ROLE role were found."
    fi
    
    # Get and run configured commands for this role
    COMMANDS=$(jq -r ".roles.\"$REVIEWER_ROLE\".commands[]" "$CONFIG_FILE" 2>/dev/null)
    if [ -n "$COMMANDS" ]; then
      echo -e "\nRunning role-specific checks..."
      for cmd in "$COMMANDS"; do
        echo "Running: $cmd"
        eval "$cmd" || echo "Command exited with non-zero status"
      done
    fi
    
    # Check if this is a critical path requiring special attention
    echo -e "\nChecking critical paths..."
    CRITICAL_PATHS=$(jq -r '.approvalRules.criticalPaths | keys[]' "$CONFIG_FILE" 2>/dev/null)
    for critical in $CRITICAL_PATHS; do
      critical_patterns=$(jq -r ".approvalRules.criticalPaths.\"$critical\".paths[]" "$CONFIG_FILE")
      required_roles=$(jq -r ".approvalRules.criticalPaths.\"$critical\".requiredRoles | join(\", \")" "$CONFIG_FILE")
      min_approvals=$(jq -r ".approvalRules.criticalPaths.\"$critical\".minApprovals" "$CONFIG_FILE")
      
      # Check if any files match critical paths
      for file in $PR_FILES; do
        for pattern in $critical_patterns; do
          regex=$(echo "$pattern" | sed 's/\*\*/.*/' | sed 's/\*/[^\/]*/' | sed 's/\//\\\//g')
          if echo "$file" | grep -q -E "$regex"; then
            echo "⚠️ Critical path '$critical' detected: $file"
            echo "   Required roles: $required_roles"
            echo "   Minimum approvals: $min_approvals"
            break
          fi
        done
      done
    done
  fi
  
  # Fallback to built-in role-specific checks if needed
  if [ "$REVIEWER_ROLE" = "engineer" ]; then
    # Run tests locally
    echo -e "\nRunning tests locally..."
    python -m pytest tests/
    
    # Lint and type check
    echo -e "\nRunning linting and type checking..."
    black --check algorithms/ tests/
    mypy algorithms/ tests/
    flake8 algorithms/ tests/
  elif [ "$REVIEWER_ROLE" = "sre" ]; then
    # Check for performance issues
    echo -e "\nChecking for performance considerations..."
    python -m pytest tests/ -m "benchmark" || echo "No benchmark tests found."
  elif [ "$REVIEWER_ROLE" = "manager" ]; then
    # Check documentation
    echo -e "\nChecking documentation updates..."
    DOCS_CHANGES=$(echo "$PR_FILES" | grep -E '^docs/|\.md$|\.org$' || echo "")
    if [ -n "$DOCS_CHANGES" ]; then
      echo "Documentation files changed:"
      echo "$DOCS_CHANGES"
    else
      echo "Warning: No documentation updates detected."
    fi
  elif [ "$REVIEWER_ROLE" = "director" ]; then
    # Check architectural changes
    echo -e "\nChecking for architectural impacts..."
    ARCH_CHANGES=$(echo "$PR_FILES" | grep -E 'architecture|diagrams' || echo "")
    if [ -n "$ARCH_CHANGES" ]; then
      echo "Architecture-related files changed:"
      echo "$ARCH_CHANGES"
    else
      echo "No architecture-related files were changed in this PR."
    fi
  fi
else
  # Default review process for no specific role
  # Run tests locally
  echo -e "\nRunning tests locally..."
  python -m pytest tests/
  
  # Lint and type check
  echo -e "\nRunning linting and type checking..."
  black --check algorithms/ tests/
  mypy algorithms/ tests/
  flake8 algorithms/ tests/
fi

# Add review comment based on role
if [ -n "$REVIEWER_ROLE" ]; then
  echo -e "\nWould you like to add a review comment? (y/n)"
  read -r ADD_COMMENT
  if [[ "$ADD_COMMENT" == "y" ]]; then
    echo "Enter your review comment (press Ctrl+D when finished):"
    COMMENT=$(cat)
    gh pr review $PR_NUMBER --comment --body "[$REVIEWER_ROLE review] $COMMENT"
  fi
  
  echo -e "\nWould you like to approve this PR? (y/n)"
  read -r APPROVE
  if [[ "$APPROVE" == "y" ]]; then
    gh pr review $PR_NUMBER --approve --body "Approved as $REVIEWER_ROLE"
    echo "PR approved as $REVIEWER_ROLE!"
  fi
fi

# Check for required approvals
APPROVALS=$(gh pr view $PR_NUMBER --json reviews -q '[.reviews[] | select(.state == "APPROVED")] | length')
echo -e "\nThis PR has $APPROVALS approval(s)"

# Prompt for merge decision
if [[ "$AUTO_MERGE" == "--auto-merge" && "$CI_STATUS" == *"All checks were successful"* && "$APPROVALS" -ge 1 ]]; then
  echo -e "\nAll checks passed and PR has required approvals. Auto-merging PR #$PR_NUMBER..."
  gh pr merge $PR_NUMBER --squash
elif [[ "$AUTO_MERGE" != "--auto-merge" ]]; then
  if [[ "$APPROVALS" -lt 1 ]]; then
    echo -e "\nWarning: This PR does not have the required minimum of 1 approval"
    echo "You should get approval before merging."
  fi
  
  echo -e "\nReview complete. Would you like to merge PR #$PR_NUMBER? (y/n)"
  read -r MERGE_DECISION
  if [[ "$MERGE_DECISION" == "y" ]]; then
    gh pr merge $PR_NUMBER --squash
    echo "PR #$PR_NUMBER merged successfully!"
  else
    echo "PR was not merged."
  fi
else
  echo -e "\nCI checks failed or PR doesn't have required approvals. PR not merged automatically."
  exit 1
fi