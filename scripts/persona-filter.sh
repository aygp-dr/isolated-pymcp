#!/usr/bin/env bash
# Persona-based filtering wrapper for bd list
#
# This script provides persona-based views of issues using the label system
# defined in config/personas.yaml. It wraps the `bd list` command with
# appropriate label filters.
#
# Usage:
#   scripts/persona-filter.sh <persona> [additional bd list flags]
#   scripts/persona-filter.sh --list-personas
#   scripts/persona-filter.sh --list-agents
#
# Examples:
#   scripts/persona-filter.sh architect
#   scripts/persona-filter.sh implementer --status open
#   scripts/persona-filter.sh builder --priority P1
#
# Environment Variables:
#   BD_PERSONA_CONFIG - Path to personas.yaml (default: config/personas.yaml)

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Configuration file
CONFIG_FILE="${BD_PERSONA_CONFIG:-$PROJECT_ROOT/config/personas.yaml}"

# Check if config file exists
if [[ ! -f "$CONFIG_FILE" ]]; then
    echo -e "${RED}Error: Configuration file not found: $CONFIG_FILE${NC}" >&2
    exit 1
fi

# Function to parse YAML and get labels for a persona
get_persona_labels() {
    local persona="$1"
    local section="${2:-personas}"  # personas or continue_agents

    # Use awk to extract labels from YAML
    # This is a simple parser - for production use, consider yq or python
    awk -v persona="$persona" -v section="$section" '
        BEGIN { in_section=0; in_persona=0; in_labels=0; }

        # Find the section (personas or continue_agents)
        $1 == section ":" { in_section=1; next; }

        # Exit section if we hit another top-level key
        in_section && /^[a-z_]+:/ && $1 != "labels:" { in_section=0; }

        # Find the persona within the section
        in_section && $1 == persona ":" { in_persona=1; next; }

        # Exit persona if we hit another persona at same indent level
        in_persona && /^  [a-z_]+:/ && $1 != "labels:" && $1 != "description:" && $1 != "continue_agent:" && $1 != "filters:" && $1 != "status:" && $1 != "priority_max:" && $1 != "personas:" {
            in_persona=0;
        }

        # Find labels section within persona
        in_persona && /^    labels:/ { in_labels=1; next; }

        # Exit labels if we hit another key at same level
        in_labels && /^    [a-z_]+:/ { in_labels=0; }

        # Print label values
        in_labels && /^      - / {
            gsub(/^      - /, "");
            gsub(/^ +/, "");
            gsub(/ +$/, "");
            print $0;
        }
    ' "$CONFIG_FILE"
}

# Function to get description for a persona
get_persona_description() {
    local persona="$1"
    local section="${2:-personas}"

    awk -v persona="$persona" -v section="$section" '
        BEGIN { in_section=0; in_persona=0; }

        $1 == section ":" { in_section=1; next; }
        in_section && /^[a-z_]+:/ && $1 != "description:" { in_section=0; }

        in_section && $1 == persona ":" { in_persona=1; next; }
        in_persona && /^  [a-z_]+:/ && $1 != "description:" { in_persona=0; }

        in_persona && /^    description:/ {
            gsub(/^    description: /, "");
            gsub(/^"/, "");
            gsub(/"$/, "");
            print $0;
            exit;
        }
    ' "$CONFIG_FILE"
}

# Function to list all personas
list_personas() {
    echo -e "${BLUE}Available Personas:${NC}\n"

    # Extract persona names - look for 2-space indented items under personas:
    local personas=$(awk '
        BEGIN { in_personas=0; }
        /^personas:/ { in_personas=1; next; }
        /^[a-z_]+:/ && in_personas { in_personas=0; }
        in_personas && /^  [a-z_]+:/ {
            gsub(/:/, "", $1);
            gsub(/^  /, "");
            if ($1 != "") print $1;
        }
    ' "$CONFIG_FILE")

    for persona in $personas; do
        local desc=$(get_persona_description "$persona" "personas")
        local labels=$(get_persona_labels "$persona" "personas" | tr '\n' ', ' | sed 's/,$//')
        echo -e "  ${GREEN}$persona${NC}"
        echo -e "    Description: $desc"
        echo -e "    Labels: $labels"
        echo ""
    done
}

# Function to list all CONTINUE agents
list_agents() {
    echo -e "${BLUE}Available CONTINUE Agents:${NC}\n"

    # Extract agent names - look for 2-space indented items under continue_agents:
    local agents=$(awk '
        BEGIN { in_agents=0; }
        /^continue_agents:/ { in_agents=1; next; }
        /^[a-z_]+:/ && in_agents { in_agents=0; }
        in_agents && /^  [a-z_]+:/ {
            gsub(/:/, "", $1);
            gsub(/^  /, "");
            if ($1 != "") print $1;
        }
    ' "$CONFIG_FILE")

    for agent in $agents; do
        local desc=$(get_persona_description "$agent" "continue_agents")
        local labels=$(get_persona_labels "$agent" "continue_agents" | tr '\n' ', ' | sed 's/,$//')
        echo -e "  ${GREEN}$agent${NC}"
        echo -e "    Description: $desc"
        echo -e "    Labels: $labels"
        echo ""
    done
}

# Function to show usage
usage() {
    cat <<EOF
${BLUE}Persona Filter for Beads${NC}

Filter issues by persona or CONTINUE agent using predefined label sets.

${YELLOW}Usage:${NC}
  $0 <persona|agent> [bd list flags]
  $0 --list-personas
  $0 --list-agents
  $0 --help

${YELLOW}Examples:${NC}
  $0 architect                    # Show architect issues
  $0 implementer --status open    # Show open implementer issues
  $0 builder --priority P1        # Show P1 builder issues
  $0 --list-personas              # List all personas

${YELLOW}Environment:${NC}
  BD_PERSONA_CONFIG - Path to personas.yaml (default: config/personas.yaml)

${YELLOW}Configuration:${NC}
  Config file: $CONFIG_FILE

EOF
}

# Main script logic
main() {
    # Handle special flags
    case "${1:-}" in
        --list-personas)
            list_personas
            exit 0
            ;;
        --list-agents)
            list_agents
            exit 0
            ;;
        --help|-h)
            usage
            exit 0
            ;;
        "")
            echo -e "${RED}Error: No persona specified${NC}" >&2
            echo ""
            usage
            exit 1
            ;;
    esac

    local persona="$1"
    shift

    # Try to find labels in personas section first
    local labels=$(get_persona_labels "$persona" "personas")

    # If not found, try continue_agents section
    if [[ -z "$labels" ]]; then
        labels=$(get_persona_labels "$persona" "continue_agents")
    fi

    # If still not found, error
    if [[ -z "$labels" ]]; then
        echo -e "${RED}Error: Unknown persona or agent: $persona${NC}" >&2
        echo ""
        echo -e "${YELLOW}Available personas:${NC}"
        awk 'BEGIN { in_personas=0; } /^personas:/ { in_personas=1; next; } /^[a-z_]+:/ && in_personas { in_personas=0; } in_personas && /^  [a-z_]+:/ { gsub(/:/, "", $1); gsub(/^  /, ""); if ($1 != "") print "  - " $1; }' "$CONFIG_FILE"
        echo ""
        echo -e "${YELLOW}Available agents:${NC}"
        awk 'BEGIN { in_agents=0; } /^continue_agents:/ { in_agents=1; next; } /^[a-z_]+:/ && in_agents { in_agents=0; } in_agents && /^  [a-z_]+:/ { gsub(/:/, "", $1); gsub(/^  /, ""); if ($1 != "") print "  - " $1; }' "$CONFIG_FILE"
        exit 1
    fi

    # Build label flags for bd list
    # Use --label-any for OR logic (issues with ANY of the persona's labels)
    local label_flags=()
    while IFS= read -r label; do
        [[ -n "$label" ]] && label_flags+=("--label-any" "$label")
    done <<< "$labels"

    # Show what we're doing
    local desc=$(get_persona_description "$persona" "personas")
    if [[ -z "$desc" ]]; then
        desc=$(get_persona_description "$persona" "continue_agents")
    fi

    echo -e "${BLUE}Filtering for persona: ${GREEN}$persona${NC}" >&2
    echo -e "${BLUE}Description: ${NC}$desc" >&2
    echo -e "${BLUE}Labels: ${NC}$(echo "$labels" | tr '\n' ', ' | sed 's/,$//')" >&2
    echo "" >&2

    # Run bd list with the label filters and any additional args
    bd list "${label_flags[@]}" "$@"
}

main "$@"
