#!/usr/bin/env bash
#
# dep-analysis.sh - Dependency analysis and validation for Beads
#
# This script provides comprehensive dependency statistics, validation,
# and visualization for the Beads issue tracking system.
#
# Usage:
#   ./scripts/dep-analysis.sh [options]
#
# Options:
#   --stats       Show dependency statistics (default)
#   --validate    Validate dependencies (check for cycles, orphans, etc.)
#   --graph       Show dependency graph (requires GraphViz)
#   --help        Show this help message
#
# Examples:
#   ./scripts/dep-analysis.sh --stats
#   ./scripts/dep-analysis.sh --validate
#   ./scripts/dep-analysis.sh --stats --validate
#

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Default options
SHOW_STATS=0
VALIDATE=0
SHOW_GRAPH=0

# Parse command line arguments
if [ $# -eq 0 ]; then
    SHOW_STATS=1
fi

while [ $# -gt 0 ]; do
    case "$1" in
        --stats)
            SHOW_STATS=1
            shift
            ;;
        --validate)
            VALIDATE=1
            shift
            ;;
        --graph)
            SHOW_GRAPH=1
            shift
            ;;
        --help|-h)
            grep '^#' "$0" | grep -v '#!/' | sed 's/^# //g' | sed 's/^#//g'
            exit 0
            ;;
        *)
            echo -e "${RED}Error: Unknown option $1${NC}"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

# Check if bd is installed
if ! command -v bd &> /dev/null; then
    echo -e "${RED}Error: bd (Beads) is not installed or not in PATH${NC}"
    exit 1
fi

# Check if jq is installed
if ! command -v jq &> /dev/null; then
    echo -e "${RED}Error: jq is required but not installed${NC}"
    echo "Install with: brew install jq (macOS) or apt-get install jq (Linux)"
    exit 1
fi

#
# Statistics Functions
#

show_statistics() {
    echo -e "${CYAN}=== Dependency Statistics ===${NC}\n"

    # Get all issues as JSON
    local issues_json
    issues_json=$(bd list --json)

    # Total issues
    local total_issues
    total_issues=$(echo "$issues_json" | jq '. | length')
    echo -e "${BLUE}Total Issues:${NC} $total_issues"

    # Issues with dependencies
    local with_deps
    with_deps=$(echo "$issues_json" | jq '[.[] | select(.dependency_count > 0)] | length')
    echo -e "${BLUE}Issues with Dependencies:${NC} $with_deps"

    # Issues that are dependencies (have dependents)
    local with_dependents
    with_dependents=$(echo "$issues_json" | jq '[.[] | select(.dependent_count > 0)] | length')
    echo -e "${BLUE}Issues with Dependents:${NC} $with_dependents"

    # Orphaned issues (no deps, no dependents)
    local orphans
    orphans=$(echo "$issues_json" | jq '[.[] | select(.dependency_count == 0 and .dependent_count == 0)] | length')
    echo -e "${BLUE}Orphaned Issues:${NC} $orphans"

    # Average dependencies per issue
    local total_deps
    total_deps=$(echo "$issues_json" | jq '[.[].dependency_count] | add // 0')
    local avg_deps
    if [ "$total_issues" -gt 0 ]; then
        avg_deps=$(echo "scale=2; $total_deps / $total_issues" | bc)
    else
        avg_deps="0"
    fi
    echo -e "${BLUE}Average Dependencies per Issue:${NC} $avg_deps"

    # Maximum dependencies
    local max_deps
    max_deps=$(echo "$issues_json" | jq '[.[].dependency_count] | max // 0')
    echo -e "${BLUE}Maximum Dependencies:${NC} $max_deps"

    # Issues with maximum dependencies
    if [ "$max_deps" -gt 0 ]; then
        local max_dep_issues
        max_dep_issues=$(echo "$issues_json" | jq -r ".[] | select(.dependency_count == $max_deps) | .id" | tr '\n' ' ')
        echo -e "${BLUE}Issue(s) with Most Dependencies:${NC} $max_dep_issues"
    fi

    echo ""
    echo -e "${CYAN}=== Dependency Type Distribution ===${NC}\n"

    # Get detailed dependency info for all issues
    local all_deps_count=0
    local blocks_count=0
    local related_count=0
    local discovered_count=0
    local parent_child_count=0
    local other_count=0

    # Iterate through issues and count dependency types
    while IFS= read -r issue_id; do
        local issue_deps
        issue_deps=$(bd show "$issue_id" --json 2>/dev/null || echo "[]")

        # Count each dependency type
        blocks_count=$((blocks_count + $(echo "$issue_deps" | jq '[.[0].dependencies[]? | select(.dependency_type == "blocks")] | length')))
        related_count=$((related_count + $(echo "$issue_deps" | jq '[.[0].dependencies[]? | select(.dependency_type == "related")] | length')))
        discovered_count=$((discovered_count + $(echo "$issue_deps" | jq '[.[0].dependencies[]? | select(.dependency_type == "discovered-from")] | length')))
        parent_child_count=$((parent_child_count + $(echo "$issue_deps" | jq '[.[0].dependencies[]? | select(.dependency_type == "parent-child")] | length')))
    done < <(echo "$issues_json" | jq -r '.[].id')

    all_deps_count=$((blocks_count + related_count + discovered_count + parent_child_count + other_count))

    echo -e "${BLUE}Total Dependencies:${NC} $all_deps_count"
    echo -e "${BLUE}  - blocks:${NC} $blocks_count"
    echo -e "${BLUE}  - related:${NC} $related_count"
    echo -e "${BLUE}  - discovered-from:${NC} $discovered_count"
    echo -e "${BLUE}  - parent-child:${NC} $parent_child_count"

    if [ "$all_deps_count" -gt 0 ]; then
        local blocks_pct
        blocks_pct=$(echo "scale=1; $blocks_count * 100 / $all_deps_count" | bc)
        local related_pct
        related_pct=$(echo "scale=1; $related_count * 100 / $all_deps_count" | bc)
        local discovered_pct
        discovered_pct=$(echo "scale=1; $discovered_count * 100 / $all_deps_count" | bc)
        local parent_pct
        parent_pct=$(echo "scale=1; $parent_child_count * 100 / $all_deps_count" | bc)

        echo ""
        echo -e "${BLUE}Percentage Distribution:${NC}"
        echo -e "${BLUE}  - blocks:${NC} ${blocks_pct}%"
        echo -e "${BLUE}  - related:${NC} ${related_pct}%"
        echo -e "${BLUE}  - discovered-from:${NC} ${discovered_pct}%"
        echo -e "${BLUE}  - parent-child:${NC} ${parent_pct}%"
    fi

    echo ""
    echo -e "${CYAN}=== Blocking Statistics ===${NC}\n"

    # Count blocked issues
    local blocked_output
    blocked_output=$(bd blocked 2>/dev/null || echo "")
    local blocked_count
    blocked_count=$(echo "$blocked_output" | grep -c '^\[P[0-9]\]' || echo "0")

    echo -e "${BLUE}Currently Blocked Issues:${NC} $blocked_count"

    # Count ready issues
    local ready_count
    ready_count=$(bd ready --json 2>/dev/null | jq '. | length' || echo "0")
    echo -e "${BLUE}Ready Issues:${NC} $ready_count"

    echo ""
}

#
# Validation Functions
#

validate_dependencies() {
    echo -e "${CYAN}=== Dependency Validation ===${NC}\n"

    local validation_errors=0

    # 1. Check for dependency cycles
    echo -e "${BLUE}Checking for dependency cycles...${NC}"
    local cycles_output
    cycles_output=$(bd dep cycles 2>&1)

    if echo "$cycles_output" | grep -q "No dependency cycles detected"; then
        echo -e "${GREEN}✓ No dependency cycles detected${NC}"
    else
        echo -e "${RED}✗ Dependency cycles found:${NC}"
        echo "$cycles_output"
        validation_errors=$((validation_errors + 1))
    fi

    echo ""

    # 2. Check for self-dependencies
    echo -e "${BLUE}Checking for self-dependencies...${NC}"
    local issues_json
    issues_json=$(bd list --json)
    local self_deps=0

    while IFS= read -r issue_id; do
        local issue_deps
        issue_deps=$(bd show "$issue_id" --json 2>/dev/null || echo "[]")

        # Check if issue depends on itself
        local has_self_dep
        has_self_dep=$(echo "$issue_deps" | jq -r ".[0].dependencies[]? | select(.id == \"$issue_id\") | .id" || echo "")

        if [ -n "$has_self_dep" ]; then
            echo -e "${RED}✗ Self-dependency found: $issue_id${NC}"
            self_deps=$((self_deps + 1))
            validation_errors=$((validation_errors + 1))
        fi
    done < <(echo "$issues_json" | jq -r '.[].id')

    if [ "$self_deps" -eq 0 ]; then
        echo -e "${GREEN}✓ No self-dependencies found${NC}"
    fi

    echo ""

    # 3. Check for dangling dependencies (references to non-existent issues)
    echo -e "${BLUE}Checking for dangling dependencies...${NC}"
    local dangling=0
    local all_issue_ids
    all_issue_ids=$(echo "$issues_json" | jq -r '.[].id')

    while IFS= read -r issue_id; do
        local issue_deps
        issue_deps=$(bd show "$issue_id" --json 2>/dev/null || echo "[]")

        # Get all dependency IDs
        local dep_ids
        dep_ids=$(echo "$issue_deps" | jq -r '.[0].dependencies[]?.id' 2>/dev/null || echo "")

        if [ -n "$dep_ids" ]; then
            while IFS= read -r dep_id; do
                if ! echo "$all_issue_ids" | grep -q "^${dep_id}$"; then
                    echo -e "${RED}✗ Dangling dependency: $issue_id depends on non-existent $dep_id${NC}"
                    dangling=$((dangling + 1))
                    validation_errors=$((validation_errors + 1))
                fi
            done <<< "$dep_ids"
        fi
    done < <(echo "$issues_json" | jq -r '.[].id')

    if [ "$dangling" -eq 0 ]; then
        echo -e "${GREEN}✓ No dangling dependencies found${NC}"
    fi

    echo ""

    # 4. Check for blocked issues with closed/done dependencies
    echo -e "${BLUE}Checking for stale blocking dependencies...${NC}"
    local stale_blocks=0

    while IFS= read -r issue_id; do
        local issue_data
        issue_data=$(bd show "$issue_id" --json 2>/dev/null || echo "[]")

        # Get blocking dependencies that are done/closed
        local stale_deps
        stale_deps=$(echo "$issue_data" | jq -r '.[0].dependencies[]? | select(.dependency_type == "blocks" and (.status == "done" or .status == "closed")) | .id' 2>/dev/null || echo "")

        if [ -n "$stale_deps" ]; then
            echo -e "${YELLOW}⚠ Issue $issue_id has resolved blocking dependencies:${NC}"
            echo "$stale_deps" | while IFS= read -r dep; do
                echo "    - $dep"
            done
            stale_blocks=$((stale_blocks + 1))
        fi
    done < <(echo "$issues_json" | jq -r '.[].id')

    if [ "$stale_blocks" -eq 0 ]; then
        echo -e "${GREEN}✓ No stale blocking dependencies${NC}"
    else
        echo -e "${YELLOW}Note: $stale_blocks issue(s) have resolved blocking dependencies (may be ready to work)${NC}"
    fi

    echo ""

    # Summary
    echo -e "${CYAN}=== Validation Summary ===${NC}\n"
    if [ "$validation_errors" -eq 0 ]; then
        echo -e "${GREEN}✓ All validation checks passed!${NC}"
        return 0
    else
        echo -e "${RED}✗ Found $validation_errors validation error(s)${NC}"
        return 1
    fi
}

#
# Graph Generation Functions
#

show_graph() {
    echo -e "${CYAN}=== Dependency Graph ===${NC}\n"

    # Check if GraphViz is installed
    if ! command -v dot &> /dev/null; then
        echo -e "${YELLOW}GraphViz not installed. Showing text representation instead.${NC}"
        echo -e "${YELLOW}Install GraphViz for visual graphs: brew install graphviz${NC}"
        echo ""
        show_text_graph
        return
    fi

    # Generate DOT file
    local dot_file="/tmp/beads-deps.dot"
    local png_file="/tmp/beads-deps.png"

    echo "digraph BeadsDependencies {" > "$dot_file"
    echo "  rankdir=TB;" >> "$dot_file"
    echo "  node [shape=box, style=rounded];" >> "$dot_file"
    echo "" >> "$dot_file"

    # Add nodes with colors based on status
    local issues_json
    issues_json=$(bd list --json)

    while IFS= read -r issue_id; do
        local issue_data
        issue_data=$(bd show "$issue_id" --json 2>/dev/null || echo "[]")

        local status
        status=$(echo "$issue_data" | jq -r '.[0].status')
        local title
        title=$(echo "$issue_data" | jq -r '.[0].title' | sed 's/"/\\"/g')

        local color="lightgray"
        case "$status" in
            done|closed) color="lightgreen" ;;
            in_progress) color="lightyellow" ;;
            open) color="lightblue" ;;
        esac

        echo "  \"$issue_id\" [label=\"$issue_id\\n$title\", fillcolor=$color, style=filled];" >> "$dot_file"
    done < <(echo "$issues_json" | jq -r '.[].id')

    echo "" >> "$dot_file"

    # Add edges
    while IFS= read -r issue_id; do
        local issue_deps
        issue_deps=$(bd show "$issue_id" --json 2>/dev/null || echo "[]")

        # Add dependency edges
        echo "$issue_deps" | jq -r '.[0].dependencies[]? | "\(.id) \(.dependency_type)"' 2>/dev/null | while IFS= read -r dep_id dep_type; do
            local edge_style="solid"
            local edge_color="black"
            local edge_label="$dep_type"

            case "$dep_type" in
                blocks)
                    edge_style="solid"
                    edge_color="red"
                    ;;
                related)
                    edge_style="dashed"
                    edge_color="blue"
                    ;;
                discovered-from)
                    edge_style="dotted"
                    edge_color="green"
                    ;;
                parent-child)
                    edge_style="bold"
                    edge_color="purple"
                    ;;
            esac

            echo "  \"$dep_id\" -> \"$issue_id\" [label=\"$edge_label\", style=$edge_style, color=$edge_color];" >> "$dot_file"
        done
    done < <(echo "$issues_json" | jq -r '.[].id')

    echo "}" >> "$dot_file"

    # Generate PNG
    if dot -Tpng "$dot_file" -o "$png_file" 2>/dev/null; then
        echo -e "${GREEN}✓ Dependency graph generated: $png_file${NC}"
        echo ""
        echo "To view:"
        echo "  open $png_file  # macOS"
        echo "  xdg-open $png_file  # Linux"
    else
        echo -e "${RED}✗ Failed to generate graph image${NC}"
        echo "Showing text representation instead:"
        echo ""
        show_text_graph
    fi
}

show_text_graph() {
    local issues_json
    issues_json=$(bd list --json)

    echo "Dependency Graph (text format):"
    echo "Legend: → blocks, ∼ related, ⋯ discovered-from, ═ parent-child"
    echo ""

    while IFS= read -r issue_id; do
        local issue_data
        issue_data=$(bd show "$issue_id" --json 2>/dev/null || echo "[]")

        local dep_count
        dep_count=$(echo "$issue_data" | jq '.[0].dependencies | length')

        if [ "$dep_count" -gt 0 ]; then
            local title
            title=$(echo "$issue_data" | jq -r '.[0].title')
            echo -e "${BLUE}$issue_id${NC}: $title"

            echo "$issue_data" | jq -r '.[0].dependencies[] | "  \(.dependency_type): \(.id) - \(.title)"' | while IFS= read -r dep_line; do
                if echo "$dep_line" | grep -q "^  blocks:"; then
                    echo -e "  ${RED}→${NC} $(echo "$dep_line" | sed 's/^  blocks: //')"
                elif echo "$dep_line" | grep -q "^  related:"; then
                    echo -e "  ${BLUE}∼${NC} $(echo "$dep_line" | sed 's/^  related: //')"
                elif echo "$dep_line" | grep -q "^  discovered-from:"; then
                    echo -e "  ${GREEN}⋯${NC} $(echo "$dep_line" | sed 's/^  discovered-from: //')"
                elif echo "$dep_line" | grep -q "^  parent-child:"; then
                    echo -e "  ${YELLOW}═${NC} $(echo "$dep_line" | sed 's/^  parent-child: //')"
                fi
            done
            echo ""
        fi
    done < <(echo "$issues_json" | jq -r '.[].id')
}

#
# Main execution
#

main() {
    # Show statistics if requested
    if [ "$SHOW_STATS" -eq 1 ]; then
        show_statistics
    fi

    # Validate if requested
    if [ "$VALIDATE" -eq 1 ]; then
        validate_dependencies
        local validate_exit=$?
        echo ""
        if [ "$validate_exit" -ne 0 ]; then
            exit 1
        fi
    fi

    # Show graph if requested
    if [ "$SHOW_GRAPH" -eq 1 ]; then
        show_graph
    fi
}

main
