#!/usr/bin/env bash
# FIFO Manager for CONTINUE Framework
# Manages Unix named pipes for inter-process agent communication
#
# Usage:
#   fifo-manager.sh init [project]     - Initialize FIFOs for project
#   fifo-manager.sh cleanup [project]  - Clean up FIFOs
#   fifo-manager.sh status [project]   - Show FIFO status
#   fifo-manager.sh send <channel> <msg> - Send message to channel
#   fifo-manager.sh recv <channel>     - Receive from channel (blocking)

set -euo pipefail

# Configuration
FIFO_BASE="${CONTINUE_FIFO_BASE:-/tmp/continue}"
PROJECT="${CONTINUE_PROJECT:-$(basename "$(pwd)")}"
FIFO_DIR="${FIFO_BASE}/${PROJECT}"

# Agent channels
CHANNELS=(
    "builder"       # Builder agent communication
    "observer"      # Observer agent communication
    "meta"          # Meta-Observer agent communication
    "announce"      # IRC-style announcements (broadcast)
    "control"       # Control commands
)

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${GREEN}[INFO]${NC} $*"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $*" >&2
}

log_agent() {
    local agent="$1"
    local msg="$2"
    case "$agent" in
        builder)  echo -e "${GREEN}[BUILDER]${NC} $msg" ;;
        observer) echo -e "${BLUE}[OBSERVER]${NC} $msg" ;;
        meta)     echo -e "${PURPLE}[META]${NC} $msg" ;;
        *)        echo -e "[${agent^^}] $msg" ;;
    esac
}

# Initialize FIFOs for a project
init_fifos() {
    local project="${1:-$PROJECT}"
    local fifo_dir="${FIFO_BASE}/${project}"

    log_info "Initializing FIFOs for project: $project"
    log_info "FIFO directory: $fifo_dir"

    # Create directory with restricted permissions
    if [[ ! -d "$fifo_dir" ]]; then
        mkdir -p "$fifo_dir"
        chmod 700 "$fifo_dir"
        log_info "Created FIFO directory"
    fi

    # Create named pipes for each channel
    for channel in "${CHANNELS[@]}"; do
        local fifo_path="${fifo_dir}/${channel}.fifo"
        if [[ ! -p "$fifo_path" ]]; then
            mkfifo "$fifo_path"
            chmod 600 "$fifo_path"
            log_info "Created FIFO: $channel"
        else
            log_info "FIFO exists: $channel"
        fi
    done

    # Create status file
    echo "initialized=$(date -Iseconds)" > "${fifo_dir}/status"
    echo "project=$project" >> "${fifo_dir}/status"
    echo "pid=$$" >> "${fifo_dir}/status"

    log_info "FIFO infrastructure ready"
}

# Clean up FIFOs
cleanup_fifos() {
    local project="${1:-$PROJECT}"
    local fifo_dir="${FIFO_BASE}/${project}"

    if [[ -d "$fifo_dir" ]]; then
        log_info "Cleaning up FIFOs for project: $project"
        rm -rf "$fifo_dir"
        log_info "Cleanup complete"
    else
        log_info "No FIFOs to clean up"
    fi
}

# Show FIFO status
show_status() {
    local project="${1:-$PROJECT}"
    local fifo_dir="${FIFO_BASE}/${project}"

    echo "CONTINUE FIFO Status"
    echo "===================="
    echo "Project: $project"
    echo "Directory: $fifo_dir"
    echo ""

    if [[ -d "$fifo_dir" ]]; then
        echo "Channels:"
        for channel in "${CHANNELS[@]}"; do
            local fifo_path="${fifo_dir}/${channel}.fifo"
            if [[ -p "$fifo_path" ]]; then
                echo "  [OK] $channel"
            else
                echo "  [--] $channel (not created)"
            fi
        done

        if [[ -f "${fifo_dir}/status" ]]; then
            echo ""
            echo "Status file:"
            cat "${fifo_dir}/status" | sed 's/^/  /'
        fi
    else
        echo "FIFOs not initialized. Run: $0 init"
    fi
}

# Send message to a channel (non-blocking with timeout)
send_message() {
    local channel="$1"
    local message="$2"
    local fifo_path="${FIFO_DIR}/${channel}.fifo"

    if [[ ! -p "$fifo_path" ]]; then
        log_error "Channel not found: $channel"
        return 1
    fi

    # Format: timestamp|sender|message
    local timestamp
    timestamp=$(date -Iseconds)
    local formatted="${timestamp}|${USER}|${message}"

    # Non-blocking write with timeout (use background + timeout)
    timeout 1 bash -c "echo '$formatted' > '$fifo_path'" 2>/dev/null || {
        log_error "Timeout sending to $channel (no reader?)"
        return 1
    }
}

# Receive message from channel (blocking)
recv_message() {
    local channel="$1"
    local fifo_path="${FIFO_DIR}/${channel}.fifo"

    if [[ ! -p "$fifo_path" ]]; then
        log_error "Channel not found: $channel"
        return 1
    fi

    # Blocking read
    cat "$fifo_path"
}

# Broadcast to announce channel
announce() {
    local agent="$1"
    local message="$2"

    log_agent "$agent" "$message"

    # Also send to announce FIFO if available
    if [[ -p "${FIFO_DIR}/announce.fifo" ]]; then
        send_message "announce" "[$agent] $message" 2>/dev/null || true
    fi
}

# List all projects with FIFOs
list_projects() {
    echo "CONTINUE Projects:"
    if [[ -d "$FIFO_BASE" ]]; then
        for project_dir in "$FIFO_BASE"/*/; do
            if [[ -d "$project_dir" ]]; then
                local project
                project=$(basename "$project_dir")
                local status="inactive"
                if [[ -f "${project_dir}/status" ]]; then
                    status="active"
                fi
                echo "  - $project ($status)"
            fi
        done
    else
        echo "  (none)"
    fi
}

# Main command dispatcher
main() {
    local cmd="${1:-status}"
    shift || true

    case "$cmd" in
        init)
            init_fifos "$@"
            ;;
        cleanup|clean)
            cleanup_fifos "$@"
            ;;
        status)
            show_status "$@"
            ;;
        send)
            if [[ $# -lt 2 ]]; then
                log_error "Usage: $0 send <channel> <message>"
                exit 1
            fi
            send_message "$1" "$2"
            ;;
        recv|receive)
            if [[ $# -lt 1 ]]; then
                log_error "Usage: $0 recv <channel>"
                exit 1
            fi
            recv_message "$1"
            ;;
        announce)
            if [[ $# -lt 2 ]]; then
                log_error "Usage: $0 announce <agent> <message>"
                exit 1
            fi
            announce "$1" "$2"
            ;;
        list)
            list_projects
            ;;
        help|--help|-h)
            echo "FIFO Manager for CONTINUE Framework"
            echo ""
            echo "Usage: $0 <command> [args]"
            echo ""
            echo "Commands:"
            echo "  init [project]           Initialize FIFOs for project"
            echo "  cleanup [project]        Clean up FIFOs"
            echo "  status [project]         Show FIFO status"
            echo "  send <channel> <msg>     Send message to channel"
            echo "  recv <channel>           Receive from channel (blocking)"
            echo "  announce <agent> <msg>   Broadcast announcement"
            echo "  list                     List all projects"
            echo ""
            echo "Channels: ${CHANNELS[*]}"
            echo ""
            echo "Environment:"
            echo "  CONTINUE_FIFO_BASE  Base directory (default: /tmp/continue)"
            echo "  CONTINUE_PROJECT    Project name (default: current dir name)"
            ;;
        *)
            log_error "Unknown command: $cmd"
            echo "Run '$0 help' for usage"
            exit 1
            ;;
    esac
}

main "$@"
